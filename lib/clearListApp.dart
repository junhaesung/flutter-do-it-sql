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
}
