import '../../../core/di/injection.dart';
import '../../../core/firebase/firebase_init.dart';
import '../domain/repositories/i_auth_repository.dart';
import 'remember_me_store.dart';

/// Enforces the "Remember Me" choice on cold start. Firebase keeps the session
/// on device unconditionally, so when the user did not opt in we sign them out
/// before the first frame. No-op when Firebase is not configured.
Future<void> enforceRememberMeOnStartup() async {
  if (!isFirebaseReady) return;
  if (getIt<RememberMeStore>().rememberMe) return;
  await getIt<IAuthRepository>().logout();
}
