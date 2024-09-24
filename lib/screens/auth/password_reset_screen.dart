import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

import '../../providers/auth/auth_provider.dart';

@RoutePage()
class PasswordResetScreen extends ConsumerWidget {
  PasswordResetScreen({super.key});

  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Password Reset'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                FormBuilder(
                  key: _formKey,
                  child: TextFormField(
                    controller: _controller,
                    autofocus: true,
                    keyboardType: TextInputType.emailAddress,
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
                      fillColor: Colors.grey.withOpacity(0.2),
                    ),
                    validator: FormBuilderValidators.email(),
                    onFieldSubmitted: (value) {
                      if (_formKey.currentState!.saveAndValidate()) {
                        // send password reset email
                        ref
                            .read(firebaseAuthProvider.notifier)
                            .resetPassword(value);

                        // show dialog box to notify user that email has been sent
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Email Sent'),
                            content: const Text(
                                'Check your email address for a password reset link.'),
                            actions: [
                              TextButton(
                                onPressed: () => context.router.maybePop(),
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(height: 16.0),
                const Text(
                    'We will send you an email. Follow the instructions to reset your password.'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
