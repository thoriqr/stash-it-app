import 'package:dio/dio.dart';

import '../../../core/error/api_failure.dart';
import '../../../core/error/api_failure_mapper.dart';
import '../domain/search_results.dart';
import 'datasources/search_api.dart';
import 'search_mapper.dart';

/// Executes Search requests and translates failures into [ApiFailure].
///
/// This is the boundary between the API client and the domain layer:
/// [DioException] is translated here so the presentation layer does not need
/// to depend on Dio. The repository has a single concrete implementation.
class SearchRepository {
  const SearchRepository({required this.api, this.now = DateTime.now});

  final SearchApi api;

  /// Provides the reference time used to calculate saved-time labels.
  ///
  /// Injecting the clock keeps those labels deterministic in tests. Production
  /// uses the default `DateTime.now` implementation.
  final DateTime Function() now;

  /// Executes one search and maps both result groups in server-defined order.
  ///
  /// [query] is sent unchanged. The controller is responsible for trimming
  /// and validating it before calling this method.
  ///
  /// Throws [ApiFailure] when the request fails. Rate limiting is an expected
  /// search outcome; this repository does not retry failed requests.
  Future<SearchResults> search(String query) async {
    try {
      final response = await api.search(query);
      final at = now();

      return searchResultsFrom(response.data, now: at);
    } on DioException catch (error) {
      throw mapApiFailure(error);
    } on TypeError catch (error) {
      // Retrofit may fail while decoding a successful response whose body
      // does not match the expected shape. This happens outside Dio's
      // exception pipeline, so mapApiFailure cannot handle it.
      throw mapDecodeFailure(error);
    } on FormatException catch (error) {
      throw mapDecodeFailure(error);
    }
  }
}
