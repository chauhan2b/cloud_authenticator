import 'package:otp/otp.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:http/http.dart' as http;

import '../../models/totp.dart';

part 'totp_provider.g.dart';

@Riverpod(keepAlive: true)
class Totp extends _$Totp {
  // list of possible domains
  final List<String> _domains = ['.com', '.net', '.org', '.io', '.dev', '.in'];

  // url to fetch the logo
  final String _baseUrl = 'https://logo.clearbit.com/';

  @override
  Future<TOTP> build(String secret) {
    return _generateTOTP(secret);
  }

  Future<TOTP> _generateTOTP(String secret) async {
    final uri = Uri.parse(secret);

    final val = TOTP(
      code: OTP.generateTOTPCodeString(
        uri.queryParameters['secret'] ?? 'none',
        DateTime.now().millisecondsSinceEpoch,
        algorithm: Algorithm.SHA1,
        interval: 30,
        length: 6,
        isGoogle: true,
      ),
      issuer: uri.queryParameters['issuer'] ?? 'none',
      email: uri.pathSegments.isNotEmpty
          ? uri.pathSegments.last.split(':').last
          : 'none',
      imageUrl: await _fetchLogo(uri.queryParameters['issuer']),
    );

    return val;
  }

  Future<String?> _fetchLogo(String? issuer) async {
    if (issuer == null) {
      return null;
    }

    // convert to lowercase
    final String baseDomain = issuer.toLowerCase();

    // check for each domain
    for (String tld in _domains) {
      // generate domain
      // google -> google.com || google.net || google.org
      String domain = baseDomain + tld;
      String logoUrl = '$_baseUrl$domain?format=png';

      try {
        final response = await http.get(Uri.parse(logoUrl));

        // if there is an image, return the url
        if (response.statusCode == 200) {
          return logoUrl;
        }
      } catch (e) {
        // if there is no image, try the next domain
        continue;
      }
    }

    // if no image is found, return null
    return null;
  }
}
