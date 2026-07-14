  import 'package:flutter/material.dart';
  import 'package:provider/provider.dart';
  import '../../core/theme/app_colors.dart';
  import '../../data/models/user_model.dart';
  import '../../providers/auth_provider.dart';
  import '../../providers/task_provider.dart';
  import '../auth/login_screen.dart';

  class ProfileScreen extends StatefulWidget {
    const ProfileScreen({super.key});

    @override
    State<ProfileScreen> createState() => _ProfileScreenState();
  }

  class _ProfileScreenState extends State<ProfileScreen> {
    @override
    void initState() {
      super.initState();
      WidgetsBinding.instance.addPostFrameCallback((_) => _load());
    }

    Future<void> _load() async {
      final auth = context.read<AuthProvider>();
      await auth.refreshFamilyMembers();
      if (auth.currentUser != null) {
        await context.read<TaskProvider>().loadMyTasks(auth.currentUser!.id);
      }
    }

    @override
    Widget build(BuildContext context) {
      final auth = context.watch<AuthProvider>();
      final taskProvider = context.watch<TaskProvider>();
      final user = auth.currentUser;
      if (user == null) return const SizedBox.shrink();

      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Perfil')),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
              child: Row(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: AppColors.summaryCardEnd,
                        child: Text(user.avatarInitial, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                      ),
                      Positioned(
                        right: 0, bottom: 0,
                        child: Container(
                          width: 12, height: 12,
                          decoration: BoxDecoration(
                            color: AppColors.priorityLow,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                        Text(user.email, style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
                        const SizedBox(height: 4),
                        const Row(
                          children: [
                            Icon(Icons.circle, size: 8, color: AppColors.priorityLow),
                            SizedBox(width: 4),
                            Text('En línea', style: TextStyle(fontSize: 12, color: AppColors.priorityLow, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text('Rendimiento', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const SizedBox(height: 12),
            Row(
              children: [
                _metricChip('Total', '${taskProvider.totalCount}', AppColors.pendingChipBg, AppColors.pendingChipText),
                const SizedBox(width: 10),
                _metricChip('Hechas', '${taskProvider.completedCount}', AppColors.completedBg, AppColors.completedCheck),
                const SizedBox(width: 10),
                _metricChip('Pendientes', '${taskProvider.pendingCount}', AppColors.priorityHighBg, AppColors.priorityHigh),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Cambiar cuenta', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const SizedBox(height: 12),
            ...auth.familyMembers.map((UserModel m) {
              final isActive = m.id == user.id;
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.summaryCardEnd,
                    child: Text(m.avatarInitial, style: const TextStyle(color: Colors.white)),
                  ),
                  title: Text(m.name),
                  // ✅
subtitle: Text(m.role.label),
                  trailing: isActive ? const Icon(Icons.check_circle, color: AppColors.summaryCardEnd) : null,
                  onTap: () {
                    auth.switchAccount(m);
                    context.read<TaskProvider>().loadMyTasks(m.id);
                  },
                ),
              );
            }),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: () {
                auth.logout();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              },
              icon: const Icon(Icons.logout, color: AppColors.error),
              label: const Text('Cerrar sesión', style: TextStyle(color: AppColors.error)),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                side: const BorderSide(color: AppColors.error),
              ),
            ),
          ],
        ),
      );
    }

    Widget _metricChip(String label, String value, Color bg, Color fg) {
      return Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14)),
          child: Column(
            children: [
              Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: fg)),
              const SizedBox(height: 2),
              Text(label, style: TextStyle(fontSize: 11.5, color: fg)),
            ],
          ),
        ),
      );
    }
  }
