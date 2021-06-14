import 'package:flutter/material.dart';
import 'package:todo_list/constants.dart';
import 'package:todo_list/screens/todo_list.dart';
import 'package:todo_list/util/notification_helper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initNotifications();
  runApp(TodoListApp());
}

class TodoListApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo List',
      theme: ThemeData(
        brightness: Brightness.dark,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: TodoList(title: Const.TODO_LIST_TITLE),
    );
  }
}
