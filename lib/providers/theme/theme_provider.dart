import 'package:cloud_authenticator/constants/shared_prefs_keys.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'theme_provider.g.dart';

@riverpod
class DarkTheme extends _$DarkTheme {
  // load dark theme from shared preferences
  Future<bool> _loadDarkTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool(SharedPrefsKeys.darkTheme) ?? false;
    return isDark;
  }

  // save dark theme to shared preferences
  Future<void> _saveDarkTheme(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(SharedPrefsKeys.darkTheme, isDark);
  }

  @override
  FutureOr<bool> build() {
    return _loadDarkTheme();
  }

  void toggleTheme() async {
    state = const AsyncValue.loading();
    final isDark = await _loadDarkTheme();
    await _saveDarkTheme(!isDark);
    state = AsyncValue.data(!isDark);
  }
}

@riverpod
class SystemTheme extends _$SystemTheme {
  // load system theme from shared preferences
  Future<bool> _loadSystemTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isSystem = prefs.getBool(SharedPrefsKeys.systemTheme) ?? false;
    return isSystem;
  }

  // save system theme to shared preferences
  Future<void> _saveSystemTheme(bool isSystem) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(SharedPrefsKeys.systemTheme, isSystem);
  }

  @override
  FutureOr<bool> build() {
    return _loadSystemTheme();
  }

  void toggleTheme() async {
    state = const AsyncValue.loading();
    final isSystem = await _loadSystemTheme();
    await _saveSystemTheme(!isSystem);
    state = AsyncValue.data(!isSystem);
  }
}

@riverpod
class MaterialTheme extends _$MaterialTheme {
  // load material theme from shared preferences
  Future<bool> _loadMaterialTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isMaterial = prefs.getBool(SharedPrefsKeys.materialTheme) ?? false;
    return isMaterial;
  }

  // save material theme to shared preferences
  Future<void> _saveMaterialTheme(bool isMaterial) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(SharedPrefsKeys.materialTheme, isMaterial);
  }

  @override
  FutureOr<bool> build() {
    return _loadMaterialTheme();
  }

  void toggleTheme() async {
    state = const AsyncValue.loading();
    final isMaterial = await _loadMaterialTheme();
    await _saveMaterialTheme(!isMaterial);
    state = AsyncValue.data(!isMaterial);
  }
}
