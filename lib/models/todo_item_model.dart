import 'package:equatable/equatable.dart';
import 'package:todo_list/models/todo_item_entity.dart';

class TodoItem extends Equatable{
  String _task;
  String id;
  bool isActive = true;
  bool swipeRightDetected = false;
  String reminderDate;
  int orderIndex;

  TodoItem(this._task, this.id, {this.reminderDate, this.isActive = true, this.orderIndex = 0});

  getTask() => this._task;

  setTask(task) => this._task = task;

  markDone() => isActive = false;

  markActive() => isActive = true;

  TodoItem copyWith({bool isActive, String id, String reminder, String task}) {
    return TodoItem(
      task ?? this._task,
      id ?? this.id,
      reminderDate: reminder ?? this.reminderDate,
    );
  }

  @override
  List<Object> get props => [isActive, id, reminderDate, _task];

  @override
  String toString() {
    return 'Todo { isActive: $isActive, task: $_task, note: $reminderDate, id: $id }';
  }

  TodoEntity toEntity() {
    return TodoEntity(_task, id, reminderDate, isActive, orderIndex);
  }

  static TodoItem fromEntity(TodoEntity entity) {
    return TodoItem(
      entity.task,
      entity.id,
      isActive: entity.isactive ?? false,
      reminderDate: entity.reminder,
      orderIndex: entity.orderindex
    );
  }
}
