import 'package:dio/dio.dart';

import '../../../core/error/api_failure.dart';
import '../../../core/error/api_failure_mapper.dart';
import '../domain/search_results.dart';
import 'datasources/search_api.dart';
import 'search_mapper.dart';

/// Reads one Search answer, with failures already translated.
///
/// The only layer that converts a [DioException] into an [ApiFailure], so
/// presentation never learns that Dio exists (`AGENTS.md` §2, rule 4). Concrete
/// with no interface, for one implementation.
class SearchRepository {
  const SearchRepository({required this.api, this.now = DateTime.now});

  final SearchApi api;

  /// The clock the saved-time labels are computed against.
  ///
  /// A parameter rather than a direct `DateTime.now` so labels are deterministic
  /// under test. Production passes the default and never reads it back.
  final DateTime Function() now;

  /// Runs one search and returns both result groups in the server's order.
  ///
  /// [query] is sent exactly as supplied. The controller trims it and applies
  /// the rune bounds before calling this, so the request that reaches the wire
  /// is already valid.
  ///
  /// Throws [ApiFailure] on any refusal. The route is rate limited, so
  /// [ApiFailureRateLimited] is an ordinary outcome rather than an unexpected
  /// one; no retry is performed here.
  Future<SearchResults> search(String query) async {
    try {
      final response = await api.search(query);
      final at = now();

      return searchResultsFrom(response.data, now: at);
    } on DioException catch (error) {
      throw mapApiFailure(error);
    } on TypeError catch (error) {
      // A `200` whose body does not match the documented shape. Retrofit
      // decodes after Dio's transformer returns, so this never passes through
      // Dio and `mapApiFailure` cannot see it.
      throw mapDecodeFailure(error);
    } on FormatException catch (error) {
      throw mapDecodeFailure(error);
    }
  }
}
