import 'package:auto_route/auto_route.dart';
import 'package:cloud_authenticator/screens/settings/settings_screen.dart';
import 'package:cloud_authenticator/screens/totp/totp_codes_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/theme/theme_provider.dart';

@RoutePage()
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    TOTPCodesScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final darkTheme = ref.watch(darkThemeProvider).value;

    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (value) {
          setState(() {
            _currentIndex = value;
          });
        },
        selectedIndex: _currentIndex,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.vpn_key_outlined),
            selectedIcon: Icon(Icons.vpn_key),
            label: 'My Codes',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        backgroundColor: darkTheme == true
            ? Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.2)
            : Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.4),
      ),
    );
  }
}
