// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_link_confirmation_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AccountLinkConfirmationResponse _$AccountLinkConfirmationResponseFromJson(
  Map<String, dynamic> json,
) => _AccountLinkConfirmationResponse(
  id: json['id'] as String,
  provider: json['provider'] as String,
  displayNameSnapshot: json['display_name_snapshot'] as String,
  maskedUserEmail: json['masked_user_email'] as String,
);

Map<String, dynamic> _$AccountLinkConfirmationResponseToJson(
  _AccountLinkConfirmationResponse instance,
) => <String, dynamic>{
  'id': instance.id,
  'provider': instance.provider,
  'display_name_snapshot': instance.displayNameSnapshot,
  'masked_user_email': instance.maskedUserEmail,
};
