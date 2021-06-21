import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:todo_list/blocs/todo_events.dart';
import 'package:todo_list/blocs/todo_states.dart';
import 'package:todo_list/models/todo_item_model.dart';
import 'package:todo_list/repository/repo.dart';
import 'package:todo_list/util/data_helper.dart';
import 'package:todo_list/util/notification_helper.dart';

class TodosBloc extends Bloc<TodosEvent, TodosState> {
  final TodosRepository todosRepository;
  final NotificationManager notificationManager;

  TodosBloc({@required this.todosRepository, @required this.notificationManager,}) : super(TodosLoading());

  @override
  TodosState get initialState => TodosLoading();

  @override
  Stream<TodosState> mapEventToState(TodosEvent event) async* {
    if (event is LoadTodos) {
      yield* _mapLoadTodosToState();
    } else if (event is CreateTodo) {
      yield* _mapCreateTodoToState(event);
    } else if (event is DeleteTodo) {
      yield* _mapDeleteTodoToState(event);
    } else if (event is ReorderTodos) {
      yield* _mapReorderTodosToState(event);
    } else if (event is MarkDone) {
      yield* _mapMarkDoneToState(event);
    }
  }

  Stream<TodosState> _mapLoadTodosToState() async* {
    try {
      final todos = await todosRepository.loadTodos();
      yield TodosLoaded(
        todos.map(TodoItem.fromEntity).toList(),
      );
    } catch (_) {
      yield TodosNotLoaded();
    }
  }

  Stream<TodosState> _mapCreateTodoToState(CreateTodo event) async* {
    if (state is TodosLoaded) {
      final updatedTodos = List<TodoItem>.from((state as TodosLoaded).todos)
        ..insert(0, event.todo);
      updateOrderIndexes(updatedTodos, 0, updatedTodos.length - 1);
      if (event.reminder != null) {
        notificationManager.scheduleNotification(
            event.todo.id, event.todo.getTask(), event.reminder);
      }
      yield TodosLoaded(updatedTodos);
      await _saveTodos(updatedTodos, null);
    }
  }

  Stream<TodosState> _mapDeleteTodoToState(DeleteTodo event) async* {
    if (state is TodosLoaded) {
      final updatedTodos = List<TodoItem>.from((state as TodosLoaded).todos);
      TodoItem deletedTodo = updatedTodos[event.deleteIndex];
      if (deletedTodo.reminderDate != null &&
          deletedTodo.reminderDate.isNotEmpty) {
        notificationManager.cancelNotification(deletedTodo.id);
      }
      updatedTodos.removeAt(event.deleteIndex);
      yield TodosLoaded(updatedTodos);
      updateOrderIndexes(
          updatedTodos, event.deleteIndex, updatedTodos.length - 1);
      await _saveTodos(
          updatedTodos.sublist(event.deleteIndex, updatedTodos.length),
          deletedTodo.id);
    }
  }

  Stream<TodosState> _mapReorderTodosToState(ReorderTodos event) async* {
    if (state is TodosLoaded) {
      final updatedTodos = List<TodoItem>.from((state as TodosLoaded).todos);
      TodoItem reorderedItem = updatedTodos[event.oldIndex];
      reorderedItem.markActive();
      updatedTodos.removeAt(event.oldIndex);
      if (event.newIndex != 0) {
        if (!updatedTodos[event.newIndex - 1].isActive) {
          if (reorderedItem.reminderDate != null &&
              reorderedItem.reminderDate.isNotEmpty) {
            notificationManager.cancelNotification(reorderedItem.id);
          }
          reorderedItem.markDone();
        }
      } else {
        if (!updatedTodos[0].isActive) {
          if (reorderedItem.reminderDate != null &&
              reorderedItem.reminderDate.isNotEmpty) {
            notificationManager.cancelNotification(reorderedItem.id);
          }
          reorderedItem.markDone();
        }
      }
      updatedTodos.insert(event.newIndex, reorderedItem);

      yield TodosLoaded(updatedTodos);

      if (event.newIndex > event.oldIndex) {
        updateOrderIndexes(updatedTodos, event.oldIndex, event.newIndex);
        await _saveTodos(
            updatedTodos.sublist(event.oldIndex, event.newIndex + 1), null);
      } else {
        updateOrderIndexes(updatedTodos, event.newIndex, event.oldIndex);
        await _saveTodos(
            updatedTodos.sublist(event.newIndex, event.oldIndex + 1), null);
      }
    }
  }

  Stream<TodosState> _mapMarkDoneToState(MarkDone event) async* {
    if (state is TodosLoaded) {
      final updatedTodos = List<TodoItem>.from((state as TodosLoaded).todos);
      TodoItem updatedItem = updatedTodos[event.markDoneIndex];
      updatedTodos.removeAt(event.markDoneIndex);
      TodoItem newItem = TodoItem(updatedItem.getTask(),
          id : DateTime.now().millisecondsSinceEpoch.toString());
      newItem.reminderDate = updatedItem.reminderDate;
      newItem.markDone();
      updatedTodos.add(newItem);

      if (updatedItem.reminderDate != null &&
          updatedItem.reminderDate.isNotEmpty) {
        notificationManager.cancelNotification(updatedItem.id);
      }
      yield TodosLoaded(updatedTodos);
      updateOrderIndexes(
          updatedTodos, event.markDoneIndex, updatedTodos.length - 1);
      await _saveTodos(
          updatedTodos.sublist(event.markDoneIndex, updatedTodos.length),
          updatedItem.id);
    }
  }

  Future _saveTodos(List<TodoItem> todos, String deletedId) {
    return todosRepository.syncTodos(
        todos.map((todo) => todo.toEntity()).toList(), deletedId);
  }
}
