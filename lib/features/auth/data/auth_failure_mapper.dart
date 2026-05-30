import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/error/failure.dart';

/// Translates Firebase exceptions into domain [Failure]s with localized keys,
/// so presentation never sees a raw `FirebaseAuthException`.
abstract final class AuthFailureMapper {
  const AuthFailureMapper._();

  static Failure fromAuth(FirebaseAuthException e) {
    if (e.code == 'network-request-failed') return const Failure.network();
    final key = switch (e.code) {
      'invalid-email' => 'error.invalidEmail',
      'user-disabled' => 'error.userDisabled',
      'user-not-found' ||
      'wrong-password' ||
      'invalid-credential' =>
        'error.invalidCredentials',
      'email-already-in-use' => 'error.emailInUse',
      'weak-password' => 'error.weakPassword',
      'too-many-requests' => 'error.tooManyRequests',
      _ => 'error.auth',
    };
    return Failure.auth(i18nKey: key);
  }

  static Failure fromFirestore(FirebaseException e) {
    return switch (e.code) {
      'permission-denied' => const Failure.auth(),
      'unavailable' => const Failure.network(),
      _ => const Failure.server(),
    };
  }
}
