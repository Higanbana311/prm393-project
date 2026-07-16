import '../main.dart';
import 'api_client.dart';

class CategoryService {
  CategoryService._();
  static final CategoryService instance = CategoryService._();

  Future<List<CategoryData>> getAll() async {
    final resp = await ApiClient.instance.dio.get('/categories');
    return (resp.data as List).map((j) => CategoryData.fromJson(j)).toList();
  }
}
