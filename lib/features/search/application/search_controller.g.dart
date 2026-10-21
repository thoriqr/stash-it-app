// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The Search screen's request lifecycle.
///
/// Owns submission, stale-response protection and clearing. It performs **no
/// request in [build]**: the initial state is complete on its own, which is what
/// keeps a screen visit from spending a rate-limited search.
///
/// **Auto-dispose, not keep-alive.** Results are transient and may name the
/// user's collections, so they must not outlive the screen. The destination's
/// `IndexedStack` branch keeps the screen mounted while the user visits another
/// tab, which keeps the provider alive for exactly as long as it should be; on
/// sign-out the screen unmounts and the state is discarded.

@ProviderFor(Search)
final searchProvider = SearchProvider._();

/// The Search screen's request lifecycle.
///
/// Owns submission, stale-response protection and clearing. It performs **no
/// request in [build]**: the initial state is complete on its own, which is what
/// keeps a screen visit from spending a rate-limited search.
///
/// **Auto-dispose, not keep-alive.** Results are transient and may name the
/// user's collections, so they must not outlive the screen. The destination's
/// `IndexedStack` branch keeps the screen mounted while the user visits another
/// tab, which keeps the provider alive for exactly as long as it should be; on
/// sign-out the screen unmounts and the state is discarded.
final class SearchProvider extends $NotifierProvider<Search, SearchState> {
  /// The Search screen's request lifecycle.
  ///
  /// Owns submission, stale-response protection and clearing. It performs **no
  /// request in [build]**: the initial state is complete on its own, which is what
  /// keeps a screen visit from spending a rate-limited search.
  ///
  /// **Auto-dispose, not keep-alive.** Results are transient and may name the
  /// user's collections, so they must not outlive the screen. The destination's
  /// `IndexedStack` branch keeps the screen mounted while the user visits another
  /// tab, which keeps the provider alive for exactly as long as it should be; on
  /// sign-out the screen unmounts and the state is discarded.
  SearchProvider._()
    : super(
        from: null,
        argument: null,
        retry: _neverRetry,
        name: r'searchProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchHash();

  @$internal
  @override
  Search create() => Search();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SearchState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SearchState>(value),
    );
  }
}

String _$searchHash() => r'8ce268cf0518c5a47c5456c4bbea7396e2c9f4c5';

/// The Search screen's request lifecycle.
///
/// Owns submission, stale-response protection and clearing. It performs **no
/// request in [build]**: the initial state is complete on its own, which is what
/// keeps a screen visit from spending a rate-limited search.
///
/// **Auto-dispose, not keep-alive.** Results are transient and may name the
/// user's collections, so they must not outlive the screen. The destination's
/// `IndexedStack` branch keeps the screen mounted while the user visits another
/// tab, which keeps the provider alive for exactly as long as it should be; on
/// sign-out the screen unmounts and the state is discarded.

abstract class _$Search extends $Notifier<SearchState> {
  SearchState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<SearchState, SearchState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SearchState, SearchState>,
              SearchState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
