// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saved_items_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The Inbox listing: the first page, and any page after it.
///
/// An [AsyncNotifier] rather than a `FutureProvider`, for two reasons. `retry()`
/// has to genuinely **refetch** rather than re-read a cached future, and paging
/// has to **append** to what is already on screen without the list ever passing
/// through a loading state that would blank it.
///
/// **`@Riverpod(keepAlive: true)`.** `@riverpod` generates an auto-dispose
/// provider, which would discard the loaded page every time the user leaves the
/// Inbox for another destination and back. The listing is a recent-history
/// screen, so keeping it is the point.
///
/// **`retry: _neverRetry` — no automatic retry, ever.** Riverpod retries a failed
/// provider build by default: `ProviderContainer.defaultRetry` allows **ten**
/// rebuilds on a 200 ms doubling backoff capped at 6.4 s, and its only
/// exclusions are `ProviderException` and `Error`. An `ApiFailure` is neither —
/// it is a plain sealed class — so every failure below, including
/// `ApiFailureRefreshUncertain`, would be retried.
///
/// That would undo the session policy this client already implements. A renewal
/// that fails ambiguously is deliberately **not** retried: the outcome is
/// genuinely unknown, the stored credentials are kept, and the user decides
/// (`session_controller.dart`, `ApiFailureRefreshUncertain`). A rebuild here
/// issues a brand-new request with a brand-new `RequestOptions`, so the
/// interceptor's one-replay bound resets each time and a second
/// `POST /auth/refresh` presents the **same** refresh token. The backend treats
/// that as reuse, revokes the whole session, and answers `SESSION_REVOKED` — so
/// an automatic retry converts a deliberately preserved session into a terminal
/// one roughly 200 ms later, without the user having touched anything.
///
/// Scoped to this provider deliberately: the session controller and the router
/// keep Riverpod's default, and no global policy is changed. [SavedItems.retry] —
/// which the Inbox's Retry button calls — remains the only way this listing is
/// fetched again, which is the manual retry **D23** asks for.

@ProviderFor(SavedItems)
final savedItemsProvider = SavedItemsProvider._();

