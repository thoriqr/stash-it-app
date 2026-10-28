// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verify_password_reset_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_VerifyPasswordResetResponse _$VerifyPasswordResetResponseFromJson(
  Map<String, dynamic> json,
) => _VerifyPasswordResetResponse(
  passwordResetContinuationToken:
      json['password_reset_continuation_token'] as String,
);

Map<String, dynamic> _$VerifyPasswordResetResponseToJson(
  _VerifyPasswordResetResponse instance,
) => <String, dynamic>{
  'password_reset_continuation_token': instance.passwordResetContinuationToken,
};
