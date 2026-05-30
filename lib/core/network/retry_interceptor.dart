import 'dart:async';

import 'package:dio/dio.dart';

/// Retries transient failures with bounded exponential backoff. Targets 429
/// (OpenSky credit limit) and timeout/connection errors. After exhausting
/// retries the original [DioException] propagates and the FailureMapper turns
/// it into a [RateLimitFailure] / [NetworkFailure].
class RetryInterceptor extends Interceptor {
  RetryInterceptor({
    required Dio dio,
    this.maxRetries = 3,
    this.baseDelay = const Duration(milliseconds: 500),
  }) : _dio = dio;

  final Dio _dio;
  final int maxRetries;
  final Duration baseDelay;

  static const _retryCountKey = 'retry_count';

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final attempt = (err.requestOptions.extra[_retryCountKey] as int?) ?? 0;

    if (!_shouldRetry(err) || attempt >= maxRetries) {
      return handler.next(err);
    }

    final delay = baseDelay * (1 << attempt); // 0.5s, 1s, 2s
    await Future<void>.delayed(delay);

    final options = err.requestOptions
      ..extra[_retryCountKey] = attempt + 1;

    try {
      final response = await _dio.fetch<dynamic>(options);
      return handler.resolve(response);
    } on DioException catch (e) {
      return handler.next(e);
    }
  }

  bool _shouldRetry(DioException err) {
    if (err.response?.statusCode == 429) return true;
    return switch (err.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.connectionError =>
        true,
      _ => false,
    };
  }
}
