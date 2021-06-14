import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:todo_list/models/todo_item_model.dart';

import '../constants.dart';

final collection = Firestore.instance.collection('tasks').orderBy('orderindex');

onCreateItemDB(List<TodoItem> tasks) {
  // insertion at top of list will effect order index for each item
  _updateOrderIndexes(tasks, 0, tasks.length - 1);
  syncTasks(tasks, null);
}

onReorderItemDB(List<TodoItem> tasks, int oldIndex, int newIndex) {
  if (newIndex > oldIndex) {
    _updateOrderIndexes(tasks, oldIndex, newIndex);
    syncTasks(tasks.sublist(oldIndex, newIndex + 1), null);
  } else {
    _updateOrderIndexes(tasks, newIndex, oldIndex);
    syncTasks(tasks.sublist(newIndex, oldIndex + 1), null);
  }
}

onMarkDoneDB(String deletedItemId, List<TodoItem> tasks, int oldIndex) {
  _updateOrderIndexes(tasks, oldIndex, tasks.length - 1);
  syncTasks(tasks.sublist(oldIndex, tasks.length), deletedItemId);
}

onDeleteItemDB(String deletedItemId, List<TodoItem> tasks, int deleteIndex) {
  _updateOrderIndexes(tasks, deleteIndex, tasks.length - 1);
  syncTasks(tasks.sublist(deleteIndex, tasks.length), deletedItemId);
}

_updateOrderIndexes(List<TodoItem> tasks, int startIndex, int endIndex) {
  for (int i = startIndex; i <= endIndex; i++) {
    tasks[i].orderIndex = i;
  }
}

Future<void> syncTasks(List<TodoItem> todoList, String deletedItemId) async {
  var db = Firestore.instance;
  //Create a batch
  var batch = db.batch();
  todoList.forEach((item) {
    batch.setData(
        db.collection(Const.DB_DOCUMENT_TASKS).document(item.id),
        {
          Const.FIELD_TASK: item.getTask(),
          Const.FIELD_ISACTIVE: item.isActive(),
          Const.FIELD_REMINDER: item.reminderDate,
          Const.FIELD_ID: item.id,
          Const.FIELD_ORDERINDEX: item.orderIndex
        },
        merge: true);
  });
  if (deletedItemId != null) {
    batch
        .delete(db.collection(Const.DB_DOCUMENT_TASKS).document(deletedItemId));
  }
  await batch.commit();
}

Future<List<TodoItem>> getTasks() async {
  List<TodoItem> items = [];

  var snapshots = await collection.getDocuments();
  List<DocumentSnapshot> doc = snapshots.documents;

  if (snapshots.documents.length > 0) {
    for (int i = 0; i < doc.length; i++) {
      TodoItem item = TodoItem(
          doc[i].data[Const.FIELD_TASK], doc[i].data[Const.FIELD_ID],
          reminderDate: doc[i].data[Const.FIELD_REMINDER]);
      item.orderIndex = i;
      if (!doc[i].data[Const.FIELD_ISACTIVE]) {
        item.markDone();
      }
      items.add(item);
    }
  }
  return items;
}
