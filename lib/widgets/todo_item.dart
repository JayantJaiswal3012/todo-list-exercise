import 'package:flutter/material.dart';
import 'package:swipedetector/swipedetector.dart';
import 'package:todo_list/models/todo_item_model.dart';

class TodoListItemWidget extends StatelessWidget {
  TodoListItemWidget(
      {@required this.key,
      @required this.itemCount,
      @required this.item,
      @required this.index,
      @required this.onDeleteItem,
      @required this.onDoneItem,
      @required this.setListState});

  Key key;
  final int itemCount;
  final TodoItem item;
  final int index;
  final Function onDeleteItem;
  final Function onDoneItem;
  final Function setListState;
  final ColorTween colorTween =
      ColorTween(begin: Colors.red, end: Colors.yellow);

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: key,
      onDismissed: (direction) {
        if (direction == DismissDirection.startToEnd) {
          item.swipeRightDetected = false;
          if (item.isActive) {
            onDoneItem(index);
          } else {
            onDeleteItem(index);
          }
        } else {
          print("endtostart");
          onDeleteItem(index);
        }
      },
      dismissThresholds: {
        DismissDirection.startToEnd: 0.01,
        DismissDirection.endToStart: 0.4
      },
      secondaryBackground: Container(
        color: Colors.black,
        child: Icon(
          Icons.close,
          color: Colors.red,
          size: 40,
        ),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
        margin: EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 4,
        ),
      ),
      background: Container(
        color: Colors.black,
        child: Icon(
          item.isActive ? Icons.check : Icons.close,
          color: item.isActive ? Colors.white : Colors.red,
          size: 40,
        ),
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(left: 20),
      ),
      child: _createItemForState(item, index),
    );
  }

  Widget _createItemForState(TodoItem item, int index) {
    if (item.isActive) {
      return Listener(
        onPointerMove: (move) {
          //print("pointer ${move.localDelta}");
          // Keeping min dx and max dy threshholds to avoid vertical swipe detection
          if (move.localDelta.dx > 5 &&
              move.localDelta.dy < 5 &&
              item.isActive) {
            item.swipeRightDetected = true;
            setListState();
          }
        },
        child: ListTile(
            tileColor: item.swipeRightDetected
                ? Colors.green
                : itemCount <= 1
                    ? Colors.red
                    : colorTween.lerp(index / (itemCount - 1)),
            title: Padding(
              padding: item.reminderDate != null && item.reminderDate.isNotEmpty
                  ? EdgeInsets.only(top: 15)
                  : EdgeInsets.only(top: 0),
              child: Text(item.getTask(),
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      decoration: item.swipeRightDetected
                          ? TextDecoration.lineThrough
                          : null,
                      decorationThickness: item.swipeRightDetected
                          ? 3 : null)),
            ),
            subtitle: item.reminderDate != null && item.reminderDate.isNotEmpty
                ? Padding(
                    padding: EdgeInsets.only(top: 14, bottom: 5),
                    child: Text(item.reminderDate, textAlign: TextAlign.start),
                  )
                : null),
      );
    } else
      return ListTile(
          tileColor: Colors.black,
          title: Padding(
            padding: item.reminderDate != null && item.reminderDate.isNotEmpty
                ? EdgeInsets.only(top: 15)
                : EdgeInsets.only(top: 0),
            child: Text(item.getTask(),
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.lineThrough,
                    decorationThickness: 3)),
          ),
          subtitle: item.reminderDate != null && item.reminderDate.isNotEmpty
              ? Padding(
                  padding: EdgeInsets.only(top: 14, bottom: 5),
                  child: Text(item.reminderDate,
                      textAlign: TextAlign.start,
                      style: TextStyle(decoration: TextDecoration.lineThrough)),
                )
              : null);
  }
}
