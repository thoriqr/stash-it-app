import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/collection_saved_items_response.dart';
import '../models/create_saved_item_request.dart';
import '../models/create_saved_item_response.dart';
import '../models/get_saved_item_response.dart';
import '../models/list_saved_items_response.dart';
import '../models/move_to_collection_request.dart';
import '../models/move_to_collection_response.dart';

part 'saved_items_api.g.dart';

/// The saved-items API surface, issued over `appDio`.
///
/// Returns the envelope, not a bare model, so `data`, `message` and `meta` are
/// decoded once at the boundary.
@RestApi()
abstract class SavedItemsApi {
  factory SavedItemsApi(Dio dio, {String? baseUrl}) = _SavedItemsApi;

  /// `POST /saved-items` — saves one URL to the caller's Unsorted collection.
  ///
  /// **Mounted as `Auth` → per-user rate limit → handler**, in that order
  /// (`saved_item/routes.go`). Two consequences matter above this layer:
  ///
  /// - A refused request never reaches the handler, so a `401` from the guard and
  ///   a `429`/`503` from the limiter are both *known not saved*. That is what
  ///   makes the interceptor's single replay of this request safe: the first
  ///   attempt was rejected before any work ran.
  /// - The handler answers `201` only after the insert committed. A single
  ///   autocommit statement is the whole write, and the enrichment enqueue that
  ///   follows it has its failure logged and swallowed — so a `201` cannot be
  ///   contradicted by anything that happens after it.
  ///
  /// The response is the minimal create representation; see
  /// `CreatedSavedItemResponse` for why it is not a `SavedItemSummary`.
  @POST('/saved-items')
  Future<CreateSavedItemResponse> create(
    @Body() CreateSavedItemRequest request,
  );

  /// `GET /saved-items` — the current user's recent saved items, newest first.
  ///
  /// **[D26] This is the Inbox listing.** Every saved item the user owns, across
  /// every collection they own, with each item naming the collection it sits in.
  /// Unsorted is one collection among those and is not this listing's subject.
  ///
  /// Read-only. It never starts enrichment, never organizes anything and never
  /// writes, so reading the history is not a reason to fetch anything.
  ///
  /// **`limit` is deliberately not sent.** The documented default is 20 and the
  /// cap is 50; the server enforces both, and restating a cap the client does not
  /// own would be a second place for it to be wrong.
  ///
  /// **[cursor] is opaque and is passed back exactly as received.** It is never
  /// parsed, logged or rebuilt: the contract states a cursor records a position
  /// rather than an item, and its contents are not part of the API surface. Null
  /// means "start at the newest item", which is why the query parameter is
  /// omitted rather than sent empty.
  @GET('/saved-items')
  Future<ListSavedItemsResponse> list({@Query('cursor') String? cursor});

  /// `GET /collections/{id}/saved-items` — one collection's saved items, newest
  /// first.
  ///
  /// **Mounted as `Auth` only** (`collection/routes.go`): the route has no rate
  /// limiter, so there is no budget variant to anticipate and no `Retry-After` to
  /// read.
  ///
  /// **The collection is reported once, in `data.collection`**, because this
  /// listing is scoped to one collection. That is the opposite of
  /// [list]'s shape, where every row names its own collection because the page
  /// spans them.
  ///
  /// **`limit` is deliberately not sent**, for the same reason as [list]: the
  /// documented default is 20 and the cap is 50, and the server enforces both.
  /// Restating a cap the client does not own would be a second place for it to be
  /// wrong.
  ///
  /// **[cursor] is opaque and is passed back exactly as received.** Null means
  /// "start at the newest item", which is why the query parameter is omitted
  /// rather than sent empty.
  ///
  /// Read-only: viewing a collection never enriches anything, never organizes and
  /// never writes.
  @GET('/collections/{id}/saved-items')
  Future<ListCollectionSavedItemsResponse> listInCollection(
    @Path('id') String id, {
    @Query('cursor') String? cursor,
  });

  /// `PUT /saved-items/{id}/collection` — file an item into a collection by
  /// name, with the caller stating whether the name selects an existing
  /// destination or asks for a new collection.
  ///
  /// **Mounted as `Auth` only** (`collection/routes.go`): the route has no rate
  /// limiter. A `401` therefore comes from the guard before any write. Other
  /// failures are classified by [ApiFailure]; the mutation treats a `5xx`, a
  /// transport failure and an unreadable success body as unestablished, because
  /// none of them proves the write did not land.
  ///
  /// **The destination is a name, never an id.** The backend resolves the name
  /// case-insensitively with surrounding whitespace ignored. `collection_intent`
  /// is required and has no default: `existing` reuses a collection of either
  /// type that holds the name (and keeps the create-or-get fallback), while
  /// `create` asks for a new collection and refuses a name already held by one
  /// of the user's collections with `COLLECTION_NAME_ALREADY_EXISTS`. An absent
  /// or unknown intent answers `400 INVALID_COLLECTION_INTENT`.
  ///
  /// A repeated request for the collection the item is already in answers `200`
  /// with `already_in_collection: true`, writes nothing and leaves `updated_at`
  /// unchanged.
  ///
  /// The body has no `meta`; see [MoveToCollectionResponse] for the exact shape.
  @PUT('/saved-items/{id}/collection')
  Future<MoveToCollectionResponse> moveToCollection(
    @Path('id') String id,
    @Body() MoveToCollectionRequest request,
  );

  /// `GET /saved-items/{id}` — one saved item with the collection it is filed in.
  ///
  /// **Mounted as `Auth` only** (`saved_item/routes.go`): the route is not rate
  /// limited, because it performs one indexed read and fetches nothing. Unlike
  /// the enrich endpoint, opening an item never starts enrichment, writes
  /// enrichment state, or moves the item between collections.
  ///
  /// The body carries the complete item and its collection as **siblings**, not
  /// as the listing's nested object, and no `meta`. A missing item and one owned
  /// by another user both answer the same `404 RESOURCE_NOT_FOUND`, so the
  /// client cannot tell the two apart and must not say which happened.
  @GET('/saved-items/{id}')
  Future<GetSavedItemResponse> getById(@Path('id') String id);
}
