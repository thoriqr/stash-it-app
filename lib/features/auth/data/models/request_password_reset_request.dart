import 'package:freezed_annotation/freezed_annotation.dart';

part 'request_password_reset_request.freezed.dart';
part 'request_password_reset_request.g.dart';

/// `POST /auth/password-reset`.
///
/// The backend answers the same `201 {verification_id}` for every address,
/// whether or not an account holds it. The client must not use the response to
/// infer account existence.
@freezed
abstract class RequestPasswordResetRequest with _$RequestPasswordResetRequest {
  const factory RequestPasswordResetRequest({required String email}) =
      _RequestPasswordResetRequest;

  factory RequestPasswordResetRequest.fromJson(Map<String, dynamic> json) =>
      _$RequestPasswordResetRequestFromJson(json);
}
