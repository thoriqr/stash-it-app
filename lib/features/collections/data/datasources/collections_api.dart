import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/delete_collection_request.dart';
import '../models/delete_collection_response.dart';
import '../models/listed_collection.dart';

part 'collections_api.g.dart';

/// Collections API, using the authenticated application client.
@RestApi()
abstract class CollectionsApi {
  factory CollectionsApi(Dio dio, {String? baseUrl}) = _CollectionsApi;

  /// Lists collections for the authenticated user.
  ///
  /// Results are cursor-paginated. The unsorted collection is pinned first
  /// regardless of the selected sort order. Defaults to `newest` sorting and
  /// a limit of 20 items; the maximum limit is 50.
  @GET('/collections')
  Future<ListCollectionsResponse> list({
    @Query('sort') String? sort,
    @Query('limit') int? limit,
    @Query('cursor') String? cursor,
  });

  /// Deletes a collection and specifies how its saved items are handled.
  ///
  /// The request must include an explicit action and, when moving items, a
  /// destination collection. This client sends `delete` with a null target for
  /// an empty collection, or `move` with the user's selected destination for a
  /// non-empty collection. It never sends `move` without a target or `delete`
  /// with one.
  ///
  /// A successful response indicates that the operation completed. The
  /// response message and empty data object are not used to determine success.
  @DELETE('/collections/{id}')
  Future<DeleteCollectionResponse> delete(
    @Path('id') String id,
    @Body() DeleteCollectionRequest request,
  );
}
