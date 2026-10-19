import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/create_saved_item_request.dart';
import '../models/create_saved_item_response.dart';
import '../models/list_saved_items_response.dart';

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
}
