// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Manages the Search screen's request lifecycle.
///
/// Owns submission, stale-response protection and clearing. No request is made
/// from [build]; the initial state is complete without a request, so simply
/// opening the screen does not consume the search rate limit.
///
/// The provider uses auto-dispose because search results are transient and
/// may contain the user's collection data. The destination's `IndexedStack`
/// keeps the screen mounted while switching tabs, preserving its state during
/// that time. When the screen unmounts, the provider can be disposed and its
/// state discarded.

@ProviderFor(Search)
final searchProvider = SearchProvider._();

/// Manages the Search screen's request lifecycle.
///
/// Owns submission, stale-response protection and clearing. No request is made
/// from [build]; the initial state is complete without a request, so simply
/// opening the screen does not consume the search rate limit.
///
/// The provider uses auto-dispose because search results are transient and
/// may contain the user's collection data. The destination's `IndexedStack`
/// keeps the screen mounted while switching tabs, preserving its state during
/// that time. When the screen unmounts, the provider can be disposed and its
/// state discarded.
final class SearchProvider extends $NotifierProvider<Search, SearchState> {
  /// Manages the Search screen's request lifecycle.
  ///
  /// Owns submission, stale-response protection and clearing. No request is made
  /// from [build]; the initial state is complete without a request, so simply
  /// opening the screen does not consume the search rate limit.
  ///
  /// The provider uses auto-dispose because search results are transient and
  /// may contain the user's collection data. The destination's `IndexedStack`
  /// keeps the screen mounted while switching tabs, preserving its state during
  /// that time. When the screen unmounts, the provider can be disposed and its
  /// state discarded.
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

/// Manages the Search screen's request lifecycle.
///
/// Owns submission, stale-response protection and clearing. No request is made
/// from [build]; the initial state is complete without a request, so simply
/// opening the screen does not consume the search rate limit.
///
/// The provider uses auto-dispose because search results are transient and
/// may contain the user's collection data. The destination's `IndexedStack`
/// keeps the screen mounted while switching tabs, preserving its state during
/// that time. When the screen unmounts, the provider can be disposed and its
/// state discarded.

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
