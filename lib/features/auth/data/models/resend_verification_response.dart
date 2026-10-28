import 'package:freezed_annotation/freezed_annotation.dart';

part 'resend_verification_response.freezed.dart';
part 'resend_verification_response.g.dart';

/// `data` of a successful resend.
///
/// Shared by `POST /auth/register/verification/{verification_id}/resend` and
/// `POST /auth/password-reset/verification/{verification_id}/resend`.
///
/// ```json
/// { "verification_id": "01a0f359-093b-737a-963a-80f7ca6768ed" }
/// ```
///
/// The verification id is unchanged by a resend; the response repeats it. The
/// cooldown is not part of this response and must be refreshed with GET.
@freezed
abstract class ResendVerificationResponse with _$ResendVerificationResponse {
  const factory ResendVerificationResponse({
    @JsonKey(name: 'verification_id') required String verificationId,
  }) = _ResendVerificationResponse;

  factory ResendVerificationResponse.fromJson(Map<String, dynamic> json) =>
      _$ResendVerificationResponseFromJson(json);
}
