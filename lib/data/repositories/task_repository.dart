import 'package:uuid/uuid.dart';
import '../models/task_model.dart';
import '../services/database_service.dart';

class TaskRepository {
  final _db = DatabaseService.instance;
  final _uuid = const Uuid();

  /// CREATE
  Future<TaskModel> createTask({
    required String title,
    required String description,
    required DateTime dueDate,
    required TaskPriority priority,
    required String assignedToId,
    required String createdById,
  }) async {
    final db = await _db.database;
    final task = TaskModel(
      id: _uuid.v4(),
      title: title.trim(),
      description: description.trim(),
      dueDate: dueDate,
      priority: priority,
      status: TaskStatus.pendiente,
      assignedToId: assignedToId,
      createdById: createdById,
    );
    await db.insert('tasks', task.toMap());
    return task;
  }

  /// READ - todas las tareas de un usuario específico
  Future<List<TaskModel>> getTasksByUser(String userId) async {
    final db = await _db.database;
    final results = await db.query(
      'tasks',
      where: 'assigned_to_id = ?',
      whereArgs: [userId],
      orderBy: 'due_date ASC',
    );
    return results.map((m) => TaskModel.fromMap(m)).toList();
  }

  /// READ - tareas de un usuario filtradas por un día específico
  /// (para la vista "tareas por día").
  Future<List<TaskModel>> getTasksByUserAndDate(String userId, DateTime day) async {
    final all = await getTasksByUser(userId);
    return all.where((t) =>
        t.dueDate.year == day.year &&
        t.dueDate.month == day.month &&
        t.dueDate.day == day.day).toList();
  }

  /// READ - todas las tareas de la familia (para el panel de administrador)
  Future<List<TaskModel>> getAllTasks() async {
    final db = await _db.database;
    final results = await db.query('tasks', orderBy: 'due_date ASC');
    return results.map((m) => TaskModel.fromMap(m)).toList();
  }

  /// UPDATE - edición general de la tarea
  Future<void> updateTask(TaskModel task) async {
    final db = await _db.database;
    await db.update('tasks', task.toMap(), where: 'id = ?', whereArgs: [task.id]);
  }

  /// UPDATE - cambio rápido de estado (tap en el círculo de la tarjeta)
  Future<void> toggleStatus(TaskModel task) async {
    final newStatus =
        task.status == TaskStatus.pendiente ? TaskStatus.completada : TaskStatus.pendiente;
    await updateTask(task.copyWith(status: newStatus));
  }

  /// DELETE
  Future<void> deleteTask(String id) async {
    final db = await _db.database;
    await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }
}
