import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import 'todo.dart';

class ClearListApp extends StatefulWidget {
  final Future<Database> database;

  ClearListApp(this.database);

  @override
  State<StatefulWidget> createState() => _ClearListApp();
}

class _ClearListApp extends State<ClearListApp> {
  late Future<List<Todo>> _clearList;

  @override
  void initState() {
    super.initState();
    _clearList = _getClearList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('완료한 일')),
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
                  if (!snapshot.hasData) {
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
                          child: Center(
                            child: Column(
                              children: [
                                Text(todo.content),
                                Container(
                                  height: 1,
                                  color: Colors.blue,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    itemCount:
                        snapshot.data != null ? snapshot.data!.length : 0,
                  );
              }
            },
            future: _clearList,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                    title: Text('완료한 일 삭제'),
                    content: Text('완료한 일을 모두 삭제할까요?'),
                    actions: [
                      FlatButton(
                        onPressed: () {
                          Navigator.of(context).pop(true);
                        },
                        child: Text('예'),
                      ),
                      FlatButton(
                        onPressed: () {
                          Navigator.of(context).pop(false);
                        },
                        child: Text('아니오'),
                      ),
                    ]);
              });
          if (result) {
            _removeAllTodos();
          }
        },
        child: Icon(Icons.remove),
      ),
    );
  }

  Future<List<Todo>> _getClearList() async {
    final Database database = await widget.database;
    List<Map<String, dynamic>> maps =
        await database.rawQuery('select * from todos where active=1');
    print(maps);
    return List.generate(maps.length, (index) {
      return Todo.from(maps[index]);
    });
  }

  void _removeAllTodos() async {
    final Database database = await widget.database;
    database.rawDelete('delete from todos where active=1');
    setState(() {
      _clearList = _getClearList();
    });
  }
}
