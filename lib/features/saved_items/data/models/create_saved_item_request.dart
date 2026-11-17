import 'package:freezed_annotation/freezed_annotation.dart';

import 'client_metadata.dart';

part 'create_saved_item_request.freezed.dart';
part 'create_saved_item_request.g.dart';

/// Request body for `POST /saved-items`.
///
/// ```json
/// { "url": "https://example.com/articles/1" }
/// { "url": "https://example.com/articles/1", "note": "Read this later." }
/// {
///   "url": "https://www.instagram.com/reel/...",
///   "metadata": { "title": "...", "platform": "Instagram" }
/// }
/// ```
///
/// `url` is required. `note` is optional plain text and may span multiple
/// lines. When it is null, the field is omitted from the JSON body so a save
/// without a note keeps its existing shape.
///
/// `metadata` is sent only for a host whose enrichment the server leaves to the
/// client. For those hosts, sending it makes the save itself the enrichment
/// attempt, so the item is stored completed or failed rather than pending.
/// Omitting it for every other host keeps the server's fetch-and-enqueue
/// behaviour unchanged. An empty metadata object is meaningful: it records a
/// failed attempt for a client-enrichment host.
///
/// The server derives the domain, assigns the item to the caller's Unsorted
/// collection, and leaves metadata for background enrichment when it fetches
/// the page itself.
///
/// The client does not pre-validate the URL. The server validates it and may
/// reject an invalid URL with `VALIDATION_ERROR` or `INVALID_URL`. Both errors
/// indicate that the item was not saved.
///
/// The URL is trimmed before being passed to this request. This is input
/// cleanup, not client-side URL validation. Note text is preserved as entered
/// when it contains non-whitespace content.
@freezed
abstract class CreateSavedItemRequest with _$CreateSavedItemRequest {
  const factory CreateSavedItemRequest({
    required String url,
    @JsonKey(includeIfNull: false) String? note,
    @JsonKey(includeIfNull: false, toJson: clientMetadataToJson)
    ClientMetadata? metadata,
  }) = _CreateSavedItemRequest;

  factory CreateSavedItemRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateSavedItemRequestFromJson(json);
}
