import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/theme/app_colors.dart';
import '../data/models/task_model.dart';

class TaskCard extends StatelessWidget {
  final TaskModel task;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TaskCard({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  Color get _priorityColor {
    switch (task.priority) {
      case TaskPriority.baja:
        return AppColors.priorityLow;
      case TaskPriority.media:
        return AppColors.priorityMedium;
      case TaskPriority.alta:
        return AppColors.priorityHigh;
    }
  }

  Color get _priorityBg {
    switch (task.priority) {
      case TaskPriority.baja:
        return AppColors.priorityLowBg;
      case TaskPriority.media:
        return AppColors.priorityMediumBg;
      case TaskPriority.alta:
        return AppColors.priorityHighBg;
    }
  }

  String get _priorityLabel {
    switch (task.priority) {
      case TaskPriority.baja:
        return 'Baja';
      case TaskPriority.media:
        return 'Media';
      case TaskPriority.alta:
        return 'Alta';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted = task.status == TaskStatus.completada;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isCompleted ? AppColors.completedBg : AppColors.cardWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: BorderSide(
            color: isCompleted ? AppColors.completedCheck : _priorityColor,
            width: 4,
          ),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onToggle,
            child: Container(
              width: 26,
              height: 26,
              margin: const EdgeInsets.only(top: 2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted
                    ? AppColors.completedCheck
                    : Colors.transparent,
                border: Border.all(
                  color: isCompleted
                      ? AppColors.completedCheck
                      : AppColors.textSecondary,
                  width: 2,
                ),
              ),
              child: isCompleted
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (task.description.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    task.description,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _chip(
                      isCompleted ? '✓ Completada' : 'Pendiente',
                      isCompleted
                          ? AppColors.completedBg
                          : AppColors.pendingChipBg,
                      isCompleted
                          ? AppColors.completedCheck
                          : AppColors.pendingChipText,
                    ),
                    _chip(_priorityLabel, _priorityBg, _priorityColor),
                    _chip(
                      DateFormat('dd MMM', 'es').format(task.dueDate),
                      AppColors.background,
                      AppColors.textSecondary,
                      icon: Icons.schedule,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.edit,
                  size: 19,
                  color: AppColors.summaryCardEnd,
                ),
                onPressed: onEdit,
                visualDensity: VisualDensity.compact,
              ),
              IconButton(
                icon: const Icon(
                  Icons.delete,
                  size: 19,
                  color: AppColors.priorityHigh,
                ),
                onPressed: onDelete,
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, Color bg, Color fg, {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 11, color: fg),
            const SizedBox(width: 3),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: fg,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
