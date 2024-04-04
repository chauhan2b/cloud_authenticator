import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../models/secret_key.dart';

part 'secret_provider.g.dart';

@Riverpod(keepAlive: true)
class Secret extends _$Secret {
  final _uid = FirebaseAuth.instance.currentUser?.uid ?? 'anonymous';
  final _firestore = FirebaseFirestore.instance;

  // local list of secrets
  List<SecretKey> _secrets = [];

  // fetch secrets from firestore
  Future<List<SecretKey>> _fetchSecrets() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(_uid)
          .collection('secrets')
          .get();

      // update local list
      _secrets = snapshot.docs
          .map((doc) => SecretKey(
                key: doc['secret'] as String,
                id: doc.id,
              ))
          .toList();

      return _secrets;
    } catch (error) {
      throw Exception('Error fetching secrets');
    }
  }

  @override
  FutureOr<List<SecretKey>> build() {
    return _fetchSecrets();
  }

  Future<void> addSecret(String secret) async {
    // add to firestore
    state = const AsyncValue.loading();
    final docRef = await _firestore
        .collection('users')
        .doc(_uid)
        .collection('secrets')
        .add({'secret': secret});

    // add to local list
    _secrets.add(SecretKey(key: secret, id: docRef.id));

    // update state
    state = AsyncValue.data(_secrets);
  }

  Future<void> removeSecret(String id) async {
    // remove from firestore
    state = const AsyncValue.loading();
    await _firestore
        .collection('users')
        .doc(_uid)
        .collection('secrets')
        .doc(id)
        .delete();

    // remove from local list
    _secrets.removeWhere((secret) => secret.id == id);

    // update state
    state = AsyncValue.data(_secrets);
  }
}
