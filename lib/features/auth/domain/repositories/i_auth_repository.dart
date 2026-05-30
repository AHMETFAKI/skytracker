import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../entities/app_user.dart';

/// Auth + profile boundary. Combines Firebase Authentication (identity) with
/// the `users/{uid}` Firestore document (profile), exposed to the domain as a
/// single [AppUser].
abstract interface class IAuthRepository {
  /// Emits the current user on subscribe, then on every sign-in/sign-out.
  /// Emits null when signed out. The emitted user carries identity only;
  /// call [getProfile] for [AppUser.fullName] / [AppUser.createdAt].
  Stream<AppUser?> authStateChanges();

  /// The signed-in user's identity, or null. Synchronous snapshot.
  AppUser? get currentUser;

  /// Creates the auth account and writes the `users/{uid}` profile document.
  Future<Either<Failure, AppUser>> register({
    required String fullName,
    required String email,
    required String password,
  });

  Future<Either<Failure, AppUser>> login({
    required String email,
    required String password,
  });

  Future<Either<Failure, Unit>> logout();

  /// Reads the `users/{uid}` profile document.
  Future<Either<Failure, AppUser>> getProfile(String uid);

  /// Updates only the `fullName` field of `users/{uid}`.
  Future<Either<Failure, AppUser>> updateFullName({
    required String uid,
    required String fullName,
  });
}
