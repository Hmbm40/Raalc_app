import 'dart:async';
import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../global/env.dart';
import 'tokenStore.dart';

class AuthInterceptor extends Interceptor {
  final Ref ref;
  AuthInterceptor(this.ref);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = ref.read(tokenStoreProvider)?.accessToken;
    if (token != null && (options.headers['Authorization'] as String?) == null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future onError(DioException err, ErrorInterceptorHandler handler) async {
    // naive 401 refresh sketch (replace with your real refresh call)
    if (err.response?.statusCode == 401) {
      final refresh = ref.read(tokenStoreProvider)?.refreshToken;
      if (refresh != null) {
        try {
          // Example: request new token
          final dio = Dio(BaseOptions(baseUrl: Env.baseUrl));
          final res = await dio.post('/auth/refresh', data: {'refresh_token': refresh});
          final newAccess = res.data['access_token'] as String?;
          if (newAccess != null) {
            ref.read(tokenStoreProvider.notifier).save(TokenPair(newAccess, refresh));
            final request = err.requestOptions;
            request.headers['Authorization'] = 'Bearer $newAccess';
            final retry = await dio.fetch(request);
            return handler.resolve(retry);
          }
        } catch (_) { /* fall through */ }
      }
    }
    return handler.next(err);
  }
}

class LoggerInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (Env.enableLogs) {
      // ignore: avoid_print
      print('→ ${options.method} ${options.uri}');
    }
    handler.next(options);
  }
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (Env.enableLogs) {
      // ignore: avoid_print
      print('← ${response.statusCode} ${response.requestOptions.uri}');
    }
    handler.next(response);
  }
}
