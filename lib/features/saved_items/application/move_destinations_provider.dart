import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stash_it_app/core/error/api_failure.dart';
import 'package:stash_it_app/features/collections/data/collections_providers.dart';
import 'package:stash_it_app/features/collections/domain/collection_summary.dart';

part 'move_destinations_provider.g.dart';

/// Riverpod's automatic retry, refused for the picker read.
///
/// The read is a plain `GET`, but an `ApiFailure` is not an `Error`, so Riverpod's
/// default policy would retry it silently. The sheet has its own visible Retry,
/// and an automatic retry would hide the failure the user needs to see.
Duration? _neverRetry(int retryCount, Object error) => null;

/// Every collection the current item can be moved into.
///
/// **A separate, auto-dispose snapshot — not `collectionsProvider`.** The
/// Collections screen is keep-alive, has its own sort and pages, and silently
/// swallows a failed `loadMore`. Reading it here would either display a stale
/// first page as though it were complete or invoke state-changing methods on a
/// destination the user is not looking at. This provider is created by the sheet,
/// fetches `sort=name` from page one, and is discarded when the sheet closes, so
/// reopening it always asks the server again.
///
/// **All pages are followed.** The contract's default limit is 20 and its cap is
/// 50; a picker that stopped at the first page would omit destinations. A
/// `has_more: true` with no cursor is unreadable rather than complete, because
/// continuing is impossible and stopping would silently hide collections.
///
/// Rows are de-duplicated by id in the server's order. The server already sorts
/// by name; this provider does not sort again (**D4**).
///
/// **Every returned collection is kept, including system collections.** The
/// picker is a view of `GET /collections`; nothing here filters by `type`, name,
/// or `system_key` (**D2**). The current collection is excluded by id in the
/// sheet, because it is context rather than a destination.
@Riverpod(retry: _neverRetry)
Future<List<CollectionSummary>> moveDestinations(Ref ref) async {
  final repository = ref.watch(collectionsRepositoryProvider);
  final destinations = <CollectionSummary>[];
  final seenIds = <String>{};
  final seenCursors = <String>{};
  String? cursor;

  while (true) {
    final page = await repository.list(sort: 'name', cursor: cursor);

    // The sheet may have closed while this page was in flight. The result is
    // discarded by Riverpod anyway; returning keeps the loop from issuing more
    // requests nobody is waiting for.
    if (!ref.mounted) return const [];

    for (final collection in page.items) {
      if (seenIds.add(collection.id)) destinations.add(collection);
    }

    if (!page.hasMore) break;

    final next = page.nextCursor;
    if (next == null || next.isEmpty || !seenCursors.add(next)) {
      throw const ApiFailureUnreadableResponse();
    }
    cursor = next;
  }

  return List<CollectionSummary>.unmodifiable(destinations);
}
