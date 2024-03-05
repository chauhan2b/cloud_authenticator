import 'package:freezed_annotation/freezed_annotation.dart';

part 'totp.freezed.dart';
part 'totp.g.dart';

@freezed
class TOTP with _$TOTP {
  const factory TOTP({
    required String secret,
    required String uri,
    required String username,
  }) = _TOTP;

  factory TOTP.fromJson(Map<String, dynamic> json) => _$TOTPFromJson(json);
}
