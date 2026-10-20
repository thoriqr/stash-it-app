import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

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
}
