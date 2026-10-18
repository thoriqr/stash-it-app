// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'network_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The client used for ordinary API requests, including protected endpoints.
///
/// Carries the [AuthInterceptor], so a request issued here picks up the bearer
/// token and is renewed transparently when the session needs it.

@ProviderFor(appDio)
final appDioProvider = AppDioProvider._();

/// The client used for ordinary API requests, including protected endpoints.
///
/// Carries the [AuthInterceptor], so a request issued here picks up the bearer
/// token and is renewed transparently when the session needs it.

final class AppDioProvider extends $FunctionalProvider<Dio, Dio, Dio>
    with $Provider<Dio> {
  /// The client used for ordinary API requests, including protected endpoints.
  ///
  /// Carries the [AuthInterceptor], so a request issued here picks up the bearer
  /// token and is renewed transparently when the session needs it.
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

@ProviderFor(refreshDio)
final refreshDioProvider = RefreshDioProvider._();

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

final class RefreshDioProvider extends $FunctionalProvider<Dio, Dio, Dio>
    with $Provider<Dio> {
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
