import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:stash_it_app/app/router/routes.dart';
import 'package:stash_it_app/app/theme/app_theme.dart';
import 'package:stash_it_app/core/error/api_failure.dart';
import 'package:stash_it_app/core/error/api_failure_messages.dart';
import 'package:stash_it_app/features/saved_items/application/delete_saved_item_controller.dart';
import 'package:stash_it_app/features/saved_items/application/enrich_saved_item_controller.dart';
import 'package:stash_it_app/features/saved_items/application/open_saved_item_url.dart';
import 'package:stash_it_app/features/saved_items/application/saved_item_detail_provider.dart';
import 'package:stash_it_app/features/saved_items/application/saved_item_url_actions.dart';
import 'package:stash_it_app/features/saved_items/domain/saved_item_summary.dart';
import 'package:stash_it_app/features/saved_items/presentation/price_label.dart';
import 'package:stash_it_app/l10n/app_localizations.dart';
import 'package:stash_it_app/shared/widgets/app_button.dart';
import 'package:stash_it_app/shared/widgets/app_confirm_dialog.dart';
import 'package:stash_it_app/shared/widgets/desktop_layout.dart';

import 'widgets/move_to_collection_sheet.dart';
import 'widgets/saved_item_collection_chip.dart';
import 'widgets/saved_item_detail_note.dart';
import 'widgets/saved_item_enrichment_state.dart';
import 'widgets/saved_item_preview.dart';

/// The detail hero uses a bounded landscape frame.
///
/// The previous fixed 110 px height became an ultra-wide strip at desktop
/// content width and cropped most of the image. A 16:9 frame keeps the hero
/// proportionate on mobile and desktop without changing the listing preview.
const double _detailImageAspectRatio = 16 / 9;

/// The desktop hero never grows wider than this, so it stays 640×360 at 16:9.
///
/// Windows and macOS share [usesDesktopLayout], so both use this same cap and
/// the centering applied below.
const double _detailImageDesktopMaxWidth = 640;

/// Displays one saved item using fresh data from `GET /saved-items/{id}`.
///
/// This is a top-level route outside the shell, not a separate navigation
/// destination. It has its own `ITEM` app bar and no Settings action. Pushing
/// it from a row preserves the underlying Inbox state and scroll position.
/// When opened directly, the back action falls back to [AppRoutes.inbox].
///
/// Opening the screen only reads the item through [savedItemDetailProvider].
/// It does not trigger enrichment, polling, background refreshes, moves or
/// deletions. **Re-read page** sends one synchronous `POST` when explicitly
/// requested. Its `200` response is applied directly, without a follow-up GET,
/// polling or automatic retry. **Move to a collection** sends one `PUT` after
/// the user selects a destination.
///
/// Opening the original page is a platform handoff, not an API request. The
/// browser or target app may fail, redirect or require sign-in. This action
/// does not modify the saved item or claim that the page loaded.
///
/// Deletion requires explicit confirmation. After the item is successfully
/// deleted, a second confirmation may offer to delete its collection if the
/// server reports that the collection is empty and deletable. Keeping or
/// dismissing that second dialog does not send a collection deletion request.
class SavedItemDetailScreen extends ConsumerWidget {
  const SavedItemDetailScreen({
    required this.itemId,
    this.originCollectionId,
    super.key,
  });

  final String itemId;

