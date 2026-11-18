// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client_metadata.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ClientMetadata _$ClientMetadataFromJson(Map<String, dynamic> json) =>
    _ClientMetadata(
      title: json['title'] as String?,
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String?,
    );

Map<String, dynamic> _$ClientMetadataToJson(_ClientMetadata instance) =>
    <String, dynamic>{
      'title': ?instance.title,
      'description': ?instance.description,
      'image_url': ?instance.imageUrl,
    };
