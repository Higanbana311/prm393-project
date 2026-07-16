import '../main.dart';
import 'api_client.dart';

class FavoriteService {
  FavoriteService._();
  static final FavoriteService instance = FavoriteService._();

  final _dio = ApiClient.instance.dio;

  Future<List<TutorialData>> getAll() async {
    final resp = await _dio.get('/favorites');
    return (resp.data as List).map((j) => TutorialData.fromJson(j)).toList();
  }

  Future<void> add(int tutorialId) async {
    await _dio.post('/favorites/$tutorialId');
  }

  Future<void> remove(int tutorialId) async {
    await _dio.delete('/favorites/$tutorialId');
  }
}
