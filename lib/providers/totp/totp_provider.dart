import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'totp_provider.g.dart';

@Riverpod(keepAlive: true)
class Totp extends _$Totp {
  final _uid = FirebaseAuth.instance.currentUser?.uid;
  final _firestore = FirebaseFirestore.instance;

  Future<List<String>> _fetchTOTPS() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(_uid)
          .collection('totps')
          .get();
      final totps = snapshot.docs.map((doc) => doc['totp'] as String).toList();
      return totps;
    } catch (error) {
      throw Exception('Error fetching TOTPs');
    }
  }

  @override
  FutureOr<List<String>> build() {
    return _fetchTOTPS();
  }

  Future<void> addTOTP(String totp) async {
    state = const AsyncValue.loading();
    await _firestore
        .collection('users')
        .doc(_uid)
        .collection('totps')
        .add({'totp': totp});
    state = await AsyncValue.guard(() => _fetchTOTPS());
  }
}
