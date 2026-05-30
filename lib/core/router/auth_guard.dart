import 'package:auto_route/auto_route.dart';

import '../../features/auth/domain/repositories/i_auth_repository.dart';
import '../di/injection.dart';
import '../firebase/firebase_init.dart';
import 'app_router.dart';

/// Gates the home shell behind authentication — but only when Firebase is
/// actually configured. In the mock-first flow (no Firebase) the app must run
/// without sign-in, so the guard lets navigation through.
class AuthGuard extends AutoRouteGuard {
  const AuthGuard();

  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    final bypass =
        !isFirebaseReady || getIt<IAuthRepository>().currentUser != null;
    if (bypass) {
      resolver.next();
    } else {
      resolver.redirectUntil(const LoginRoute());
    }
  }
}
