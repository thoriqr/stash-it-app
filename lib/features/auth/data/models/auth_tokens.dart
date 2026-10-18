import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_tokens.freezed.dart';
part 'auth_tokens.g.dart';

/// A credential pair as the client holds it.
///
/// Deliberately distinct from the wire shape in
/// [AuthTokensResponse]: this is a value the client persists and reads, not a
/// decoded payload, and keeping them apart means a change to the server's
/// envelope cannot silently change what is written to disk.
@freezed
abstract class AuthTokens with _$AuthTokens {
  const factory AuthTokens({
    required String accessToken,
    required String refreshToken,
  }) = _AuthTokens;

  factory AuthTokens.fromJson(Map<String, dynamic> json) =>
      _$AuthTokensFromJson(json);
}
