import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists the "Remember Me" choice. On mobile, Firebase Auth always keeps the
/// session on device, so this flag lets the app sign out a non-remembered user
/// on the next cold start (see bootstrap startup check).
@lazySingleton
class RememberMeStore {
  RememberMeStore(this._prefs);

  static const _key = 'auth.remember_me';

  final SharedPreferences _prefs;

  bool get rememberMe => _prefs.getBool(_key) ?? false;

  Future<void> setRememberMe({required bool value}) =>
      _prefs.setBool(_key, value);
}
