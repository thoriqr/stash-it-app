// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_router.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The application router.
///
/// Owned by Riverpod rather than a top-level `final` for two reasons: the
/// redirect needs a `Ref` to read auth state, and the router must be rebuilt
/// when the session changes so `refreshListenable` fires. A top-level singleton
/// could do neither — it has no `Ref`, and one built once would keep a
/// `refreshListenable` that outlives any particular session.
///
/// D1 fixes four destinations: Inbox, Collections, Search, Profile. They are
/// peers, so they sit in a `StatefulShellRoute.indexedStack` and each destination
/// keeps its own navigation state as the user moves between them.
///
/// The pending-URL queue is deliberately absent here: D18 and D25 place it as a
/// section inside the Inbox, not as a fifth destination.

@ProviderFor(appRouter)
final appRouterProvider = AppRouterProvider._();

/// The application router.
///
/// Owned by Riverpod rather than a top-level `final` for two reasons: the
/// redirect needs a `Ref` to read auth state, and the router must be rebuilt
/// when the session changes so `refreshListenable` fires. A top-level singleton
/// could do neither — it has no `Ref`, and one built once would keep a
/// `refreshListenable` that outlives any particular session.
///
/// D1 fixes four destinations: Inbox, Collections, Search, Profile. They are
/// peers, so they sit in a `StatefulShellRoute.indexedStack` and each destination
/// keeps its own navigation state as the user moves between them.
///
/// The pending-URL queue is deliberately absent here: D18 and D25 place it as a
/// section inside the Inbox, not as a fifth destination.

final class AppRouterProvider
    extends $FunctionalProvider<GoRouter, GoRouter, GoRouter>
    with $Provider<GoRouter> {
  /// The application router.
  ///
  /// Owned by Riverpod rather than a top-level `final` for two reasons: the
  /// redirect needs a `Ref` to read auth state, and the router must be rebuilt
  /// when the session changes so `refreshListenable` fires. A top-level singleton
  /// could do neither — it has no `Ref`, and one built once would keep a
  /// `refreshListenable` that outlives any particular session.
  ///
  /// D1 fixes four destinations: Inbox, Collections, Search, Profile. They are
  /// peers, so they sit in a `StatefulShellRoute.indexedStack` and each destination
  /// keeps its own navigation state as the user moves between them.
  ///
  /// The pending-URL queue is deliberately absent here: D18 and D25 place it as a
  /// section inside the Inbox, not as a fifth destination.
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
