import 'package:freezed_annotation/freezed_annotation.dart';

part 'register_manual_response.freezed.dart';
part 'register_manual_response.g.dart';

/// `data` of a successful `POST /auth/register/manual`.
///
/// ```json
/// {
///   "verification_id": "01a0f359-093b-737a-963a-80f7ca6768ed",
///   "verification_status": "pending"
/// }
/// ```
///
/// The verification id is required: accepting a `201` without it would leave the
/// registration flow unable to request the first PIN while pretending
/// registration had progressed.
///
/// **`verification_status` is nullable on purpose.** It was added to the backend
/// after this client shipped, so an older server omits it. A missing value, like
/// any value this client does not recognise, is treated as `pending` — the
/// pre-change behaviour — rather than failing to decode or guessing that the
/// registration is already verified. Only the literal `verified` suppresses the
/// PIN step.
@freezed
abstract class RegisterManualResponse with _$RegisterManualResponse {
  const RegisterManualResponse._();

  const factory RegisterManualResponse({
    @JsonKey(name: 'verification_id') required String verificationId,
    @JsonKey(name: 'verification_status') String? verificationStatus,
  }) = _RegisterManualResponse;

  factory RegisterManualResponse.fromJson(Map<String, dynamic> json) =>
      _$RegisterManualResponseFromJson(json);

  /// Whether PIN verification has already completed and a usable continuation
  /// exists.
  ///
  /// The backend states `verified` only when a live registration continuation is
  /// available. That does not mean the client has it: the raw token is stored
  /// locally or not at all, and the backend cannot reissue it.
  bool get isVerified => verificationStatus == 'verified';
}
