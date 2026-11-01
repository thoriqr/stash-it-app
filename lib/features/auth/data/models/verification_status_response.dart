import 'package:freezed_annotation/freezed_annotation.dart';

part 'verification_status_response.freezed.dart';
part 'verification_status_response.g.dart';

/// Represents the response data from a verification status request.
///
/// Shared by registration and password-reset verification endpoints.
///
/// The response is available while verification is pending. An already
/// verified request returns `409 VERIFICATION_NOT_PENDING`.
///
/// `resendInSeconds` provides the remaining cooldown in seconds; zero means
/// another PIN can be requested immediately.
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
