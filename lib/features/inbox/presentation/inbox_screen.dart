import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:stash_it_app/app/router/routes.dart';
import 'package:stash_it_app/app/theme/app_theme.dart';
import 'package:stash_it_app/core/error/api_failure.dart';
import 'package:stash_it_app/core/error/api_failure_messages.dart';
import 'package:stash_it_app/features/inbox/presentation/widgets/inbox_intake.dart';
import 'package:stash_it_app/features/pending_urls/application/pending_urls_controller.dart';
import 'package:stash_it_app/features/pending_urls/presentation/widgets/pending_urls_entry.dart';
import 'package:stash_it_app/features/saved_items/application/saved_items_controller.dart';
import 'package:stash_it_app/features/saved_items/application/saved_items_state.dart';
import 'package:stash_it_app/features/saved_items/presentation/widgets/saved_item_row.dart';
import 'package:stash_it_app/features/saved_items/presentation/widgets/saved_item_skeleton.dart';
import 'package:stash_it_app/l10n/app_localizations.dart';
import 'package:stash_it_app/shared/widgets/app_button.dart';
import 'package:stash_it_app/shared/widgets/destination_app_bar.dart';

/// The Inbox destination.
///
/// Shows recent saved items across all of the user's collections, using
/// `GET /saved-items`. Each row identifies the collection that currently
/// contains the item. Unsorted is included as one of those collections.
///
/// All item states (`pending`, `completed`, and `failed`) are displayed.
/// A `completed` item does not necessarily have metadata, so an item without
/// a title uses its URL as a neutral fallback rather than showing an error.
///
/// Rows retain the order returned by the API. The server orders them by
/// `created_at DESC, id DESC`; the client does not apply another sort.
///
/// The intake above the list handles new saves. Each confirmed Save URL tap
/// submits one `POST /saved-items` request, then refreshes the list head while
/// preserving pages already loaded. Pulling down refreshes page one and
/// replaces the loaded history with the latest server results.
///
/// The pending-URL queue and collection mutations are handled elsewhere.
class InboxScreen extends ConsumerStatefulWidget {
  const InboxScreen({super.key});

  @override
  ConsumerState<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends ConsumerState<InboxScreen> {
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
  /// The controller prevents duplicate or unusable page requests, so repeated
  /// scroll notifications do not start redundant requests.
  void _onScrolled() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 320) {
      ref.read(savedItemsProvider.notifier).loadMore();
    }
  }

  /// Fetches a fresh first page and replaces the loaded history.
  ///
  /// Existing rows remain visible while refreshing. The skeleton is reserved
  /// for the initial load rather than being shown during a manual refresh.
  Future<void> _refresh() => ref.read(savedItemsProvider.notifier).refresh();

  /// Makes a centred empty or error state pull-to-refresh capable.
  ///
  /// [RefreshIndicator] requires a scrollable descendant. This wrapper gives
  /// non-list states a full-height scroll view with
  /// [AlwaysScrollableScrollPhysics], while keeping the message centred.
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

  @override
  Widget build(BuildContext context) {
    final tokens = AppTheme.tokensOf(context);
    final listing = ref.watch(savedItemsProvider);
    final pendingCount = ref.watch(pendingUrlCountProvider);

    return Scaffold(
      appBar: const DestinationAppBar(title: 'INBOX'),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const InboxIntake(),
          if (pendingCount > 0)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppMetrics.space3,
                AppMetrics.space2,
                AppMetrics.space3,
                0,
              ),
              child: PendingUrlsEntry(
                count: pendingCount,
                onTap: () => context.push(AppRoutes.savedOnDevice),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppMetrics.space3,
              AppMetrics.space3,
              AppMetrics.space3,
              0,
            ),
            child: Text(
              'RECENTLY SAVED',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.sectionLabel.copyWith(
                color: tokens.textTertiary,
              ),
            ),
          ),
          Expanded(child: _body(context, listing)),
        ],
      ),
    );
  }

  Widget _body(BuildContext context, AsyncValue<SavedItemsState> listing) {
    return switch (listing) {
      // An empty page is a successful response and is handled separately from
      // loading and error states.
      AsyncData(:final value) => _rows(context, value),

      // A settled first-page failure. Retry fetches the page again, and the
      // displayed message comes from the typed failure rather than server text.
      // A failed manual refresh also retains the error state.
      AsyncError(:final error, isLoading: false) => _refreshable(
        _InboxError(
          failure: error,
          onRetry: () => ref.read(savedItemsProvider.notifier).retry(),
        ),
      ),
      AsyncError() => const SavedItemSkeletonList(),

      // A genuine first load. Manual refreshes retain the current content and
      // show the RefreshIndicator instead.
      _ => const SavedItemSkeletonList(),
    };
  }

  Widget _rows(BuildContext context, SavedItemsState state) {
    // An empty result is a successful response, not an error. It remains
    // pull-to-refresh capable so newly saved items can appear.
    if (state.items.isEmpty) return _refreshable(const _InboxEmpty());

    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView.separated(
        controller: _scrollController,
        // Allows pull-to-refresh even when the first page does not fill the
        // viewport.
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppMetrics.space3,
          AppMetrics.space2,
          AppMetrics.space3,
          AppMetrics.space4,
        ),
        itemCount: state.items.length + (state.isLoadingMore ? 1 : 0),
        // Each saved item is displayed as a separate card.
        separatorBuilder: (context, index) => const SizedBox(height: 9),
        itemBuilder: (context, index) {
          if (index >= state.items.length) return const _LoadingMoreRow();
          final item = state.items[index];
          return SavedItemRow(
            item: item,
            // Returning from the detail screen preserves this list's scroll
            // position and loaded pages. The detail screen fetches the item
            // again rather than relying on potentially stale row data.
            onTap: () => context.push(AppRoutes.savedItemDetail(item.id)),
          );
        },
      ),
    );
  }
}

