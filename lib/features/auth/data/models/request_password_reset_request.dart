import 'package:freezed_annotation/freezed_annotation.dart';

part 'request_password_reset_request.freezed.dart';
part 'request_password_reset_request.g.dart';

/// Request body for `POST /auth/password-reset`.
///
/// The response does not reveal whether an account exists for the submitted
/// email address. The client must not infer account existence from the result.
@freezed
abstract class RequestPasswordResetRequest with _$RequestPasswordResetRequest {
  const factory RequestPasswordResetRequest({required String email}) =
      _RequestPasswordResetRequest;

  factory RequestPasswordResetRequest.fromJson(Map<String, dynamic> json) =>
      _$RequestPasswordResetRequestFromJson(json);
}
