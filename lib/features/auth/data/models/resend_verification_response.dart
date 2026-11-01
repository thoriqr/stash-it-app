import 'package:freezed_annotation/freezed_annotation.dart';

part 'resend_verification_response.freezed.dart';
part 'resend_verification_response.g.dart';

/// Represents the response data from a successful PIN resend.
///
/// Shared by registration and password-reset resend endpoints.
///
/// The verification ID remains unchanged after a resend. The response repeats
/// that ID, while the updated cooldown must be retrieved separately through
/// the corresponding verification status endpoint.
@freezed
abstract class ResendVerificationResponse with _$ResendVerificationResponse {
  const factory ResendVerificationResponse({
    @JsonKey(name: 'verification_id') required String verificationId,
  }) = _ResendVerificationResponse;

  factory ResendVerificationResponse.fromJson(Map<String, dynamic> json) =>
      _$ResendVerificationResponseFromJson(json);
}
