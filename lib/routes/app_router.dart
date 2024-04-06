import 'package:auto_route/auto_route.dart';
import 'package:cloud_authenticator/routes/auth_guard.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../screens/totp/totp_codes_screen.dart';
import '../screens/totp/components/qr_view.dart';
import '../screens/auth/signin_screen.dart';
import '../screens/home_screen.dart';
import '../screens/settings/settings_screen.dart';

part 'app_router.gr.dart';
part 'app_router.g.dart';

@AutoRouterConfig(replaceInRouteName: 'Screen,Route')
class AppRouter extends _$AppRouter {
  @override
  late List<AutoRoute> routes = [];
  final AuthGuard authGuard;

  AppRouter({super.navigatorKey, required this.authGuard}) {
    routes = [
      AutoRoute(
        page: HomeRoute.page,
        path: '/home',
        initial: true,
        guards: [authGuard],
      ),
      AutoRoute(
        page: TOTPCodesRoute.page,
        path: '/totp-codes',
      ),
      AutoRoute(page: SettingsRoute.page, path: '/settings'),
      AutoRoute(page: SignInRoute.page, path: '/sign-in'),
      AutoRoute(page: QRViewRoute.page, path: '/qr-view'),
    ];
  }
}

@riverpod
// ignore: unsupported_provider_value
AppRouter appRouter(AppRouterRef ref, AuthGuard authGuard) {
  return AppRouter(authGuard: authGuard);
}
