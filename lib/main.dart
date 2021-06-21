import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_list/constants.dart';
import 'package:todo_list/repository/todo_repository.dart';
import 'package:todo_list/screens/onboarding_screen.dart';
import 'package:todo_list/screens/todo_list.dart';
import 'package:todo_list/util/data_helper.dart';
import 'package:todo_list/util/notification_helper.dart';

import 'blocs/todo_bloc.dart';
import 'blocs/todo_bloc_observer.dart';
import 'blocs/todo_events.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationManager().initNotifications();
  Bloc.observer = SimpleBlocObserver();
  runApp(BlocProvider(
      create: (context) {
        return TodosBloc(
          todosRepository: FirestoreTodosRepository(firestore),
          notificationManager: NotificationManager(),
        )..add(LoadTodos());
      },
      child:
      TodoListApp()));
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
      home: Splash(),
    );
  }
}

class Splash extends StatefulWidget {
  @override
  _SplashState createState() => new _SplashState();
}

class _SplashState extends State<Splash> with AfterLayoutMixin<Splash> {
  Future checkFirstSeen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool _onBoarded = (prefs.getBool('onboarded') ?? false);

    if (_onBoarded) {
      Navigator.of(context).pushReplacement(new MaterialPageRoute(
          builder: (context) => TodoList(title: Const.TODO_LIST_TITLE)));
    } else {
      await prefs.setBool('onboarded', true);
      Navigator.of(context).pushReplacement(
          new MaterialPageRoute(builder: (context) => OnBoardingScreen()));
    }
  }

  @override
  void afterFirstLayout(BuildContext context) => checkFirstSeen();

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Center(
        child: new Text('Splash'),
      ),
    );
  }
}
