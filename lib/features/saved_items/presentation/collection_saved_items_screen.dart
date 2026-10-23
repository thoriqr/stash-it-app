import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:stash_it_app/app/router/routes.dart';
import 'package:stash_it_app/app/theme/app_theme.dart';
import 'package:stash_it_app/core/error/api_failure.dart';
import 'package:stash_it_app/core/error/api_failure_messages.dart';
import 'package:stash_it_app/features/saved_items/application/collection_saved_items_controller.dart';
import 'package:stash_it_app/features/saved_items/application/collection_saved_items_state.dart';
import 'package:stash_it_app/features/saved_items/presentation/widgets/saved_item_row.dart';
import 'package:stash_it_app/features/saved_items/presentation/widgets/saved_item_skeleton.dart';
import 'package:stash_it_app/shared/widgets/app_button.dart';

/// One collection and the items in it, read from
/// `GET /collections/{id}/saved-items`.
///
/// **A top-level route, not a fifth destination.** It sits outside the shell,
/// carries a plain `COLLECTION` app bar with no Settings action, and is reached by
/// pushing from a collection tile. Popping returns to the Collections destination
/// with its branch state — the chosen sort and the scroll position — intact. A
/// direct entry with nothing beneath it falls back to
/// [AppRoutes.collections].
///
/// **The header is the server's name, not the tile's.** The tile that opened the
/// screen had a name from `GET /collections`, which may have been read long
/// before; `data.collection.name` is the name as of this read, and is the only
/// thing displayed here.
///
/// **Rows are rendered in the order the API returned them.** The contract fixes it
/// at `created_at DESC, id DESC` and offers no sort parameter, so sorting here
/// would be a second ordering rule that could disagree with the server's (**D4**).
///
/// The collection chip is hidden on every row: this listing is one collection, so
/// repeating its name down the page adds nothing to the header that already says
/// it. The enrichment Retry is also absent — **[D8]** allows it, but enrichment is
/// handled on the saved-item detail screen, and this screen is a listing. Neither
/// decision touches the API Retry controls, which are the only way to recover from
/// a failed read.
class CollectionSavedItemsScreen extends ConsumerStatefulWidget {
  const CollectionSavedItemsScreen({required this.collectionId, super.key});

  /// The collection's backend-issued id, from the route's `:id` segment.
  final String collectionId;

  @override
  ConsumerState<CollectionSavedItemsScreen> createState() =>
      _CollectionSavedItemsScreenState();
}

