import 'package:equatable/equatable.dart';
import 'package:todo_list/models/todo_item_model.dart';

abstract class TodosEvent extends Equatable {
  const TodosEvent();

  @override
  List<Object> get props => [];
}

class LoadTodos extends TodosEvent {}

class CreateTodo extends TodosEvent {
  final TodoItem todo;
  final DateTime reminder;

  const CreateTodo(this.todo, this.reminder);

  @override
  List<Object> get props => [todo];

  @override
  String toString() => 'AddTodo { todo: $todo }';
}

class ReorderTodos extends TodosEvent {
  final int oldIndex;
  final int newIndex;

  const ReorderTodos(this.oldIndex, this.newIndex);

  @override
  List<Object> get props => [oldIndex, newIndex];

  @override
  String toString() => 'ReorderTodos { from: $oldIndex to: $newIndex}';
}

class DeleteTodo extends TodosEvent {
  final int deleteIndex;

  const DeleteTodo(this.deleteIndex);

  @override
  List<Object> get props => [deleteIndex];

  @override
  String toString() => 'DeleteTodo { deleteIndex: $deleteIndex }';
}

class MarkDone extends TodosEvent {
  final int markDoneIndex;

  const MarkDone(this.markDoneIndex);

  @override
  List<Object> get props => [markDoneIndex];

  @override
  String toString() => 'MarkDone { MarkDoneIndex: $markDoneIndex }';
}
