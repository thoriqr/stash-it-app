// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'registration_continuation_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RegistrationContinuationResponse _$RegistrationContinuationResponseFromJson(
  Map<String, dynamic> json,
) => _RegistrationContinuationResponse(
  email: json['email'] as String,
  registrationType: json['registration_type'] as String,
  requiresPassword: json['requires_password'] as bool,
);

Map<String, dynamic> _$RegistrationContinuationResponseToJson(
  _RegistrationContinuationResponse instance,
) => <String, dynamic>{
  'email': instance.email,
  'registration_type': instance.registrationType,
  'requires_password': instance.requiresPassword,
};
