import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

/// Loads and edits the signed-in user's `users/{uid}` profile. `build` throws
/// the domain [Failure] on read errors so the UI can render it via AsyncError.
class ProfileController extends AsyncNotifier<AppUser> {
  @override
  Future<AppUser> build() async {
    final repo = ref.read(authRepositoryProvider);
    final uid = repo.currentUser?.uid;
    if (uid == null) throw const Failure.auth();
    final result = await repo.getProfile(uid);
    return result.match((failure) => throw failure, (user) => user);
  }

  Future<bool> updateFullName(String fullName) async {
    final repo = ref.read(authRepositoryProvider);
    final uid = repo.currentUser?.uid;
    if (uid == null) return false;
    state = const AsyncLoading();
    final result = await repo.updateFullName(uid: uid, fullName: fullName);
    state = result.match(
      (failure) => AsyncError(failure, StackTrace.current),
      AsyncData.new,
    );
    return result.isRight();
  }
}

final profileControllerProvider =
    AsyncNotifierProvider<ProfileController, AppUser>(ProfileController.new);
