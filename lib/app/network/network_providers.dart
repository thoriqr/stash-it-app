import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/network/auth_interceptor.dart';
import '../../core/network/client_metadata_interceptor.dart';
import '../../features/auth/application/session_controller.dart';
import '../config/api_config.dart';

part 'network_providers.g.dart';

/// How long a request may wait before it is abandoned.
///
/// Set once, here, so both Dio instances share it. Without an explicit ceiling a
/// request on a dead network can hang until the platform's own timeout, which
/// leaves the user looking at a spinner with no way forward.
const Duration _kRequestTimeout = Duration(seconds: 30);

/// The client used for ordinary API requests, including protected endpoints.
///
/// Carries the [AuthInterceptor], so a request issued here picks up the bearer
/// token and is renewed transparently when the session needs it.
@Riverpod(keepAlive: true)
Dio appDio(Ref ref) {
  final dio = Dio(_baseOptions());

  dio.interceptors.addAll([
    ClientMetadataInterceptor(
      platform: _currentPlatform(),
      deviceName: defaultTargetPlatform == TargetPlatform.android
          ? 'Android'
          : 'iOS',
    ),
    AuthInterceptor(
      dio: dio,
      // Watched, not read lazily. The dependency
      // `appDio -> sessionController -> refreshApi -> refreshDio` is acyclic:
      // the session controller reaches the network only through `refreshDio`,
      // which carries no auth interceptor and so cannot depend back on this
      // provider. A captured-`Ref` closure would have hidden that, and would
      // have turned a future cycle into a runtime `CircularDependencyError` at
      // the first request rather than at build time.
      tokenProvider: ref.watch(sessionControllerProvider.notifier),
    ),
  ]);

  return dio;
}

/// The client used **only** for `POST /auth/refresh`.
///
/// Deliberately separate from [appDio] and deliberately without an
/// [AuthInterceptor]. That is what makes recursive renewal structurally
/// impossible rather than guarded against: the renewal response cannot reach
/// the interceptor, because the interceptor is not on this instance.
///
/// The metadata interceptor is present because the same session metadata applies
/// to every call; there is no `Authorization` header here, which is correct —
/// the route has no bearer guard and the body token is the whole credential.
@Riverpod(keepAlive: true)
Dio refreshDio(Ref ref) {
  final dio = Dio(_baseOptions());

  dio.interceptors.add(
    ClientMetadataInterceptor(
      platform: _currentPlatform(),
      deviceName: defaultTargetPlatform == TargetPlatform.android
          ? 'Android'
          : 'iOS',
    ),
  );

  return dio;
}

BaseOptions _baseOptions() {
  return BaseOptions(
    baseUrl: ApiConfig.baseUrl,
    contentType: Headers.jsonContentType,
    // Applies to every response, including error responses.
    //
    // Without it Dio discards non-2xx bodies, and `error.code` — the only thing
    // this client branches on — would be unreachable. `receiveDataWhenStatusError`
    // defaults to true (`dio/src/options.dart:733`); it is set explicitly
    // because the entire error taxonomy depends on it and a future default
    // change would be silent.
    receiveDataWhenStatusError: true,
    connectTimeout: _kRequestTimeout,
    receiveTimeout: _kRequestTimeout,
    sendTimeout: _kRequestTimeout,
  );
}

/// The backend stores this verbatim and shows it in a device list
/// (`auth-sessions.md`, "Identifiers"). It describes the client and is never a
/// saved item's `platform`, which is a different concept entirely.
String _currentPlatform() {
  return switch (defaultTargetPlatform) {
    TargetPlatform.android => 'android',
    TargetPlatform.iOS => 'ios',
    TargetPlatform.macOS => 'macos',
    TargetPlatform.windows => 'windows',
    TargetPlatform.linux => 'linux',
    // Fuchsia and unknown platforms are still worth naming rather than omitting.
    TargetPlatform.fuchsia => 'fuchsia',
  };
}
