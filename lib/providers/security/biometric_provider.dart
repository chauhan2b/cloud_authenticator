import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'biometric_provider.g.dart';

@Riverpod(keepAlive: true)
class Biometric extends _$Biometric {
  // load material theme from shared preferences
  Future<bool> _loadBiometricChoice() async {
    final prefs = await SharedPreferences.getInstance();
    final isBiometricEnabled = prefs.getBool('biometric') ?? false;
    return isBiometricEnabled;
  }

  // save material theme to shared preferences
  Future<void> _saveBiometricChoice(bool isBiometricEnabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('biometric', isBiometricEnabled);
  }

  @override
  FutureOr<bool> build() {
    return _loadBiometricChoice();
  }

  void toggleChoice() async {
    state = const AsyncValue.loading();
    final isBiometricEnabled = await _loadBiometricChoice();
    await _saveBiometricChoice(!isBiometricEnabled);
    state = AsyncValue.data(!isBiometricEnabled);
  }
}
