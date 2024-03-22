import 'package:freezed_annotation/freezed_annotation.dart';

part 'secret_key.g.dart';
part 'secret_key.freezed.dart';

@freezed
class SecretKey with _$SecretKey {
  const factory SecretKey({
    required String key,
    required String id,
  }) = _SecretKey;

  factory SecretKey.fromJson(Map<String, dynamic> json) =>
      _$SecretKeyFromJson(json);
}
