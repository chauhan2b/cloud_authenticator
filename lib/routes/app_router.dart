import 'package:auto_route/auto_route.dart';

import '../screens/home/home_screen.dart';
import '../screens/auth/signin_screen.dart';

part 'app_router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Screen,Route')
class AppRouter extends _$AppRouter {
  @override
  List<AutoRoute> get routes => [
        AutoRoute(page: HomeRoute.page, path: '/home', initial: true),
        AutoRoute(page: SignInRoute.page, path: '/sign-in')
      ];
}
