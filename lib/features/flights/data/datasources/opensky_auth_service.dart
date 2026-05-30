import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/access_token_provider.dart';

/// Obtains and caches an OpenSky OAuth2 access token (Client Credentials flow).
/// Tokens live ~30 min; this caches them in secure storage with their expiry
/// and refreshes only when missing/expired or explicitly invalidated on 401.
@LazySingleton(as: AccessTokenProvider, env: ['remote'])
class OpenSkyAuthService implements AccessTokenProvider {
  OpenSkyAuthService(this._config, this._storage)
      : _tokenDio = Dio(
          BaseOptions(
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 15),
          ),
        );

  final AppConfig _config;
  final FlutterSecureStorage _storage;
  final Dio _tokenDio;

  static const String _tokenEndpoint =
      'https://auth.opensky-network.org/auth/realms/opensky-network/protocol/openid-connect/token';
  static const String _tokenKey = 'opensky_access_token';
  static const String _expiryKey = 'opensky_token_expiry';

  // Refresh slightly early so a token never expires mid-flight.
  static const Duration _expirySkew = Duration(seconds: 30);

  String? _cachedToken;
  DateTime? _cachedExpiry;

  /// Returns a valid bearer token, fetching a fresh one if needed.
  @override
  Future<String> getToken() async {
    final existing = await _readValidToken();
    if (existing != null) return existing;
    return _fetchAndStore();
  }

  /// Drops the cached token so the next [getToken] forces a refresh. Called by
  /// the auth interceptor on a 401.
  @override
  Future<void> invalidate() async {
    _cachedToken = null;
    _cachedExpiry = null;
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _expiryKey);
  }

  Future<String?> _readValidToken() async {
    if (_cachedToken != null && _isFresh(_cachedExpiry)) {
      return _cachedToken;
    }

    final token = await _storage.read(key: _tokenKey);
    final expiryRaw = await _storage.read(key: _expiryKey);
    if (token == null || expiryRaw == null) return null;

    final expiry = DateTime.tryParse(expiryRaw);
    if (!_isFresh(expiry)) return null;

    _cachedToken = token;
    _cachedExpiry = expiry;
    return token;
  }

  bool _isFresh(DateTime? expiry) =>
      expiry != null && DateTime.now().isBefore(expiry.subtract(_expirySkew));

  Future<String> _fetchAndStore() async {
    if (!_config.hasOpenSkyCredentials) {
      throw const AuthException('Missing OpenSky client credentials');
    }

    try {
      final response = await _tokenDio.post<Map<String, dynamic>>(
        _tokenEndpoint,
        data: {
          'grant_type': 'client_credentials',
          'client_id': _config.openSkyClientId,
          'client_secret': _config.openSkyClientSecret,
        },
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
        ),
      );

      final body = response.data ?? const {};
      final token = body['access_token'] as String?;
      final expiresIn = (body['expires_in'] as num?)?.toInt() ?? 1800;
      if (token == null || token.isEmpty) {
        throw const AuthException('OpenSky token response missing access_token');
      }

      final expiry = DateTime.now().add(Duration(seconds: expiresIn));
      _cachedToken = token;
      _cachedExpiry = expiry;
      await _storage.write(key: _tokenKey, value: token);
      await _storage.write(key: _expiryKey, value: expiry.toIso8601String());

      return token;
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status == 401 || status == 403) {
        throw const AuthException('Invalid OpenSky credentials');
      }
      rethrow;
    }
  }
}
