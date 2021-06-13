import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import 'todo.dart';

class DatabaseApp extends StatefulWidget {
  final Future<Database> db;

  DatabaseApp(this.db);

  @override
  State<StatefulWidget> createState() => _DatabaseApp();
}

class _DatabaseApp extends State<DatabaseApp> {
  late Future<List<Todo>> todoList;

  @override
  void initState() {
    super.initState();
    this.todoList = getTodos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Database Example'),
        actions: [
          FlatButton(
            onPressed: () async {
              await Navigator.of(context).pushNamed('/clear');
              setState(() {
                todoList = getTodos();
              });
            },
            child: Text(
              '완료한 일',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Container(
          child: Center(
              child: FutureBuilder<List<Todo>>(
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.none:
                    case ConnectionState.waiting:
                    case ConnectionState.active:
                      return CircularProgressIndicator();
                    case ConnectionState.done:
                      if (!snapshot.hasData || snapshot.data == null) {
                        return Text('No data');
                      }
                      return ListView.builder(
                        itemBuilder: (context, index) {
                          Todo todo = snapshot.data![index];
                          return ListTile(
                            title: Text(
                              todo.title,
                              style: TextStyle(fontSize: 20),
                            ),
                            subtitle: Container(
                              child: Column(
                                children: [
                                  Text(todo.content),
                                  Text('체크 : ${todo.active.toString()}'),
                                  Container(
                                    height: 1,
                                    color: Colors.blue,
                                  )
                                ],
                              ),
                            ),
                            onTap: () async {
                              TextEditingController controller = TextEditingController(
                                  text: todo.content);
                              Todo? result = await showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text('${todo.id} : ${todo.title}'),
                                      content: TextField(
                                        controller: controller,
                                        keyboardType: TextInputType.text,
                                      ),
                                      actions: [
                                        FlatButton(
                                          onPressed: () {
                                            setState(() {
                                              todo.active = !todo.active;
                                              todo.content =
                                                  controller.value.text;
                                            });
                                            Navigator.of(context).pop(todo);
                                          },
                                          child: Text('예'),
                                        ),
                                        FlatButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: Text('아니오'),
                                        )
                                      ],
                                    );
                                  });
                              if (result != null) {
                                _updateTodo(result);
                              }
                            },
                            onLongPress: () async {
                              Todo? result = await showDialog(context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text('${todo.id} : ${todo.title}'),
                                      content: Text(
                                          '${todo.content}를 삭제하시겠습니까?'),
                                      actions: [
                                        FlatButton(onPressed: () {
                                          Navigator.of(context).pop(todo);
                                        }, child: Text('예'),),
                                        FlatButton(onPressed: () {
                                          Navigator.of(context).pop();
                                        }, child: Text('아니오'),)
                                      ],
                                    )
                                  });
                              if (result != null) {
                                _deleteTodo(result);
                              }
                            },
                          );
                        },
                        itemCount: snapshot.data != null ? snapshot.data!.length : 0,
                      );
                  }
                },
                future: todoList,
              ))),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final Todo todo =
          await Navigator.of(context).pushNamed('/add') as Todo;
          _insertTodo(todo);
        },
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  void _insertTodo(Todo todo) async {
    final Database database = await widget.db;
    await database.insert('todos', todo.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    setState(() {
      this.todoList = getTodos();
    });
  }

  void _updateTodo(Todo todo) async {
    final Database database = await widget.db;
    await database.update(
      'todos',
      todo.toMap(),
      where: 'id = ?',
      whereArgs: [todo.id],
    );
    setState(() {
      todoList = getTodos();
    });
  }

  void _deleteTodo(Todo todo) async {
    final Database database = await widget.db;
    await database.delete('todos', where: 'id=?', whereArgs: [todo.id]);
    setState(() {
      todoList = getTodos();
    });
  }

  Future<List<Todo>> getTodos() async {
    final Database database = await widget.db;
    final List<Map<String, dynamic>> maps = await database.query('todos');
    return List.generate(maps.length, (index) => Todo.from(maps[index]));
  }
}