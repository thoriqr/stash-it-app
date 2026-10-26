import 'package:freezed_annotation/freezed_annotation.dart';

part 'finalize_manual_registration_response.freezed.dart';
part 'finalize_manual_registration_response.g.dart';

/// `data` of a successful `POST /auth/register/finalize/manual`.
@freezed
abstract class FinalizeManualRegistrationResponse
    with _$FinalizeManualRegistrationResponse {
  const factory FinalizeManualRegistrationResponse({
    required String email,
    @JsonKey(name: 'display_name') required String displayName,
  }) = _FinalizeManualRegistrationResponse;

  factory FinalizeManualRegistrationResponse.fromJson(
    Map<String, dynamic> json,
  ) =>
      _$FinalizeManualRegistrationResponseFromJson(json);
}