  /// The collection whose contents screen opened this route, if applicable.
  ///
  /// Null when opened from the Inbox, Search or a direct entry. Used after a
  /// successful collection deletion to determine whether the collection route
  /// beneath this detail screen must also be popped.
  final String? originCollectionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final detail = ref.watch(savedItemDetailProvider(itemId));
    final deleting = ref.watch(deleteSavedItemProvider);
    final enriching = ref.watch(enrichSavedItemProvider);
    final urlActions = ref.read(savedItemUrlActionsProvider);
    final canPop = Navigator.of(context).canPop();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.savedItemDetailTitle),
        // Use a normal pop when a previous page exists. Direct entries fall
        // back to the Inbox instead.
        leading: canPop
            ? const BackButton()
            : IconButton(
                icon: const Icon(Icons.arrow_back, size: AppMetrics.iconSize),
                tooltip: l10n.savedItemBackToInbox,
                onPressed: () => context.go(AppRoutes.inbox),
              ),
      ),
      body: DesktopContentFrame(
        child: switch (detail) {
          AsyncData(:final value) => _DetailBody(
            item: value,
            deleting: deleting,
            enriching: enriching,
            showShareAction: showsSavedItemShareAction,
            onMoveToCollection: () =>
                showMoveToCollectionSheet(context, item: value),
            onOpenUrl: () => ref.read(openSavedItemUrlProvider).open(value),
            onCopyUrl: () => urlActions.copy(value.url),
            onShareUrl: () => urlActions.share(value.url),
            onEditNote: () => showSavedItemNoteEditor(context, item: value),
            onDelete: () => _confirmDelete(context, ref, value),
            onReRead: () =>
                ref.read(enrichSavedItemProvider.notifier).enrich(value),
          ),
          AsyncError(:final error, :final isLoading) when !isLoading =>
            error is ApiFailureNotFound
                ? _NotFound(onBack: () => _leave(context))
                : _ReadError(
                    failure: error,
                    onRetry: () =>
                        ref.invalidate(savedItemDetailProvider(itemId)),
                  ),
          // The initial read and a manual retry both show the detail layout
          // under a skeleton instead of a bare spinner.
          _ => const _DetailSkeleton(),
        },
      ),
    );
  }

  /// Runs the two-step deletion flow.
  ///
  /// The controller handles the requests, in-flight guard, cache updates and
  /// feedback. This method handles only the order of user decisions and
  /// navigation. The item deletion is never repeated if collection deletion
  /// fails; the item is already known to be deleted at that point.
  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    SavedItemSummary item,
  ) async {
    if (ref.read(deleteSavedItemProvider)) return;

    final l10n = AppLocalizations.of(context);
    final confirmed = await showAppConfirmDialog(
      context: context,
      title: l10n.savedItemDeleteDialogTitle,
      message: l10n.savedItemDeleteDialogMessage,
      cancelLabel: l10n.savedItemKeepAction,
      confirmLabel: l10n.savedItemDeleteConfirmAction,
      destructive: true,
    );
    if (confirmed != true || !context.mounted) return;

    final outcome = await ref
        .read(deleteSavedItemProvider.notifier)
        .deleteItem(item);

    if (!context.mounted) return;

    switch (outcome) {
      case DeleteSavedItemCollectionOffered(:final result):
        // The controller has already checked the collection identity and
        // deletion eligibility. Use the trimmed name in the confirmation.
        final name = item.collectionName.trim();
        final deleteCollection = await showAppConfirmDialog(
          context: context,
          title: l10n.savedItemCollectionEmptyTitle(name),
          message: l10n.savedItemCollectionEmptyMessage(name),
          cancelLabel: l10n.savedItemKeepCollectionAction,
          confirmLabel: l10n.savedItemDeleteCollectionAction,
          destructive: true,
        );

        if (!context.mounted) return;

        // If this detail was opened from the collection being deleted, its
        // underlying contents route will also need to be removed.
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
            // Remove both the detail and deleted collection routes. The
            // existing navigation stack determines the destination beneath
            // the collection, such as Collections or Search.
            context.pop();
            context.pop();
            return;
          }
        } else {
          // Keeping, dismissing or going Back all preserve the collection.
          // Publish the success notice only after the dialog is closed.
          ref.read(deleteSavedItemProvider.notifier).keepCollection();
        }

        if (!context.mounted) return;
        _leave(context);

      case DeleteSavedItemSucceeded():
      case DeleteSavedItemNotFound():
        _leave(context);

      // The deletion outcome is not confirmed. Keep the screen open rather
      // than implying that the item was successfully deleted.
      case DeleteSavedItemUnconfirmed():
      case DeleteSavedItemFailed():
      case DeleteSavedItemIgnored():
        break;
    }
  }

  /// Pops to the previous page, or opens the Inbox when there is no page below.
  ///
  /// Shared by the app bar fallback and the not-found state.
  void _leave(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.inbox);
    }
  }
}

