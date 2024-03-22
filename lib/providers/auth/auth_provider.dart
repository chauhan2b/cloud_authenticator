import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../models/user_model.dart';
import '../../services/auth_service.dart';

part 'auth_provider.g.dart';

@Riverpod(keepAlive: true)
AuthService authService(AuthServiceRef ref) {
  return AuthService();
}

@Riverpod(keepAlive: true)
Stream<UserModel?> authState(AuthStateRef ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.user;
}

@riverpod
class FirebaseAuth extends _$FirebaseAuth {
  @override
  FutureOr<void> build() {
    // nothing to do
  }

  Future<void> createAccount(String email, String password) async {
    final authService = ref.read(authServiceProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
        () => authService.createAccount(email, password));
  }

  Future<void> signIn(String email, String password) async {
    final authService = ref.read(authServiceProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => authService.signIn(email, password));
  }

  Future<void> signOut() async {
    final authService = ref.read(authServiceProvider);
    return await authService.signOut();
  }
}
