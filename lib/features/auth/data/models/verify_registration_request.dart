import 'package:freezed_annotation/freezed_annotation.dart';

part 'verify_registration_request.freezed.dart';
part 'verify_registration_request.g.dart';

/// Request body for `POST /auth/register/verification/{id}/verify`.
@freezed
abstract class VerifyRegistrationRequest with _$VerifyRegistrationRequest {
  const factory VerifyRegistrationRequest({
    @JsonKey(name: 'pin') required String pin,
  }) = _VerifyRegistrationRequest;

  factory VerifyRegistrationRequest.fromJson(Map<String, dynamic> json) =>
      _$VerifyRegistrationRequestFromJson(json);
}
