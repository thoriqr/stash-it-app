import 'package:freezed_annotation/freezed_annotation.dart';

part 'request_password_reset_response.freezed.dart';
part 'request_password_reset_response.g.dart';

/// `data` of a successful `POST /auth/password-reset`.
///
/// ```json
/// { "verification_id": "01a0f359-093b-737a-963a-80f7ca6768ed" }
/// ```
///
/// The id is the credential for the reset verification routes. For an address
/// with no account it is a random, unpersisted placeholder: the response shape
/// is identical on purpose, so this body cannot be used to discover which
/// addresses are registered.
@freezed
abstract class RequestPasswordResetResponse
    with _$RequestPasswordResetResponse {
  const factory RequestPasswordResetResponse({
    @JsonKey(name: 'verification_id') required String verificationId,
  }) = _RequestPasswordResetResponse;

  factory RequestPasswordResetResponse.fromJson(Map<String, dynamic> json) =>
      _$RequestPasswordResetResponseFromJson(json);
}
