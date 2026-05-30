/// Low-level exceptions thrown by data sources. They are caught at the
/// repository boundary and mapped to [Failure] via `failure_mapper.dart`.
/// Presentation never sees these — it only deals with `Either<Failure, T>`.
library;

/// Base for all app-thrown exceptions.
sealed class AppException implements Exception {
  const AppException(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// Non-2xx HTTP response (5xx, unexpected 4xx).
class ServerException extends AppException {
  const ServerException([super.message = 'Server error', this.statusCode]);

  final int? statusCode;
}

/// No connectivity / socket / timeout.
class NetworkException extends AppException {
  const NetworkException([super.message = 'Network error']);
}

/// 401 / invalid credentials / expired token.
class AuthException extends AppException {
  const AuthException([super.message = 'Authentication error']);
}

/// 429 — OpenSky rate / credit limit reached.
class RateLimitException extends AppException {
  const RateLimitException([super.message = 'Rate limit exceeded']);
}

/// Local cache / storage read-write failure.
class CacheException extends AppException {
  const CacheException([super.message = 'Cache error']);
}

/// Location services disabled or permission denied.
class LocationException extends AppException {
  const LocationException([super.message = 'Location error']);
}
