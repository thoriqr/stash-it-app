import 'package:freezed_annotation/freezed_annotation.dart';

part 'request_password_reset_response.freezed.dart';
part 'request_password_reset_response.g.dart';

/// Represents the response data from `POST /auth/password-reset`.
///
/// The verification ID is used to continue the password-reset verification
/// flow.
///
/// The API returns the same response shape whether or not an account exists
/// for the submitted email address. For addresses without an account, the ID
/// is a random placeholder. The client must not use this value to infer
/// account existence.
@freezed
abstract class RequestPasswordResetResponse
    with _$RequestPasswordResetResponse {
  const factory RequestPasswordResetResponse({
    @JsonKey(name: 'verification_id') required String verificationId,
  }) = _RequestPasswordResetResponse;

  factory RequestPasswordResetResponse.fromJson(Map<String, dynamic> json) =>
      _$RequestPasswordResetResponseFromJson(json);
}
