import '../main.dart';
import 'api_client.dart';

class FriendService {
  FriendService._();
  static final FriendService instance = FriendService._();

  final _dio = ApiClient.instance.dio;

  Future<List<Friend>> getAll() async {
    final resp = await _dio.get('/friends');
    return (resp.data as List).map((j) => Friend.fromJson(j as Map<String, dynamic>)).toList();
  }

  Future<List<Friend>> searchByName(String name) async {
    final resp = await _dio.get('/friends/search', queryParameters: {'name': name});
    return (resp.data as List).map((j) => Friend.fromJson(j as Map<String, dynamic>)).toList();
  }

  Future<void> sendRequest(int friendId) async {
    await _dio.post('/friends/request', data: {'friendId': friendId});
  }

  Future<List<FriendRequest>> getPendingRequests() async {
    final resp = await _dio.get('/friends/requests');
    return (resp.data as List)
        .map((j) => FriendRequest.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  Future<void> acceptRequest(int requestId) async {
    await _dio.post('/friends/requests/$requestId/accept');
  }

  Future<void> rejectRequest(int requestId) async {
    await _dio.delete('/friends/requests/$requestId');
  }

  Future<void> remove(int friendId) async {
    await _dio.delete('/friends/$friendId');
  }
}
