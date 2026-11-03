import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:stash_it_app/app/router/routes.dart';
import 'package:stash_it_app/app/theme/app_theme.dart';
import 'package:stash_it_app/core/error/api_failure.dart';
import 'package:stash_it_app/core/error/api_failure_messages.dart';
import 'package:stash_it_app/features/collections/application/collections_controller.dart';
import 'package:stash_it_app/features/collections/domain/collection_summary.dart';
import 'package:stash_it_app/features/saved_items/application/collection_saved_items_controller.dart';
import 'package:stash_it_app/features/saved_items/application/collection_saved_items_state.dart';
import 'package:stash_it_app/features/saved_items/application/delete_collection_controller.dart';
import 'package:stash_it_app/features/saved_items/presentation/widgets/delete_collection_sheet.dart';
import 'package:stash_it_app/features/saved_items/presentation/widgets/saved_item_row.dart';
import 'package:stash_it_app/features/saved_items/presentation/widgets/saved_item_skeleton.dart';
import 'package:stash_it_app/l10n/app_localizations.dart';
import 'package:stash_it_app/shared/widgets/app_button.dart';
import 'package:stash_it_app/shared/widgets/app_confirm_dialog.dart';
import 'package:stash_it_app/shared/widgets/desktop_layout.dart';

/// Displays a collection and its saved items from the collection listing.
///
/// This is a top-level route outside the main navigation shell. It is opened
/// from a collection tile and uses a dedicated `COLLECTION` app bar.
/// Returning from the screen preserves the Collections branch state, including
/// its sort order and scroll position. Direct entry without a previous route
/// provides a fallback to [AppRoutes.collections].
///
/// The header uses the collection name from the current listing response rather
/// than the potentially stale name from the tile that opened this screen.
///
/// Rows retain the order returned by the API. The server determines the order
/// using `created_at DESC, id DESC`, and this screen does not apply another
/// sorting rule.
///
/// Collection chips are hidden because every row belongs to the same
/// collection, whose name is already shown in the header. Enrichment retry is
/// also omitted from this listing; that action is available on the saved-item
/// detail screen. Read failures have their own retry controls.
///
/// Collection deletion is available only when the listing has settled and
/// the collection's identity is known to be a regular collection rather than
/// Unsorted. An empty listing is also considered settled and can use the
/// simpler deletion confirmation. Identity is determined from the loaded
/// Collections list, never from the display name. This screen does not fetch
/// the Collections list solely to determine whether deletion is available.
class CollectionSavedItemsScreen extends ConsumerStatefulWidget {
  const CollectionSavedItemsScreen({required this.collectionId, super.key});

  /// Collection ID supplied by the route.
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

