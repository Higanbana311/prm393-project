import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_client.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  static const _keyToken = 'auth_token';
  static const _keyUserId = 'user_id';
  static const _keyUserName = 'user_name';
  static const _keyUserEmail = 'user_email';
  static const _keyUserInitials = 'user_initials';
  static const _keyUserColor = 'user_color';

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyUserId);
  }

  Future<bool> isLoggedIn() async => (await getToken()) != null;

  Future<Map<String, dynamic>> login(String email, String password) async {
    final resp = await ApiClient.instance.dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    await _saveSession(resp.data);
    return resp.data;
  }

  Future<Map<String, dynamic>> register(
      String fullName, String email, String password) async {
    final resp = await ApiClient.instance.dio.post('/auth/register', data: {
      'fullName': fullName,
      'email': email,
      'password': password,
    });
    await _saveSession(resp.data);
    return resp.data;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyUserName);
    await prefs.remove(_keyUserEmail);
    await prefs.remove(_keyUserInitials);
    await prefs.remove(_keyUserColor);
  }

  Future<Map<String, String?>> getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'name': prefs.getString(_keyUserName),
      'email': prefs.getString(_keyUserEmail),
      'initials': prefs.getString(_keyUserInitials),
      'color': prefs.getString(_keyUserColor),
    };
  }

  Future<void> _saveSession(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final token = data['token'] as String;
    final user = data['user'] as Map<String, dynamic>;
    await prefs.setString(_keyToken, token);
    await prefs.setInt(_keyUserId, user['Id'] as int);
    await prefs.setString(_keyUserName, user['FullName'] as String);
    await prefs.setString(_keyUserEmail, user['Email'] as String);
    await prefs.setString(_keyUserInitials, user['AvatarInitials'] as String? ?? '');
    await prefs.setString(_keyUserColor, user['AvatarColor'] as String? ?? '#8B2FC9');
  }

  String dioErrorMessage(Object e) {
    if (e is DioException && e.response != null) {
      return e.response!.data['message'] ?? 'Lỗi không xác định';
    }
    return 'Không thể kết nối server';
  }
}
