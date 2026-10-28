import 'package:freezed_annotation/freezed_annotation.dart';

part 'verify_password_reset_request.freezed.dart';
part 'verify_password_reset_request.g.dart';

/// `POST /auth/password-reset/verification/{verification_id}/verify`.
@freezed
abstract class VerifyPasswordResetRequest with _$VerifyPasswordResetRequest {
  const factory VerifyPasswordResetRequest({required String pin}) =
      _VerifyPasswordResetRequest;

  factory VerifyPasswordResetRequest.fromJson(Map<String, dynamic> json) =>
      _$VerifyPasswordResetRequestFromJson(json);
}
