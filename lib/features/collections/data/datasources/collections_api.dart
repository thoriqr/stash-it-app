import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/delete_collection_request.dart';
import '../models/delete_collection_response.dart';
import '../models/listed_collection.dart';

part 'collections_api.g.dart';

/// The collections API surface, issued over `appDio`.
@RestApi()
abstract class CollectionsApi {
  factory CollectionsApi(Dio dio, {String? baseUrl}) = _CollectionsApi;

  /// `GET /collections` — list collections for authenticated user.
  ///
  /// Returns cursor-paginated results. Unsorted is pinned first under every sort.
  /// `sort` defaults to "newest" on server; we pass it explicitly to match contract.
  /// `limit` defaults to 20, capped at 50 on server.
  @GET('/collections')
  Future<ListCollectionsResponse> list({
    @Query('sort') String? sort,
    @Query('limit') int? limit,
    @Query('cursor') String? cursor,
  });

  /// `DELETE /collections/{id}` — removes one collection and states what happens
  /// to its saved items.
  ///
  /// **Mounted as `Auth` only** (`collection/routes.go`): no rate limiter. The
  /// body is required; the action is never defaulted.
  ///
  /// This client only sends `saved_items_action: "delete"` with an explicit
  /// `target_collection_id: null`. The follow-up is offered only for a collection
  /// the saved-item delete reported as empty, so deleting its contents is the
  /// intended consequence of the action the user confirmed.
  ///
  /// The `200` carries `data: {}` and a message. Neither is read to establish
  /// success: the response means the delete transaction committed.
  @DELETE('/collections/{id}')
  Future<DeleteCollectionResponse> delete(
    @Path('id') String id,
    @Body() DeleteCollectionRequest request,
  );
}
