import 'package:auto_route/auto_route.dart';
import 'package:injectable/injectable.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/flights/presentation/pages/flight_map_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/shell/presentation/pages/home_shell_page.dart';
import 'auth_guard.dart';

part 'app_router.gr.dart';

/// Central route table. The home shell hosts the Map / Profile tabs and is
/// gated by [AuthGuard] (which is a no-op when Firebase is not configured).
@AutoRouterConfig(replaceInRouteName: 'Page,Route')
@singleton
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
        AutoRoute(
          page: HomeShellRoute.page,
          initial: true,
          guards: const [AuthGuard()],
          children: [
            AutoRoute(page: FlightMapRoute.page, initial: true),
            AutoRoute(page: ProfileRoute.page),
          ],
        ),
        AutoRoute(page: LoginRoute.page),
        AutoRoute(page: RegisterRoute.page),
      ];
}
