import 'package:flutter/foundation.dart';
import '../data/models/notification_model.dart';
import '../data/repositories/notification_repository.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationRepository _repo = NotificationRepository();

  List<NotificationModel> _notifications = [];
  bool isLoading = false;
  String? errorMessage;

  List<NotificationModel> get notifications => _notifications;

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  Future<void> loadNotifications() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final fresh = await _repo.getAll();
      _notifications = fresh;
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(String id) async {
    // Optimistic update
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1 && !_notifications[index].isRead) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      notifyListeners();
      try {
        await _repo.markAsRead(id);
      } catch (_) {
        // Revert on error
        _notifications[index] = _notifications[index].copyWith(isRead: false);
        notifyListeners();
      }
    }
  }

  Future<void> markAllAsRead() async {
    // Optimistic update
    _notifications = _notifications
        .map((n) => n.copyWith(isRead: true))
        .toList();
    notifyListeners();
    try {
      await _repo.markAllAsRead();
    } catch (e) {
      errorMessage = 'No se pudo marcar todo como leído. Intenta de nuevo.';
      // Reload real state from server
      await loadNotifications();
    }
  }
}
