import 'package:freezed_annotation/freezed_annotation.dart';

part 'client_metadata.freezed.dart';
part 'client_metadata.g.dart';

/// Metadata the app extracted for a host the server leaves to the client.
///
/// Mirrors `clientmetadata.Metadata`. Every field is optional, and a field that
/// is null is omitted from the JSON body. An instance with every field null
/// serializes as `{}`, which the server stores as a failed enrichment attempt
/// for a client-enrichment host.
///
/// The server derives the platform from the URL host, so the client sends only
/// the extracted fields. The client trims whitespace and decodes HTML entities
/// before building an instance. The title and description are sent as
/// extracted, without truncation: the server applies its own Instagram title
/// handling and owns the field limits. An image URL that is not an absolute
/// http/https URL within the limit is dropped rather than sent.
@freezed
abstract class ClientMetadata with _$ClientMetadata {
  const factory ClientMetadata({
    @JsonKey(includeIfNull: false) String? title,
    @JsonKey(includeIfNull: false) String? description,
    @JsonKey(name: 'image_url', includeIfNull: false) String? imageUrl,
  }) = _ClientMetadata;

  factory ClientMetadata.fromJson(Map<String, dynamic> json) =>
      _$ClientMetadataFromJson(json);
}

/// Serializes [metadata] as a plain map for a nested request field.
///
/// json_serializable omits a nested `toJson` call by default and would leave
/// the object to the transport encoder. This helper keeps the request's own
/// `toJson` JSON-ready, so the wire shape is the same everywhere it is built.
Map<String, dynamic>? clientMetadataToJson(ClientMetadata? metadata) =>
    metadata?.toJson();
