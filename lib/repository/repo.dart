import 'dart:async';
import 'dart:core';

import 'package:todo_list/models/todo_item_entity.dart';

abstract class TodosRepository {
  Future<void> addNewTodo(TodoEntity todo);

  Future<void> deleteTodo(List<String> idList);

  Future<List<TodoEntity>> loadTodos();

  Future<void> updateTodo(TodoEntity todo);

  Future<void> syncTodos(List<TodoEntity> list, String deletedId) {}
}
