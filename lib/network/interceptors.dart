import 'dart:async';
import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../global/env.dart';
import 'tokenStore.dart';

/// Interceptor that automatically attaches the access token to requests and
/// refreshes it transparently when a 401 is encountered. Uses a shared
/// [Dio] instance and guards concurrent refresh attempts with a cached [Future].
class AuthInterceptor extends QueuedInterceptor {
  final Ref ref;
  final Dio _dio;

  /// Cached refresh call to ensure only a single refresh request executes at a
  /// time. Subsequent calls await this future.
  Future<TokenPair?>? _refreshFuture;

  AuthInterceptor(this.ref, this._dio);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Skip auth on refresh requests.
    if (options.extra['noAuth'] == true) {
      handler.next(options);
      return;
    }

    final token = ref.read(tokenStoreProvider)?.accessToken;
    if (token != null && (options.headers['Authorization'] as String?) == null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      final refresh = ref.read(tokenStoreProvider)?.refreshToken;
      if (refresh != null) {
        try {
          // If a refresh is already in progress, wait for it.
          _refreshFuture ??= _refreshToken(refresh);
          final tokenPair = await _refreshFuture!;

          if (tokenPair != null) {
            // Save the new token.
            ref.read(tokenStoreProvider.notifier).save(tokenPair);

            // Retry the failed request with the new access token.
            final request = err.requestOptions;
            request.headers['Authorization'] = 'Bearer ${tokenPair.accessToken}';

            final retryResponse = await _dio.fetch(request);
            return handler.resolve(retryResponse);
          }
        } catch (_) {
          // fall through to clear tokens and propagate error
        } finally {
          // Always reset for the next time.
          _refreshFuture = null;
        }

        // Refresh failed: clear tokens and propagate error.
        ref.read(tokenStoreProvider.notifier).save(null);
        return handler.next(err);
      }
    }
    return handler.next(err);
  }

  /// Performs the refresh token call using the shared [_dio] instance but with
  /// interceptors disabled so it doesn't trigger itself.
  Future<TokenPair?> _refreshToken(String refresh) async {
    try {
      final res = await _dio.post(
        '/auth/refresh',
        data: {'refresh_token': refresh},
        options: Options(extra: {'noAuth': true}),
      );
      final newAccess = res.data['access_token'] as String?;
      if (newAccess != null) {
        return TokenPair(newAccess, refresh);
      }
    } catch (_) {
      // swallow errors; caller handles null
    }
    return null;
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
