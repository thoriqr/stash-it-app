import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/collection_saved_items_response.dart';
import '../models/create_saved_item_request.dart';
import '../models/create_saved_item_response.dart';
import '../models/delete_saved_item_response.dart';
import '../models/enrich_saved_item_response.dart';
import '../models/get_saved_item_response.dart';
import '../models/list_saved_items_response.dart';
import '../models/move_to_collection_request.dart';
import '../models/move_to_collection_response.dart';

part 'saved_items_api.g.dart';

/// The saved-items API surface, accessed through `appDio`.
///
/// Returns response envelopes rather than bare models, so `data`, `message`,
/// and `meta` are decoded at the API boundary.
@RestApi()
abstract class SavedItemsApi {
  factory SavedItemsApi(Dio dio, {String? baseUrl}) = _SavedItemsApi;

  /// `POST /saved-items` — saves one URL to the caller's Unsorted collection.
  ///
  /// Requests rejected before the save operation runs are known not to have
  /// created an item. This includes authentication and rate-limit refusals,
  /// making the authentication interceptor's replay safe in those cases.
  ///
  /// A successful `201` confirms that the item was created. Subsequent
  /// enrichment scheduling does not change that result.
  ///
  /// Returns the minimal create representation rather than a full
  /// [SavedItemSummary].
  @POST('/saved-items')
  Future<CreateSavedItemResponse> create(
    @Body() CreateSavedItemRequest request,
  );

  /// `GET /saved-items` — lists the current user's saved items across all
  /// collections, newest first.
  ///
  /// This is the Inbox listing. Each item identifies the collection it belongs
  /// to, including Unsorted.
  ///
  /// This endpoint is read-only: listing items does not trigger enrichment,
  /// organization, or other writes.
  ///
  /// `limit` is omitted so the server applies its documented default and cap.
  ///
  /// [cursor] is opaque and must be passed back exactly as received. A null
  /// cursor starts from the newest item, so the query parameter is omitted.
  @GET('/saved-items')
  Future<ListSavedItemsResponse> list({@Query('cursor') String? cursor});

  /// `GET /collections/{id}/saved-items` — lists the saved items in one
  /// collection, newest first.
  ///
  /// The collection is returned once in `data.collection`, while each item
  /// contains its own summary. This differs from [list], which spans multiple
  /// collections and therefore identifies the collection on every item.
  ///
  /// `limit` is omitted so the server applies its documented default and cap.
  /// [cursor] is opaque and must be passed back exactly as received. A null
  /// cursor starts from the newest item, so the query parameter is omitted.
  ///
  /// This endpoint is read-only and does not trigger enrichment or organization.
  @GET('/collections/{id}/saved-items')
  Future<ListCollectionSavedItemsResponse> listInCollection(
    @Path('id') String id, {
    @Query('cursor') String? cursor,
  });

  /// `PUT /saved-items/{id}/collection` — moves an item into a collection
  /// selected by name.
  ///
  /// The destination is identified by name, not ID. Name matching ignores
  /// casing and surrounding whitespace.
  ///
  /// `collection_intent` is required:
  /// - `existing` selects an existing collection with that name.
  /// - `create` requests a new collection and is rejected if the user already
  ///   has a collection with that name.
  ///
  /// An absent or unsupported intent is rejected as an invalid request.
  ///
  /// A request targeting the item's current collection returns
  /// `already_in_collection: true` without changing the item.
  ///
  /// The response has no `meta`; see [MoveToCollectionResponse] for its shape.
  /// Server errors, transport failures, and unreadable success responses may
  /// leave the outcome uncertain, so they must not automatically be treated
  /// as proof that the move failed.
  @PUT('/saved-items/{id}/collection')
  Future<MoveToCollectionResponse> moveToCollection(
    @Path('id') String id,
    @Body() MoveToCollectionRequest request,
  );

  /// `GET /saved-items/{id}` — retrieves one saved item and its collection.
  ///
  /// The item and collection are returned as sibling fields. The response has
  /// no `meta`.
  ///
  /// Opening an item does not trigger enrichment or change its collection.
  /// A missing item and an item owned by another user return the same
  /// `404 RESOURCE_NOT_FOUND`; the client cannot distinguish those cases.
  @GET('/saved-items/{id}')
  Future<GetSavedItemResponse> getById(@Path('id') String id);

  /// `POST /saved-items/{id}/enrich` — re-reads the saved item's source page
  /// and records the extraction result.
  ///
  /// The saved URL is read from the server. The item ID is the only input;
  /// no request body or query parameters are needed.
  ///
  /// Authentication and rate-limit refusals occur before the re-read starts.
  /// A `401`, `429`, or `503` therefore means no enrichment attempt was made.
  ///
  /// The operation is synchronous and returns the resulting item directly.
  /// A page that cannot be extracted is reported as a `failed` enrichment
  /// status in a successful `200` response, not as an HTTP failure.
  /// A `pending` status is not returned by this endpoint.
  ///
  /// `404 SAVED_ITEM_NOT_FOUND` also covers an item deleted while the attempt
  /// was running.
  ///
  /// The response contains the same `saved_item` shape as [getById], but
  /// without the sibling `collection`, because enrichment does not change
  /// collection membership. See [EnrichSavedItemResponse].
  @POST('/saved-items/{id}/enrich')
  Future<EnrichSavedItemResponse> enrich(@Path('id') String id);

  /// `DELETE /saved-items/{id}` — permanently deletes one saved item.
  ///
  /// A server error may occur after the item has already been deleted.
  /// Therefore, a server fault does not necessarily establish that the delete
  /// failed.
  ///
  /// The successful response identifies the item's former collection and
  /// indicates whether that collection is now empty and eligible for deletion.
  /// These values are advisory; this request never deletes the collection.
  ///
  /// A missing item and an item owned by another user return the same
  /// `404 RESOURCE_NOT_FOUND`; the client cannot distinguish those cases.
  @DELETE('/saved-items/{id}')
  Future<DeleteSavedItemResponse> delete(@Path('id') String id);
}
