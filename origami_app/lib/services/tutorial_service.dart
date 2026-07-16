import '../main.dart';
import 'api_client.dart';

class TutorialService {
  TutorialService._();
  static final TutorialService instance = TutorialService._();

  final _dio = ApiClient.instance.dio;

  Future<List<TutorialData>> getFeatured() async {
    final resp = await _dio.get('/tutorials/featured');
    return (resp.data as List).map((j) => TutorialData.fromJson(j)).toList();
  }

  Future<List<TutorialData>> getNewDesigns() async {
    final resp = await _dio.get('/tutorials/new');
    return (resp.data as List).map((j) => TutorialData.fromJson(j)).toList();
  }

  Future<TutorialData> getById(int id) async {
    final resp = await _dio.get('/tutorials/$id');
    return TutorialData.fromJson(resp.data);
  }

  Future<List<TutorialData>> search(String query) async {
    final resp = await _dio.get('/tutorials/search',
        queryParameters: {'q': query});
    return (resp.data as List).map((j) => TutorialData.fromJson(j)).toList();
  }

  Future<List<TutorialData>> getByCategory(int categoryId) async {
    final resp = await _dio.get('/tutorials',
        queryParameters: {'categoryId': categoryId});
    return (resp.data as List).map((j) => TutorialData.fromJson(j)).toList();
  }

  /// Chia sẻ một mẫu tới danh sách bạn bè. [type] = 'detail' hoặc 'completion'.
  /// Trả về số người đã nhận được chia sẻ.
  Future<int> share(int tutorialId, List<int> friendIds,
      {String type = 'detail'}) async {
    final resp = await _dio.post('/tutorials/$tutorialId/share',
        data: {'friendIds': friendIds, 'type': type});
    return (resp.data['sent'] as int?) ?? friendIds.length;
  }
}
