import 'package:dio/dio.dart';

import 'exceptions.dart';
import 'failure.dart';

/// Translates low-level exceptions into domain [Failure]s. Called at the
/// repository boundary so the rest of the app deals only in `Failure`.
abstract final class FailureMapper {
  const FailureMapper._();

  /// Maps any caught error into a [Failure]. Handles [AppException],
  /// [DioException], and unknown errors.
  static Failure map(Object error) {
    return switch (error) {
      final AppException e => _fromAppException(e),
      final DioException e => _fromDioException(e),
      _ => const Failure.unknown(),
    };
  }

  static Failure _fromAppException(AppException e) {
    return switch (e) {
      ServerException(:final statusCode) =>
        Failure.server(statusCode: statusCode),
      NetworkException() => const Failure.network(),
      AuthException() => const Failure.auth(),
      RateLimitException() => const Failure.rateLimit(),
      CacheException() => const Failure.cache(),
      LocationException() => const Failure.location(),
    };
  }

  static Failure _fromDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return const Failure.network();
      case DioExceptionType.badCertificate:
      case DioExceptionType.cancel:
      case DioExceptionType.unknown:
        return const Failure.unknown();
      case DioExceptionType.badResponse:
        final status = e.response?.statusCode;
        return switch (status) {
          401 || 403 => const Failure.auth(),
          429 => const Failure.rateLimit(),
          _ => Failure.server(statusCode: status),
        };
    }
  }
}
