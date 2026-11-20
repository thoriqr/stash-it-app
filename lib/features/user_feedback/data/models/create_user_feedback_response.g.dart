// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_user_feedback_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CreatedUserFeedbackResponse _$CreatedUserFeedbackResponseFromJson(
  Map<String, dynamic> json,
) => _CreatedUserFeedbackResponse(
  id: json['id'] as String,
  createdAt: json['created_at'] as String,
);

Map<String, dynamic> _$CreatedUserFeedbackResponseToJson(
  _CreatedUserFeedbackResponse instance,
) => <String, dynamic>{'id': instance.id, 'created_at': instance.createdAt};

_CreateUserFeedbackResponse _$CreateUserFeedbackResponseFromJson(
  Map<String, dynamic> json,
) => _CreateUserFeedbackResponse(
  data: CreatedUserFeedbackResponse.fromJson(
    json['data'] as Map<String, dynamic>,
  ),
  message: json['message'] as String?,
);

Map<String, dynamic> _$CreateUserFeedbackResponseToJson(
  _CreateUserFeedbackResponse instance,
) => <String, dynamic>{'data': instance.data, 'message': instance.message};