/// Displays the loaded item's content and available actions.
class _DetailBody extends StatelessWidget {
  const _DetailBody({
    required this.item,
    this.onMoveToCollection,
    this.onOpenUrl,
    this.onCopyUrl,
    this.onShareUrl,
    this.onEditNote,
    this.onDelete,
    this.onReRead,
    this.showShareAction = false,
    this.deleting = false,
    this.enriching = false,
  });

  final SavedItemSummary item;

  /// Null outside the loaded-data state, so the action is unavailable while
  /// loading or when the detail request has failed.
  final VoidCallback? onMoveToCollection;

  /// Null outside the loaded-data state because opening the original page
  /// requires the saved item's URL.
  ///
  /// Remains available while writes are in flight. Opening the URL does not
  /// modify the saved item, so it does not need to be blocked by those writes.
  final VoidCallback? onOpenUrl;

  /// Copies the complete original URL. Null outside the loaded-data state.
  final VoidCallback? onCopyUrl;

  /// Opens the native share sheet for the complete original URL. Null outside
  /// the loaded-data state or when the platform has no share action.
  final VoidCallback? onShareUrl;

  /// Opens the one note editor sheet. Null outside the loaded-data state.
  final VoidCallback? onEditNote;

  /// Whether this platform exposes the native share action.
  final bool showShareAction;

  /// Null outside the loaded-data state.
  final VoidCallback? onDelete;

  /// Null outside the loaded-data state, so a re-read cannot start without
  /// loaded item data.
  final VoidCallback? onReRead;

  /// Whether an item deletion is in flight. The delete action shows progress,
  /// and both item-level mutation actions are disabled.
  final bool deleting;

