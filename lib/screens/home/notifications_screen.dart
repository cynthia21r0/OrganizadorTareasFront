import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/notification_model.dart';
import '../../providers/notification_provider.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          _buildBody(context),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
        title: Consumer<NotificationProvider>(
          builder: (_, prov, child) => Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Notificaciones',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                ),
              ),
              if (prov.unreadCount > 0) ...[
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.navActive,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${prov.unreadCount}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6FA3EE), Color(0xFF5B8DEE)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      actions: [
        Consumer<NotificationProvider>(
          builder: (_, prov, child) {
            if (prov.unreadCount == 0) return const SizedBox.shrink();
            return TextButton.icon(
              onPressed: prov.isLoading ? null : prov.markAllAsRead,
              icon: const Icon(Icons.done_all_rounded,
                  color: Colors.white, size: 18),
              label: const Text(
                'Leer todo',
                style: TextStyle(color: Colors.white, fontSize: 13),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (_, prov, child) {
        if (prov.isLoading) {
          return const SliverFillRemaining(
            child: Center(
              child: CircularProgressIndicator(color: AppColors.navActive),
            ),
          );
        }

        if (prov.notifications.isEmpty) {
          return SliverFillRemaining(
            child: _EmptyState(),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) {
                final n = prov.notifications[i];
                return _NotificationCard(
                  notification: n,
                  onTap: () => prov.markAsRead(n.id),
                );
              },
              childCount: prov.notifications.length,
            ),
          ),
        );
      },
    );
  }
}

// ─── Notification Card ───────────────────────────────────────────────────────

class _NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  const _NotificationCard({
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final n = notification;
    final config = _typeConfig(n.type);
    final timeAgo = _formatTime(n.createdAt);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: n.isRead ? AppColors.cardWhite : const Color(0xFFEEF4FF),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: n.isRead ? Colors.transparent
                : AppColors.navActive.withValues(alpha: 0.25),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: config.bgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(config.icon, color: config.iconColor, size: 22),
              ),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      config.label,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: config.iconColor,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      n.message,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                        fontWeight:
                            n.isRead ? FontWeight.w400 : FontWeight.w600,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      timeAgo,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              // Unread dot
              if (!n.isRead)
                Padding(
                  padding: const EdgeInsets.only(top: 4, left: 6),
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.navActive,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  _TypeConfig _typeConfig(NotificationType type) {
    switch (type) {
      case NotificationType.taskAssigned:
        return _TypeConfig(
          icon: Icons.assignment_ind_rounded,
          iconColor: const Color(0xFF4A7FD6),
          bgColor: const Color(0xFFDCE8FB),
          label: 'TAREA ASIGNADA',
        );
      case NotificationType.taskDueSoon:
        return _TypeConfig(
          icon: Icons.access_time_rounded,
          iconColor: const Color(0xFFE08B3A),
          bgColor: const Color(0xFFFFF3E0),
          label: 'VENCE PRONTO',
        );
      case NotificationType.taskCompleted:
        return _TypeConfig(
          icon: Icons.check_circle_rounded,
          iconColor: const Color(0xFF4CAF7D),
          bgColor: const Color(0xFFDFF5E7),
          label: 'TAREA COMPLETADA',
        );
    }
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Ahora mismo';
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Hace ${diff.inHours} h';
    if (diff.inDays == 1) return 'Ayer';
    if (diff.inDays < 7) return 'Hace ${diff.inDays} días';
    return DateFormat('d MMM yyyy', 'es').format(dt);
  }
}

class _TypeConfig {
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final String label;
  const _TypeConfig({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.label,
  });
}

// ─── Empty State ─────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: AppColors.navActiveBg,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.notifications_none_rounded,
            size: 56,
            color: AppColors.navActive,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Sin notificaciones',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Aquí aparecerán tus alertas\nde tareas asignadas y vencimientos.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
