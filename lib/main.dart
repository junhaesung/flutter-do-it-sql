import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'todo.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Future<Database> database = initDatabase();

    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => DatabaseApp(database),
        '/add': (context) => AddTodoApp(database),
      },
    );
  }

  Future<Database> initDatabase() async {
    return openDatabase(
      join(await getDatabasesPath(), 'todo_database.db'),
      onCreate: (db, version) {
        return db.execute(
            'CREATE TABLE todos(id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, content TEXT, active BOOL)');
      },
      version: 1,
    );
  }
}

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
      ),
      body: Container(
          child: Center(
              child: FutureBuilder(
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
              List<Todo> todos = snapshot.data as List<Todo>;
              return ListView.builder(
                itemBuilder: (context, index) {
                  Todo todo = todos[index];
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
                        Todo result = await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('${todo.id} : ${todo.title}'),
                                content: Text('Todo를 체크하시겠습니까?'),
                                actions: [
                                  FlatButton(
                                    onPressed: () {
                                      setState(() {
                                        todo.active = !todo.active;
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
                      });
                },
                itemCount: todos.length,
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

  Future<List<Todo>> getTodos() async {
    final Database database = await widget.db;
    final List<Map<String, dynamic>> maps = await database.query('todos');
    return List.generate(maps.length, (index) => Todo.from(maps[index]));
  }
}

class AddTodoApp extends StatefulWidget {
  final Future<Database> db;

  AddTodoApp(this.db);

  @override
  State<StatefulWidget> createState() => _AddTodoApp();
}

class _AddTodoApp extends State<AddTodoApp> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _titleController = new TextEditingController();
    _contentController = new TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Todo 추가'),
      ),
      body: Container(
        child: Center(
            child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(10),
              child: TextField(
                controller: _titleController,
                decoration: InputDecoration(labelText: '제목'),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: TextField(
                controller: _contentController,
                decoration: InputDecoration(labelText: '할 일'),
              ),
            ),
            RaisedButton(
              onPressed: () {
                Todo todo = Todo(
                  title: _titleController.value.text,
                  content: _contentController.value.text,
                  active: false,
                );
                Navigator.of(context).pop(todo);
              },
              child: Text('저장하기'),
            )
          ],
        )),
      ),
    );
  }
}
