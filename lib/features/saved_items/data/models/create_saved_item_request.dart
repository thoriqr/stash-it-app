import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_saved_item_request.freezed.dart';
part 'create_saved_item_request.g.dart';

/// Request body for `POST /saved-items`.
///
/// ```json
/// { "url": "https://example.com/articles/1" }
/// { "url": "https://example.com/articles/1", "note": "Read this later." }
/// ```
///
/// `url` is required. `note` is optional plain text and may span multiple
/// lines. When it is null, the field is omitted from the JSON body so a save
/// without a note keeps its existing shape.
///
/// The server derives the domain, assigns the item to the caller's Unsorted
/// collection, and leaves metadata for background enrichment.
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
  }) = _CreateSavedItemRequest;

  factory CreateSavedItemRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateSavedItemRequestFromJson(json);
}
