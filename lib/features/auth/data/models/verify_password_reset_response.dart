import 'package:freezed_annotation/freezed_annotation.dart';

part 'verify_password_reset_response.freezed.dart';
part 'verify_password_reset_response.g.dart';

/// `data` of a successful
/// `POST /auth/password-reset/verification/{verification_id}/verify`.
///
/// ```json
/// { "password_reset_continuation_token": "..." }
/// ```
///
/// The raw token is returned exactly once. The backend stores only its hash, so
/// the client must persist it before leaving the verification screen. It is used
/// in the `X-Password-Reset-Continuation` header for validation and
/// finalization.
@freezed
abstract class VerifyPasswordResetResponse with _$VerifyPasswordResetResponse {
  const factory VerifyPasswordResetResponse({
    @JsonKey(name: 'password_reset_continuation_token')
    required String passwordResetContinuationToken,
  }) = _VerifyPasswordResetResponse;

  factory VerifyPasswordResetResponse.fromJson(Map<String, dynamic> json) =>
      _$VerifyPasswordResetResponseFromJson(json);
}
