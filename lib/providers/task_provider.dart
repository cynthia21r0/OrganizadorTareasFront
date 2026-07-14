import 'package:flutter/foundation.dart';
import '../data/models/task_model.dart';
import '../data/repositories/task_repository.dart';

class TaskProvider extends ChangeNotifier {
  final TaskRepository _repo = TaskRepository();

  List<TaskModel> _myTasks = [];
  List<TaskModel> _allTasks = [];
  bool isLoading = false;

  List<TaskModel> get myTasks => _myTasks;
  List<TaskModel> get allTasks => _allTasks;

  int get pendingCount =>
      _myTasks.where((t) => t.status == TaskStatus.pendiente).length;
  int get completedCount =>
      _myTasks.where((t) => t.status == TaskStatus.completada).length;
  int get totalCount => _myTasks.length;
  double get progress => totalCount == 0 ? 0 : completedCount / totalCount;

  Future<void> loadMyTasks(String userId) async {
    final fresh = await _repo.getTasksByUser(userId);
    if (!listEquals(_myTasks, fresh)) {
      _myTasks = fresh;
      notifyListeners();
    }
  }

  Future<void> loadMyTasksByDay(String userId, DateTime day) async {
    final fresh = await _repo.getTasksByUser(userId, day: day);
    if (!listEquals(_myTasks, fresh)) {
      _myTasks = fresh;
      notifyListeners();
    }
  }

  Future<void> loadAllTasks() async {
    final fresh = await _repo.getAllTasks();
    if (!listEquals(_allTasks, fresh)) {
      _allTasks = fresh;
      notifyListeners();
    }
  }

  Future<void> _refreshAll(String userId) async {
    await Future.wait([loadMyTasks(userId), loadAllTasks()]);
  }

  Future<void> createTask({
    required String title,
    required String description,
    required DateTime dueDate,
    required TaskPriority priority,
    required String assignedToId,
  }) async {
    await _repo.createTask(
      title: title,
      description: description,
      dueDate: dueDate,
      priority: priority,
      assignedToId: assignedToId,
    );
    await _refreshAll(assignedToId);
  }

  Future<void> updateTask(TaskModel task, String currentUserId) async {
    await _repo.updateTask(task);
    await _refreshAll(currentUserId);
  }

  Future<void> toggleStatus(TaskModel task, String currentUserId) async {
    final newStatus = (task.status == TaskStatus.pendiente)
        ? TaskStatus.completada
        : TaskStatus.pendiente;

    final updatedTask = task.copyWith(status: newStatus);

    final myIndex = _myTasks.indexWhere((t) => t.id == task.id);
    if (myIndex != -1) {
      _myTasks[myIndex] = updatedTask;
    }

    final allIndex = _allTasks.indexWhere((t) => t.id == task.id);
    if (allIndex != -1) {
      _allTasks[allIndex] = updatedTask;
    }

    notifyListeners();

    try {
      await _repo.toggleStatus(task.id);
      await _refreshAll(currentUserId);
    } catch (e) {
      final revertIndex = _myTasks.indexWhere((t) => t.id == task.id);
      if (revertIndex != -1) {
        _myTasks[revertIndex] = task;
        notifyListeners();
      }
    }
  }

  Future<void> deleteTask(String taskId, String currentUserId) async {
    await _repo.deleteTask(taskId);
    await _refreshAll(currentUserId);
  }
}
