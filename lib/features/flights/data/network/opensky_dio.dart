import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/network/access_token_provider.dart';
import '../../../../core/network/auth_interceptor.dart';
import '../../../../core/network/retry_interceptor.dart';

/// Builds the OpenSky-bound [Dio] (base URL + OAuth + retry). Registered only
/// in the `remote` environment and named so it doesn't collide with the
/// generic core [Dio].
@module
abstract class OpenSkyDioModule {
  @Named('opensky')
  @Environment('remote')
  @lazySingleton
  Dio openSkyDio(AccessTokenProvider tokenProvider) {
    final dio = Dio(
      BaseOptions(
        baseUrl: 'https://opensky-network.org/api',
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 25),
        headers: {'Accept': 'application/json'},
      ),
    );

    dio.interceptors.add(RetryInterceptor(dio: dio));
    dio.interceptors.add(AuthInterceptor(tokenProvider: tokenProvider, dio: dio));

    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(logPrint: (Object o) => debugPrint(o.toString())),
      );
    }

    return dio;
  }
}
