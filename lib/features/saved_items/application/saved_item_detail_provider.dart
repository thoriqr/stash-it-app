import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stash_it_app/features/saved_items/data/saved_items_providers.dart';
import 'package:stash_it_app/features/saved_items/domain/saved_item_summary.dart';

part 'saved_item_detail_provider.g.dart';

/// Riverpod's automatic retry, refused for the detail read.
///
/// **`retry: _neverRetry` is a correctness requirement, not a nicety.** Riverpod
/// retries a failed provider build by default: ten rebuilds on a 200 ms doubling
/// backoff, excluding only `ProviderException` and `Error`. An `ApiFailure` is a
/// plain sealed class, so every failure here — including
/// `ApiFailureRefreshUncertain` — would be retried.
///
/// Each rebuild issues a brand-new request. If the first one reached the
/// authentication interceptor and its renewal failed ambiguously, a retry would
/// present the **same** refresh token again; the backend reads that as reuse and
/// revokes the session. An automatic retry would therefore destroy, without the
/// user acting, the session the client had deliberately preserved.
///
/// Recovery is the explicit Retry action on the screen, which invalidates this
/// provider and issues exactly one new GET — the manual retry **[D23]** asks for.
///
/// A top-level tear-off because `@Riverpod` is a `const` constructor and an
/// inline `(_, __) => null` is not a constant expression.
Duration? _neverRetry(int retryCount, Object error) => null;

/// One saved item, read fresh from `GET /saved-items/{id}`.
///
/// **Auto-dispose, not keep-alive.** The detail is transient screen state, like
/// Search results: it is keyed by the item id, belongs to one visit, and must not
/// outlive the route. This is the opposite of `savedItemsProvider`, which is
/// keep-alive because the Inbox is a retained destination.
///
/// The provider performs the GET in [build] because opening the detail is
/// precisely the read the screen exists for. The route is not rate limited, so a
/// visit costs one indexed read and nothing else.
///
/// **This request never enriches anything.** It is a plain read; the enrichment
/// endpoint is not called by this feature.
@Riverpod(retry: _neverRetry)
Future<SavedItemSummary> savedItemDetail(Ref ref, String id) {
  return ref.watch(savedItemsRepositoryProvider).getById(id);
}
