// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_router.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The application router.
///
/// Managed by Riverpod so the router can react to authentication state changes
/// through [AuthRefreshNotifier]. Keeping the router alive preserves its
/// navigation state throughout the application lifecycle.
///
/// The four main destinations use [StatefulShellRoute.indexedStack]. Each
/// destination retains its own navigation state when switching between tabs.

@ProviderFor(appRouter)
final appRouterProvider = AppRouterProvider._();

/// The application router.
///
/// Managed by Riverpod so the router can react to authentication state changes
/// through [AuthRefreshNotifier]. Keeping the router alive preserves its
/// navigation state throughout the application lifecycle.
///
/// The four main destinations use [StatefulShellRoute.indexedStack]. Each
/// destination retains its own navigation state when switching between tabs.

final class AppRouterProvider
    extends $FunctionalProvider<GoRouter, GoRouter, GoRouter>
    with $Provider<GoRouter> {
  /// The application router.
  ///
  /// Managed by Riverpod so the router can react to authentication state changes
  /// through [AuthRefreshNotifier]. Keeping the router alive preserves its
  /// navigation state throughout the application lifecycle.
  ///
  /// The four main destinations use [StatefulShellRoute.indexedStack]. Each
  /// destination retains its own navigation state when switching between tabs.
  AppRouterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appRouterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appRouterHash();

  @$internal
  @override
  $ProviderElement<GoRouter> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GoRouter create(Ref ref) {
    return appRouter(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GoRouter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GoRouter>(value),
    );
  }
}

String _$appRouterHash() => r'bd95fc86ee46cdb959a7651f11cd44f90352c97a';