/// A loading indicator shown after the existing rows while another page loads.
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

/// The empty state shown when the user has no saved items.
class _InboxEmpty extends StatelessWidget {
  const _InboxEmpty();

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
              'Nothing saved yet',
              textAlign: TextAlign.center,
              style: AppTypography.screenHeading.copyWith(
                fontSize: 15,
                color: tokens.textPrimary,
              ),
            ),
            const SizedBox(height: AppMetrics.space2),
            Text(
              'Save a link and it will appear here, in the collection it belongs to.',
              textAlign: TextAlign.center,
              style: AppTypography.body.copyWith(color: tokens.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

/// An inline listing error with a Retry action.
class _InboxError extends StatelessWidget {
  const _InboxError({required this.failure, required this.onRetry});

  final Object failure;
  final VoidCallback onRetry;

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
              _messageFor(failure, AppLocalizations.of(context)),
              textAlign: TextAlign.center,
              style: AppTypography.body.copyWith(color: tokens.textPrimary),
            ),
            const SizedBox(height: AppMetrics.space4),
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

  /// Selects client-owned copy for a failed listing request.
  ///
  /// Messages are selected from the typed [ApiFailure], not from
  /// `error.message`. A failed read does not change any saved item, so these
  /// messages describe the listing result rather than an item's save status.
  static String _messageFor(
    Object failure,
    AppLocalizations localizations,
  ) => switch (failure) {
    // The session ended or could not be renewed. The router handles the
    // redirect to sign-in; this message explains why the list is unavailable.
    ApiFailureSessionEnded() =>
      'Your session has ended. Sign in again to see your saved items.',
    ApiFailureAuthRequired() => 'Sign in again to see your saved items.',

    ApiFailureServerUnavailable() =>
      'Your saved items are temporarily unavailable. Try again shortly.',

    // The read could not be completed because the server response was not
    // received. This does not indicate that any saved item was changed.
    ApiFailureTransport() =>
      'No connection to the server. We could not load your saved items.',

    // Uses shared client-side copy for other listing failures. Server-provided
    // messages are not displayed.
    _ =>
      genericReadFailureMessage(failure, localizations) ??
          'We could not load your saved items. Try again.',
  };
}
