// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verification_status_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_VerificationStatusResponse _$VerificationStatusResponseFromJson(
  Map<String, dynamic> json,
) => _VerificationStatusResponse(
  verificationId: json['verification_id'] as String,
  status: json['status'] as String,
  pinIssued: json['pin_issued'] as bool,
  resendInSeconds: (json['resend_in_seconds'] as num).toInt(),
);

Map<String, dynamic> _$VerificationStatusResponseToJson(
  _VerificationStatusResponse instance,
) => <String, dynamic>{
  'verification_id': instance.verificationId,
  'status': instance.status,
  'pin_issued': instance.pinIssued,
  'resend_in_seconds': instance.resendInSeconds,
};
