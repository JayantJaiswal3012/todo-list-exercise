class TodoItem {
  String _task;
  String id;
  bool _isActive = true;
  bool swipeRightDetected = false;
  String reminderDate;
  int orderIndex;

  TodoItem(this._task, this.id, {this.reminderDate});

  getTask() => this._task;

  setTask(task) => this._task = task;

  isActive() => _isActive;

  markDone() => _isActive = false;

  markActive() => _isActive = true;
}
