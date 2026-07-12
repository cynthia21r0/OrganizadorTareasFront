import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../data/models/task_model.dart';
import '../../data/models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/task_provider.dart';

/// Muestra el modal de creación/edición de tarea.
/// [taskToEdit] es null cuando se está creando una tarea nueva.
Future<void> showTaskFormModal(BuildContext context, {TaskModel? taskToEdit}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => TaskFormModal(taskToEdit: taskToEdit),
  );
}

class TaskFormModal extends StatefulWidget {
  final TaskModel? taskToEdit;
  const TaskFormModal({super.key, this.taskToEdit});

  @override
  State<TaskFormModal> createState() => _TaskFormModalState();
}

class _TaskFormModalState extends State<TaskFormModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleCtrl;
  late TextEditingController _descCtrl;
  DateTime _dueDate = DateTime.now();
  TaskPriority _priority = TaskPriority.media;
  String? _assignedToId;

  bool get _isEditing => widget.taskToEdit != null;

  @override
  void initState() {
    super.initState();
    final t = widget.taskToEdit;
    _titleCtrl = TextEditingController(text: t?.title ?? '');
    _descCtrl = TextEditingController(text: t?.description ?? '');
    _dueDate = t?.dueDate ?? DateTime.now();
    _priority = t?.priority ?? TaskPriority.media;
    _assignedToId = t?.assignedToId;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final taskProvider = context.read<TaskProvider>();
    final currentUser = auth.currentUser!;
    final assignedId = _assignedToId ?? currentUser.id;

    if (_isEditing) {
      final updated = widget.taskToEdit!.copyWith(
        title: _titleCtrl.text,
        description: _descCtrl.text,
        dueDate: _dueDate,
        priority: _priority,
        assignedToId: assignedId,
      );
      await taskProvider.updateTask(updated, currentUser.id);
    } else {
      await taskProvider.createTask(
        title: _titleCtrl.text,
        description: _descCtrl.text,
        dueDate: _dueDate,
        priority: _priority,
        assignedToId: assignedId,
        createdById: currentUser.id,
      );
    }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final members = auth.familyMembers;
    final isTitleValid = _titleCtrl.text.trim().isNotEmpty;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
        child: Form(
          key: _formKey,
          onChanged: () => setState(() {}),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(4)),
                  ),
                ),
                const SizedBox(height: 16),
                Text(_isEditing ? 'Editar tarea' : 'Nueva tarea',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _titleCtrl,
                  decoration: const InputDecoration(labelText: 'Título *'),
                  validator: (v) => Validators.required(v, field: 'El título'),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _descCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'Descripción'),
                ),
                const SizedBox(height: 14),
                InkWell(
                  onTap: _pickDate,
                  borderRadius: BorderRadius.circular(14),
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: 'Fecha límite', prefixIcon: Icon(Icons.calendar_today_outlined)),
                    child: Text(DateFormat('dd MMM yyyy', 'es').format(_dueDate)),
                  ),
                ),
                const SizedBox(height: 14),
                Text('Prioridad', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                const SizedBox(height: 8),
                Row(
                  children: TaskPriority.values.map((p) {
                    final selected = _priority == p;
                    final label = {
                      TaskPriority.baja: 'Baja',
                      TaskPriority.media: 'Media',
                      TaskPriority.alta: 'Alta',
                    }[p]!;
                    final color = {
                      TaskPriority.baja: AppColors.priorityLow,
                      TaskPriority.media: AppColors.priorityMedium,
                      TaskPriority.alta: AppColors.priorityHigh,
                    }[p]!;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _priority = p),
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: selected ? color : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: color, width: 1.4),
                          ),
                          child: Text(label,
                              style: TextStyle(color: selected ? Colors.white : color, fontWeight: FontWeight.w600)),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 14),
                if (members.isNotEmpty) ...[
                  Text('Asignar a', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _assignedToId ?? auth.currentUser?.id,
                    items: members
                        .map((UserModel m) => DropdownMenuItem(value: m.id, child: Text(m.name)))
                        .toList(),
                    onChanged: (v) => setState(() => _assignedToId = v),
                    decoration: const InputDecoration(prefixIcon: Icon(Icons.person_pin_circle_outlined)),
                  ),
                  const SizedBox(height: 20),
                ],
                ElevatedButton(
                  onPressed: isTitleValid ? _submit : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isTitleValid ? AppColors.fabPurple : Colors.grey.shade300,
                  ),
                  child: Text(_isEditing ? 'Guardar cambios' : 'Crear tarea'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
