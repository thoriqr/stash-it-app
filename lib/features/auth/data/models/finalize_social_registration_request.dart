import 'package:freezed_annotation/freezed_annotation.dart';

part 'finalize_social_registration_request.freezed.dart';
part 'finalize_social_registration_request.g.dart';

/// `POST /auth/register/finalize/social`.
///
/// The continuation token travels in the `X-Registration-Continuation` header.
/// No password is sent: a social account has no password credential.
@freezed
abstract class FinalizeSocialRegistrationRequest
    with _$FinalizeSocialRegistrationRequest {
  const factory FinalizeSocialRegistrationRequest({
    @JsonKey(name: 'display_name') required String displayName,
  }) = _FinalizeSocialRegistrationRequest;

  factory FinalizeSocialRegistrationRequest.fromJson(
    Map<String, dynamic> json,
  ) => _$FinalizeSocialRegistrationRequestFromJson(json);
}
