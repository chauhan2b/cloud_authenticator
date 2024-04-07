import 'package:cloud_authenticator/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // check if biometrics is enabled
  final prefs = await SharedPreferences.getInstance();
  bool isBiometricsEnabled = prefs.getBool('biometric') ?? false;

  // authenticate user with biometrics
  if (isBiometricsEnabled) {
    final localAuth = LocalAuthentication();
    bool didAuthenticate = await localAuth.authenticate(
      localizedReason: 'Please authenticate to start app',
    );

    // if user did not authenticate, close app
    if (!didAuthenticate) {
      SystemNavigator.pop();
      return;
    }
  }

  // if user authenticated, run app
  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MyApp();
  }
}
