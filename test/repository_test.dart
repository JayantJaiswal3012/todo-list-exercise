import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:todo_list/constants.dart';
import 'package:todo_list/models/todo_item_entity.dart';
import 'package:todo_list/repository/todo_repository.dart';

class MockFirestore extends Mock implements Firestore {}

class MockCollectionReference extends Mock implements CollectionReference {}

class MockQueryReference extends Mock implements Query {}

class MockDocumentSnapshot extends Mock implements DocumentSnapshot {
  @override
  final Map<String, dynamic> data;

  MockDocumentSnapshot([this.data]);

  @override
  dynamic operator [](String key) => data[key];
}

class MockDocumentReference extends Mock implements DocumentReference {}

class MockQuerySnapshot extends Mock implements QuerySnapshot {}

class MockWriteBatch extends Mock implements WriteBatch {}


void main() {
  group('FirestoreTodosRepository', () {
    test('create new todo', () {
      final firestore = MockFirestore();
      final collection = MockCollectionReference();
      final document = MockDocumentReference();
      final repository = FirestoreTodosRepository(firestore);
      final todo = TodoEntity('Added item', '1', '', true, 0);

      when(firestore.collection(Const.DB_DOCUMENT_TASKS))
          .thenReturn(collection);
      when(collection.document(todo.id)).thenReturn(document);
      repository.addNewTodo(todo);
      verify(document.setData(todo.toJson()));
    });

    test('update todos', () {
      final firestore = MockFirestore();
      final collection = MockCollectionReference();
      final document = MockDocumentReference();
      final repository = FirestoreTodosRepository(firestore);
      final todo = TodoEntity('Updated item', '1', '', true, 0);

      when(firestore.collection(Const.DB_DOCUMENT_TASKS))
          .thenReturn(collection);
      when(collection.document(todo.id)).thenReturn(document);
      repository.updateTodo(todo);
      verify(document.updateData(todo.toJson()));
    });

    test('delete todos', () async {
      final todoId = 'ID';
      final firestore = MockFirestore();
      final collection = MockCollectionReference();
      final documentA = MockDocumentReference();
      final repository = FirestoreTodosRepository(firestore);

      when(firestore.collection(Const.DB_DOCUMENT_TASKS))
          .thenReturn(collection);
      when(collection.document(todoId)).thenReturn(documentA);

      repository.deleteTodo(todoId);
      verify(documentA.delete());
    });

    test('load todos', () async {
      final firestore = MockFirestore();
      final collection = MockCollectionReference();
      final query = MockQueryReference();
      final repository = FirestoreTodosRepository(firestore);
      final snapshot = new MockQuerySnapshot();
      final todo = TodoEntity('Loaded item', '1', '', true, 0);
      final document = MockDocumentSnapshot(todo.toJson());

      when(firestore.collection(Const.DB_DOCUMENT_TASKS))
          .thenReturn(collection);
      when(collection.orderBy(Const.FIELD_ORDERINDEX)).thenReturn(query);

      when(query.getDocuments()).thenAnswer((_) => Future.value(snapshot));
      when(snapshot.documents).thenReturn([document]);
      when(document.documentID).thenReturn(todo.id);

      await expectLater(repository.loadTodos(), completion([todo]));
    });

    test('sync todos', () async {
      final todoA = TodoEntity('Sync item', '1', '', true, 0);
      final todoB = TodoEntity('Sync item', '2', '', true, 1);
      final todolist = [todoA, todoB];
      final firestore = MockFirestore();
      final batch = MockWriteBatch();
      final collection = MockCollectionReference();
      final document = MockDocumentReference();
      final repository = FirestoreTodosRepository(firestore);

      when(firestore.batch()).thenReturn(batch);
      when(firestore.collection(Const.DB_DOCUMENT_TASKS))
          .thenReturn(collection);
      when(collection.document(any)).thenReturn(document);

      repository.syncTodos(todolist, "1");
      verify(batch.setData(document, todoA.toJson(), merge: true));
      verify(batch.setData(document, todoB.toJson(), merge: true));
      verify(batch.delete(document));
    });
  });
}