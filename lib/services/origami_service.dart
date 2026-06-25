import '../main.dart';
import 'api_client.dart';

class OrigamiService {
  OrigamiService._();
  static final OrigamiService instance = OrigamiService._();

  final _dio = ApiClient.instance.dio;

  Future<List<TutorialData>> getAll() async {
    final resp = await _dio.get('/my-origami');
    return (resp.data as List).map((j) => TutorialData.fromJson(j)).toList();
  }

  Future<void> add(int tutorialId) async {
    await _dio.post('/my-origami/$tutorialId');
  }

  Future<void> remove(int tutorialId) async {
    await _dio.delete('/my-origami/$tutorialId');
  }
}
