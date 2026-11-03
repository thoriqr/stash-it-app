import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/network/auth_interceptor.dart';
import '../../core/network/client_metadata_interceptor.dart';
import '../../features/auth/application/session_controller.dart';
import '../config/api_config.dart';

part 'network_providers.g.dart';

/// Maximum time allowed for connecting, sending, or receiving a request.
const Duration _kRequestTimeout = Duration(seconds: 30);

/// Dio client for ordinary API requests, including protected endpoints.
///
/// Adds authentication and client metadata interceptors. The authentication
/// interceptor handles bearer tokens and session renewal.
@Riverpod(keepAlive: true)
Dio appDio(Ref ref) {
  final dio = Dio(_baseOptions());

  dio.interceptors.addAll([
    ClientMetadataInterceptor(
      platform: _currentPlatform(),
      deviceName: _deviceName(),
    ),
    AuthInterceptor(
      dio: dio,
      // Watch the session controller so Riverpod can detect dependency cycles
      // when building providers, rather than encountering them at request time.
      //
      // The session controller uses refreshDio for token renewal. That client
      // has no AuthInterceptor, keeping the dependency graph acyclic.
      tokenProvider: ref.watch(sessionControllerProvider.notifier),
    ),
  ]);

  return dio;
}

/// Dio client used exclusively for `POST /auth/refresh`.
///
/// Intentionally has no AuthInterceptor. This prevents refresh requests from
/// triggering another refresh cycle. Client metadata is still attached.
@Riverpod(keepAlive: true)
Dio refreshDio(Ref ref) {
  final dio = Dio(_baseOptions());

  dio.interceptors.add(
    ClientMetadataInterceptor(
      platform: _currentPlatform(),
      deviceName: _deviceName(),
    ),
  );

  return dio;
}

BaseOptions _baseOptions() {
  return BaseOptions(
    baseUrl: ApiConfig.baseUrl,
    contentType: Headers.jsonContentType,
    // Preserve response bodies for non-2xx responses so the authentication
    // and error-handling layers can inspect the backend's error payload.
    receiveDataWhenStatusError: true,
    connectTimeout: _kRequestTimeout,
    receiveTimeout: _kRequestTimeout,
    sendTimeout: _kRequestTimeout,
  );
}

/// Returns the platform identifier sent with client metadata.
String _currentPlatform() {
  return switch (defaultTargetPlatform) {
    TargetPlatform.android => 'android',
    TargetPlatform.iOS => 'ios',
    TargetPlatform.macOS => 'macos',
    TargetPlatform.windows => 'windows',
    TargetPlatform.linux => 'linux',
    TargetPlatform.fuchsia => 'fuchsia',
  };
}

/// Returns the device label sent with client metadata.
///
/// Other platforms retain the existing iOS label; Windows uses a fixed name
/// rather than looking up the computer hostname.
String _deviceName() {
  return switch (defaultTargetPlatform) {
    TargetPlatform.android => 'Android',
    TargetPlatform.windows => 'Windows PC',
    _ => 'iOS',
  };
}
