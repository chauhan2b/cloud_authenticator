import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_secret.freezed.dart';
part 'user_secret.g.dart';

@freezed
class UserSecret with _$UserSecret {
  const factory UserSecret({
    required String id,
    required String secret,
    required String issuer,
    required String email,
    String? imageUrl,
  }) = _UserSecret;

  factory UserSecret.fromJson(Map<String, Object?> json) =>
      _$UserSecretFromJson(json);
}
