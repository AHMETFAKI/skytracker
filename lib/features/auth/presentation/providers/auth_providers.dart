import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/di/injection.dart';
import '../../data/remember_me_store.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/i_auth_repository.dart';

/// Resolves the DI-registered auth repository.
final authRepositoryProvider = Provider<IAuthRepository>(
  (_) => getIt<IAuthRepository>(),
);

final rememberMeStoreProvider = Provider<RememberMeStore>(
  (_) => getIt<RememberMeStore>(),
);

/// Reactive auth identity: null when signed out, otherwise the current user
/// (identity only — profile detail is fetched per screen).
final authStateProvider = StreamProvider<AppUser?>(
  (ref) => ref.watch(authRepositoryProvider).authStateChanges(),
);

/// Drives the login/register/logout actions and exposes loading/error state
/// for the forms. On failure, `state.error` holds the domain `Failure`.
class AuthController extends AsyncNotifier<void> {
  @override
  void build() {}

  IAuthRepository get _repo => ref.read(authRepositoryProvider);
  RememberMeStore get _remember => ref.read(rememberMeStoreProvider);

  Future<bool> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    final result = await _repo.register(
      fullName: fullName,
      email: email,
      password: password,
    );
    final success = result.isRight();
    if (success) await _remember.setRememberMe(value: true);
    state = result.match(
      (failure) => AsyncError(failure, StackTrace.current),
      (_) => const AsyncData(null),
    );
    return success;
  }

  Future<bool> login({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    state = const AsyncLoading();
    final result = await _repo.login(email: email, password: password);
    final success = result.isRight();
    if (success) await _remember.setRememberMe(value: rememberMe);
    state = result.match(
      (failure) => AsyncError(failure, StackTrace.current),
      (_) => const AsyncData(null),
    );
    return success;
  }

  Future<void> logout() async {
    await _repo.logout();
    await _remember.setRememberMe(value: false);
    state = const AsyncData(null);
  }
}

final authControllerProvider =
    AsyncNotifierProvider<AuthController, void>(AuthController.new);
