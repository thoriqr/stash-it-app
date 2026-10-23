import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:stash_it_app/app/router/routes.dart';
import 'package:stash_it_app/app/theme/app_theme.dart';
import 'package:stash_it_app/core/error/api_failure.dart';
import 'package:stash_it_app/core/error/api_failure_messages.dart';
import 'package:stash_it_app/features/saved_items/application/delete_saved_item_controller.dart';
import 'package:stash_it_app/features/saved_items/application/saved_item_detail_provider.dart';
import 'package:stash_it_app/features/saved_items/domain/saved_item_summary.dart';
import 'package:stash_it_app/shared/widgets/app_button.dart';
import 'package:stash_it_app/shared/widgets/app_confirm_dialog.dart';

import 'widgets/move_to_collection_sheet.dart';
import 'widgets/saved_item_collection_chip.dart';
import 'widgets/saved_item_enrichment_state.dart';
import 'widgets/saved_item_preview.dart';

/// One saved item, read fresh from `GET /saved-items/{id}`.
///
/// **A top-level route, not a fifth destination.** It sits outside the shell,
/// has its own `ITEM` app bar and no Settings action, and is reached by pushing
/// from a row. Popping returns to the Inbox with its branch state and scroll
/// position intact; a direct entry with nothing beneath it falls back to
/// [AppRoutes.inbox].
///
/// **Opening this screen only reads.** The only request a visit makes by itself is
/// the GET behind [savedItemDetailProvider]. Viewing never enriches, extracts,
/// polls, refreshes in the background, moves, or deletes. The explicit **Move to
/// a collection** action issues one `PUT` only after the user chooses a
/// destination; the enrichment control beside it is deliberately inert.
///
/// **Delete is explicit and confirmed.** The danger action below Move opens the
/// first confirmation dialog. Only a confirmed choice issues
/// `DELETE /saved-items/{id}`. If that succeeds and the server reports the
/// item's collection is empty and deletable, a second dialog may offer to delete
/// that collection; confirming it issues exactly one
/// `DELETE /collections/{id}`. Keeping, dismissing, or going Back sends no
/// collection request, and nothing is ever deleted automatically.
///
/// The three content states are the wireframe's C1, C2 and C3:
/// - C1: metadata available; title, source, collection, status and description.
/// - C2: `pending` or `failed`; the item stays visible with whatever metadata it
///   has. `pending` is the server's state, not a request this screen started.
/// - C3: the verified `RESOURCE_NOT_FOUND` → a neutral not-found state with no
///   Retry, because re-reading cannot bring the item back.
class SavedItemDetailScreen extends ConsumerWidget {
  const SavedItemDetailScreen({
    required this.itemId,
    this.originCollectionId,
    super.key,
  });

  final String itemId;

  /// The collection whose contents screen pushed this route, when there is one.
  ///
  /// Null for the Inbox, Search and a direct entry. Used only after a successful
  /// collection delete: if that collection is the one this detail was opened
  /// from, the collection route beneath this one is now gone and must be popped
  /// as well.
  final String? originCollectionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(savedItemDetailProvider(itemId));
    final deleting = ref.watch(deleteSavedItemProvider);
    final canPop = Navigator.of(context).canPop();

