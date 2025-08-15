// lib/services/authApi.dart
import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../network/dioClient.dart';   // for dioProvider
import '../network/apiResult.dart';   // for ApiResult

/// Simple auth-facing API with uniform ApiResult responses.
///
/// Usage with Riverpod:
///   final api = ref.read(authApiProvider);
///   final res = await api.register(...);
///   res.when(ok: (data) { ... }, err: (e, st) { ... });
class AuthApi {
  AuthApi(this._dio);
  final Dio _dio;

  // Endpoints
  static const _registerPath = '/register';
  static const _saveRegisterPath = '/save_register_data';

  /// Register user (initial step). Backend generally sends OTP out-of-band.
  Future<ApiResult<Map<String, dynamic>>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    CancelToken? cancelToken,
  }) async {
    final body = {
      'name': name,
      'email': email,
      'phone': phone,
      'password': password,
      'password_confirmation': password,
    };
    return _postJson(_registerPath, body, cancelToken: cancelToken);
  }

  /// Complete registration by submitting OTP (+ optional backend-issued token).
  Future<ApiResult<Map<String, dynamic>>> saveRegisterData({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String otp,           // user-entered code
    String? otpToken,              // backend-issued opaque token if available
    CancelToken? cancelToken,
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
    return _postJson(_saveRegisterPath, body, cancelToken: cancelToken);
  }

  // ────────────────────────────────────────────────────────────
  // Internals
  // ────────────────────────────────────────────────────────────

  Future<ApiResult<Map<String, dynamic>>> _postJson(
    String path,
    Map<String, dynamic> data, {
    CancelToken? cancelToken,
  }) async {
    try {
      final res = await _dio.post(
        path,
        data: data,
        options: Options(
          contentType: Headers.jsonContentType,
          responseType: ResponseType.json,
        ),
        cancelToken: cancelToken,
      );

      final payload = res.data;
      if (payload is Map) {
        return ApiResult.ok(Map<String, dynamic>.from(payload));
      }
      return ApiResult.ok(<String, dynamic>{'raw': payload});
    } on DioException catch (e, st) {
      return ApiResult.err(e, st);
    } catch (e, st) {
      return ApiResult.err(e, st);
    }
  }
}

/// Riverpod provider that injects the shared Dio from dioProvider.
final authApiProvider = Provider<AuthApi>((ref) {
  final dio = ref.watch(dioProvider);
  return AuthApi(dio);
});
