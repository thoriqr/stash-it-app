import 'package:freezed_annotation/freezed_annotation.dart';

part 'verification_status_response.freezed.dart';
part 'verification_status_response.g.dart';

/// `data` of a successful verification-status read.
///
/// Shared by `GET /auth/register/verification/{verification_id}` and
/// `GET /auth/password-reset/verification/{verification_id}`; both endpoints
/// return this shape.
///
/// ```json
/// {
///   "verification_id": "01a0f359-093b-737a-963a-80f7ca6768ed",
///   "status": "pending",
///   "pin_issued": true,
///   "resend_in_seconds": 42
/// }
/// ```
///
/// The backend only returns a body while the verification is `pending`; a
/// verified request answers `409 VERIFICATION_NOT_PENDING`. `pin_issued` reports
/// whether a PIN has been issued, not whether an email reached the inbox.
/// `resend_in_seconds` is the authoritative remaining cooldown; zero means no
/// wait.
@freezed
abstract class VerificationStatusResponse with _$VerificationStatusResponse {
  const factory VerificationStatusResponse({
    @JsonKey(name: 'verification_id') required String verificationId,
    required String status,
    @JsonKey(name: 'pin_issued') required bool pinIssued,
    @JsonKey(name: 'resend_in_seconds') required int resendInSeconds,
  }) = _VerificationStatusResponse;

  factory VerificationStatusResponse.fromJson(Map<String, dynamic> json) =>
      _$VerificationStatusResponseFromJson(json);
}
