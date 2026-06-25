import '../main.dart';
import 'api_client.dart';

class FriendService {
  FriendService._();
  static final FriendService instance = FriendService._();

  final _dio = ApiClient.instance.dio;

  Future<List<Friend>> getAll() async {
    final resp = await _dio.get('/friends');
    return (resp.data as List).map((j) => Friend.fromJson(j)).toList();
  }

  Future<List<Friend>> searchByName(String name) async {
    final resp = await _dio.get('/friends/search', queryParameters: {'name': name});
    return (resp.data as List).map((j) => Friend.fromJson(j)).toList();
  }

  Future<void> addById(int friendId) async {
    await _dio.post('/friends/add', data: {'friendId': friendId});
  }

  Future<String> addByEmail(String email) async {
    final resp = await _dio.post('/friends', data: {'email': email});
    return resp.data['message'] as String;
  }

  Future<void> remove(int friendId) async {
    await _dio.delete('/friends/$friendId');
  }
}
