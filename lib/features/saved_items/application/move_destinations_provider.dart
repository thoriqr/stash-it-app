import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stash_it_app/core/error/api_failure.dart';
import 'package:stash_it_app/features/collections/data/collections_providers.dart';
import 'package:stash_it_app/features/collections/domain/collection_page.dart';

part 'move_destinations_provider.g.dart';

/// Riverpod's automatic retry, refused for the preview read.
///
/// The read is a plain `GET`, but an `ApiFailure` is not an `Error`, so Riverpod's
/// default policy would retry it silently. The sheet has its own visible Retry,
/// and an automatic retry would hide the failure the user needs to see.
Duration? _neverRetry(int retryCount, Object error) => null;

/// One extra row beyond the five the main sheet renders.
///
/// The extra slot accounts for the current collection appearing in the first
/// page. Without it, the current collection would displace a real destination
/// and the sheet would show only four rows while claiming to show five.
const int moveDestinationsFetchLimit = 6;

/// The bounded destination preview for the main Move to a collection sheet.
///
/// **A separate, auto-dispose snapshot — not `collectionsProvider`.** The
/// Collections screen is keep-alive, has its own sort and pages, and silently
/// swallows a failed `loadMore`. Reading it here would either display a stale
/// first page as though it were complete or invoke state-changing methods on a
/// destination the user is not looking at. This provider is created by the sheet,
/// fetches `sort=name` from page one, and is discarded when the sheet closes, so
/// reopening it always asks the server again.
///
/// **Only one page is read.** The main sheet shows at most five rows and offers
/// `Browse all collections` when this page has more. The separate, paginated
/// picker follows `next_cursor` on demand; this provider must never fetch every
/// collection just to populate a bounded preview.
///
/// A `has_more: true` with no cursor is unreadable rather than complete, because
/// the sheet cannot tell whether `Browse all collections` can continue.
///
/// The server already sorts by name; this provider does not sort again (**D4**).
/// Every returned collection is kept, including system collections; the current
/// collection is excluded by id in the sheet because it is context, not a
/// destination (**D2**).
@Riverpod(retry: _neverRetry)
Future<CollectionPage> moveDestinations(Ref ref) async {
  final page = await ref
      .watch(collectionsRepositoryProvider)
      .list(sort: 'name', limit: moveDestinationsFetchLimit);

  if (page.hasMore && (page.nextCursor == null || page.nextCursor!.isEmpty)) {
    throw const ApiFailureUnreadableResponse();
  }

  return page;
}
