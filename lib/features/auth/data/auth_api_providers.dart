import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/network/network_providers.dart';
import 'datasources/auth_api.dart';
import 'datasources/refresh_api.dart';

/// Provides the auth API client using `appDio`.
///
/// Requests pass through the auth interceptor, which handles expired access
/// tokens by renewing them and retrying the original request once. This also
/// allows logout to complete when the access token has expired.
final Provider<AuthApi> authApiProvider = Provider<AuthApi>(
  (ref) => AuthApi(ref.watch(appDioProvider)),
);

/// Provides a separate refresh API client using `refreshDio`.
///
/// Keeping it separate from [authApiProvider] prevents refresh requests from
/// re-entering the auth interceptor and triggering a renewal loop.
final Provider<RefreshApi> refreshApiProvider = Provider<RefreshApi>(
  (ref) => RefreshApi(ref.watch(refreshDioProvider)),
);
