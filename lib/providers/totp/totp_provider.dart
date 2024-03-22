import 'package:otp/otp.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../models/secret_key.dart';
import '../../models/totp.dart';

part 'totp_provider.g.dart';

@riverpod
class Totp extends _$Totp {
  @override
  TOTP build(SecretKey secret) {
    return _generateTOTP(secret.key);
  }

  TOTP _generateTOTP(String secret) {
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
