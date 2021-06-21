import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_list/blocs/todo_bloc.dart';
import 'package:todo_list/blocs/todo_events.dart';
import 'package:todo_list/blocs/todo_states.dart';
import 'package:todo_list/models/todo_item_model.dart';
import 'package:todo_list/widgets/create_item.dart';
import 'package:intl/intl.dart';
import '../constants.dart';
import '../util/widget_helper.dart';

class TodoList extends StatefulWidget {
  TodoList({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _TodoListState createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {
  bool dragDetected = false;
  bool downDragDetected = false;
  bool createItemShowing = false;
  double percent = 0.0;
  FocusNode focusNode;
  String selectedDateTime = "";
  TextEditingController controller;
  bool loadingData = true;
  DateTime selectedDate;

  @override
  void initState() {
    super.initState();
    focusNode = FocusNode();
    controller = TextEditingController();
  }

  @override
  void dispose() {
    focusNode.dispose();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //final todosBloc = BlocProvider.of<TodosBloc>(context);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: BlocBuilder<TodosBloc, TodosState>(builder: (context, state) {
        if (state is TodosLoading) {
          return Center(child: Text('Loading List...'));
        } else if (state is TodosNotLoaded) {
          return Center(child: Text('Error in Fetching List'));
        } else if (state is TodosLoaded) {
          return Center(
              child: GestureDetector(
                  onVerticalDragStart: (details) {
                    dragDetected = true;
                  },
                  onVerticalDragUpdate: (details) {
                    if (dragDetected && details.delta.dy > 2.0) {
                      downDragDetected = true;
                      if (percent < 1.0) {
                        percent += 0.10;
                      }
                      setState(() {});
                    }
                  },
                  onVerticalDragEnd: (details) {
                    dragDetected = false;
                    downDragDetected = false;
                    percent = percent < 1.0 ? 0 : percent;
                    if (percent >= 1.0) {
                      focusNode.requestFocus();
                      createItemShowing = true;
                    }
                    setState(() {});
                  },
                  child: Column(
                    children: [
                      Container(
                        height: 70 * percent,
                        child: CreateItem(
                            focusNode: focusNode,
                            downDragDetected: downDragDetected,
                            onDateSelected: _onDateSelected,
                            selectedDateTime: selectedDateTime,
                            onItemCreated: _onItemCreated,
                            controller: controller),
                      ),
                      Expanded(
                        child: IgnorePointer(
                          ignoring: createItemShowing,
                          child: ReorderableListView(
                            onReorder: _onReorder,
                            children: state.todos.isNotEmpty
                                ? getListItems(state.todos, _onDeleteItem,
                                    _onDoneItem, _setListState)
                                : getEmptyListView(createItemShowing),
                          ),
                        ),
                      ),
                    ],
                  )));
        }
      }),
    );
  }

  _setListState() {
    setState(() {});
  }

  _onItemCreated(String task, DateTime reminderDateTime) {
    percent = 0;
    createItemShowing = false;
    if (task != null && task.isNotEmpty) {
      TodoItem item = TodoItem(
          task, id: DateTime.now().millisecondsSinceEpoch.toString(),
          reminderDate: selectedDateTime);
      BlocProvider.of<TodosBloc>(context)
          .add(CreateTodo(item, reminderDateTime));
    }
    selectedDateTime = "";
  }

  _onReorder(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    BlocProvider.of<TodosBloc>(context).add(ReorderTodos(oldIndex, newIndex));
  }

  _onDeleteItem(int index) {
    BlocProvider.of<TodosBloc>(context).add(DeleteTodo(index));
  }

  _onDoneItem(int index) {
    BlocProvider.of<TodosBloc>(context).add(MarkDone(index));
  }

  _onDateSelected(val) {
    setState(() {
      DateFormat df = DateFormat(Const.DATE_FORMAT);
      selectedDateTime = df.format(val);
    });
  }
}
