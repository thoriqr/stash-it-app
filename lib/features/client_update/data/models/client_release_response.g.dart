// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client_release_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ClientReleaseEnvelope _$ClientReleaseEnvelopeFromJson(
  Map<String, dynamic> json,
) => _ClientReleaseEnvelope(
  data: json['data'] == null
      ? null
      : ClientReleaseCheck.fromJson(json['data'] as Map<String, dynamic>),
  message: json['message'] as String?,
);

Map<String, dynamic> _$ClientReleaseEnvelopeToJson(
  _ClientReleaseEnvelope instance,
) => <String, dynamic>{'data': instance.data, 'message': instance.message};

_ClientReleaseCheck _$ClientReleaseCheckFromJson(Map<String, dynamic> json) =>
    _ClientReleaseCheck(
      status: json['status'] as String?,
      latest: json['latest'] == null
          ? null
          : ClientReleaseDto.fromJson(json['latest'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ClientReleaseCheckToJson(_ClientReleaseCheck instance) =>
    <String, dynamic>{'status': instance.status, 'latest': instance.latest};

_ClientReleaseDto _$ClientReleaseDtoFromJson(Map<String, dynamic> json) =>
    _ClientReleaseDto(
      version: json['version'] as String?,
      build: (json['build'] as num?)?.toInt(),
      downloadUrl: json['download_url'] as String?,
      sha256: json['sha256'] as String?,
      fileSizeBytes: (json['file_size_bytes'] as num?)?.toInt(),
      releaseNotes: json['release_notes'] as String?,
      publishedAt: json['published_at'] as String?,
    );

Map<String, dynamic> _$ClientReleaseDtoToJson(_ClientReleaseDto instance) =>
    <String, dynamic>{
      'version': instance.version,
      'build': instance.build,
      'download_url': instance.downloadUrl,
      'sha256': instance.sha256,
      'file_size_bytes': instance.fileSizeBytes,
      'release_notes': instance.releaseNotes,
      'published_at': instance.publishedAt,
    };
