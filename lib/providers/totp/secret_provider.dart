import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../models/secret_key.dart';

part 'secret_provider.g.dart';

@riverpod
class Secret extends _$Secret {
  final _uid = FirebaseAuth.instance.currentUser?.uid;
  final _firestore = FirebaseFirestore.instance;

  Future<List<SecretKey>> _fetchSecrets() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(_uid)
          .collection('secrets')
          .get();
      return snapshot.docs
          .map((doc) => SecretKey(
                secret: doc['secret'] as String,
                id: doc.id,
              ))
          .toList();
    } catch (error) {
      throw Exception('Error fetching secrets');
    }
  }

  @override
  FutureOr<List<SecretKey>> build() {
    return _fetchSecrets();
  }

  Future<void> addSecret(String secret) async {
    state = const AsyncValue.loading();
    await _firestore
        .collection('users')
        .doc(_uid)
        .collection('secrets')
        .add({'secret': secret});
    state = await AsyncValue.guard(() => _fetchSecrets());
  }

  Future<void> removeSecret(String id) async {
    state = const AsyncValue.loading();
    await _firestore
        .collection('users')
        .doc(_uid)
        .collection('secrets')
        .doc(id)
        .delete();
    state = await AsyncValue.guard(() => _fetchSecrets());
  }
}
