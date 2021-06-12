class Todo {
  String title;
  String content;
  bool active;
  int? id;

  Todo(
      {required this.title,
      required this.content,
      required this.active,
      this.id});

  static Todo from(Map<String, dynamic> todoMap) {
    return Todo(
      title: todoMap['title'],
      content: todoMap['content'],
      active: todoMap['active'] == 1,
      id: todoMap['id'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'active': active,
    };
  }
}
