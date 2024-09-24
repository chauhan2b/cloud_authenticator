import 'package:otp/otp.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'totp_provider.g.dart';

@riverpod
class Totp extends _$Totp {
  @override
  String build(String secret) {
    return OTP.generateTOTPCodeString(
      secret,
      DateTime.now().millisecondsSinceEpoch,
      algorithm: Algorithm.SHA1,
      interval: 30,
      length: 6,
      isGoogle: true,
    );
  }
}