    return Scaffold(
      appBar: AppBar(
        title: const Text('ITEM'),
        // The detail always has a back affordance. When it was pushed, that is
        // an ordinary pop; when it was entered directly there is no page beneath
        // it, so the control says where it goes and falls back to the Inbox.
        leading: canPop
            ? const BackButton()
            : IconButton(
                icon: const Icon(Icons.arrow_back, size: AppMetrics.iconSize),
                tooltip: 'Back to Inbox',
                onPressed: () => context.go(AppRoutes.inbox),
              ),
      ),
      body: switch (detail) {
        AsyncData(:final value) => _DetailBody(
          item: value,
          deleting: deleting,
          onMoveToCollection: () =>
              showMoveToCollectionSheet(context, item: value),
          onDelete: () => _confirmDelete(context, ref, value),
        ),
        AsyncError(:final error, :final isLoading) when !isLoading =>
          error is ApiFailureNotFound
              ? _NotFound(onBack: () => _leave(context))
              : _ReadError(
                  failure: error,
                  onRetry: () =>
                      ref.invalidate(savedItemDetailProvider(itemId)),
                ),
        // A manual retry in flight, or the first read. Both show the real layout
        // under a skeleton rather than a bare spinner.
        _ => const _DetailSkeleton(),
      },
    );
  }

  /// Runs the two-dialog destructive flow.
  ///
  /// The controller owns both requests, the in-flight guard, cache
  /// reconciliation and every feedback message. This method owns only the order
  /// of user decisions and navigation. **The item delete is never repeated when
  /// the collection step fails**: the second request is a separate outcome, and
  /// the screen leaves once the item is known deleted.
  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    SavedItemSummary item,
  ) async {
    if (ref.read(deleteSavedItemProvider)) return;

    final confirmed = await showAppConfirmDialog(
      context: context,
      title: 'Delete this item?',
      message: 'This removes the saved item. It cannot be undone.',
      cancelLabel: 'Keep',
      confirmLabel: 'Delete',
      destructive: true,
    );
    if (confirmed != true || !context.mounted) return;

    final outcome = await ref
        .read(deleteSavedItemProvider.notifier)
        .deleteItem(item);

    if (!context.mounted) return;

    switch (outcome) {
      case DeleteSavedItemCollectionOffered(:final result):
        // Eligibility was checked defensively by the controller, including the
        // exact collection id match and a non-empty trimmed name. The dialog
        // uses the trimmed name in both sentences.
        final name = item.collectionName.trim();
        final deleteCollection = await showAppConfirmDialog(
          context: context,
          title: '$name is now empty',
          message:
              'This was the last item in $name. You can keep this empty '
              'collection or delete it.',
          cancelLabel: 'Keep it',
          confirmLabel: 'Delete collection',
          destructive: true,
        );

        if (!context.mounted) return;

        // The collection contents route beneath this detail is the one being
        // deleted. Its contents provider does not need a refresh that can only
        // answer 404; the route is about to be removed.
        final leavesCollection = originCollectionId == result.collectionId;

        if (deleteCollection == true) {
          final outcome = await ref
              .read(deleteSavedItemProvider.notifier)
              .deleteCollection(
                collectionId: result.collectionId,
                collectionName: name,
                invalidateContents: !leavesCollection,
              );

          if (!context.mounted) return;

          if (leavesCollection &&
              (outcome is DeleteCollectionSucceeded ||
                  outcome is DeleteCollectionNotFound)) {
            // Pop this detail and the collection screen it was opened from. The
            // second pop reveals whatever destination held that collection —
            // Collections or Search — through the existing stack, rather than
            // inventing a destination or leaving a deleted collection on screen.
            context.pop();
            context.pop();
            return;
          }
        } else {
          // Barrier tap, Back and the explicit Keep it all mean keep. The
          // success notice is published only now so it cannot cover the dialog.
          ref.read(deleteSavedItemProvider.notifier).keepCollection();
        }

        if (!context.mounted) return;
        _leave(context);

      case DeleteSavedItemSucceeded():
      case DeleteSavedItemNotFound():
        _leave(context);

      // The outcome is genuinely unknown. Staying keeps the distinction visible
      // and lets the user retry; leaving would imply the deletion completed.
      case DeleteSavedItemUnconfirmed():
      case DeleteSavedItemFailed():
      case DeleteSavedItemIgnored():
        break;
    }
  }

  /// Pops when there is a page to return to, otherwise opens the Inbox.
  ///
  /// Used by both the app bar's fallback and C3's action, so a directly-entered
  /// not-found item has the same safe exit as a directly-entered live one.
  void _leave(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.inbox);
    }
  }
}

/// C1 and C2: the item's real content, in the wireframe's order.
class _DetailBody extends StatelessWidget {
  const _DetailBody({
    required this.item,
    this.onMoveToCollection,
    this.onDelete,
    this.deleting = false,
  });

