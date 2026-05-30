import 'package:auto_route/auto_route.dart';
import 'package:injectable/injectable.dart';

import '../../features/flights/presentation/pages/flight_map_page.dart';

part 'app_router.gr.dart';

/// Central route table. Routes are added per feature as phases land
/// (auth → Phase 5, shell/profile → Phase 6). [AuthGuard] is attached in
/// Phase 5 once auth state exists.
@AutoRouterConfig(replaceInRouteName: 'Page,Route')
@singleton
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
        AutoRoute(page: FlightMapRoute.page, initial: true),
      ];
}
