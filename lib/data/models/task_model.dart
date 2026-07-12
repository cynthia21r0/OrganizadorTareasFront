enum TaskPriority { baja, media, alta }

enum TaskStatus { pendiente, completada }

class TaskModel {
  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final TaskPriority priority;
  final TaskStatus status;
  final String assignedToId; // id del usuario/miembro asignado
  final String createdById;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.priority,
    required this.status,
    required this.assignedToId,
    required this.createdById,
  });

  TaskModel copyWith({
    String? title,
    String? description,
    DateTime? dueDate,
    TaskPriority? priority,
    TaskStatus? status,
    String? assignedToId,
  }) {
    return TaskModel(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      assignedToId: assignedToId ?? this.assignedToId,
      createdById: createdById,
    );
  }

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String? ?? '',
      dueDate: DateTime.parse(map['due_date'] as String),
      priority: TaskPriority.values.firstWhere(
        (p) => p.name == map['priority'],
        orElse: () => TaskPriority.media,
      ),
      status: TaskStatus.values.firstWhere(
        (s) => s.name == map['status'],
        orElse: () => TaskStatus.pendiente,
      ),
      assignedToId: map['assigned_to_id'] as String,
      createdById: map['created_by_id'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'due_date': dueDate.toIso8601String(),
      'priority': priority.name,
      'status': status.name,
      'assigned_to_id': assignedToId,
      'created_by_id': createdById,
    };
  }
}
