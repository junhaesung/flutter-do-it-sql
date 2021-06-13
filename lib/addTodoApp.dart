import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import 'todo.dart';

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
    _titleController = TextEditingController();
    _contentController = TextEditingController();
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
