import 'package:dio/dio.dart';

import 'access_token_provider.dart';

/// Attaches a bearer token to outgoing requests and transparently refreshes it
/// once on a 401. Token acquisition is delegated to an [AccessTokenProvider].
class AuthInterceptor extends Interceptor {
  AuthInterceptor({required AccessTokenProvider tokenProvider, required Dio dio})
      : _tokenProvider = tokenProvider,
        _dio = dio;

  final AccessTokenProvider _tokenProvider;
  final Dio _dio;

  static const _retriedKey = 'auth_retried';

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      final token = await _tokenProvider.getToken();
      options.headers['Authorization'] = 'Bearer $token';
      return handler.next(options);
    } on Object catch (e) {
      return handler.reject(
        DioException(requestOptions: options, error: e),
        true,
      );
    }
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final isAuthError = err.response?.statusCode == 401;
    final alreadyRetried =
        err.requestOptions.extra[_retriedKey] == true;

    if (!isAuthError || alreadyRetried) {
      return handler.next(err);
    }

    try {
      await _tokenProvider.invalidate();
      final token = await _tokenProvider.getToken();

      final options = err.requestOptions
        ..extra[_retriedKey] = true
        ..headers['Authorization'] = 'Bearer $token';

      final response = await _dio.fetch<dynamic>(options);
      return handler.resolve(response);
    } on DioException catch (e) {
      return handler.next(e);
    } on Object catch (e) {
      return handler.next(
        DioException(requestOptions: err.requestOptions, error: e),
      );
    }
  }
}
