import 'package:otp/otp.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../models/totp.dart';

part 'totp_provider.g.dart';

@Riverpod(keepAlive: true)
class Totp extends _$Totp {
  @override
  TOTP build(String secret) {
    return _generateTOTP(secret);
  }

  TOTP _generateTOTP(String secret) {
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
    );

    return val;
  }
}
