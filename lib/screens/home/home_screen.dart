import 'package:auto_route/auto_route.dart';
import 'package:cloud_authenticator/providers/auth/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@RoutePage()
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future<void> signOut() async {
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen'),
        actions: [
          IconButton(
            onPressed: signOut,
            icon: const Icon(Icons.exit_to_app),
          ),
        ],
      ),
      body: const Center(
        child: Text("Your auth codes will appear here."),
      ),
    );
  }
}
