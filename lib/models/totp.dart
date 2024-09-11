import 'package:freezed_annotation/freezed_annotation.dart';

part 'totp.freezed.dart';
part 'totp.g.dart';

@freezed
class TOTP with _$TOTP {
  const factory TOTP({
    required String code,
    required String issuer,
    required String email,
    String? imageUrl,
  }) = _TOTP;

  factory TOTP.fromJson(Map<String, dynamic> json) => _$TOTPFromJson(json);
}
