import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/network/network_providers.dart';
import 'datasources/search_api.dart';
import 'search_repository.dart';

/// The Search client, over `appDio`.
///
/// **`appDio`, not a bare `Dio`.** That client carries the `AuthInterceptor`, so
/// Search picks up the bearer token and an expired one is renewed and replayed
/// without this feature knowing anything about it.
///
/// **Plain [Provider], not `@Riverpod`.** `riverpod_generator` cannot convert a
/// Retrofit `@RestApi` type to code — it raises `InvalidTypeException` on the
/// redirecting factory constructor. This mirrors the saved-items and collections
/// providers.
final Provider<SearchApi> searchApiProvider = Provider<SearchApi>(
  (ref) => SearchApi(ref.watch(appDioProvider)),
);

/// The Search repository.
final Provider<SearchRepository> searchRepositoryProvider =
    Provider<SearchRepository>(
      (ref) => SearchRepository(api: ref.watch(searchApiProvider)),
    );