  /// Requests the next page when the user approaches the end of the list.
  ///
  /// The controller handles duplicate requests, unavailable cursors, and
  /// requests awaiting explicit retry. A failed cursor is not retried
  /// automatically; the footer's Retry action is the only recovery path.
  void _onScrolled() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 320) {
      ref
          .read(collectionSavedItemsProvider(widget.collectionId).notifier)
          .loadMore();
    }
  }

  /// Fetches a fresh first page and replaces the currently loaded pages.
  ///
  /// Existing rows remain visible while refreshing. The loading skeleton is
  /// reserved for the initial load or a retry that replaces the previous
  /// failed result.
  Future<void> _refresh() => ref
      .read(collectionSavedItemsProvider(widget.collectionId).notifier)
      .refresh();

  /// Makes a centered empty or error state compatible with pull-to-refresh.
  ///
  /// A scrollable descendant is required by [RefreshIndicator], even when
  /// the displayed content is not a list.
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

  /// Returns to the previous route, or opens Collections when there is no
  /// previous route.
  ///
  /// Used by the not-found state to provide a safe exit for both direct entry
  /// and navigation from a collection tile.
  void _leave() {
    if (Navigator.of(context).canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.collections);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final listing = ref.watch(
      collectionSavedItemsProvider(widget.collectionId),
    );
    final canPop = Navigator.of(context).canPop();

    // The collection name is available only after a successful page read.
    // During the initial load, show a placeholder; after a settled failure,
    // omit the header rather than displaying an invented name.
    final showHeader = listing.hasValue || listing.isLoading;

    // Deletion requires a settled listing. An empty result is valid, while
    // an initial load or failed first read cannot establish the item count.
    // Refreshing retains the previous result and keeps deletion available.
    final loaded = switch (listing) {
      AsyncData(:final value) => value,
      _ => null,
    };
    final identity = _knownIdentity(ref);
    final deleting = ref.watch(collectionDeletionProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.savedItemCollectionDetailTitle),
        // Always provide a way back. Direct entry has no previous route,
        // so its back action navigates to Collections instead.
        leading: canPop
            ? const BackButton()
            : IconButton(
                icon: const Icon(Icons.arrow_back, size: AppMetrics.iconSize),
                tooltip: l10n.savedItemBackToCollections,
                onPressed: () => context.go(AppRoutes.collections),
              ),
        actions: [
          // Deletion is offered only when the listing is settled and the
          // collection is confirmed not to be Unsorted. Unknown identity
          // hides the action rather than assuming deletion is allowed.
          if (loaded != null && identity != null && !identity.isUnsorted)
            PopupMenuButton<_CollectionAction>(
              tooltip: l10n.savedItemCollectionActionsTooltip,
              enabled: !deleting,
              onSelected: (action) {
                switch (action) {
                  case _CollectionAction.delete:
                    _startDeletion(loaded);
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: _CollectionAction.delete,
                  child: Text(
                    l10n.savedItemDeleteCollectionAction,
                    style: TextStyle(color: AppTheme.tokensOf(context).danger),
                  ),
                ),
              ],
            ),
        ],
      ),
      body: DesktopContentFrame(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showHeader) _header(context, listing),
            Expanded(child: _body(context, listing)),
          ],
        ),
      ),
    );
  }

  /// Finds this collection in the already-loaded Collections list.
  ///
  /// Does not trigger a fetch. If the list has not been loaded or the
  /// collection cannot be found in its current data, its identity remains
  /// unknown and the deletion action stays hidden. Unsorted is identified
  /// by its system identifier, not by its display name.
  CollectionSummary? _knownIdentity(WidgetRef ref) {
    if (!ref.exists(collectionsProvider)) return null;

    final items = switch (ref.watch(collectionsProvider)) {
      AsyncData(:final value) => value.items,
      _ => const <CollectionSummary>[],
    };

    for (final collection in items) {
      if (collection.id == widget.collectionId) return collection;
    }
    return null;
  }

  /// Starts the appropriate deletion flow and leaves when the collection
  /// is confirmed to be gone.
  ///
  /// An empty collection needs only a destructive confirmation because
  /// there are no items to move or discard. A non-empty collection uses the
  /// decision sheet, which offers Move, Delete, and Keep.
  ///
  /// The loaded item count is treated as a total only when all pages have
  /// been fetched. Otherwise, the count passed to the sheet is null.
  ///
  /// The controller handles the request, in-flight guard, cache updates,
  /// and user feedback. This method handles the decision flow and navigation;
  /// it does not retry deletion automatically.
  Future<void> _startDeletion(CollectionSavedItemsState listing) async {
    if (ref.read(collectionDeletionProvider)) return;

    final l10n = AppLocalizations.of(context);
    final name = listing.collectionName;
    // A count is exact only when the listing has no additional pages.
    final itemCount = listing.hasMore ? null : listing.items.length;

    if (itemCount == 0) {
      final confirmed = await showAppConfirmDialog(
        context: context,
        title: name.trim().isEmpty
            ? l10n.savedItemEmptyCollectionDeleteTitle
            : l10n.savedItemDeleteCollectionNamedTitle(name),
        message: l10n.savedItemEmptyCollectionDeleteMessage,
        cancelLabel: l10n.savedItemCancelAction,
        confirmLabel: l10n.savedItemDeleteConfirmAction,
        destructive: true,
      );
      if (confirmed != true || !mounted) return;

      final outcome = await ref
          .read(collectionDeletionProvider.notifier)
          .deleteDiscardingItems(
            collectionId: widget.collectionId,
            collectionName: name,
          );

      if (!mounted) return;
      if (outcome is CollectionDeletionSucceeded ||
          outcome is CollectionDeletionSourceNotFound) {
        _leave();
      }
      return;
    }

    final result = await showDeleteCollectionSheet(
      context,
      collectionId: widget.collectionId,
      collectionName: name,
      itemCount: itemCount,
    );

    if (!mounted) return;
    if (result == DeleteCollectionSheetResult.deleted) _leave();
  }

  /// Displays the collection name or a placeholder while the first page loads.
  ///
  /// The header uses its own [Skeletonizer] rather than wrapping the entire
  /// listing. This keeps the row placeholders from being skeletonized twice.
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
          // The placeholder is visual only; it must not be announced as
          // the collection's actual name.
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
      // A successful empty page is handled separately from loading and errors.
      AsyncData(:final value) => _rows(context, value),

      // A verified not-found response does not distinguish a deleted
      // collection from one belonging to another account. No retry is offered.
      AsyncError(:final error, isLoading: false)
          when error is ApiFailureNotFound =>
        _NotFound(onBack: _leave),

      // A failed initial read can be retried explicitly or through pull-to-refresh.
      AsyncError(:final error, isLoading: false) => _refreshable(
        _LoadError(
          failure: error,
          onRetry: () => ref
              .read(collectionSavedItemsProvider(widget.collectionId).notifier)
              .retry(),
        ),
      ),

      // A retry replaces the failed first-page result, so show the initial
      // loading skeleton while the request is in progress.
      AsyncError() => const SavedItemSkeletonList(showCollectionChip: false),

      // Initial load: no previous page is available to keep on screen.
      _ => const SavedItemSkeletonList(showCollectionChip: false),
    };
  }

  Widget _rows(BuildContext context, CollectionSavedItemsState state) {
    // An empty page is a successful result. Keep it refreshable because
    // the collection may receive items after this response.
    if (state.items.isEmpty) return _refreshable(const _Empty());

    // A failed next-page request stays visible until the user explicitly
    // retries it. Otherwise, show the loading indicator or no footer.
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
        // Allow pull-to-refresh even when the first page does not fill
        // the viewport.
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppMetrics.space3,
          AppMetrics.space2,
          AppMetrics.space3,
          AppMetrics.space4,
        ),
        itemCount: state.items.length + (footer == null ? 0 : 1),
        // Each item is a separate card rather than a row divided by a line.
        separatorBuilder: (context, index) => const SizedBox(height: 9),
        itemBuilder: (context, index) {
          if (index >= state.items.length) return footer!;
          final item = state.items[index];
          return SavedItemRow(
            item: item,
            // The collection name is already shown in the screen header.
            showCollectionChip: false,
            // Push the detail route so returning preserves this listing's
            // loaded pages and scroll position. The detail screen fetches
            // the item again rather than relying on this potentially stale
            // row data. The origin also lets the detail screen return here
            // if the collection is deleted after its last item is removed.
            onTap: () => context.push(
              AppRoutes.savedItemDetail(item.id),
              extra: SavedItemDetailOrigin.collection(widget.collectionId),
            ),
            // Enrichment retry is available from the saved-item detail screen.
          );
        },
      ),
    );
  }
}

