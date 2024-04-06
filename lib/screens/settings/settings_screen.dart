import 'package:auto_route/auto_route.dart';
import 'package:cloud_authenticator/providers/auth/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@RoutePage()
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.dark_mode_outlined),
            title: const Text('Dark Mode'),
            trailing: Switch(
              value: false,
              onChanged: (value) {},
            ),
          ),
          ListTile(
            leading: const Icon(Icons.phone_android_outlined),
            title: const Text('Follow System'),
            trailing: Switch(
              value: false,
              onChanged: (value) {},
            ),
          ),
          ListTile(
            leading: const Icon(Icons.waves),
            title: const Text('Use Material Theme'),
            trailing: Switch(
              value: false,
              onChanged: (value) {},
            ),
          ),
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text('Sign Out'),
            onTap: () async {
              try {
                await ref.read(firebaseAuthProvider.notifier).signOut();

                if (context.mounted) {
                  context.router.replaceNamed('/sign-in');
                }
              } catch (error) {
                // ignore: avoid_print
                print(error);
              }
            },
          ),
        ],
      ),
    );
  }
}
