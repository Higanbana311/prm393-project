import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'auth_service.dart';

// Chrome/web → localhost | Android emulator → 10.0.2.2 | Thiết bị thật → IP máy tính
String get kBaseUrl => kIsWeb
    ? 'http://localhost:3000/api'
    : 'http://10.0.2.2:3000/api';

class ApiClient {
  ApiClient._();
  static final ApiClient instance = ApiClient._();

  late final Dio _dio = Dio(BaseOptions(
    baseUrl: kBaseUrl, // evaluated at first access, after kIsWeb is known
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {'Content-Type': 'application/json'},
  ))..interceptors.add(_AuthInterceptor());

  Dio get dio => _dio;
}

class _AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await AuthService.instance.getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}