  /// Whether a re-read is in flight. The item remains visible, the re-read
  /// action shows progress, and both item-level mutation actions are disabled.
  /// The enrichment status is not changed optimistically.
  final bool enriching;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTheme.tokensOf(context);
    final description = _descriptionOf(item);
    final price = priceLabel(
      amount: item.priceAmount,
      currency: item.priceCurrency,
    );

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
          // Reuses the row preview's rendering rules for pending, unavailable
          // and loaded images, but gives the detail a deliberate 16:9 hero
          // instead of a fixed shallow height.
          LayoutBuilder(
            builder: (context, constraints) {
              final available = constraints.maxWidth;
              final width =
                  usesDesktopLayout && available > _detailImageDesktopMaxWidth
                  ? _detailImageDesktopMaxWidth
                  : available;
              final preview = SavedItemPreview(
                imageUrl: item.imageUrl,
                enrichmentStatus: item.enrichmentStatus,
                width: width,
                height: width / _detailImageAspectRatio,
              );

              // Windows and macOS share usesDesktopLayout. Android keeps the
              // existing full-content-width presentation.
              return usesDesktopLayout
                  ? Align(alignment: Alignment.center, child: preview)
                  : preview;
            },
          ),
          const SizedBox(height: AppMetrics.space4),
          Text(
            item.displayTitle,
            style: AppTypography.itemTitle.copyWith(
              // A fallback title is normal display copy, not an error state.
              color: item.usesFallbackTitle
                  ? tokens.textTertiary
                  : tokens.textPrimary,
              fontWeight: item.usesFallbackTitle
                  ? FontWeight.w400
                  : FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppMetrics.space1),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  item.displaySource,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.mono.copyWith(
                    color: tokens.textTertiary,
                  ),
                ),
              ),
              if (onShareUrl != null && showShareAction)
                _UrlAction(
                  icon: Icons.share_outlined,
                  tooltip: l10n.savedItemShareUrl,
                  onPressed: onShareUrl,
                ),
              if (onCopyUrl != null)
                _UrlAction(
                  icon: Icons.copy_outlined,
                  tooltip: l10n.savedItemCopyUrl,
                  onPressed: onCopyUrl,
                ),
            ],
          ),
          if (price != null) ...[
            const SizedBox(height: 4),
            Text(
              price,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.meta.copyWith(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: tokens.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              l10n.savedItemPriceMayHaveChanged,
              style: AppTypography.meta.copyWith(color: tokens.textTertiary),
            ),
          ],
          const SizedBox(height: AppMetrics.space3),
          // Completed items with metadata need no status message. Pending,
          // failed and completed items without metadata show their
          // corresponding status. Wrapping lets the full localized status move
          // below the collection chip when the two do not fit on one line.
          Wrap(
            spacing: AppMetrics.space2,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SavedItemCollectionChip(name: item.collectionName, maxWidth: 220),
              SavedItemEnrichmentState(item: item, wrap: true),
            ],
          ),
          if (description != null) ...[
            const SizedBox(height: AppMetrics.space3),
            // Show the full description here; the list row is the component
            // that limits it to two lines.
            Text(
              description,
              style: AppTypography.body.copyWith(color: tokens.textSecondary),
            ),
          ],
          if (onEditNote != null) ...[
            const SizedBox(height: AppMetrics.space3),
            SavedItemDetailNote(note: item.note, onTap: onEditNote!),
          ],
          const SizedBox(height: AppMetrics.space5),
          Divider(
            height: AppMetrics.borderWidth,
            thickness: AppMetrics.borderWidth,
            color: tokens.border,
          ),
          const SizedBox(height: AppMetrics.space4),
          if (onMoveToCollection != null ||
              onOpenUrl != null ||
              onDelete != null) ...[
            Text(
              l10n.savedItemActionsSection,
              style: AppTypography.sectionLabel.copyWith(
                color: tokens.textTertiary,
              ),
            ),
            const SizedBox(height: AppMetrics.space3),
            if (onMoveToCollection != null) ...[
              AppButton(
                label: l10n.savedItemMoveAction,
                variant: AppButtonVariant.secondary,
                onPressed: deleting || enriching ? null : onMoveToCollection,
              ),
              if (onOpenUrl != null || onDelete != null)
                const SizedBox(height: AppMetrics.space2),
            ],
            // Opening the original page is a platform handoff, not an item
            // mutation. It remains separate from the write actions.
            if (onOpenUrl != null) ...[
              AppButton(
                label: l10n.savedItemOpenAction,
                variant: AppButtonVariant.secondary,
                onPressed: onOpenUrl,
              ),
              if (onDelete != null) const SizedBox(height: AppMetrics.space2),
            ],
            if (onDelete != null)
              AppButton(
                label: l10n.savedItemDeleteAction,
                variant: AppButtonVariant.danger,
                busy: deleting,
                onPressed: deleting || enriching ? null : onDelete,
              ),
            const SizedBox(height: AppMetrics.space6),
          ],
          _EnrichmentAction(
            tokens: tokens,
            onReRead: onReRead,
            enriching: enriching,
          ),
        ],
      ),
    );
  }

  /// Returns null when the description is missing, empty or whitespace-only.
  ///
  /// The status message already explains missing metadata for pending or
  /// failed items. A completed item without a description is also valid, so
  /// an additional placeholder sentence would not add useful information.
  static String? _descriptionOf(SavedItemSummary item) {
    final description = item.description?.trim();
    if (description == null || description.isEmpty) return null;
    return description;
  }
}

