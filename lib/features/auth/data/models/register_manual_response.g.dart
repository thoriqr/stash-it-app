// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'register_manual_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RegisterManualResponse _$RegisterManualResponseFromJson(
  Map<String, dynamic> json,
) => _RegisterManualResponse(
  verificationId: json['verification_id'] as String,
  verificationStatus: json['verification_status'] as String?,
);

Map<String, dynamic> _$RegisterManualResponseToJson(
  _RegisterManualResponse instance,
) => <String, dynamic>{
  'verification_id': instance.verificationId,
  'verification_status': instance.verificationStatus,
};
