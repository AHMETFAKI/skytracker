import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skytracker/core/error/exceptions.dart';
import 'package:skytracker/core/error/failure.dart';
import 'package:skytracker/core/error/failure_mapper.dart';

void main() {
  group('FailureMapper.map — AppException', () {
    test('ServerException carries its status code', () {
      final failure = FailureMapper.map(const ServerException('boom', 503));
      expect(failure, isA<ServerFailure>());
      expect((failure as ServerFailure).statusCode, 503);
    });

    test('NetworkException -> NetworkFailure', () {
      expect(FailureMapper.map(const NetworkException()), isA<NetworkFailure>());
    });

    test('AuthException -> AuthFailure', () {
      expect(FailureMapper.map(const AuthException()), isA<AuthFailure>());
    });

    test('RateLimitException -> RateLimitFailure', () {
      expect(FailureMapper.map(const RateLimitException()), isA<RateLimitFailure>());
    });
  });

  group('FailureMapper.map — DioException', () {
    DioException badResponse(int status) => DioException(
          requestOptions: RequestOptions(path: '/states/all'),
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: RequestOptions(path: '/states/all'),
            statusCode: status,
          ),
        );

    test('401 -> AuthFailure', () {
      expect(FailureMapper.map(badResponse(401)), isA<AuthFailure>());
    });

    test('429 -> RateLimitFailure', () {
      expect(FailureMapper.map(badResponse(429)), isA<RateLimitFailure>());
    });

    test('500 -> ServerFailure with status', () {
      final failure = FailureMapper.map(badResponse(500));
      expect((failure as ServerFailure).statusCode, 500);
    });

    test('connection timeout -> NetworkFailure', () {
      final failure = FailureMapper.map(
        DioException(
          requestOptions: RequestOptions(path: '/states/all'),
          type: DioExceptionType.connectionTimeout,
        ),
      );
      expect(failure, isA<NetworkFailure>());
    });
  });

  test('unknown error -> UnknownFailure', () {
    expect(FailureMapper.map(Object()), isA<UnknownFailure>());
  });
}
