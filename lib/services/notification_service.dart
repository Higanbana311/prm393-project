import '../main.dart';
import 'api_client.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _dio = ApiClient.instance.dio;

  Future<List<AppNotification>> getAll() async {
    final resp = await _dio.get('/notifications');
    return (resp.data as List)
        .map((j) => AppNotification.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  Future<void> markRead(int id) async {
    await _dio.put('/notifications/$id/read');
  }
}
