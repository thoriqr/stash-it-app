import 'package:freezed_annotation/freezed_annotation.dart';

import 'listed_saved_item.dart';

part 'list_saved_items_response.freezed.dart';
part 'list_saved_items_response.g.dart';

/// `meta.cursor` of `GET /saved-items`.
@freezed
abstract class CursorPageMetaResponse with _$CursorPageMetaResponse {
  const factory CursorPageMetaResponse({
    @JsonKey(name: 'has_more') required bool hasMore,
    @JsonKey(name: 'next_cursor') String? nextCursor,
  }) = _CursorPageMetaResponse;

  factory CursorPageMetaResponse.fromJson(Map<String, dynamic> json) =>
      _$CursorPageMetaResponseFromJson(json);
}

/// `meta` of `GET /saved-items`.
@freezed
abstract class ListSavedItemsMetaResponse with _$ListSavedItemsMetaResponse {
  const factory ListSavedItemsMetaResponse({
    required CursorPageMetaResponse cursor,
  }) = _ListSavedItemsMetaResponse;

  factory ListSavedItemsMetaResponse.fromJson(Map<String, dynamic> json) =>
      _$ListSavedItemsMetaResponseFromJson(json);
}

/// `data` of a successful `GET /saved-items`.
///
/// **Not nullable.** Every response to this route carries a page, and an empty
/// one is `{"saved_items": []}` rather than `null` — the contract says so
/// explicitly, so a missing `data` is a shape this client does not understand
/// rather than an empty result.
@freezed
abstract class ListSavedItemsDataResponse with _$ListSavedItemsDataResponse {
  const factory ListSavedItemsDataResponse({
    @JsonKey(name: 'saved_items')
    required List<ListedSavedItemResponse> savedItems,
  }) = _ListSavedItemsDataResponse;

  factory ListSavedItemsDataResponse.fromJson(Map<String, dynamic> json) =>
      _$ListSavedItemsDataResponseFromJson(json);
}

/// The whole `200` body of `GET /saved-items`.
///
/// ```json
/// {
///   "data": { "saved_items": [ ... ] },
///   "message": "saved items retrieved successfully",
///   "meta": { "cursor": { "has_more": true, "next_cursor": "eyJ2Ijox..." } }
/// }
/// ```
///
/// A saved-items envelope rather than the shared `ApiEnvelope<T>`, because **this**
/// route's `meta` is typed and `ApiEnvelope.meta` is an untyped `Map`. Decoding
/// the cursor out of a map by hand would put the one structured part of the
/// contract behind string keys; the shape here is the contract, so it is declared.
///
/// **`next_cursor` is nullable and is the only way to know there is a next
/// page.** It is explicitly `null` on the final page, where `has_more` is false.
@freezed
abstract class ListSavedItemsResponse with _$ListSavedItemsResponse {
  const factory ListSavedItemsResponse({
    required ListSavedItemsDataResponse data,
    String? message,
    ListSavedItemsMetaResponse? meta,
  }) = _ListSavedItemsResponse;

  factory ListSavedItemsResponse.fromJson(Map<String, dynamic> json) =>
      _$ListSavedItemsResponseFromJson(json);
}
