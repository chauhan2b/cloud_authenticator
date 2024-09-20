import 'dart:developer';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;

class LogoService {
  final _storage = FirebaseStorage.instance;

  Future<String?> getLogoUrl(String issuer) async {
    final logoRef = _storage.ref('logos/$issuer.png');
    try {
      return await logoRef.getDownloadURL();
    } catch (_) {
      return await fetchAndStoreLogo(issuer);
    }
  }

  Future<String?> fetchAndStoreLogo(String issuer) async {
    log('MADE A NETWORK REQUEST FOR $issuer');

    // list of possible domains
    final List<String> domains = ['.com', '.net', '.org', '.io', '.dev', '.in'];

    // convert to lowercase (Google -> google)
    final baseDomain = issuer.toLowerCase();

    // check for all domains (google.com, google.net, google.org, ...)
    for (String tld in domains) {
      final domain = baseDomain + tld;
      final logoUrl = 'https://logo.clearbit.com/$domain';

      try {
        final response = await http.get(Uri.parse(logoUrl));

        // if logo found, store it in Firebase Storage
        if (response.statusCode == 200) {
          final logoRef = _storage.ref('logos/$issuer.png');
          await logoRef.putData(response.bodyBytes);
          return await logoRef.getDownloadURL();
        }
      } catch (_) {
        // if logo not found, continue to next domain
        continue;
      }
    }

    // if logo not found, return null
    return null;
  }
}