  final SavedItemSummary item;

  /// Null in the skeleton and in every non-data state, which is what keeps the
  /// action out of the loading, generic-error and C3 screens.
  final VoidCallback? onMoveToCollection;

  /// Null in the skeleton and every non-data state, for the same reason as
  /// [onMoveToCollection].
  final VoidCallback? onDelete;

  /// A destructive request is in flight. Both actions are disabled, and the
  /// delete control shows its own progress rather than leaving a dead button.
  final bool deleting;

  @override
  Widget build(BuildContext context) {
    final tokens = AppTheme.tokensOf(context);
    final description = _descriptionOf(item);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppMetrics.screenPadding,
        AppMetrics.space4,
        AppMetrics.screenPadding,
        AppMetrics.space6,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // The preview well is the row's, widened. The same widget decides the
          // pending, unavailable and loaded states here, so the detail cannot
          // drift from the row.
          SavedItemPreview(
            imageUrl: item.imageUrl,
            enrichmentStatus: item.enrichmentStatus,
            width: double.infinity,
            height: 110,
          ),
          const SizedBox(height: AppMetrics.space4),
          Text(
            item.displayTitle,
            style: AppTypography.itemTitle.copyWith(
              // A fallback title is neutral copy, never a warning colour. D17
              // confirms a title-less item is normal.
              color: item.usesFallbackTitle
                  ? tokens.textTertiary
                  : tokens.textPrimary,
              fontWeight: item.usesFallbackTitle
                  ? FontWeight.w400
                  : FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppMetrics.space1),
          Text(
            item.displaySource,
            style: AppTypography.mono.copyWith(color: tokens.textTertiary),
          ),
          const SizedBox(height: AppMetrics.space3),
          Row(
            children: [
              Flexible(
                child: SavedItemCollectionChip(
                  name: item.collectionName,
                  maxWidth: 220,
                ),
              ),
              const SizedBox(width: AppMetrics.space2),
              // `completed` with metadata renders nothing here; `pending`,
              // `failed` and `completed` without metadata render their neutral
              // or danger wording. No spinner: nothing is in flight on this
              // screen's behalf.
              Expanded(child: SavedItemEnrichmentState(item: item)),
            ],
          ),
          if (description != null) ...[
            const SizedBox(height: AppMetrics.space3),
            // Full text. The row clamps to two lines; the detail exists to show
            // the description, so truncating it here would defeat the screen.
            Text(
              description,
              style: AppTypography.body.copyWith(color: tokens.textSecondary),
            ),
          ],
          const SizedBox(height: AppMetrics.space5),
          Divider(
            height: AppMetrics.borderWidth,
            thickness: AppMetrics.borderWidth,
            color: tokens.border,
          ),
          const SizedBox(height: AppMetrics.space4),
          if (onMoveToCollection != null || onDelete != null) ...[
            Text(
              'ACTIONS',
              style: AppTypography.sectionLabel.copyWith(
                color: tokens.textTertiary,
              ),
            ),
            const SizedBox(height: AppMetrics.space3),
            if (onMoveToCollection != null) ...[
              AppButton(
                label: 'Move to a collection',
                variant: AppButtonVariant.secondary,
                onPressed: deleting ? null : onMoveToCollection,
              ),
              if (onDelete != null) const SizedBox(height: AppMetrics.space2),
            ],
            if (onDelete != null)
              AppButton(
                label: 'Delete this item',
                variant: AppButtonVariant.danger,
                busy: deleting,
                onPressed: deleting ? null : onDelete,
              ),
            const SizedBox(height: AppMetrics.space6),
          ],
          _EnrichmentAction(tokens: tokens),
        ],
      ),
    );
  }

  /// Null for a missing, empty or whitespace-only description.
  ///
  /// The wireframe's C2 shows "No description yet" as a neutral note, but the
  /// status line already explains why a pending or failed item has none, and a
  /// completed item with no description is an ordinary page. An extra sentence
  /// would add copy without adding information.
  static String? _descriptionOf(SavedItemSummary item) {
    final description = item.description?.trim();
    if (description == null || description.isEmpty) return null;
    return description;
  }
}

