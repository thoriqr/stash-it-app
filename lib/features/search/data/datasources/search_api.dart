import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/search_response.dart';

part 'search_api.g.dart';

/// The Search API surface, issued over `appDio`.
///
/// Returns the envelope, not a bare model, so `data` and `message` are decoded
/// once at the boundary.
@RestApi()
abstract class SearchApi {
  factory SearchApi(Dio dio, {String? baseUrl}) = _SearchApi;

  /// `GET /search` — one query across the caller's saved items and collections.
  ///
  /// **`q` is the only parameter.** The endpoint does not accept a limit, page,
  /// cursor or sort: its result is capped rather than paged, with no metadata to
  /// paginate. Sending any of those would be inventing a contract.
  ///
  /// **The route is rate limited per user** (30 per minute, namespace
  /// `search-user`) and auth-guarded. `appDio` supplies both the bearer token and
  /// the one-replay session renewal; this client does not handle `401` itself.
  ///
  /// A successful response may carry two empty arrays — that is a successful
  /// search, not a missing resource.
  @GET('/search')
  Future<SearchResponse> search(@Query('q') String query);
}
