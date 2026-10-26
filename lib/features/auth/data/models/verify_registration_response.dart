import 'package:freezed_annotation/freezed_annotation.dart';

part 'verify_registration_response.freezed.dart';
part 'verify_registration_response.g.dart';

/// `data` of a successful `POST /auth/register/verification/{id}/verify`.
@freezed
abstract class VerifyRegistrationResponse with _$VerifyRegistrationResponse {
  const factory VerifyRegistrationResponse({
    @JsonKey(name: 'registration_continuation_token')
    required String registrationContinuationToken,
  }) = _VerifyRegistrationResponse;

  factory VerifyRegistrationResponse.fromJson(Map<String, dynamic> json) =>
      _$VerifyRegistrationResponseFromJson(json);
}
