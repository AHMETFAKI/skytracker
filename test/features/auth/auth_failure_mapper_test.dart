import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skytracker/core/error/failure.dart';
import 'package:skytracker/features/auth/data/auth_failure_mapper.dart';

void main() {
  group('AuthFailureMapper.fromAuth', () {
    Failure map(String code) =>
        AuthFailureMapper.fromAuth(FirebaseAuthException(code: code));

    test('maps invalid-credential to AuthFailure with localized key', () {
      final failure = map('invalid-credential');
      expect(failure, isA<AuthFailure>());
      expect(failure.i18nKey, 'error.invalidCredentials');
    });

    test('maps email-already-in-use to its key', () {
      expect(map('email-already-in-use').i18nKey, 'error.emailInUse');
    });

    test('maps weak-password to its key', () {
      expect(map('weak-password').i18nKey, 'error.weakPassword');
    });

    test('maps network-request-failed to NetworkFailure', () {
      expect(map('network-request-failed'), isA<NetworkFailure>());
    });

    test('falls back to generic auth key for unknown codes', () {
      expect(map('something-else').i18nKey, 'error.auth');
    });
  });
}
