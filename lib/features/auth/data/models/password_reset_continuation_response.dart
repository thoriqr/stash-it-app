import 'package:freezed_annotation/freezed_annotation.dart';

part 'password_reset_continuation_response.freezed.dart';
part 'password_reset_continuation_response.g.dart';

/// `data` of a successful `GET /auth/password-reset/continuation`.
///
/// ```json
/// { "email": "user@example.com", "has_password_credential": true }
/// ```
///
/// `has_password_credential` reports whether the account already holds a
/// password. A social-only account answers `false`; finalization still creates
/// one. It is presentation context only and does not gate the form.
@freezed
abstract class PasswordResetContinuationResponse
    with _$PasswordResetContinuationResponse {
  const factory PasswordResetContinuationResponse({
    required String email,
    @JsonKey(name: 'has_password_credential')
    required bool hasPasswordCredential,
  }) = _PasswordResetContinuationResponse;

  factory PasswordResetContinuationResponse.fromJson(
    Map<String, dynamic> json,
  ) => _$PasswordResetContinuationResponseFromJson(json);
}
