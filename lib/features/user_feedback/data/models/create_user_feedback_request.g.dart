// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_user_feedback_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CreateUserFeedbackRequest _$CreateUserFeedbackRequestFromJson(
  Map<String, dynamic> json,
) => _CreateUserFeedbackRequest(
  type: json['type'] as String,
  message: json['message'] as String,
  appVersion: json['app_version'] as String?,
  appBuild: (json['app_build'] as num?)?.toInt(),
);

Map<String, dynamic> _$CreateUserFeedbackRequestToJson(
  _CreateUserFeedbackRequest instance,
) => <String, dynamic>{
  'type': instance.type,
  'message': instance.message,
  'app_version': ?instance.appVersion,
  'app_build': ?instance.appBuild,
};
