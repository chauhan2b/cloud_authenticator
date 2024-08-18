import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:share_plus/share_plus.dart';

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

  // export secrets to device
  Future<void> exportSecrets() async {
    if (await Permission.storage.request().isGranted) {
      try {
        // fetch secrets
        await _fetchSecrets();

        // get local documents directory
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/secrets.txt');

        // write secrets to file
        await file
            .writeAsString(_secrets.map((secret) => secret.key).join('\n'));

        // share the file
        await Share.shareXFiles([XFile(file.path)], text: 'My secret keys');

        // print file path
        debugPrint('Secrets exported to ${file.path}');
      } catch (error) {
        throw Exception('Error exporting secrets');
      }
    } else {
      debugPrint('Permission denied');
    }
  }
}
