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
}
