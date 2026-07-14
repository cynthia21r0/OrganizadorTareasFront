import '../../core/network/api_client.dart';
import '../models/task_model.dart';

class TaskRepository {
  final _dio = ApiClient.instance.dio;

  Future<TaskModel> createTask({
    required String title,
    required String description,
    required DateTime dueDate,
    required TaskPriority priority,
    required String assignedToId,
  }) async {
    final res = await _dio.post('/tasks', data: {
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'priority': priority.name,
      'assignedToId': assignedToId,
    });
    return TaskModel.fromJson(res.data);
  }

  Future<List<TaskModel>> getTasksByUser(String userId, {DateTime? day}) async {
    final res = await _dio.get(
      '/tasks/user/$userId',
      queryParameters: day != null ? {'day': day.toIso8601String().split('T').first} : null,
    );
    return (res.data as List).map((m) => TaskModel.fromJson(m)).toList();
  }

  Future<List<TaskModel>> getAllTasks() async {
    final res = await _dio.get('/tasks');
    return (res.data as List).map((m) => TaskModel.fromJson(m)).toList();
  }

  Future<TaskModel> updateTask(TaskModel task) async {
    final res = await _dio.patch('/tasks/${task.id}', data: {
      'title': task.title,
      'description': task.description,
      'dueDate': task.dueDate.toIso8601String(),
      'priority': task.priority.name,
      'assignedToId': task.assignedToId,
      'status': task.status.name,
    });
    return TaskModel.fromJson(res.data);
  }

  Future<TaskModel> toggleStatus(String taskId) async {
    final res = await _dio.patch('/tasks/$taskId/toggle');
    return TaskModel.fromJson(res.data);
  }

  Future<void> deleteTask(String id) async {
    await _dio.delete('/tasks/$id');
  }
}