import 'package:auto_route/auto_route.dart';
import 'package:cloud_authenticator/providers/totp/totp_provider.dart';
import 'package:cloud_authenticator/routes/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/auth/auth_provider.dart';

@RoutePage()
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totpsAsync = ref.watch(totpProvider);

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
            onPressed: () {
              ref.read(totpProvider.notifier).addTOTP('123456');
            },
            icon: const Icon(Icons.add),
          ),
          IconButton(
            onPressed: signOut,
            icon: const Icon(Icons.exit_to_app),
          ),
        ],
      ),
      body: totpsAsync.when(
        data: (totps) => totps.isEmpty
            ? const Center(
                child: Text('Your authentication codes will appear here'),
              )
            : ListView.builder(
                itemCount: totps.length,
                itemBuilder: (context, index) => ListTile(
                  title: Text(totps[index]),
                ),
              ),
        error: (error, stackTrace) => Center(
          child: Text(error.toString()),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.router.push(const QRViewRoute());
        },
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}
