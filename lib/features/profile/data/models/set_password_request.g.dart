// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'set_password_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SetPasswordRequest _$SetPasswordRequestFromJson(Map<String, dynamic> json) =>
    _SetPasswordRequest(
      currentPassword: json['current_password'] as String?,
      newPassword: json['new_password'] as String,
    );

Map<String, dynamic> _$SetPasswordRequestToJson(_SetPasswordRequest instance) =>
    <String, dynamic>{
      'current_password': ?instance.currentPassword,
      'new_password': instance.newPassword,
    };
