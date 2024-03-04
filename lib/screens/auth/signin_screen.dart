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

  bool _isSigningIn = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final firebaseAuth = ref.read(firebaseAuthProvider.notifier);

    Future<void> signIn(String email, String password) async {
      await firebaseAuth.signIn(email, password);
    }

    Future<void> createAccount(String email, String password) async {
      await firebaseAuth.createAccount(email, password);
    }

    Future<void> authenticate(String email, String password) async {
      if (_formKey.currentState!.validate()) {
        try {
          _isSigningIn
              ? await signIn(email, password)
              : await createAccount(email, password);

          if (context.mounted) {
            context.router.replaceNamed('/home');
          }
        } catch (error) {
          // ignore: avoid_print
          print(error);
        }
      }
    }

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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(label: Text('Password')),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  } else if (value.length < 6) {
                    return 'Password must be at least 6 characters long';
                  }
                  return null;
                },
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                await authenticate(
                  _emailController.text.trim(),
                  _passwordController.text.trim(),
                );
              },
              child:
                  _isSigningIn ? const Text('Sign In') : const Text('Register'),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                setState(() {
                  _isSigningIn = !_isSigningIn;
                });
              },
              child: _isSigningIn
                  ? const Text('Don\'t have an account? Register')
                  : const Text('Already have an account? Sign in'),
            ),
          ],
        ),
      ),
    );
  }
}
