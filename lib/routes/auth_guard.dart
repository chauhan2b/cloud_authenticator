import 'package:auto_route/auto_route.dart';
import 'package:cloud_authenticator/providers/auth/auth_provider.dart';
import 'package:cloud_authenticator/routes/app_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_guard.g.dart';

class AuthGuard extends AutoRouteGuard {
  AuthGuard({required this.ref});
  final Ref ref;

  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) async {
    final user = await ref.read(authStateProvider.future);
    final authenticated = user != null;

    if (authenticated) {
      resolver.next(true);
    } else {
      resolver.redirect(const SignInRoute());
    }
  }
}

@riverpod
AuthGuard authGuard(AuthGuardRef ref) {
  return AuthGuard(ref: ref);
}
