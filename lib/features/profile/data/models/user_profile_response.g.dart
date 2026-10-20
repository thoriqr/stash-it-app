// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserIdentityResponse _$UserIdentityResponseFromJson(
  Map<String, dynamic> json,
) => _UserIdentityResponse(
  provider: json['provider'] as String,
  linkedAt: json['linked_at'] as String,
  emailSnapshot: json['email_snapshot'] as String?,
  displayNameSnapshot: json['display_name_snapshot'] as String?,
);

Map<String, dynamic> _$UserIdentityResponseToJson(
  _UserIdentityResponse instance,
) => <String, dynamic>{
  'provider': instance.provider,
  'linked_at': instance.linkedAt,
  'email_snapshot': instance.emailSnapshot,
  'display_name_snapshot': instance.displayNameSnapshot,
};

_UserResponse _$UserResponseFromJson(Map<String, dynamic> json) =>
    _UserResponse(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['display_name'] as String,
      hasPasswordCredential: json['has_password_credential'] as bool,
      createdAt: json['created_at'] as String,
      identities: (json['identities'] as List<dynamic>)
          .map((e) => UserIdentityResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$UserResponseToJson(_UserResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'display_name': instance.displayName,
      'has_password_credential': instance.hasPasswordCredential,
      'created_at': instance.createdAt,
      'identities': instance.identities,
    };

_UserDataResponse _$UserDataResponseFromJson(Map<String, dynamic> json) =>
    _UserDataResponse(
      user: UserResponse.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$UserDataResponseToJson(_UserDataResponse instance) =>
    <String, dynamic>{'user': instance.user};

_GetUserResponse _$GetUserResponseFromJson(Map<String, dynamic> json) =>
    _GetUserResponse(
      data: UserDataResponse.fromJson(json['data'] as Map<String, dynamic>),
      message: json['message'] as String?,
    );

Map<String, dynamic> _$GetUserResponseToJson(_GetUserResponse instance) =>
    <String, dynamic>{'data': instance.data, 'message': instance.message};
