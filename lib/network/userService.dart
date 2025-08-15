// lib/network/userService.dart
import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'apiResult.dart';
import 'dioClient.dart'; // must expose: final dioProvider = Provider<Dio>((ref) => ...);

class UserDto {
  final String id;
  final String email;
  const UserDto({required this.id, required this.email});

  factory UserDto.fromJson(Map<String, dynamic> j) {
    // Defensive parsing in case backend wraps data or types vary
    final idValue = j['id'];
    final emailValue = j['email'];
    return UserDto(
      id: idValue == null ? '' : idValue.toString(),
      email: emailValue == null ? '' : emailValue.toString(),
    );
  }
}

final userServiceProvider = Provider<UserService>((ref) => UserService(ref));

class UserService {
  final Ref _ref;
  const UserService(this._ref);

  Dio get _dio => _ref.read(dioProvider);

  Future<ApiResult<UserDto>> me() async {
    try {
      final res = await _dio.get('/users/me');
      final data = res.data;

      // Handle common API shapes
      if (data is Map<String, dynamic>) {
        if (data['data'] is Map<String, dynamic>) {
          return ApiResult.ok(UserDto.fromJson(data['data'] as Map<String, dynamic>));
        }
        return ApiResult.ok(UserDto.fromJson(data));
      }

      // If backend returns an unexpected shape:
      return ApiResult.err(
        DioException.badResponse(
          statusCode: res.statusCode ?? 500,
          requestOptions: res.requestOptions,
          response: res,
        ),
      );
    } on DioException catch (e, st) {
      return ApiResult.err(e, st);
    } catch (e, st) {
      return ApiResult.err(e, st);
    }
  }
}
