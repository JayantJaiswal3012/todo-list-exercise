import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:todo_list/models/todo_item_model.dart';

final firestore = Firestore.instance;

updateOrderIndexes(List<TodoItem> tasks, int startIndex, int endIndex) {
  for (int i = startIndex; i <= endIndex; i++) {
    tasks[i].orderIndex = i;
  }
}
