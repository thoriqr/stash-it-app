import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stash_it_app/app/theme/app_theme.dart';
import 'package:stash_it_app/core/error/api_failure.dart';
import 'package:stash_it_app/features/inbox/presentation/widgets/inbox_intake.dart';
import 'package:stash_it_app/features/saved_items/application/saved_items_controller.dart';
import 'package:stash_it_app/features/saved_items/application/saved_items_state.dart';
import 'package:stash_it_app/features/saved_items/presentation/widgets/saved_item_row.dart';
import 'package:stash_it_app/features/saved_items/presentation/widgets/saved_item_skeleton.dart';
import 'package:stash_it_app/shared/widgets/app_button.dart';

/// The Inbox destination (S7).
///
/// **[D26] A recent saved items history across every collection the user owns**,
/// read from `GET /saved-items`. Each row names the collection the item currently
/// sits in. Unsorted is one collection among those and is not this screen's
/// subject.
///
/// Nothing is filtered: `pending`, `completed` and `failed` all appear, because
/// the listing does not filter and a client that hid states would be inventing a
/// product rule. **[D8]** `completed` means the enrichment process ran, not that
/// any metadata was found, so a `completed` item with no title renders its URL
/// fallback in neutral copy rather than as a fault.
///
/// Rows are rendered **in the order the API returned them**. The contract fixes
/// it at `created_at DESC, id DESC` with no sort parameter, so sorting here would
/// be a second ordering rule that could disagree with the server's (**D4**).
///
/// Not implemented here, deliberately: URL submission, the clipboard, the
/// pending-URL queue, `POST /saved-items`, and any collection mutation.
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
  /// Throttled by what is loaded rather than by a pixel offset: the controller
  /// already refuses to start a page it cannot use or one already in flight, so
  /// a scroll notification that arrives several times costs nothing.
  void _onScrolled() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 320) {
      ref.read(savedItemsProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AppTheme.tokensOf(context);
    final listing = ref.watch(savedItemsProvider);

    return Scaffold(
      appBar: AppBar(
        // Written uppercase at the call site: Flutter has no text-transform.
        title: const Text('INBOX'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const InboxIntake(),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppMetrics.space3,
              AppMetrics.space2,
              AppMetrics.space3,
              0,
            ),
            child: Text(
              'RECENTLY SAVED',
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
      // [_rows] decides between the empty state and the list, because an empty
      // page is a *successful* answer and must not look like a loading one.
      AsyncData(:final value) => _rows(context, value),

      // A failed first page. Retry refetches — it is not a re-read of a cached
      // future — and the copy is selected from the typed failure, never from a
      // backend message.
      AsyncError(:final error) => _InboxError(
        failure: error,
        onRetry: () => ref.read(savedItemsProvider.notifier).retry(),
      ),

      // Loading, or refreshing while nothing is on screen yet.
      _ => const SavedItemSkeletonList(),
    };
  }

  Widget _rows(BuildContext context, SavedItemsState state) {
    // An empty page is a successful answer, not an error and not a loading
    // state: this user has saved nothing yet.
    if (state.items.isEmpty) return const _InboxEmpty();

    return ListView.separated(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(
        AppMetrics.space3,
        AppMetrics.space2,
        AppMetrics.space3,
        AppMetrics.space4,
      ),
      itemCount: state.items.length + (state.isLoadingMore ? 1 : 0),
      // Inventory slots are separate cards on the canvas, not rows divided by a
      // hairline.
      separatorBuilder: (context, index) => const SizedBox(height: 9),
      itemBuilder: (context, index) {
        if (index >= state.items.length) return const _LoadingMoreRow();
        return SavedItemRow(item: state.items[index]);
      },
    );
  }
}

/// A quiet marker at the end of the list while the next page is in flight.
///
/// Distinct from the skeleton because it appears *under* real rows: it says more
/// is coming without pretending the whole list is loading again.
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

/// This user has saved nothing yet.
///
/// A successful answer with no rows. It never claims the items were deleted or
/// never existed — **[D15]** distinguishes "known not saved" from "uncertain",
/// and an empty page is simply an empty page.
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

/// An inline failure state with a Retry that genuinely refetches.
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
              _messageFor(failure),
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

  /// Client-owned copy for a failed listing read.
  ///
  /// **[D22] Selected from the typed [ApiFailure], never from `error.message`.**
  /// Nothing here names a backend code or status.
  ///
  /// A read is not a write, so **every** one of these is "known not shown"
  /// rather than uncertain — there is no request whose outcome is in doubt, only
  /// a page that did not arrive. **[D15]** therefore does not license "we could
  /// not confirm" wording here, and none uses it.
  static String _messageFor(Object failure) => switch (failure) {
    // The session ended or could not be renewed. The router redirect handles
    // moving the user to sign-in; this says why the list is empty meanwhile.
    ApiFailureSessionEnded() =>
      'Your session has ended. Sign in again to see your saved items.',
    ApiFailureAuthRequired() => 'Sign in again to see your saved items.',

    ApiFailureServerUnavailable() =>
      'Your saved items are temporarily unavailable. Try again shortly.',

    ApiFailureServerFault() =>
      'We could not reach the server. Try again shortly.',

    ApiFailureRateLimited() => 'Too many attempts. Try again shortly.',

    // An unparseable body or a shape this client does not understand. The backend
    // prose is never shown, because it is not part of any contract.
    ApiFailureUnreadableResponse() ||
    ApiFailureMalformedRequest() ||
    ApiFailureValidation() => "We couldn't read the server's reply. Try again.",

    // The one uncertain case, and it is uncertain about a *read*: the request may
    // have been served and the answer lost. Saying so is accurate and says
    // nothing about any item's fate.
    ApiFailureTransport() =>
      'No connection to the server. We could not load your saved items.',

    _ => 'We could not load your saved items. Try again.',
  };
}
