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

  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  bool isEmailFocused = false;
  bool isPasswordFocused = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _emailFocusNode.addListener(() {
      setState(() {
        isEmailFocused = _emailFocusNode.hasFocus;
      });
    });
    _passwordFocusNode.addListener(() {
      setState(() {
        isPasswordFocused = _passwordFocusNode.hasFocus;
      });
    });
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

    // listen for changes in the authentication state and display an error dialog
    ref.listen<AsyncValue>(firebaseAuthProvider, (_, state) {
      if (!state.isLoading && state.hasError) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Error'),
              content: Text(state.error.toString()),
              actions: [
                TextButton(
                  onPressed: () {
                    context.router.maybePop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    });

    return Scaffold(
      body: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _isSigningIn
                ? const Text(
                    'Sign In',
                    style: TextStyle(fontSize: 32),
                  )
                : const Text(
                    'Register',
                    style: TextStyle(fontSize: 32),
                  ),
            _isSigningIn
                ? Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Good to see you again!',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 16, color: Colors.grey.shade700),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Welcome! Let\'s get you set up.',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 16, color: Colors.grey.shade700),
                    ),
                  ),
            const SizedBox(
              height: 50,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 18.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Email',
                  style: isEmailFocused
                      ? TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold)
                      : null,
                ),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: TextFormField(
                controller: _emailController,
                focusNode: _emailFocusNode,
                decoration: InputDecoration(
                  hintText: 'Email',
                  filled: true,
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 18.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Password',
                  style: isPasswordFocused
                      ? TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold)
                      : null,
                ),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: TextFormField(
                controller: _passwordController,
                obscureText: true,
                focusNode: _passwordFocusNode,
                decoration: InputDecoration(
                  hintText: 'Password',
                  filled: true,
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  } else if (value.length < 6) {
                    return 'Password must be at least 6 characters long';
                  }
                  return null;
                },
                onFieldSubmitted: (_) {
                  authenticate(
                    _emailController.text.trim(),
                    _passwordController.text.trim(),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () async {
                    await authenticate(
                      _emailController.text.trim(),
                      _passwordController.text.trim(),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    foregroundColor: Colors.white,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isSigningIn
                      ? const Text('Sign In')
                      : const Text('Register'),
                ),
              ),
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
