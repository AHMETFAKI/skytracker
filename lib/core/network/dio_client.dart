import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import 'retry_interceptor.dart';

/// Factory for the app's configured [Dio] instance. Registered in DI via
/// [registerDio]; the OpenSky [AuthInterceptor] is attached in Phase 3 once
/// token handling exists.
@module
abstract class DioModule {
  @lazySingleton
  Dio dio() {
    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 20),
        headers: {'Accept': 'application/json'},
      ),
    );

    dio.interceptors.add(RetryInterceptor(dio: dio));

    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(
          logPrint: (Object o) => debugPrint(o.toString()),
        ),
      );
    }

    return dio;
  }
}
