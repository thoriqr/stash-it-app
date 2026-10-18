import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/network/network_providers.dart';
import 'datasources/auth_api.dart';
import 'datasources/refresh_api.dart';

/// The auth API client, over `appDio`.
///
/// So it carries the bearer token and is renewed transparently. Signing out of
/// an expired session is a normal operation, and routing it through a client
/// that cannot renew would make it fail for the wrong reason: the bearer guard
/// answers `ACCESS_TOKEN_EXPIRED`, the auth interceptor renews and replays the
/// request once, and the revocation lands.
///
/// **Plain [Provider], not `@Riverpod`.** `riverpod_generator` cannot convert a
/// Retrofit `@RestApi` type to code — it raises `InvalidTypeException` on the
/// redirecting factory constructor. A hand-written provider sidesteps the
/// generator entirely, which is the same reason `credentialStoreProvider` and
/// `authRepositoryProvider` are hand-written.
final Provider<AuthApi> authApiProvider = Provider<AuthApi>(
  (ref) => AuthApi(ref.watch(appDioProvider)),
);

/// The refresh API client, over `refreshDio`.
///
/// A separate instance from [authApiProvider], so renewal can never re-enter the
/// auth interceptor and recurse.
final Provider<RefreshApi> refreshApiProvider = Provider<RefreshApi>(
  (ref) => RefreshApi(ref.watch(refreshDioProvider)),
);
