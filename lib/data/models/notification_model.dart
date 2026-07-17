enum NotificationType {
  taskAssigned,
  taskDueSoon,
  taskCompleted,
}

class NotificationModel {
  final String id;
  final NotificationType type;
  final String message;
  final bool isRead;
  final String userId;
  final String? taskId;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.type,
    required this.message,
    required this.isRead,
    required this.userId,
    this.taskId,
    required this.createdAt,
  });

  static const _typeMap = {
    'task_assigned': NotificationType.taskAssigned,
    'task_due_soon': NotificationType.taskDueSoon,
    'task_completed': NotificationType.taskCompleted,
  };

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      type: _typeMap[json['type']] ?? NotificationType.taskAssigned,
      message: json['message'] as String,
      isRead: json['isRead'] as bool? ?? false,
      userId: json['userId'] as String,
      taskId: json['taskId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }


  NotificationModel copyWith({bool? isRead}) {
    return NotificationModel(
      id: id,
      type: type,
      message: message,
      isRead: isRead ?? this.isRead,
      userId: userId,
      taskId: taskId,
      createdAt: createdAt,
    );
  }
}
