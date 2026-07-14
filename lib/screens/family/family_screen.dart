import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class _FamilyScreenState extends State<FamilyScreen>
    with WidgetsBindingObserver {
  UserModel? _selectedMember;

  final Map<String, Uint8List> _imageCache = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _refreshData());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshData();
    }
  }

  Future<void> _refreshData() async {
    await context.read<AuthProvider>().refreshFamilyMembers();
    await context.read<TaskProvider>().loadAllTasks();
  }

  Uint8List? _decodedImage(UserModel m) {
    if (m.profilePicture == null) return null;
    return _imageCache.putIfAbsent(m.id, () => base64Decode(m.profilePicture!));
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final taskProvider = context.watch<TaskProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          _selectedMember == null ? 'Familia' : _selectedMember!.name,
        ),
        leading: _selectedMember != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() => _selectedMember = null),
              )
            : null,
      ),
      body: _selectedMember == null
          ? _buildGrid(auth.familyMembers, taskProvider.allTasks, context)
          : _buildMemberDetail(_selectedMember!, taskProvider.allTasks),
    );
  }

  int _pendingFor(String userId, List<TaskModel> tasks) => tasks
      .where(
        (t) => t.assignedToId == userId && t.status == TaskStatus.pendiente,
      )
      .length;

  Widget _buildGrid(
    List<UserModel> members,
    List<TaskModel> tasks,
    BuildContext context,
  ) {
    final String inviteCode =
        context.read<AuthProvider>().currentUser?.familyInviteCode ??
        'Sin código';

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: members.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(height: 100),
                Center(
                  child: Text(
                    'Aún no hay integrantes registrados',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              ],
            )
          : SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInviteCard(inviteCode, context),
                  const SizedBox(height: 24),
                  const Text(
                    'Integrantes del hogar',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 14),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
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
                        key: ValueKey(m.id),
                        onTap: () => setState(() => _selectedMember = m),
                        child: _buildMemberCard(m, pending),
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildInviteCard(String inviteCode, BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Código de Invitación',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 4),
              Text(
                inviteCode,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.copy, color: AppColors.priorityLow),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: inviteCode));
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Código copiado')));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMemberCard(UserModel m, int pending) {
    final imageBytes = _decodedImage(m);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: AppColors.summaryCardEnd,
            backgroundImage: imageBytes != null
                ? MemoryImage(imageBytes)
                : null,
            child: imageBytes == null
                ? Text(
                    m.avatarInitial,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          const SizedBox(height: 10),
          Text(
            m.name,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            m.role.label,
            style: const TextStyle(
              fontSize: 11.5,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.priorityMediumBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$pending pendientes',
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.priorityMedium,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberDetail(UserModel member, List<TaskModel> allTasks) {
    final tasks = allTasks.where((t) => t.assignedToId == member.id).toList();
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: tasks.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(height: 100),
                Center(child: Text('Sin tareas')),
              ],
            )
          : ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
              itemCount: tasks.length,
              itemBuilder: (_, i) {
                final t = tasks[i];
                final isCompleted = t.status == TaskStatus.completada;
                return Container(
                  key: ValueKey(t.id),
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isCompleted ? AppColors.completedBg : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isCompleted
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        color: isCompleted
                            ? AppColors.completedCheck
                            : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t.title,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                decoration: isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                            Text(
                              '→ ${member.name} · ${DateFormat('dd MMM', 'es').format(t.dueDate)}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
