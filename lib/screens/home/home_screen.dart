import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/task_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/task_provider.dart';
import '../../widgets/summary_card.dart';
import '../../widgets/task_card.dart';
import 'task_form_modal.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime? _filterDay;
  bool _loadError = false;

  String? _cachedProfilePictureSource;
  Uint8List? _cachedImageBytes;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadTasks());
  }

  Future<void> _loadTasks() async {
    final auth = context.read<AuthProvider>();
    final taskProvider = context.read<TaskProvider>();
    if (auth.currentUser == null) return;
    setState(() => _loadError = false);
    try {
      if (_filterDay == null) {
        await taskProvider.loadMyTasks(auth.currentUser!.id);
      } else {
        await taskProvider.loadMyTasksByDay(auth.currentUser!.id, _filterDay!);
      }
    } catch (_) {
      if (mounted) setState(() => _loadError = true);
    }
  }

  Uint8List? _decodedProfilePicture(String? profilePicture) {
    if (profilePicture == null) return null;
    if (profilePicture == _cachedProfilePictureSource &&
        _cachedImageBytes != null) {
      return _cachedImageBytes;
    }
    _cachedProfilePictureSource = profilePicture;
    _cachedImageBytes = base64Decode(profilePicture);
    return _cachedImageBytes;
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final taskProvider = context.watch<TaskProvider>();
    final user = auth.currentUser;
    final avatarBytes = _decodedProfilePicture(user?.profilePicture);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.primary,
        onPressed: () async {
          await showTaskFormModal(context);
          await _loadTasks();
          if (mounted) await context.read<TaskProvider>().loadAllTasks();
        },
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await _loadTasks();
            await context.read<TaskProvider>().loadAllTasks();
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Hola 👋',
                          style: TextStyle(color: Colors.grey),
                        ),
                        Text(
                          user?.name ?? '',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    backgroundImage: avatarBytes != null
                        ? MemoryImage(avatarBytes)
                        : null,
                    child: avatarBytes == null
                        ? Text(
                            user?.avatarInitial ?? '?',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SummaryCard(
                pending: taskProvider.pendingCount,
                completed: taskProvider.completedCount,
                total: taskProvider.totalCount,
                progress: taskProvider.progress,
              ),
              const SizedBox(height: 24),
              _dayFilterRow(),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Mis tareas',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    '${taskProvider.pendingCount} pendientes',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (taskProvider.isLoading)
                const Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_loadError)
                _errorState()
              else if (taskProvider.myTasks.isEmpty)
                _emptyState()
              else
                ...taskProvider.myTasks.map(
                  (task) => TaskCard(
                    key: ValueKey(task.id),
                    task: task,
                    onToggle: () async {
                      await taskProvider.toggleStatus(task, user!.id);
                      if (mounted && taskProvider.errorMessage != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(taskProvider.errorMessage!),
                            backgroundColor: AppColors.error,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                      await _loadTasks();
                      if (mounted) await taskProvider.loadAllTasks();
                    },
                    onEdit: () async {
                      await showTaskFormModal(context, taskToEdit: task);
                      await _loadTasks();
                      if (mounted) await taskProvider.loadAllTasks();
                    },
                    onDelete: () => _confirmDelete(task),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dayFilterRow() {
    final today = DateTime.now();
    final days = List.generate(7, (i) => today.add(Duration(days: i - 1)));

    return SizedBox(
      height: 64,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: days.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          if (i == 0) {
            final selected = _filterDay == null;
            return _dayChip('Todas', '', selected, () {
              setState(() => _filterDay = null);
              _loadTasks();
            });
          }
          final d = days[i - 1];
          final selected =
              _filterDay != null &&
              _filterDay!.year == d.year &&
              _filterDay!.month == d.month &&
              _filterDay!.day == d.day;
          const weekDays = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
          return _dayChip(weekDays[d.weekday - 1], '${d.day}', selected, () {
            setState(() => _filterDay = d);
            _loadTasks();
          });
        },
      ),
    );
  }

  Widget _dayChip(
    String label,
    String number,
    bool selected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        decoration: BoxDecoration(
          color: selected ? Theme.of(context).colorScheme.primary : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: selected ? Colors.white70 : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            if (number.isNotEmpty)
              Text(
                number,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: selected ? Colors.white : Theme.of(context).colorScheme.onSurface,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _errorState() {
    return Padding(
      padding: const EdgeInsets.only(top: 30),
      child: Column(
        children: [
          Icon(
            Icons.wifi_off_rounded,
            size: 56,
            color: AppColors.error.withOpacity(0.5),
          ),
          const SizedBox(height: 12),
          const Text(
            'No se pudieron cargar las tareas',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _loadTasks,
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Padding(
      padding: const EdgeInsets.only(top: 30),
      child: Column(
        children: [
          Icon(
            Icons.task_alt,
            size: 56,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 12),
          Text(
            'Sin tareas asignadas',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(TaskModel task) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar tarea'),
        content: Text('¿Seguro que deseas eliminar "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              final auth = context.read<AuthProvider>();
              final taskProvider = context.read<TaskProvider>();
              try {
                await taskProvider.deleteTask(task.id, auth.currentUser!.id);
                if (mounted) {
                  Navigator.pop(context);
                  await _loadTasks();
                  await taskProvider.loadAllTasks();
                }
              } catch (_) {
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        taskProvider.errorMessage ?? 'No se pudo eliminar la tarea.',
                      ),
                      backgroundColor: AppColors.error,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
            child: Text(
              'Eliminar',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }
}
