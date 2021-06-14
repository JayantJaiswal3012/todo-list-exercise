import 'package:flutter/material.dart';
import 'package:todo_list/util/notification_helper.dart';
import '../constants.dart';
import '../util/widget_helper.dart';

class CreateItem extends StatelessWidget {
  CreateItem(
      {@required this.focusNode,
      @required this.downDragDetected,
      @required this.onDateSelected,
      @required this.selectedDateTime,
      @required this.onItemCreated,
      @required this.controller});

  final FocusNode focusNode;
  final bool downDragDetected;
  final Function onDateSelected;
  final String selectedDateTime;
  final Function onItemCreated;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return ListTile(
        tileColor: Colors.red,
        title: TextField(
            cursorColor: Colors.white,
            focusNode: focusNode,
            controller: controller,
            decoration: new InputDecoration(
                hintStyle: TextStyle(color: Colors.white),
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                hintText: downDragDetected ? Const.RELEASE_TO_CREATE : null),
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            onSubmitted: (todoText) {
              print("On Create $todoText");
              onItemCreated(todoText, selectedDate);
              controller.clear();
              ;
            }),
        subtitle: GestureDetector(
          onTap: () {
            if (selectedDateTime.isEmpty) {
              selectDateTimePicker(context, onSelected);
            } else {
              print("Tapped");
            }
          },
          child: Text(
            selectedDateTime.isEmpty ? Const.ADD_REMINDER : selectedDateTime,
            textAlign: TextAlign.start,
          ),
        ));
  }

  onSelected(dateTime){
    selectedDate = dateTime;
    onDateSelected(dateTime);
  }
}
