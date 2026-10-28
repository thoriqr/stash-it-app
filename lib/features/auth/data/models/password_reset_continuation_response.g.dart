// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'password_reset_continuation_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PasswordResetContinuationResponse _$PasswordResetContinuationResponseFromJson(
  Map<String, dynamic> json,
) => _PasswordResetContinuationResponse(
  email: json['email'] as String,
  hasPasswordCredential: json['has_password_credential'] as bool,
);

Map<String, dynamic> _$PasswordResetContinuationResponseToJson(
  _PasswordResetContinuationResponse instance,
) => <String, dynamic>{
  'email': instance.email,
  'has_password_credential': instance.hasPasswordCredential,
};
