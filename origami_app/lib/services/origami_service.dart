import '../main.dart';
import 'api_client.dart';

class OrigamiService {
  OrigamiService._();
  static final OrigamiService instance = OrigamiService._();

  final _dio = ApiClient.instance.dio;

  Future<List<TutorialData>> getAll() async {
    final resp = await _dio.get('/my-origami');
    final items = (resp.data as List).map((j) => TutorialData.fromJson(j)).toList();
    completedIdsNotifier.value = items.map((t) => t.id).whereType<int>().toSet();
    return items;
  }

  /// Nạp lại danh sách đã hoàn thành để các màn hình khác đánh dấu đúng.
  /// Bỏ qua lỗi (ví dụ khách chưa đăng nhập) vì đây chỉ là dữ liệu hiển thị thêm.
  Future<void> refreshCompleted() async {
    try {
      await getAll();
    } catch (_) {}
  }

  void clearCompleted() => completedIdsNotifier.value = {};

  Future<void> add(int tutorialId) async {
    await _dio.post('/my-origami/$tutorialId');
    completedIdsNotifier.value = {...completedIdsNotifier.value, tutorialId};
  }

  Future<void> remove(int tutorialId) async {
    await _dio.delete('/my-origami/$tutorialId');
    completedIdsNotifier.value = {...completedIdsNotifier.value}..remove(tutorialId);
  }
}
