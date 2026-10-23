import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stash_it_app/features/saved_items/data/saved_items_providers.dart';
import 'package:stash_it_app/features/saved_items/domain/saved_item_enrichment_result.dart';
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
/// The GET happens in [build] because opening the detail is precisely the read the
/// screen exists for. The route is not rate limited, so a visit costs one indexed
/// read and nothing else.
///
/// **A notifier rather than a plain `FutureProvider` for one reason:**
/// [applyEnrichment] has to replace the loaded value in place after a confirmed
/// re-read. Invalidating the provider instead would issue a second GET for
/// information the POST already returned, and a failed follow-up would replace a
/// successful re-read with the screen's error state. The notifier keeps the
/// completed POST authoritative.
@Riverpod(retry: _neverRetry)
class SavedItemDetail extends _$SavedItemDetail {
  @override
  Future<SavedItemSummary> build(String id) {
    return ref.watch(savedItemsRepositoryProvider).getById(id);
  }

  /// Applies a confirmed re-read without fetching anything.
  ///
  /// **Only a loaded detail for the same item is updated.** No current data — the
  /// screen is still loading, failed, or was never opened — means there is
  /// nothing to patch, and a different id means the result belongs to another
  /// item. Both are silent no-ops, not errors.
  ///
  /// The collection name and id are preserved: the enrich response carries no
  /// collection, and enrichment never changes membership. Only the four fields the
  /// write actually decided are replaced, through
  /// [SavedItemSummary.copyWithEnrichment].
  ///
  /// **No request is issued here.** The caller has already received the complete
  /// post-attempt item in the POST's `200`.
  void applyEnrichment(SavedItemEnrichmentResult result) {
    final current = switch (state) {
      AsyncData(:final value) => value,
      _ => null,
    };
    if (current == null || current.id != result.savedItemId) return;

    state = AsyncData(
      current.copyWithEnrichment(
        title: result.title,
        description: result.description,
        imageUrl: result.imageUrl,
        enrichmentStatus: result.enrichmentStatus,
      ),
    );
  }
}
