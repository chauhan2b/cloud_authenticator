import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:share_plus/share_plus.dart';

import '../../models/user_secret.dart';
import '../../services/backup_service.dart';
import '../../services/logo_service.dart';

part 'secrets_provider.g.dart';

@Riverpod(keepAlive: true)
class Secrets extends _$Secrets {
  final _uid = FirebaseAuth.instance.currentUser?.uid ?? 'anonymous';
  final _firestore = FirebaseFirestore.instance;

  // helper services
  final _logoService = LogoService();
  final _backupService = BackupService();

  // local list of secrets
  List<UserSecret> _secrets = [];

  // fetch secrets from firestore
  Future<List<UserSecret>> _fetchSecrets() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(_uid)
          .collection('secrets')
          .get();

      // update local list
      _secrets = await Future.wait(snapshot.docs.map((doc) async {
        final data = doc.data();
        final imageUrl =
            await _logoService.getLogoUrl(data['issuer'] as String);
        return UserSecret(
          id: doc.id,
          secret: data['secret'] as String,
          issuer: data['issuer'] as String,
          email: data['email'] as String,
          imageUrl: imageUrl,
        );
      }));

      return _secrets;
    } catch (error) {
      throw Exception('Error fetching secrets');
    }
  }

  @override
  Future<List<UserSecret>> build() {
    return _fetchSecrets();
  }

  Future<void> addSecret(UserSecret secret) async {
    // check if the secret already exists
    if (_secrets.any((s) => s.secret == secret.secret)) {
      debugPrint('Secret already exists');
      return;
    }

    state = const AsyncValue.loading();

    // fetch and store logo if not already available
    final logoUrl = await _logoService.getLogoUrl(secret.issuer);
    final secretWithLogoUrl = secret.copyWith(imageUrl: logoUrl);

    // add to firestore
    final docRef = await _firestore
        .collection('users')
        .doc(_uid)
        .collection('secrets')
        .add(secretWithLogoUrl.toJson());

    // update id
    final secretWithFirebaseId = secretWithLogoUrl.copyWith(id: docRef.id);
    await docRef.update({'id': docRef.id});

    // add to local list
    _secrets.add(secretWithFirebaseId);

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

  // import secrets from file
  Future<int> importSecrets() async {
    try {
      // get file from device
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['txt'],
      );

      // check if file is selected
      if (result == null || result.files.isEmpty) {
        throw Exception('No file selected');
      }

      // read secrets from file
      final file = File(result.files.single.path!);
      final lines = await file.readAsLines();

      int importedCount = 0;

      // add secrets to firestore
      for (final line in lines) {
        if (line.startsWith('otpauth://totp/')) {
          final secret = _backupService.parseOtpUrl(line);
          await addSecret(secret);
          importedCount++;
        }
      }

      return importedCount;
    } catch (error) {
      rethrow;
    }
  }

  // export secrets to device
  Future<void> exportSecrets() async {
    try {
      // fetch secrets
      await _fetchSecrets();

      // get local documents directory
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/secrets.txt');

      // write secrets to file
      final content = _secrets.map(_backupService.generateOtpUri).join('\n');

      await file.writeAsString(content);

      // share the file
      await Share.shareXFiles([XFile(file.path)], text: 'My secret keys');

      // print file path
      debugPrint('Secrets exported to ${file.path}');
    } catch (error) {
      throw Exception('Error exporting secrets');
    }
  }
}
