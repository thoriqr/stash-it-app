import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/search_providers.dart';
import '../domain/search_query.dart';
import 'search_state.dart';

part 'search_controller.g.dart';

/// Riverpod's automatic retry, refused for Search.
///
/// Passed to `@Riverpod` as a named function because the annotation is a `const`
/// constructor and an inline `(_, __) => null` is not a constant expression.
/// Returning `null` is how Riverpod is told not to retry: `triggerRetry` treats
/// it as "no delay", arms no timer, and publishes the failure instead.
///
/// **This matters most for the rate limit.** A failed search is an ordinary
/// outcome, and silently reissuing it would spend more of the same per-user
/// budget without the user asking. Recovery is the explicit Retry action, which
/// is the manual retry **[D23]** asks for.
Duration? _neverRetry(int retryCount, Object error) => null;

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
@Riverpod(retry: _neverRetry)
class Search extends _$Search {
  /// Identifies the request whose answer the screen is still waiting for.
  ///
  /// Every submission and every clear increments this. A response is applied
  /// only when its version is still current, so a superseded query cannot
  /// replace newer results and a cleared screen cannot have old results
  /// reappear.
  int _requestVersion = 0;

  @override
  SearchState build() => const SearchState.initial();

  /// Submits [rawQuery], trimming it and validating it first.
  ///
  /// An invalid query is **never sent**: this is the second guard behind the
  /// screen's local validation, and the point is to protect the endpoint's
  /// rate-limit budget from a request that could only be refused. The returned
  /// future completes when the request does, or immediately for an invalid
  /// query.
  ///
  /// A previous request may still be in flight; it is superseded rather than
  /// cancelled, and its answer is ignored when it arrives.
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

      // `error` is an `ApiFailure` from the repository. It is stored typed and
      // never displayed: the screen selects client-owned copy from the variant.
      state = SearchState.failure(query: query, failure: error);
    }
  }

  /// Resubmits the query a failed request used.
  ///
  /// Deliberately **manual only**. Nothing here runs on startup, on returning to
  /// the foreground, or on a connectivity change, and no loop is possible: one
  /// call issues at most one request.
  Future<void> retry() async {
    final failedQuery = switch (state) {
      SearchFailure(:final query) => query,
      _ => null,
    };

    if (failedQuery == null) return;
    await submit(failedQuery);
  }

  /// Returns the screen to its initial state and invalidates any request in
  /// flight.
  ///
  /// The version bump is the invalidation: a response that arrives afterwards
  /// fails its guard and is dropped, so stale results cannot reappear on a
  /// cleared screen.
  void clear() {
    _requestVersion++;
    state = const SearchState.initial();
  }
}
