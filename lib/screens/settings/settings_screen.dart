import 'package:auto_route/auto_route.dart';
import 'package:cloud_authenticator/providers/auth/auth_provider.dart';
import 'package:cloud_authenticator/providers/security/biometric_provider.dart';
import 'package:cloud_authenticator/providers/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';

@RoutePage()
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // theme providers
    final darkTheme = ref.watch(darkThemeProvider).value;
    final systemTheme = ref.watch(systemThemeProvider).value;
    final materialTheme = ref.watch(materialThemeProvider).value;
    final isBiometricEnabled = ref.watch(biometricProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          const SettingsHeader(title: 'Security'),
          ListTile(
            leading: const Icon(Icons.fingerprint),
            title: const Text('Use Biometrics'),
            subtitle: const Text('Require fingerprint to unlock app'),
            trailing: Switch(
              value: isBiometricEnabled == true,
              onChanged: (value) async {
                final localAuth = LocalAuthentication();
                bool didAuthenticate = await localAuth.authenticate(
                  localizedReason: 'Verify to enable authentication',
                );

                if (!didAuthenticate) {
                  return;
                }

                // toggle biometric choice
                ref.read(biometricProvider.notifier).toggleChoice();
              },
            ),
          ),
          const SettingsHeader(title: 'Theme'),
          ListTile(
            leading: const Icon(Icons.phone_android_outlined),
            title: const Text('Follow System'),
            trailing: Switch(
              value: systemTheme == true,
              onChanged: (_) {
                ref.read(systemThemeProvider.notifier).toggleTheme();
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dark_mode_outlined),
            title: const Text('Dark Mode'),
            trailing: Switch(
              value: darkTheme == true,
              onChanged: systemTheme == true
                  ? null
                  : (_) {
                      ref.read(darkThemeProvider.notifier).toggleTheme();
                    },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.waves),
            title: const Text('Material Theme'),
            subtitle: const Text('Use colors from wallpaper'),
            trailing: Switch(
              value: materialTheme == true,
              onChanged: (_) {
                ref.read(materialThemeProvider.notifier).toggleTheme();
              },
            ),
          ),
          const SettingsHeader(title: 'Backup'),
          ListTile(
            leading: const Icon(Icons.file_download_rounded),
            title: const Text('Import from device'),
            onTap: () {
              context.router.pushNamed('/backup');
            },
          ),
          ListTile(
            leading: const Icon(Icons.upload_file),
            title: const Text('Export to device'),
            onTap: () {
              context.router.pushNamed('/backup/export');
            },
          ),
          const SettingsHeader(title: 'Account'),
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text('Sign Out'),
            onTap: () async {
              final confirmSignOut = await showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Sign Out'),
                    content: const Text('Are you sure you want to sign out?'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(false);
                        },
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(true);
                        },
                        child: const Text('Sign Out'),
                      ),
                    ],
                  );
                },
              );

              if (confirmSignOut) {
                try {
                  await ref.read(firebaseAuthProvider.notifier).signOut();

                  if (context.mounted) {
                    context.router.replaceNamed('/sign-in');
                  }
                } catch (error) {
                  // ignore: avoid_print
                  print(error);
                }
              }
            },
          ),
        ],
      ),
    );
  }
}

class SettingsHeader extends StatelessWidget {
  const SettingsHeader({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
