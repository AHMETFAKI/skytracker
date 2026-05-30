/// Supplies bearer tokens to [AuthInterceptor]. Defined in core so the
/// interceptor stays independent of any specific auth provider; the OpenSky
/// implementation lives in the flights feature and is bound in DI.
abstract interface class AccessTokenProvider {
  /// A valid access token, fetched/refreshed as needed.
  Future<String> getToken();

  /// Drops the cached token so the next [getToken] forces a refresh.
  Future<void> invalidate();
}
