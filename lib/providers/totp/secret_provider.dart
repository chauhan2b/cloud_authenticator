import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../../models/secret_key.dart';

part 'secret_provider.g.dart';

@riverpod
class Secret extends _$Secret {
  final _uid = FirebaseAuth.instance.currentUser?.uid;
  final _firestore = FirebaseFirestore.instance;

  // local list of secrets
  List<SecretKey> _secrets = [];

  // save secrets to shared preferences
  Future<void> _saveSecretsToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final secretsString = jsonEncode(_secrets.map((e) => e.toJson()).toList());
    await prefs.setString('secrets', secretsString);
  }

  // fetch secrets from firestore
  Future<List<SecretKey>> _fetchSecrets() async {
    try {
      // try loading from shared preferences
      final prefs = await SharedPreferences.getInstance();
      final secretsString = prefs.getString('secrets');
      if (secretsString != null) {
        final List<dynamic> secretsJson = jsonDecode(secretsString);
        _secrets = secretsJson.map((e) => SecretKey.fromJson(e)).toList();
        return _secrets;
      }

      // if not found in shared preferences, load from firestore
      final snapshot = await _firestore
          .collection('users')
          .doc(_uid)
          .collection('secrets')
          .get();

      // update local list
      _secrets = snapshot.docs
          .map((doc) => SecretKey(
                secret: doc['secret'] as String,
                id: doc.id,
              ))
          .toList();
      await _saveSecretsToPrefs();
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
    _secrets.add(SecretKey(secret: secret, id: docRef.id));

    // update state
    state = AsyncValue.data(_secrets);
    await _saveSecretsToPrefs();
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
    await _saveSecretsToPrefs();
  }
}
