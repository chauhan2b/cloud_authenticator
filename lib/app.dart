import 'package:cloud_authenticator/routes/app_router.dart';
import 'package:cloud_authenticator/routes/auth_guard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authGuard = ref.read(authGuardProvider);
    final appRouter = ref.read(appRouterProvider(authGuard));
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter.config(),
    );
  }
}
