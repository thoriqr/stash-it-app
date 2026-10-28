// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_google_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LoginGoogleResponse _$LoginGoogleResponseFromJson(Map<String, dynamic> json) =>
    _LoginGoogleResponse(
      outcome: json['outcome'] as String,
      accessToken: json['access_token'] as String?,
      refreshToken: json['refresh_token'] as String?,
      user: json['user'] == null
          ? null
          : AuthUser.fromJson(json['user'] as Map<String, dynamic>),
      provider: json['provider'] as String?,
      confirmationId: json['confirmation_id'] as String?,
      verificationId: json['verification_id'] as String?,
    );

Map<String, dynamic> _$LoginGoogleResponseToJson(
  _LoginGoogleResponse instance,
) => <String, dynamic>{
  'outcome': instance.outcome,
  'access_token': instance.accessToken,
  'refresh_token': instance.refreshToken,
  'user': instance.user,
  'provider': instance.provider,
  'confirmation_id': instance.confirmationId,
  'verification_id': instance.verificationId,
};
