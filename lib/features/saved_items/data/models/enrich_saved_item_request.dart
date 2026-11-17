import 'package:freezed_annotation/freezed_annotation.dart';

import 'client_metadata.dart';

part 'enrich_saved_item_request.freezed.dart';
part 'enrich_saved_item_request.g.dart';

/// Request body for `POST /saved-items/{id}/enrich`.
///
/// ```json
/// { "metadata": { "title": "...", "platform": "Instagram" } }
/// { "metadata": {} }
/// {}
/// ```
///
/// `metadata` is what the app extracted for a client-enrichment host. For every
/// other host it is omitted and the server fetches the page itself, exactly as
/// before. An empty object is meaningful for a client-enrichment host: it
/// records the attempt as failed instead of leaving the item pending.
@freezed
abstract class EnrichSavedItemRequest with _$EnrichSavedItemRequest {
  const factory EnrichSavedItemRequest({
    @JsonKey(includeIfNull: false, toJson: clientMetadataToJson)
    ClientMetadata? metadata,
  }) = _EnrichSavedItemRequest;

  factory EnrichSavedItemRequest.fromJson(Map<String, dynamic> json) =>
      _$EnrichSavedItemRequestFromJson(json);
}
