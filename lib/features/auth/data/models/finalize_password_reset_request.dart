import 'package:freezed_annotation/freezed_annotation.dart';

part 'finalize_password_reset_request.freezed.dart';
part 'finalize_password_reset_request.g.dart';

/// `POST /auth/password-reset/finalize`.
///
/// The continuation token travels in the `X-Password-Reset-Continuation`
/// header, never in this body.
@freezed
abstract class FinalizePasswordResetRequest
    with _$FinalizePasswordResetRequest {
  const factory FinalizePasswordResetRequest({required String password}) =
      _FinalizePasswordResetRequest;

  factory FinalizePasswordResetRequest.fromJson(Map<String, dynamic> json) =>
      _$FinalizePasswordResetRequestFromJson(json);
}