/// The Inbox listing: the first page, and any page after it.
///
/// An [AsyncNotifier] rather than a `FutureProvider`, for two reasons. `retry()`
/// has to genuinely **refetch** rather than re-read a cached future, and paging
/// has to **append** to what is already on screen without the list ever passing
/// through a loading state that would blank it.
///
/// **`@Riverpod(keepAlive: true)`.** `@riverpod` generates an auto-dispose
/// provider, which would discard the loaded page every time the user leaves the
/// Inbox for another destination and back. The listing is a recent-history
/// screen, so keeping it is the point.
///
/// **`retry: _neverRetry` — no automatic retry, ever.** Riverpod retries a failed
/// provider build by default: `ProviderContainer.defaultRetry` allows **ten**
/// rebuilds on a 200 ms doubling backoff capped at 6.4 s, and its only
/// exclusions are `ProviderException` and `Error`. An `ApiFailure` is neither —
/// it is a plain sealed class — so every failure below, including
/// `ApiFailureRefreshUncertain`, would be retried.
///
/// That would undo the session policy this client already implements. A renewal
/// that fails ambiguously is deliberately **not** retried: the outcome is
/// genuinely unknown, the stored credentials are kept, and the user decides
/// (`session_controller.dart`, `ApiFailureRefreshUncertain`). A rebuild here
/// issues a brand-new request with a brand-new `RequestOptions`, so the
/// interceptor's one-replay bound resets each time and a second
/// `POST /auth/refresh` presents the **same** refresh token. The backend treats
/// that as reuse, revokes the whole session, and answers `SESSION_REVOKED` — so
/// an automatic retry converts a deliberately preserved session into a terminal
/// one roughly 200 ms later, without the user having touched anything.
///
/// Scoped to this provider deliberately: the session controller and the router
/// keep Riverpod's default, and no global policy is changed. [SavedItems.retry] —
/// which the Inbox's Retry button calls — remains the only way this listing is
/// fetched again, which is the manual retry **D23** asks for.
final class SavedItemsProvider
    extends $AsyncNotifierProvider<SavedItems, SavedItemsState> {
  /// The Inbox listing: the first page, and any page after it.
  ///
  /// An [AsyncNotifier] rather than a `FutureProvider`, for two reasons. `retry()`
  /// has to genuinely **refetch** rather than re-read a cached future, and paging
  /// has to **append** to what is already on screen without the list ever passing
  /// through a loading state that would blank it.
  ///
  /// **`@Riverpod(keepAlive: true)`.** `@riverpod` generates an auto-dispose
  /// provider, which would discard the loaded page every time the user leaves the
  /// Inbox for another destination and back. The listing is a recent-history
  /// screen, so keeping it is the point.
  ///
  /// **`retry: _neverRetry` — no automatic retry, ever.** Riverpod retries a failed
  /// provider build by default: `ProviderContainer.defaultRetry` allows **ten**
  /// rebuilds on a 200 ms doubling backoff capped at 6.4 s, and its only
  /// exclusions are `ProviderException` and `Error`. An `ApiFailure` is neither —
  /// it is a plain sealed class — so every failure below, including
  /// `ApiFailureRefreshUncertain`, would be retried.
  ///
  /// That would undo the session policy this client already implements. A renewal
  /// that fails ambiguously is deliberately **not** retried: the outcome is
  /// genuinely unknown, the stored credentials are kept, and the user decides
  /// (`session_controller.dart`, `ApiFailureRefreshUncertain`). A rebuild here
  /// issues a brand-new request with a brand-new `RequestOptions`, so the
  /// interceptor's one-replay bound resets each time and a second
  /// `POST /auth/refresh` presents the **same** refresh token. The backend treats
  /// that as reuse, revokes the whole session, and answers `SESSION_REVOKED` — so
  /// an automatic retry converts a deliberately preserved session into a terminal
  /// one roughly 200 ms later, without the user having touched anything.
  ///
  /// Scoped to this provider deliberately: the session controller and the router
  /// keep Riverpod's default, and no global policy is changed. [SavedItems.retry] —
  /// which the Inbox's Retry button calls — remains the only way this listing is
  /// fetched again, which is the manual retry **D23** asks for.
  SavedItemsProvider._()
    : super(
        from: null,
        argument: null,
        retry: _neverRetry,
        name: r'savedItemsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$savedItemsHash();

  @$internal
  @override
  SavedItems create() => SavedItems();
}

String _$savedItemsHash() => r'2b274fb835df6b205baab35f3c796ad8409042d9';

/// The Inbox listing: the first page, and any page after it.
///
/// An [AsyncNotifier] rather than a `FutureProvider`, for two reasons. `retry()`
/// has to genuinely **refetch** rather than re-read a cached future, and paging
/// has to **append** to what is already on screen without the list ever passing
/// through a loading state that would blank it.
///
/// **`@Riverpod(keepAlive: true)`.** `@riverpod` generates an auto-dispose
/// provider, which would discard the loaded page every time the user leaves the
/// Inbox for another destination and back. The listing is a recent-history
/// screen, so keeping it is the point.
///
/// **`retry: _neverRetry` — no automatic retry, ever.** Riverpod retries a failed
/// provider build by default: `ProviderContainer.defaultRetry` allows **ten**
/// rebuilds on a 200 ms doubling backoff capped at 6.4 s, and its only
/// exclusions are `ProviderException` and `Error`. An `ApiFailure` is neither —
/// it is a plain sealed class — so every failure below, including
/// `ApiFailureRefreshUncertain`, would be retried.
///
/// That would undo the session policy this client already implements. A renewal
/// that fails ambiguously is deliberately **not** retried: the outcome is
/// genuinely unknown, the stored credentials are kept, and the user decides
/// (`session_controller.dart`, `ApiFailureRefreshUncertain`). A rebuild here
/// issues a brand-new request with a brand-new `RequestOptions`, so the
/// interceptor's one-replay bound resets each time and a second
/// `POST /auth/refresh` presents the **same** refresh token. The backend treats
/// that as reuse, revokes the whole session, and answers `SESSION_REVOKED` — so
/// an automatic retry converts a deliberately preserved session into a terminal
/// one roughly 200 ms later, without the user having touched anything.
///
/// Scoped to this provider deliberately: the session controller and the router
/// keep Riverpod's default, and no global policy is changed. [SavedItems.retry] —
/// which the Inbox's Retry button calls — remains the only way this listing is
/// fetched again, which is the manual retry **D23** asks for.

abstract class _$SavedItems extends $AsyncNotifier<SavedItemsState> {
  FutureOr<SavedItemsState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<SavedItemsState>, SavedItemsState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<SavedItemsState>, SavedItemsState>,
              AsyncValue<SavedItemsState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
