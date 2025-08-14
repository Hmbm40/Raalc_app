// lib/services/auth_api.dart
import 'package:dio/dio.dart';
import 'dioClient.dart';

class AuthApi {
  AuthApi(this._dio);
  final Dio _dio;

  static final instance = AuthApi(createDio());

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    final res = await _dio.post('/register', data: {
      'name': name,
      'email': email,
      'phone': phone,
      'password': password,
      'password_confirmation': password,
    });
    return (res.data is Map) ? Map<String, dynamic>.from(res.data) : {'raw': res.data};
  }

  Future<Map<String, dynamic>> saveRegisterData({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String otp,           // user-entered
    String? otpToken,              // backend-issued opaque token if available
  }) async {
    final body = {
      'name': name,
      'email': email,
      'phone': phone,
      'password': password,
      'password_confirmation': password,
      'otp': otp,
      if (otpToken != null) 'otp_token': otpToken,
    };
    final res = await _dio.post('/save_register_data', data: body);
    return (res.data is Map) ? Map<String, dynamic>.from(res.data) : {'raw': res.data};
  }
}
