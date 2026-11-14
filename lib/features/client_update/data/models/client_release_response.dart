import 'package:freezed_annotation/freezed_annotation.dart';

part 'client_release_response.freezed.dart';
part 'client_release_response.g.dart';

/// The whole `200` body of `GET /client-releases/latest`.
///
/// The success envelope has `data` and `message` but no `meta`.
@freezed
abstract class ClientReleaseEnvelope with _$ClientReleaseEnvelope {
  const factory ClientReleaseEnvelope({
    ClientReleaseCheck? data,
    String? message,
  }) = _ClientReleaseEnvelope;

  factory ClientReleaseEnvelope.fromJson(Map<String, dynamic> json) =>
      _$ClientReleaseEnvelopeFromJson(json);
}

/// The server's update decision for the requested platform and build.
@freezed
abstract class ClientReleaseCheck with _$ClientReleaseCheck {
  const factory ClientReleaseCheck({String? status, ClientReleaseDto? latest}) =
      _ClientReleaseCheck;

  factory ClientReleaseCheck.fromJson(Map<String, dynamic> json) =>
      _$ClientReleaseCheckFromJson(json);
}

/// The latest published release for the platform.
@freezed
abstract class ClientReleaseDto with _$ClientReleaseDto {
  const factory ClientReleaseDto({
    String? version,
    int? build,
    @JsonKey(name: 'download_url') String? downloadUrl,
    String? sha256,
    @JsonKey(name: 'file_size_bytes') int? fileSizeBytes,
    @JsonKey(name: 'release_notes') String? releaseNotes,
    @JsonKey(name: 'published_at') String? publishedAt,
  }) = _ClientReleaseDto;

  factory ClientReleaseDto.fromJson(Map<String, dynamic> json) =>
      _$ClientReleaseDtoFromJson(json);
}
