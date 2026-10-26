import 'package:freezed_annotation/freezed_annotation.dart';

part 'register_manual_response.freezed.dart';
part 'register_manual_response.g.dart';

/// `data` of a successful `POST /auth/register/manual`.
///
/// ```json
/// { "verification_id": "01a0f359-093b-737a-963a-80f7ca6768ed" }
/// ```
///
/// The verification id is the only value the next call needs. It is required:
/// accepting a `201` without it would leave the registration flow unable to
/// request the first PIN while pretending registration had progressed.
@freezed
abstract class RegisterManualResponse with _$RegisterManualResponse {
  const factory RegisterManualResponse({
    @JsonKey(name: 'verification_id') required String verificationId,
  }) = _RegisterManualResponse;

  factory RegisterManualResponse.fromJson(Map<String, dynamic> json) =>
      _$RegisterManualResponseFromJson(json);
}
