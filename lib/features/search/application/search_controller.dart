import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/search_providers.dart';
import '../domain/search_query.dart';
import 'search_state.dart';

part 'search_controller.g.dart';

/// Disables Riverpod's automatic retry for Search.
///
/// Riverpod receives this as a named function because the `@Riverpod`
/// annotation uses a const constructor and an inline closure is not a constant
/// expression. Returning `null` prevents Riverpod from scheduling another
/// attempt and allows the failure to be published immediately.
///
/// Automatic retries are especially undesirable for rate-limited searches:
/// repeating a failed request would consume more of the user's request budget
/// without an explicit action. Recovery is available through the screen's
/// manual Retry action.
Duration? _neverRetry(int retryCount, Object error) => null;

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
@Riverpod(retry: _neverRetry)
class Search extends _$Search {
  /// Identifies the request whose response is still allowed to update the state.
  ///
  /// Each submission and clear operation increments this version. A response
  /// is applied only if its version is still current. This prevents an older
  /// query from replacing newer results and prevents cleared results from
  /// reappearing.
  int _requestVersion = 0;

  @override
  SearchState build() => const SearchState.initial();

  /// Submits [rawQuery] after validation and normalization.
  ///
  /// Invalid queries are never sent. This provides a second validation guard
  /// beyond the screen and avoids spending the endpoint's rate-limit budget on
  /// requests that would be rejected.
  ///
  /// The returned future completes when the request finishes, or immediately
  /// when the query is invalid. A previous request is not cancelled when a
  /// new one starts; its response is ignored if its version is no longer
  /// current.
  Future<void> submit(String rawQuery) async {
    if (validateSearchQuery(rawQuery) != null) return;

    final query = normalizeSearchQuery(rawQuery);
    final version = ++_requestVersion;

    state = SearchState.loading(query: query);

    try {
      final results = await ref.read(searchRepositoryProvider).search(query);

      if (!ref.mounted || version != _requestVersion) return;

      state = SearchState.success(
        query: query,
        collections: results.collections,
        savedItems: results.savedItems,
      );
    } catch (error) {
      if (!ref.mounted || version != _requestVersion) return;

      // Store the repository failure as a typed value. The screen displays
      // client-owned copy based on its failure variant, not the raw error.
      state = SearchState.failure(query: query, failure: error);
    }
  }

  /// Manually resubmits the query associated with the current failure.
  ///
  /// No automatic retry occurs on startup, foreground return or connectivity
  /// changes. Each call issues at most one request.
  Future<void> retry() async {
    final failedQuery = switch (state) {
      SearchFailure(:final query) => query,
      _ => null,
    };

    if (failedQuery == null) return;
    await submit(failedQuery);
  }

  /// Restores the initial state and invalidates any request still in flight.
  ///
  /// Incrementing the request version makes any subsequent response from an
  /// earlier request fail its version check, preventing stale results from
  /// being applied to the cleared screen.
  void clear() {
    _requestVersion++;
    state = const SearchState.initial();
  }
}