/// A compact icon action beside the URL.
class _UrlAction extends StatelessWidget {
  const _UrlAction({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final tokens = AppTheme.tokensOf(context);

    return IconButton(
      icon: Icon(icon, size: AppMetrics.iconSize),
      tooltip: tooltip,
      color: tokens.textTertiary,
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
      onPressed: onPressed,
    );
  }
}

/// Provides the user-triggered action to re-read the saved page.
///
/// Available for all enrichment states: pending items have not been read,
/// failed items could not be read, and completed items may have changed since
/// the last read. The user decides when to try again.
///
/// The callback is supplied only when detail data is loaded. In the skeleton
/// and non-data states the control remains visible but cannot start a request.
/// While a request is in flight, the button shows progress and the caption
/// describes the ongoing operation.
class _EnrichmentAction extends StatelessWidget {
  const _EnrichmentAction({
    required this.tokens,
    this.onReRead,
    this.enriching = false,
  });

  final AppTokens tokens;

  /// Null when no loaded item is available.
  final VoidCallback? onReRead;

  final bool enriching;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.savedItemEnrichmentSection,
          style: AppTypography.sectionLabel.copyWith(
            color: tokens.textTertiary,
          ),
        ),
        const SizedBox(height: AppMetrics.space3),
        AppButton(
          label: l10n.savedItemReReadAction,
          variant: AppButtonVariant.secondary,
          busy: enriching,
          onPressed: enriching ? null : onReRead,
        ),
        if (enriching) ...[
          const SizedBox(height: AppMetrics.space2),
          Text(
            l10n.savedItemReadingPage,
            style: AppTypography.meta.copyWith(color: tokens.textTertiary),
          ),
        ],
      ],
    );
  }
}

/// Shows the detail layout under `Skeletonizer` while the item is loading.
///
/// Placeholder values provide realistic text lengths for the skeleton.
/// [ExcludeSemantics] keeps those placeholders out of the screen reader.
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
            // No image URL is supplied, so the skeleton cannot trigger a
            // network image request. The preview still reserves its space.
          ),
        ),
      ),
    );
  }
}

/// Shows a neutral state when the item is unavailable.
///
/// Only [ApiFailureNotFound] reaches this state. The message does not reveal
/// whether the item was deleted or belongs to another account. There is no
/// Retry action because another read cannot restore an unavailable item.
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
              l10n.savedItemNotFoundTitle,
              textAlign: TextAlign.center,
              style: AppTypography.screenHeading.copyWith(
                color: tokens.textPrimary,
              ),
            ),
            const SizedBox(height: AppMetrics.space2),
            Text(
              l10n.savedItemNotFoundBody,
              textAlign: TextAlign.center,
              style: AppTypography.body.copyWith(color: tokens.textSecondary),
            ),
            const SizedBox(height: AppMetrics.space5),
            AppButton(
              label: l10n.savedItemBackToInbox,
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

/// Displays retryable read failures, including transport, server, auth,
/// unreadable-response and rate-limit failures.
///
/// This is distinct from the not-found state. A malformed `404` response is
/// unreadable, not proof that the item is missing, so it still offers Retry.
/// Only a verified `RESOURCE_NOT_FOUND` failure reaches [_NotFound].
class _ReadError extends StatelessWidget {
  const _ReadError({required this.failure, required this.onRetry});

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
              l10n.savedItemLoadErrorTitle,
              textAlign: TextAlign.center,
              style: AppTypography.screenHeading.copyWith(
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

  /// Uses client-owned copy for each failure type. The API response message
  /// is not displayed; [genericReadFailureMessage] handles other failures.
  static String _messageFor(Object failure, AppLocalizations localizations) =>
      switch (failure) {
        ApiFailureSessionEnded() => localizations.savedItemSessionEnded,
        ApiFailureAuthRequired() => localizations.savedItemSignInRequired,
        ApiFailureServerUnavailable() => localizations.savedItemUnavailable,
        ApiFailureTransport() => localizations.savedItemLoadTransport,
        // Not-found failures are handled before this widget. The fallback also
        // covers failures that do not establish that the session has ended.
        _ =>
          genericReadFailureMessage(failure, localizations) ??
              localizations.savedItemLoadGeneric,
      };
}
