import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/task_model.dart';
import '../../data/models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/task_provider.dart';

class FamilyScreen extends StatefulWidget {
  const FamilyScreen({super.key});

  @override
  State<FamilyScreen> createState() => _FamilyScreenState();
}

class _FamilyScreenState extends State<FamilyScreen> {
  UserModel? _selectedMember; // null = vista de cuadrícula

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().refreshFamilyMembers();
      context.read<TaskProvider>().loadAllTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final taskProvider = context.watch<TaskProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_selectedMember == null ? 'Familia' : _selectedMember!.name),
        leading: _selectedMember != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() => _selectedMember = null),
              )
            : null,
      ),
      body: _selectedMember == null
          ? _buildGrid(auth.familyMembers, taskProvider.allTasks)
          : _buildMemberDetail(_selectedMember!, taskProvider.allTasks),
    );
  }

  int _pendingFor(String userId, List<TaskModel> tasks) =>
      tasks.where((t) => t.assignedToId == userId && t.status == TaskStatus.pendiente).length;

  Widget _buildGrid(List<UserModel> members, List<TaskModel> tasks) {
    if (members.isEmpty) {
      return const Center(child: Text('Aún no hay integrantes registrados', style: TextStyle(color: AppColors.textSecondary)));
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Integrantes del hogar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 14),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 0.95,
              ),
              itemCount: members.length,
              itemBuilder: (_, i) {
                final m = members[i];
                final pending = _pendingFor(m.id, tasks);
                return GestureDetector(
                  onTap: () => setState(() => _selectedMember = m),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: const [BoxShadow(color: Color(0x0F000000), blurRadius: 10, offset: Offset(0, 4))],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 26,
                          backgroundColor: AppColors.summaryCardEnd,
                          child: Text(m.avatarInitial, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 10),
                        Text(m.name, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                        Text(m.role == UserRole.admin ? 'Administrador' : 'Miembro',
                            style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(color: AppColors.priorityMediumBg, borderRadius: BorderRadius.circular(20)),
                          child: Text('$pending pendientes',
                              style: const TextStyle(fontSize: 11, color: AppColors.priorityMedium, fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberDetail(UserModel member, List<TaskModel> allTasks) {
    final tasks = allTasks.where((t) => t.assignedToId == member.id).toList();

    if (tasks.isEmpty) {
      return Column(
        children: [
          const SizedBox(height: 60),
          Icon(Icons.inbox_outlined, size: 56, color: AppColors.textSecondary.withOpacity(0.4)),
          const SizedBox(height: 12),
          const Text('Sin tareas asignadas', style: TextStyle(color: AppColors.textSecondary)),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
      itemCount: tasks.length,
      itemBuilder: (_, i) {
        final t = tasks[i];
        final isCompleted = t.status == TaskStatus.completada;
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isCompleted ? AppColors.completedBg : Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Icon(
                isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                color: isCompleted ? AppColors.completedCheck : AppColors.textSecondary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t.title,
                        style: TextStyle(fontWeight: FontWeight.w600, decoration: isCompleted ? TextDecoration.lineThrough : null)),
                    Text('→ ${member.name} · ${DateFormat('dd MMM', 'es').format(t.dueDate)}',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
