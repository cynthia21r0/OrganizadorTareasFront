import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../providers/notification_provider.dart';

class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final navBg = isDark ? AppTheme.darkNavBg : AppColors.navBackground;
    // Usa el color primario del tema actual (respeta el acento seleccionado)
    final activeColor = Theme.of(context).colorScheme.primary;
    final activeBg = activeColor.withValues(alpha: 0.12);

    return Container(
      decoration: BoxDecoration(
        color: navBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 12,
            offset: Offset(0, -3),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(context, 0, Icons.home_rounded, 'Inicio',
                activeColor, activeBg),
            _navItem(context, 1, Icons.groups_rounded, 'Familia',
                activeColor, activeBg),
            _notifItem(context, activeColor, activeBg),
            _navItem(context, 3, Icons.person_rounded, 'Perfil',
                activeColor, activeBg),
          ],
        ),
      ),
    );
  }

  Widget _navItem(BuildContext context, int index, IconData icon, String label,
      Color activeColor, Color activeBg) {
    final isActive = index == currentIndex;
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isActive ? activeBg : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isActive ? activeColor : AppColors.navInactive,
              size: 24,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              color: isActive ? activeColor : AppColors.navInactive,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _notifItem(
      BuildContext context, Color activeColor, Color activeBg) {
    const index = 2;
    final isActive = index == currentIndex;
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isActive ? activeBg : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.notifications_rounded,
                  color: isActive ? activeColor : AppColors.navInactive,
                  size: 24,
                ),
              ),
              // Badge de notificaciones no leídas
              Consumer<NotificationProvider>(
                builder: (_, prov, child) {
                  if (prov.unreadCount == 0) return const SizedBox.shrink();
                  return Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        shape: prov.unreadCount > 9
                            ? BoxShape.rectangle
                            : BoxShape.circle,
                        borderRadius: prov.unreadCount > 9
                            ? BorderRadius.circular(8)
                            : null,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      constraints:
                          const BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Text(
                        prov.unreadCount > 99 ? '99+' : '${prov.unreadCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          height: 1,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            'Alertas',
            style: TextStyle(
              fontSize: 11.5,
              color: isActive ? activeColor : AppColors.navInactive,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
