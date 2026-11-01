// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'network_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Dio client for ordinary API requests, including protected endpoints.
///
/// Adds authentication and client metadata interceptors. The authentication
/// interceptor handles bearer tokens and session renewal.

@ProviderFor(appDio)
final appDioProvider = AppDioProvider._();

/// Dio client for ordinary API requests, including protected endpoints.
///
/// Adds authentication and client metadata interceptors. The authentication
/// interceptor handles bearer tokens and session renewal.

final class AppDioProvider extends $FunctionalProvider<Dio, Dio, Dio>
    with $Provider<Dio> {
  /// Dio client for ordinary API requests, including protected endpoints.
  ///
  /// Adds authentication and client metadata interceptors. The authentication
  /// interceptor handles bearer tokens and session renewal.
  AppDioProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appDioProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appDioHash();

  @$internal
  @override
  $ProviderElement<Dio> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Dio create(Ref ref) {
    return appDio(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Dio value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Dio>(value),
    );
  }
}

String _$appDioHash() => r'34f73601cdd78856c8141c3247b249d236391c59';

/// Dio client used exclusively for `POST /auth/refresh`.
///
/// Intentionally has no AuthInterceptor. This prevents refresh requests from
/// triggering another refresh cycle. Client metadata is still attached.

@ProviderFor(refreshDio)
final refreshDioProvider = RefreshDioProvider._();

/// Dio client used exclusively for `POST /auth/refresh`.
///
/// Intentionally has no AuthInterceptor. This prevents refresh requests from
/// triggering another refresh cycle. Client metadata is still attached.

final class RefreshDioProvider extends $FunctionalProvider<Dio, Dio, Dio>
    with $Provider<Dio> {
  /// Dio client used exclusively for `POST /auth/refresh`.
  ///
  /// Intentionally has no AuthInterceptor. This prevents refresh requests from
  /// triggering another refresh cycle. Client metadata is still attached.
  RefreshDioProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'refreshDioProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$refreshDioHash();

  @$internal
  @override
  $ProviderElement<Dio> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Dio create(Ref ref) {
    return refreshDio(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Dio value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Dio>(value),
    );
  }
}

String _$refreshDioHash() => r'e83c62831ea0798c0312491f705665eadc4dd0b2';
