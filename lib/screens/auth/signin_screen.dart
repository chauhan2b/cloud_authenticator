import 'package:auto_route/auto_route.dart';
import 'package:cloud_authenticator/providers/auth/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@RoutePage()
class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(label: Text('Email')),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(label: Text('Password')),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await ref
                      .read(firebaseAuthProvider.notifier)
                      .signIn('test@test.com', '123456');

                  if (context.mounted) {
                    context.router.replaceNamed('/home');
                  }
                } catch (error) {
                  // ignore: avoid_print
                  print(error);
                }
              },
              child: const Text('Sign in'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                try {
                  await ref
                      .read(firebaseAuthProvider.notifier)
                      .createAccount('test@test.com', '123456');

                  if (context.mounted) {
                    context.router.replaceNamed('/home');
                  }
                } catch (error) {
                  // ignore: avoid_print
                  print(error);
                }
              },
              child: const Text('Register'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                final authState = ref.read(authStateProvider);
                // ignore: avoid_print
                print(authState.value.toString());
              },
              child: const Text('Get Auth State'),
            ),
          ],
        ),
      ),
    );
  }
}
