import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/list_saved_items_response.dart';

part 'saved_items_api.g.dart';

/// The saved-items API surface, issued over `appDio`.
///
/// Returns the envelope, not a bare model, so `data`, `message` and `meta` are
/// decoded once at the boundary.
@RestApi()
abstract class SavedItemsApi {
  factory SavedItemsApi(Dio dio, {String? baseUrl}) = _SavedItemsApi;

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
