// lib/services/dio_client.dart
import 'package:dio/dio.dart';

Dio createDio() {
  final dio = Dio(BaseOptions(
    baseUrl: 'https://api.raalc.ae/api/app',
    connectTimeout: const Duration(seconds: 20),
    receiveTimeout: const Duration(seconds: 20),
    headers: {'Content-Type': 'application/json'},
  ));

  dio.interceptors.add(LogInterceptor(
    requestBody: true,
    responseBody: true,
    requestHeader: false,
    responseHeader: false,
  ));

  return dio;
}