/// The one deliberately disabled control on this screen.
///
/// It has **no callback** (`onPressed: null`) and therefore cannot issue a
/// request, let alone enrich. The caption is what makes that understandable: a
/// bare disabled "Re-read page" would leave the user guessing whether the app is
/// busy or broken, and the wireframe's "Reading the page…" would falsely claim an
/// enrichment this iteration never starts.
class _EnrichmentAction extends StatelessWidget {
  const _EnrichmentAction({required this.tokens});

  final AppTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ENRICHMENT',
          style: AppTypography.sectionLabel.copyWith(
            color: tokens.textTertiary,
          ),
        ),
        const SizedBox(height: AppMetrics.space3),
        const AppButton(
          label: 'Re-read page',
          // No callback. Not "busy": nothing is running, and a spinner would say
          // otherwise.
          onPressed: null,
          variant: AppButtonVariant.secondary,
        ),
        const SizedBox(height: AppMetrics.space2),
        Text(
          'Not available in this version.',
          style: AppTypography.meta.copyWith(color: tokens.textTertiary),
        ),
      ],
    );
  }
}

/// Loading: the real detail layout under `Skeletonizer`.
///
/// The placeholder strings never reach a screen reader: [ExcludeSemantics]
/// removes the subtree. They exist so the bones have realistic lengths, not to
/// present invented metadata as fact.
class _DetailSkeleton extends StatelessWidget {
  const _DetailSkeleton();

  @override
  Widget build(BuildContext context) {
    return const ExcludeSemantics(
      child: Skeletonizer(
        child: _DetailBody(
          item: SavedItemSummary(
            id: 'skeleton',
            collectionId: 'skeleton',
            url: 'https://example.com/articles/quiet-mornings',
            collectionName: 'Unsorted',
            enrichmentStatus: EnrichmentStatus.completed,
            title:
                'A saved item title about as long as a real one tends to run',
            description:
                'A description long enough to show the shape of the detail '
                'layout while the item is being read. It wraps across several '
                'lines, as a real description can.',
            // No `imageUrl`: a skeleton is not an item and must never issue a
            // network image request. `completed` with no image is a real state,
            // and the well reserves the same space either way.
          ),
        ),
      ),
    );
  }
}

/// C3: the item is gone, or is not this account's.
///
/// Only [ApiFailureNotFound] reaches this state, and the copy never says which
/// of the two happened — the backend uses one response on purpose so IDs cannot
/// be enumerated. **There is no Retry**: the server has already said the
/// resource is unavailable, and re-reading cannot change that.
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
              'This item is no longer available',
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
              label: 'Back to Inbox',
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
/// It is deliberately distinct from C3. A malformed `404` is an unreadable
/// response, not a missing item, and must offer a retry; only the verified
/// `RESOURCE_NOT_FOUND` code may claim the item is gone.
class _ReadError extends StatelessWidget {
  const _ReadError({required this.failure, required this.onRetry});

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
              'We could not load this item',
              textAlign: TextAlign.center,
              style: AppTypography.screenHeading.copyWith(
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
  /// (D22); `genericReadFailureMessage` supplies the feature-agnostic remainder.
  static String _messageFor(Object failure) => switch (failure) {
    ApiFailureSessionEnded() =>
      'Your session has ended. Sign in again to see this item.',
    ApiFailureAuthRequired() => 'Sign in again to see this item.',
    ApiFailureServerUnavailable() =>
      'This item is temporarily unavailable. Try again shortly.',
    ApiFailureTransport() =>
      "No connection to the server. We couldn't load this item.",
    // `ApiFailureNotFound` is handled before this widget. The fallback covers
    // `RefreshUncertain` and `CredentialStorage` without claiming the session
    // ended, which neither of them establishes.
    _ =>
      genericReadFailureMessage(failure) ??
          "We couldn't load this item. Try again.",
  };
}
