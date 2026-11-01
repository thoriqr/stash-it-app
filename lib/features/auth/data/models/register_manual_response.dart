import 'package:freezed_annotation/freezed_annotation.dart';

part 'register_manual_response.freezed.dart';
part 'register_manual_response.g.dart';

/// Represents the response data from `POST /auth/register/manual`.
///
/// The verification ID is required because the client needs it to continue
/// the PIN verification flow.
///
/// `verificationStatus` is nullable for compatibility with responses that
/// omit the field. Missing or unrecognized values follow the pending
/// verification flow. Only the literal `verified` status skips PIN
/// verification.
@freezed
abstract class RegisterManualResponse with _$RegisterManualResponse {
  const RegisterManualResponse._();

  const factory RegisterManualResponse({
    @JsonKey(name: 'verification_id') required String verificationId,
    @JsonKey(name: 'verification_status') String? verificationStatus,
  }) = _RegisterManualResponse;

  factory RegisterManualResponse.fromJson(Map<String, dynamic> json) =>
      _$RegisterManualResponseFromJson(json);

  /// Whether PIN verification has already completed.
  ///
  /// This status does not guarantee that the client has the corresponding
  /// continuation token. The token must already be available in local storage
  /// to continue registration.
  bool get isVerified => verificationStatus == 'verified';
}
