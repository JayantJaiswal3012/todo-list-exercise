import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:todo_list/models/todo_item_entity.dart';
import 'package:todo_list/repository/repo.dart';

import '../constants.dart';

class FirestoreTodosRepository implements TodosRepository {
  final String path = Const.DB_DOCUMENT_TASKS;
  final String orderIndex = Const.FIELD_ORDERINDEX;

  final Firestore firestore;

  FirestoreTodosRepository(this.firestore);

  @override
  Future<void> addNewTodo(TodoEntity todo) {
    return firestore.collection(path).document(todo.id).setData(todo.toJson());
  }

  @override
  Future<void> deleteTodo(List<String> idList) async {
    await Future.wait<void>(idList.map((id) {
      return firestore.collection(path).document(id).delete();
    }));
  }

  @override
  Future<void> updateTodo(TodoEntity todo) {
    return firestore
        .collection(path)
        .document(todo.id)
        .updateData(todo.toJson());
  }

  @override
  Future<List<TodoEntity>> loadTodos() async {
    var snapshots =
        await firestore.collection(path).orderBy(orderIndex).getDocuments();
    return snapshots.documents
        .map((e) => TodoEntity(
              e['task'],
              e.documentID,
              e['reminder'] ?? '',
              e['isactive'] ?? false,
              e['orderindex'] ?? 0,
            ))
        .toList();
  }

  @override
  Future<void> syncTodos(
      List<TodoEntity> entityList, String deletedItemId) async {
    //Create a batch
    var batch = firestore.batch();
    entityList.forEach((todoEntity) {
      batch.setData(firestore.collection(path).document(todoEntity.id),
          todoEntity.toJson(),
          merge: true);
    });
    if (deletedItemId != null) {
      batch.delete(firestore.collection(path).document(deletedItemId));
    }
    await batch.commit();
  }
}
