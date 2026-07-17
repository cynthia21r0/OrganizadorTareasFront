import '../../core/network/api_client.dart';
import '../models/notification_model.dart';

class NotificationRepository {
  final _dio = ApiClient.instance.dio;

  Future<List<NotificationModel>> getAll() async {
    final res = await _dio.get('/notifications');
    return (res.data as List)
        .map((m) => NotificationModel.fromJson(m))
        .toList();
  }

  Future<List<NotificationModel>> getUnread() async {
    final res = await _dio.get('/notifications/unread');
    return (res.data as List)
        .map((m) => NotificationModel.fromJson(m))
        .toList();
  }

  Future<void> markAsRead(String id) async {
    await _dio.patch('/notifications/$id/read');
  }

  Future<void> markAllAsRead() async {
    await _dio.post('/notifications/read-all');
  }
}
