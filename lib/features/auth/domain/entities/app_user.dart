import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_user.freezed.dart';

/// An authenticated user in the app's domain vocabulary. Built from the
/// Firebase user plus the `users/{uid}` Firestore profile document.
///
/// [createdAt] is null until the profile document has been read (the Firebase
/// auth record alone does not carry it).
@freezed
sealed class AppUser with _$AppUser {
  const factory AppUser({
    required String uid,
    required String email,
    required String fullName,
    DateTime? createdAt,
  }) = _AppUser;
}
