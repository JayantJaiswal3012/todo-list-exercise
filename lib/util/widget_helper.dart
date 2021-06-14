import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:todo_list/widgets/todo_item.dart';

import '../constants.dart';

List<Widget> getListItems(tasks, onDeleteItem, onDoneItem, setListState) {
  List<Widget> widgetList = new List<Widget>();
  for (var i = 0; i < tasks.length; i++) {
    widgetList.add(TodoListItem(
        key: Key(tasks[i].id),
        itemCount: tasks.length,
        item: tasks[i],
        index: i,
        onDeleteItem: onDeleteItem,
        onDoneItem: onDoneItem,
    setListState: setListState));
  }
  return widgetList;
}

List<Widget> getEmptyListView(createItemShowing) {
  List<Widget> widgetList = new List<Widget>();
  widgetList.add(createItemShowing
      ? SizedBox(key: Key("0"))
      : ListTile(
          key: Key("0"),
          tileColor: Colors.red,
          title: Text(Const.PULL_TO_CREATE,
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ));
  return widgetList;
}

selectDateTimePicker(BuildContext context, Function onSelected) async {
  DateTime pickedDate = await showModalBottomSheet<DateTime>(
    context: context,
    builder: (context) {
      DateTime tempPickedDate;
      return Container(
        height: 250,
        color: Color.fromARGB(255, 255, 255, 255),
        child: Column(
          children: <Widget>[
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  CupertinoButton(
                    child: Text(Const.CANCEL),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  CupertinoButton(
                    child: Text(Const.DONE),
                    onPressed: () {
                      Navigator.of(context).pop(tempPickedDate);
                    },
                  ),
                ],
              ),
            ),
            Divider(
              height: 0,
              thickness: 1,
            ),
            Expanded(
              child: Container(
                child: CupertinoDatePicker(
                  minimumDate: DateTime.now(),
                  initialDateTime: DateTime.now(),
                  onDateTimeChanged: (DateTime dateTime) {
                    tempPickedDate = dateTime;
                  },
                ),
              ),
            ),
          ],
        ),
      );
    },
  );

  if (pickedDate != null) {
    onSelected(pickedDate);
  }
}
