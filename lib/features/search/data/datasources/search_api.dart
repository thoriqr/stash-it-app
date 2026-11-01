import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/search_response.dart';

part 'search_api.g.dart';

/// Defines the Search API client using `appDio`.
///
/// Returns the response envelope rather than a bare model, so `data` and
/// `message` are decoded at the API boundary.
@RestApi()
abstract class SearchApi {
  factory SearchApi(Dio dio, {String? baseUrl}) = _SearchApi;

  /// `GET /search` searches the caller's saved items and collections.
  ///
  /// **`q` is the only supported parameter.** Results are capped rather than
  /// paginated; the endpoint does not accept a limit, page, cursor or sort
  /// parameter and does not return pagination metadata.
  ///
  /// The endpoint requires authentication and is rate-limited per user.
  /// `appDio` supplies the bearer token and handles session renewal, so this
  /// client does not handle `401` responses directly.
  ///
  /// A successful response may contain two empty arrays. This represents a
  /// valid search with no matches, not a missing resource.
  @GET('/search')
  Future<SearchResponse> search(@Query('q') String query);
}
