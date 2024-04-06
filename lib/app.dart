import 'package:cloud_authenticator/providers/theme/app_color_scheme.dart';
import 'package:cloud_authenticator/providers/theme/theme_provider.dart';
import 'package:cloud_authenticator/routes/app_router.dart';
import 'package:cloud_authenticator/routes/auth_guard.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // auto route providers
    final authGuard = ref.watch(authGuardProvider);
    final appRouter = ref.watch(appRouterProvider(authGuard));

    // theme providers
    final appColorScheme = ref.watch(appColorSchemeProvider.notifier);
    final darkTheme = ref.watch(darkThemeProvider).value;
    final systemTheme = ref.watch(systemThemeProvider).value;
    final materialTheme = ref.watch(materialThemeProvider).value;

    return DynamicColorBuilder(
      builder: (lightColorScheme, darkColorScheme) => MaterialApp.router(
        debugShowCheckedModeBanner: false,
        routerConfig: appRouter.config(),
        theme: materialTheme == true
            ? appColorScheme.lightColorScheme(lightColorScheme)
            : appColorScheme.defaultLightColorScheme(),
        darkTheme: darkTheme == true
            ? appColorScheme.darkColorScheme(darkColorScheme)
            : appColorScheme.defaultDarkColorScheme(),
        themeMode: systemTheme == true
            ? ThemeMode.system
            : darkTheme == true
                ? ThemeMode.dark
                : ThemeMode.light,
      ),
    );
  }
}