class _CollectionSavedItemsScreenState
    extends ConsumerState<CollectionSavedItemsScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScrolled);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScrolled)
      ..dispose();
    super.dispose();
  }

  /// Requests the next page as the user approaches the end.
  ///
  /// Same threshold and same reasoning as the Inbox: the controller refuses a page
  /// it cannot use, one already in flight, and one that is waiting for an explicit
  /// Retry, so a listener that fires repeatedly costs nothing. In particular it
  /// **cannot** restart a failed cursor: that is the footer's Retry alone.
  void _onScrolled() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 320) {
      ref
          .read(collectionSavedItemsProvider(widget.collectionId).notifier)
          .loadMore();
    }
  }

  /// Fetches a fresh first page and replaces the loaded pages.
  ///
  /// The provider does the request and the replacement; the indicator only waits
  /// on it. Current rows stay in the tree while it runs, so the skeleton remains
  /// reserved for a genuine first load.
  Future<void> _refresh() => ref
      .read(collectionSavedItemsProvider(widget.collectionId).notifier)
      .refresh();

  /// Wraps a centred, non-scrolling state so it can still be pulled.
  ///
  /// `RefreshIndicator` needs a scrollable descendant, and the empty and error
  /// states are messages rather than lists.
  Widget _refreshable(Widget child) {
    return RefreshIndicator(
      onRefresh: _refresh,
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: child,
          ),
        ),
      ),
    );
  }

  /// Pops when there is a page to return to, otherwise opens Collections.
  ///
  /// Used by the not-found state's action so a directly-entered missing collection
  /// has the same safe exit as one reached from a tile.
  void _leave() {
    if (Navigator.of(context).canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.collections);
    }
  }

  @override
  Widget build(BuildContext context) {
    final listing = ref.watch(
      collectionSavedItemsProvider(widget.collectionId),
    );
    final canPop = Navigator.of(context).canPop();

    // The name only exists once a page has been read, so the header is drawn in
    // the loading state as a skeleton and omitted from a settled failure — where
    // there is no name to show and inventing one would contradict the error.
    final showHeader = listing.hasValue || listing.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('COLLECTION'),
        // Always a way back. When pushed, that is an ordinary pop; when entered
        // directly there is no page beneath it, so the control says where it goes.
        leading: canPop
            ? const BackButton()
            : IconButton(
                icon: const Icon(Icons.arrow_back, size: AppMetrics.iconSize),
                tooltip: 'Back to Collections',
                onPressed: () => context.go(AppRoutes.collections),
              ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showHeader) _header(context, listing),
          Expanded(child: _body(context, listing)),
        ],
      ),
    );
  }

  /// The collection's name, or a placeholder of the same shape while it is read.
  ///
  /// A second `Skeletonizer` beside the row list rather than around it: nesting
  /// one inside another would skeletonize the placeholders themselves. Both
  /// inherit the config `StashItApp` installs, so the treatment is the app's.
  Widget _header(
    BuildContext context,
    AsyncValue<CollectionSavedItemsState> listing,
  ) {
    final tokens = AppTheme.tokensOf(context);
    final name = switch (listing) {
      AsyncData(:final value) => value.collectionName,
      _ => null,
    };

    final style = AppTypography.screenHeading.copyWith(
      color: tokens.textPrimary,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppMetrics.screenPadding,
        AppMetrics.space5,
        AppMetrics.screenPadding,
        AppMetrics.space3,
      ),
      child: name == null
          // The placeholder never reaches a screen reader: it exists so the bone
          // has a realistic length, not to present an invented name as fact.
          ? ExcludeSemantics(
              child: Skeletonizer(child: Text('Collection name', style: style)),
            )
          : Text(name, style: style),
    );
  }

  Widget _body(
    BuildContext context,
    AsyncValue<CollectionSavedItemsState> listing,
  ) {
    return switch (listing) {
      // [_rows] decides between the empty state and the list, because an empty
      // page is a *successful* answer and must not look like a loading one.
      AsyncData(:final value) => _rows(context, value),

      // The verified `COLLECTION_NOT_FOUND`. Missing and another user's
      // collection share one response on purpose, so the copy says neither. No
      // Retry: re-reading cannot make the collection available, and offering one
      // would promise a recovery that cannot happen.
      AsyncError(:final error, isLoading: false)
          when error is ApiFailureNotFound =>
        _NotFound(onBack: _leave),

      // A failed first page. Retry issues a new initial request through the
      // controller, which also refuses a second one while the first is in flight.
      // Pulling to refresh is the same recovery, so the state stays usable.
      AsyncError(:final error, isLoading: false) => _refreshable(
        _LoadError(
          failure: error,
          onRetry: () => ref
              .read(collectionSavedItemsProvider(widget.collectionId).notifier)
              .retry(),
        ),
      ),

      // A manual retry in flight. The controller publishes `AsyncLoading` while it
      // refetches page one, so the skeleton is the honest state: nothing from the
      // previous attempt is still being shown.
      AsyncError() => const SavedItemSkeletonList(showCollectionChip: false),

      // A genuine first load. A pull does not reach here: it keeps the current
      // rows (or the current empty/error state) in the tree and shows only the
      // RefreshIndicator.
      _ => const SavedItemSkeletonList(showCollectionChip: false),
    };
  }

  Widget _rows(BuildContext context, CollectionSavedItemsState state) {
    // An empty page is a successful answer, not an error and not a loading
    // state: this collection has nothing in it. It is still refreshable, because
    // the answer may have changed on the server since it was read.
    if (state.items.isEmpty) return _refreshable(const _Empty());

    // The footer is one of two things or nothing. A failed page keeps its Retry
    // until the user taps it, so the list never resumes that cursor by itself.
    final footer = state.loadMoreFailed
        ? _LoadMoreFailed(
            onRetry: () => ref
                .read(
                  collectionSavedItemsProvider(widget.collectionId).notifier,
                )
                .retryLoadMore(),
          )
        : state.isLoadingMore
        ? const _LoadingMoreRow()
        : null;

    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView.separated(
        controller: _scrollController,
        // A short first page may not fill the viewport. Always-scrollable
        // physics is what lets the pull gesture reach RefreshIndicator in that
        // case, and is harmless once the list is long enough to scroll.
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppMetrics.space3,
          AppMetrics.space2,
          AppMetrics.space3,
          AppMetrics.space4,
        ),
        itemCount: state.items.length + (footer == null ? 0 : 1),
        // Inventory slots are separate cards on the canvas, not rows divided by a
        // hairline.
        separatorBuilder: (context, index) => const SizedBox(height: 9),
        itemBuilder: (context, index) {
          if (index >= state.items.length) return footer!;
          final item = state.items[index];
          return SavedItemRow(
            item: item,
            // One collection, so the header already says which one. Hidden on the
            // row rather than repeated in smaller type.
            showCollectionChip: false,
            // Pushed above the shell, so returning pops back to this collection
            // with its pages and scroll position intact. The detail reads the item
            // again; it never trusts this row's copy as current. The origin lets
            // the detail pop this screen too if the user deletes this collection
            // after deleting its last item.
            onTap: () => context.push(
              AppRoutes.savedItemDetail(item.id),
              extra: SavedItemDetailOrigin.collection(widget.collectionId),
            ),
            // No `onRetry`: enrichment is acted on in the saved-item detail.
          );
        },
      ),
    );
  }
}

/// A quiet marker at the end of the list while the next page is in flight.
///
/// Distinct from the skeleton because it appears *under* real rows: it says more
/// is coming without pretending the whole list is loading again. Mirrors the
/// Inbox's footer, which is private to that screen.
class _LoadingMoreRow extends StatelessWidget {
  const _LoadingMoreRow();

