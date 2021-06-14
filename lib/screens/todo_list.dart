import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:todo_list/models/todo_item_model.dart';
import 'package:todo_list/util/data_helper.dart';
import 'package:todo_list/util/notification_helper.dart';
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
  List<TodoItem> tasks = [];
  bool dragDetected = false;
  bool downDragDetected = false;
  bool createItemShowing = false;
  double percent = 0.0;
  FocusNode focusNode;
  String selectedDateTime = "";
  TextEditingController controller;
  bool loadingData = true;

  @override
  void initState() {
    super.initState();
    focusNode = FocusNode();
    controller = TextEditingController();
    getTasks().then((resullist) {
      setState(() {
        tasks = resullist;
        loadingData = false;
      });
    });
  }

  @override
  void dispose() {
    focusNode.dispose();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: Center(
          child: loadingData
              ? Text('Loading List...')
              : GestureDetector(
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
                            children: tasks.isNotEmpty
                                ? getListItems(tasks, _onDeleteItem,
                                    _onDoneItem, _setListState)
                                : getEmptyListView(createItemShowing),
                          ),
                        ),
                      ),
                    ],
                  ))
          ),
    );
  }

  _setListState() {
    setState(() {});
  }

  _onItemCreated(String task, DateTime reminderDateTime) {
    setState(() {
      percent = 0;
      createItemShowing = false;
      if (task != null && task.isNotEmpty) {
        TodoItem item = TodoItem(
            task, DateTime.now().millisecondsSinceEpoch.toString(),
            reminderDate: selectedDateTime);
        tasks.insert(0, item);

        onCreateItemDB(tasks);

        if (selectedDate != null) {
          scheduleNotification(item.id, task, selectedDate);
          selectedDate = null;
        }
      }
      selectedDateTime = "";
    });
  }

  _onDateSelected(val) {
    setState(() {
      DateFormat df = DateFormat(Const.DATE_FORMAT);
      selectedDateTime = df.format(val);
    });
  }

  _onReorder(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    setState(() {
      TodoItem item = tasks[oldIndex];
      item.markActive();
      tasks.removeAt(oldIndex);
      if (newIndex != 0) {
        if (!tasks[newIndex - 1].isActive()) {
          if (item.reminderDate != null && item.reminderDate.isNotEmpty) {
            cancelNotification(item.id);
          }
          item.markDone();
        }
      } else {
        if (!tasks[0].isActive()) {
          if (item.reminderDate != null && item.reminderDate.isNotEmpty) {
            cancelNotification(item.id);
          }
          item.markDone();
        }
      }
      tasks.insert(newIndex, item);

      onReorderItemDB(tasks, oldIndex, newIndex);
    });
  }

  _onDeleteItem(int index) {
    setState(() {
      TodoItem item = tasks[index];
      if (item.reminderDate != null && item.reminderDate.isNotEmpty) {
        cancelNotification(item.id);
      }
      tasks.removeAt(index);

      onDeleteItemDB(item.id, tasks, index);
    });
  }

  _onDoneItem(int index) {
    setState(() {
      TodoItem item = tasks[index];
      tasks.removeAt(index);
      TodoItem newItem = TodoItem(
          item.getTask(), DateTime.now().millisecondsSinceEpoch.toString());
      newItem.reminderDate = item.reminderDate;
      newItem.markDone();
      tasks.add(newItem);

      if (item.reminderDate != null && item.reminderDate.isNotEmpty) {
        cancelNotification(item.id);
      }

      onMarkDoneDB(item.id, tasks, index);
    });
  }
}
