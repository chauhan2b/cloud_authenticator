import 'package:auto_route/auto_route.dart';
import 'package:cloud_authenticator/routes/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/auth/auth_provider.dart';
import '../../providers/totp/secret_provider.dart';
import '../../providers/totp/totp_provider.dart';

@RoutePage()
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final secretsFuture = ref.watch(secretProvider);
    const secret = 'secret';

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
              ref.read(secretProvider.notifier).addSecret(secret);
            },
            icon: const Icon(Icons.add),
          ),
          IconButton(
            onPressed: signOut,
            icon: const Icon(Icons.exit_to_app),
          ),
        ],
      ),
      body: secretsFuture.when(
        data: (secrets) => secrets.isEmpty
            ? const Center(
                child: Text('Your authentication codes will appear here'),
              )
            : ListView.builder(
                itemCount: secrets.length,
                itemBuilder: (context, index) {
                  final secret = secrets[index];
                  final totp = ref.read(totpProvider(secret.key));
                  return ListTile(
                    title: Text(totp.code),
                    subtitle: Text(totp.issuer),
                    trailing: IconButton(
                      onPressed: () {
                        ref
                            .read(secretProvider.notifier)
                            .removeSecret(secret.id);
                      },
                      icon: const Icon(Icons.delete, color: Colors.red),
                    ),
                  );
                },
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
