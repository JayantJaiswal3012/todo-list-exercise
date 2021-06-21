import '../constants.dart';

class TodoEntity {
  final bool isactive;
  final String id;
  final String reminder;
  final String task;
  final int orderindex;

  TodoEntity(this.task, this.id, this.reminder, this.isactive, this.orderindex);

  @override
  int get hashCode =>
      isactive.hashCode ^ task.hashCode ^ reminder.hashCode ^ id.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TodoEntity &&
          runtimeType == other.runtimeType &&
          isactive == other.isactive &&
          task == other.task &&
          reminder == other.reminder &&
          id == other.id;

  Map<String, Object> toJson() {
    return {
      'isactive': isactive,
      'task': task,
      'reminder': reminder,
      'id': id,
      'orderindex': orderindex,
    };
  }

  @override
  String toString() {
    return 'TodoEntity{isactive: $isactive, task: $task, reminder: $reminder, id: $id}';
  }

  static TodoEntity fromJson(Map<String, Object> json) {
    return TodoEntity(
      json['task'] as String,
      json['id'] as String,
      json['reminder'] as String,
      json['isactive'] as bool,
      json['orderindex'] as int,
    );
  }
}