/// Actions available from the collection app bar.
enum _CollectionAction { delete }

/// Footer shown while the next page is loading.
class _LoadingMoreRow extends StatelessWidget {
  const _LoadingMoreRow();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
            l10n.savedItemLoadingMore,
            style: AppTypography.meta.copyWith(color: tokens.textTertiary),
          ),
        ],
      ),
    );
  }
}

/// Footer shown when loading the next page fails.
///
/// Previously loaded rows remain visible because a later-page failure does
/// not invalidate earlier pages. The footer provides the explicit retry
/// action for the failed page.
class _LoadMoreFailed extends StatelessWidget {
  const _LoadMoreFailed({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTheme.tokensOf(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppMetrics.space3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: Text(
              l10n.savedItemLoadMoreFailed,
              style: AppTypography.meta.copyWith(color: tokens.textSecondary),
            ),
          ),
          const SizedBox(width: AppMetrics.space2),
          AppButton(
            label: l10n.savedItemRetry,
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

/// Empty state shown when the collection has no saved items.
///
/// An empty page is a successful read, not an error. It therefore has no
/// retry action or error styling.
class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTheme.tokensOf(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppMetrics.space6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.savedItemEmptyCollectionTitle,
              textAlign: TextAlign.center,
              style: AppTypography.screenHeading.copyWith(
                fontSize: 15,
                color: tokens.textPrimary,
              ),
            ),
            const SizedBox(height: AppMetrics.space2),
            Text(
              l10n.savedItemEmptyCollectionBody,
              textAlign: TextAlign.center,
              style: AppTypography.body.copyWith(color: tokens.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

/// State shown when the collection is unavailable.
///
/// The same not-found response can mean that the collection was deleted
/// or belongs to another account. The UI does not reveal which case occurred.
/// No retry is offered because another read cannot make the resource available.
class _NotFound extends StatelessWidget {
  const _NotFound({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTheme.tokensOf(context);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppMetrics.space6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.savedItemCollectionUnavailableTitle,
              textAlign: TextAlign.center,
              style: AppTypography.screenHeading.copyWith(
                color: tokens.textPrimary,
              ),
            ),
            const SizedBox(height: AppMetrics.space2),
            Text(
              l10n.savedItemCollectionUnavailableBody,
              textAlign: TextAlign.center,
              style: AppTypography.body.copyWith(color: tokens.textSecondary),
            ),
            const SizedBox(height: AppMetrics.space5),
            AppButton(
              label: l10n.savedItemBackToCollections,
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

/// Error state for failed reads other than a verified not-found response.
///
/// A malformed not-found response is not treated as proof that the
/// collection is missing. It remains a read failure with an available retry.
class _LoadError extends StatelessWidget {
  const _LoadError({required this.failure, required this.onRetry});

  final Object failure;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTheme.tokensOf(context);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppMetrics.space6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.savedItemCollectionLoadErrorTitle,
              textAlign: TextAlign.center,
              style: AppTypography.screenHeading.copyWith(
                fontSize: 15,
                color: tokens.textPrimary,
              ),
            ),
            const SizedBox(height: AppMetrics.space2),
            Text(
              _messageFor(failure, l10n),
              textAlign: TextAlign.center,
              style: AppTypography.body.copyWith(color: tokens.textSecondary),
            ),
            const SizedBox(height: AppMetrics.space5),
            AppButton(
              label: l10n.savedItemRetry,
              variant: AppButtonVariant.secondary,
              block: false,
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }

  /// Returns client-owned copy for known failure types, falling back to
  /// the shared read-failure message for other errors.
  ///
  /// These are failed reads, not writes with an uncertain outcome. The UI
  /// therefore describes the page as unavailable rather than suggesting
  /// that an operation may or may not have completed.
  static String _messageFor(
    Object failure,
    AppLocalizations localizations,
  ) => switch (failure) {
    ApiFailureSessionEnded() => localizations.savedItemCollectionSessionEnded,
    ApiFailureAuthRequired() => localizations.savedItemCollectionSignInRequired,
    ApiFailureServerUnavailable() =>
      localizations.savedItemCollectionUnavailable,
    ApiFailureTransport() => localizations.savedItemCollectionLoadTransport,
    _ =>
      genericReadFailureMessage(failure, localizations) ??
          localizations.savedItemCollectionLoadGeneric,
  };
}
