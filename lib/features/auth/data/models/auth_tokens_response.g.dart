// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_tokens_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AuthTokensResponse _$AuthTokensResponseFromJson(Map<String, dynamic> json) =>
    _AuthTokensResponse(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
    );

Map<String, dynamic> _$AuthTokensResponseToJson(_AuthTokensResponse instance) =>
    <String, dynamic>{
      'access_token': instance.accessToken,
      'refresh_token': instance.refreshToken,
    };
