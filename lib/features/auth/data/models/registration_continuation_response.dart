import 'package:freezed_annotation/freezed_annotation.dart';

part 'registration_continuation_response.freezed.dart';
part 'registration_continuation_response.g.dart';

/// `data` of a successful `GET /auth/register/continuation`.
@freezed
abstract class RegistrationContinuationResponse
    with _$RegistrationContinuationResponse {
  const factory RegistrationContinuationResponse({
    required String email,
    @JsonKey(name: 'registration_type') required String registrationType,
    @JsonKey(name: 'requires_password') required bool requiresPassword,
  }) = _RegistrationContinuationResponse;

  factory RegistrationContinuationResponse.fromJson(Map<String, dynamic> json) =>
      _$RegistrationContinuationResponseFromJson(json);
}
