import 'package:flutter/material.dart';
import '../data/models/task_model.dart';
import '../data/repositories/task_repository.dart';

class TaskProvider extends ChangeNotifier {
  final TaskRepository _repo = TaskRepository();

  List<TaskModel> _myTasks = [];
  List<TaskModel> _allTasks = [];
  bool isLoading = false;

  List<TaskModel> get myTasks => _myTasks;
  List<TaskModel> get allTasks => _allTasks;

  int get pendingCount => _myTasks.where((t) => t.status == TaskStatus.pendiente).length;
  int get completedCount => _myTasks.where((t) => t.status == TaskStatus.completada).length;
  int get totalCount => _myTasks.length;
  double get progress => totalCount == 0 ? 0 : completedCount / totalCount;

  Future<void> loadMyTasks(String userId) async {
    isLoading = true;
    notifyListeners();
    _myTasks = await _repo.getTasksByUser(userId);
    isLoading = false;
    notifyListeners();
  }

  Future<void> loadMyTasksByDay(String userId, DateTime day) async {
    isLoading = true;
    notifyListeners();
    _myTasks = await _repo.getTasksByUserAndDate(userId, day);
    isLoading = false;
    notifyListeners();
  }

  Future<void> loadAllTasks() async {
    _allTasks = await _repo.getAllTasks();
    notifyListeners();
  }

  Future<void> createTask({
    required String title,
    required String description,
    required DateTime dueDate,
    required TaskPriority priority,
    required String assignedToId,
    required String createdById,
  }) async {
    await _repo.createTask(
      title: title,
      description: description,
      dueDate: dueDate,
      priority: priority,
      assignedToId: assignedToId,
      createdById: createdById,
    );
    await loadMyTasks(createdById);
  }

  Future<void> updateTask(TaskModel task, String currentUserId) async {
    await _repo.updateTask(task);
    await loadMyTasks(currentUserId);
  }

  Future<void> toggleStatus(TaskModel task, String currentUserId) async {
    await _repo.toggleStatus(task);
    await loadMyTasks(currentUserId);
  }

  Future<void> deleteTask(String taskId, String currentUserId) async {
    await _repo.deleteTask(taskId);
    await loadMyTasks(currentUserId);
  }
}
