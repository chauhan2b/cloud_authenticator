import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../screens/auth/password_reset_screen.dart';
import '../screens/auth/signin_screen.dart';
import '../screens/home_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/totp/components/qr_view.dart';
import '../screens/totp/totp_codes_screen.dart';
import 'auth_guard.dart';

part 'app_router.gr.dart';
part 'app_router.g.dart';

@AutoRouterConfig(replaceInRouteName: 'Screen,Route')
class AppRouter extends RootStackRouter {
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
      AutoRoute(page: PasswordResetRoute.page, path: '/password-reset'),
    ];
  }
}

@riverpod
// ignore: unsupported_provider_value
AppRouter appRouter(AppRouterRef ref, AuthGuard authGuard) {
  return AppRouter(authGuard: authGuard);
}
