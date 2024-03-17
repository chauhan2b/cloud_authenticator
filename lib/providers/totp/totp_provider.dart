import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:otp/otp.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../models/totp.dart';

part 'totp_provider.g.dart';

@Riverpod(keepAlive: true)
class Totp extends _$Totp {
  final _uid = FirebaseAuth.instance.currentUser?.uid;
  final _firestore = FirebaseFirestore.instance;

  Future<List<TOTP>> _fetchTOTPS() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(_uid)
          .collection('totps')
          .get();
      final secrets =
          snapshot.docs.map((doc) => doc['totp'] as String).toList();

      return secrets.map(generateTOTP).toList();
    } catch (error) {
      throw Exception('Error fetching TOTPs');
    }
  }

  @override
  FutureOr<List<TOTP>> build() {
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

  Future<void> removeTOTP(TOTP totp) async {
    state = const AsyncValue.loading();
    final snapshot = await _firestore
        .collection('users')
        .doc(_uid)
        .collection('totps')
        .where('totp', isEqualTo: totp.toString())
        .get();
    await Future.wait(snapshot.docs.map((doc) => doc.reference.delete()));
    state = await AsyncValue.guard(() => _fetchTOTPS());
  }

  TOTP generateTOTP(String secret) {
    final uri = Uri.parse(secret);
    return TOTP(
      code: OTP.generateTOTPCodeString(
        secret,
        DateTime.now().millisecondsSinceEpoch,
        algorithm: Algorithm.SHA1,
        interval: 30,
        length: 6,
        isGoogle: false,
      ),
      issuer: uri.queryParameters['issuer'] ?? 'none',
      email: uri.pathSegments.isNotEmpty
          ? uri.pathSegments.last.split(':').last
          : 'none',
    );
  }
}

@riverpod
Stream<int> time(TimeRef ref) {
  return Stream.periodic(const Duration(seconds: 1), (i) => i);
}
