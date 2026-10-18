import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/network/network_providers.dart';
import 'datasources/saved_items_api.dart';
import 'saved_items_repository.dart';

/// The saved-items client, over `appDio`.
///
/// **`appDio`, not a bare `Dio`.** That client carries the `AuthInterceptor`, so
/// the listing picks up the bearer token and an expired one is renewed and the
/// request replayed without this feature knowing anything about it. Adding a
/// second interceptor, or handling `ACCESS_TOKEN_EXPIRED` here, would duplicate
/// the session flow that already owns it.
///
/// **Plain [Provider], not `@Riverpod`.** `riverpod_generator` cannot convert a
/// Retrofit `@RestApi` type to code — it raises `InvalidTypeException` on the
/// redirecting factory constructor. Hand-written providers sidestep it entirely,
/// which is why `authApiProvider` and `authRepositoryProvider` are hand-written
/// too.
final Provider<SavedItemsApi> savedItemsApiProvider = Provider<SavedItemsApi>(
  (ref) => SavedItemsApi(ref.watch(appDioProvider)),
);

/// The Inbox listing repository.
final Provider<SavedItemsRepository> savedItemsRepositoryProvider =
    Provider<SavedItemsRepository>(
      (ref) => SavedItemsRepository(api: ref.watch(savedItemsApiProvider)),
    );