  @override
  Widget build(BuildContext context) {
    final tokens = AppTheme.tokensOf(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppMetrics.space3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: tokens.accent,
            ),
          ),
          const SizedBox(width: AppMetrics.space2),
          Text(
            'Loading more…',
            style: AppTypography.meta.copyWith(color: tokens.textTertiary),
          ),
        ],
      ),
    );
  }
}

/// The failed page, with the only control that may retry it.
///
/// The rows above this are still valid — a later page failing does not make the
/// earlier ones wrong — so it sits at the end of the list rather than replacing
/// it. The copy is client-owned: the backend's `message` is never rendered
/// (**[D22]**), and this is a read, so nothing here claims an item's fate
/// (**[D15]**).
class _LoadMoreFailed extends StatelessWidget {
  const _LoadMoreFailed({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final tokens = AppTheme.tokensOf(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppMetrics.space3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: Text(
              "Couldn't load more items.",
              style: AppTypography.meta.copyWith(color: tokens.textSecondary),
            ),
          ),
          const SizedBox(width: AppMetrics.space2),
          AppButton(
            label: 'Retry',
            variant: AppButtonVariant.quiet,
            small: true,
            block: false,
            onPressed: onRetry,
          ),
        ],
      ),
    );
  }
}

/// This collection has nothing in it.
///
/// A successful answer with no rows, so it carries no Retry and no error colour.
/// It never claims the items were deleted or never existed — **[D15]**
/// distinguishes "known not saved" from "uncertain", and an empty page is simply
/// an empty page.
class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) {
    final tokens = AppTheme.tokensOf(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppMetrics.space6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Nothing saved here yet',
              textAlign: TextAlign.center,
              style: AppTypography.screenHeading.copyWith(
                fontSize: 15,
                color: tokens.textPrimary,
              ),
            ),
            const SizedBox(height: AppMetrics.space2),
            Text(
              'Items saved to this collection will appear here.',
              textAlign: TextAlign.center,
              style: AppTypography.body.copyWith(color: tokens.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

/// The collection is gone, or is not this account's.
///
/// Only [ApiFailureNotFound] reaches this state, and the copy never says which of
/// the two happened — the backend uses one response on purpose so ids cannot be
/// enumerated. **There is no Retry**: the server has already said the resource is
/// unavailable, and re-reading cannot change that. The action is a way out, not a
/// retry.
class _NotFound extends StatelessWidget {
  const _NotFound({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final tokens = AppTheme.tokensOf(context);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppMetrics.space6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'This collection is no longer available',
              textAlign: TextAlign.center,
              style: AppTypography.screenHeading.copyWith(
                color: tokens.textPrimary,
              ),
            ),
            const SizedBox(height: AppMetrics.space2),
            Text(
              'It may have been deleted, or it may belong to another account.',
              textAlign: TextAlign.center,
              style: AppTypography.body.copyWith(color: tokens.textSecondary),
            ),
            const SizedBox(height: AppMetrics.space5),
            AppButton(
              label: 'Back to Collections',
              variant: AppButtonVariant.secondary,
              block: false,
              onPressed: onBack,
            ),
          ],
        ),
      ),
    );
  }
}

/// Every other failed read: transport, server, auth, unreadable, rate limit.
///
/// Deliberately distinct from [_NotFound]. A malformed `404` is an unreadable
/// response, not a missing collection, and must offer a retry; only the verified
/// `COLLECTION_NOT_FOUND` code may claim the collection is gone.
class _LoadError extends StatelessWidget {
  const _LoadError({required this.failure, required this.onRetry});

  final Object failure;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final tokens = AppTheme.tokensOf(context);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppMetrics.space6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'We could not load this collection',
              textAlign: TextAlign.center,
              style: AppTypography.screenHeading.copyWith(
                fontSize: 15,
                color: tokens.textPrimary,
              ),
            ),
            const SizedBox(height: AppMetrics.space2),
            Text(
              _messageFor(failure),
              textAlign: TextAlign.center,
              style: AppTypography.body.copyWith(color: tokens.textSecondary),
            ),
            const SizedBox(height: AppMetrics.space5),
            AppButton(
              label: 'Retry',
              variant: AppButtonVariant.secondary,
              block: false,
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }

  /// Client-owned copy per failure. The backend's `message` is never rendered
  /// (**[D22]**); `genericReadFailureMessage` supplies the feature-agnostic
  /// remainder.
  ///
  /// A read is not a write, so every one of these is "known not shown" rather than
  /// uncertain: there is no request whose outcome is in doubt, only a page that did
  /// not arrive. **[D15]** therefore does not license "we could not confirm"
  /// wording here, and none uses it.
  static String _messageFor(Object failure) => switch (failure) {
    ApiFailureSessionEnded() =>
      'Your session has ended. Sign in again to see this collection.',
    ApiFailureAuthRequired() => 'Sign in again to see this collection.',
    ApiFailureServerUnavailable() =>
      'This collection is temporarily unavailable. Try again shortly.',
    ApiFailureTransport() =>
      'No connection to the server. We could not load this collection.',
    _ =>
      genericReadFailureMessage(failure) ??
          'We could not load this collection. Try again.',
  };
}
