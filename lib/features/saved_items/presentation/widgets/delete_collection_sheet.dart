import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stash_it_app/app/theme/app_theme.dart';
import 'package:stash_it_app/features/collections/domain/collection_summary.dart';
import 'package:stash_it_app/features/saved_items/application/delete_collection_controller.dart';
import 'package:stash_it_app/shared/widgets/app_button.dart';

import 'move_collection_picker_sheet.dart';

/// Result of one visit to the collection deletion decision sheet.
enum DeleteCollectionSheetResult {
  /// The collection was kept, or a known refusal left it in place.
  dismissed,

  /// The collection was deleted or was already absent.
  deleted,
}

/// Decision sheet for deleting a non-empty collection.
///
/// The user can move all items to another collection or delete the items
/// together with the collection. Moving opens the same paginated destination
/// picker used for single-item moves. The selected destination is submitted
/// together with the collection deletion in one request.
///
/// Barrier and drag dismissal are disabled so an outside tap cannot
/// accidentally discard the decision. The user can choose to keep the
/// collection or use system Back. Back is blocked while a request is in flight.
///
/// [itemCount] is null when the loaded listing does not cover the entire
/// collection. In that case, the sheet indicates that items exist without
/// presenting a partial-page count as the total.
class DeleteCollectionSheet extends ConsumerStatefulWidget {
  const DeleteCollectionSheet({
    required this.collectionId,
    required this.collectionName,
    required this.itemCount,
    super.key,
  });

  /// ID of the collection being deleted. This collection is excluded from
  /// the destination picker.
  final String collectionId;

  /// Collection name reported by the loaded listing.
  final String collectionName;

  /// Exact number of saved items, or null when the listing does not contain
  /// enough information to determine the total.
  final int? itemCount;

  @override
  ConsumerState<DeleteCollectionSheet> createState() =>
      _DeleteCollectionSheetState();
}

/// Identifies the action currently in progress so only its button shows
/// a loading indicator.
enum _PendingAction { move, delete }

class _DeleteCollectionSheetState extends ConsumerState<DeleteCollectionSheet> {
  _PendingAction? _pending;

  /// Whether the last outcome was ambiguous and the collection's state
  /// could not be confirmed.
  ///
  /// In this state, the dismissal action is labelled "Close" rather than
  /// "Keep collection", since the sheet cannot confirm that the collection
  /// was kept.
  bool _uncertain = false;

  String get _name {
    final trimmed = widget.collectionName.trim();
    return trimmed.isEmpty ? 'This collection' : trimmed;
  }

  String get _countCopy {
    final count = widget.itemCount;
    if (count == null) {
      return 'This collection has saved items. Choose what happens to them.';
    }
    if (count == 1) {
      return 'This collection has 1 saved item. Choose what happens to it.';
    }
    return 'This collection has $count saved items. '
        'Choose what happens to them.';
  }

  String get _pickCopy => widget.itemCount == 1
      ? 'Choose where this item should go. $_name will be deleted.'
      : 'Choose where these items should go. $_name will be deleted.';

  @override
  Widget build(BuildContext context) {
    final tokens = AppTheme.tokensOf(context);
    final busy = ref.watch(collectionDeletionProvider);

    return PopScope(
      canPop: !busy,
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppMetrics.screenPadding,
            AppMetrics.space4,
            AppMetrics.screenPadding,
            AppMetrics.space5,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Delete $_name?',
                style: AppTypography.screenHeading.copyWith(
                  color: tokens.textPrimary,
                ),
              ),
              const SizedBox(height: AppMetrics.space2),
              Text(
                _countCopy,
                style: AppTypography.body.copyWith(color: tokens.textSecondary),
              ),
              const SizedBox(height: AppMetrics.space3),
              Text(
                'Deleting the collection cannot be undone, and items you choose '
                'to delete cannot be recovered.',
                style: AppTypography.body.copyWith(color: tokens.textSecondary),
              ),
              const SizedBox(height: AppMetrics.space5),
              AppButton(
                label: 'Move items to another collection',
                variant: AppButtonVariant.secondary,
                busy: _pending == _PendingAction.move,
                onPressed: busy ? null : _pickDestination,
              ),
              const SizedBox(height: AppMetrics.space2),
              AppButton(
                label: 'Delete collection and items',
                variant: AppButtonVariant.danger,
                busy: _pending == _PendingAction.delete,
                onPressed: busy ? null : _deleteItems,
              ),
              const SizedBox(height: AppMetrics.space3),
              AppButton(
                label: _uncertain ? 'Close' : 'Keep collection',
                variant: AppButtonVariant.quiet,
                onPressed: busy
                    ? null
                    : () => _close(DeleteCollectionSheetResult.dismissed),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Opens the destination picker and submits the selected collection
  /// as the target of the bulk move.
  ///
  /// Dismissing the picker leaves this sheet open without sending a request.
  /// The current collection is excluded from the picker, while Unsorted
  /// remains available as a destination.
  Future<void> _pickDestination() async {
    if (ref.read(collectionDeletionProvider)) return;

    final target = await showMoveCollectionPickerSheet(
      context,
      currentCollectionId: widget.collectionId,
      description: _pickCopy,
    );
    if (!mounted || target == null) return;

    await _submitMove(target);
  }

  Future<void> _submitMove(CollectionSummary target) async {
    setState(() {
      _pending = _PendingAction.move;
      _uncertain = false;
    });

    final outcome = await ref
        .read(collectionDeletionProvider.notifier)
        .moveItemsAndDelete(
          collectionId: widget.collectionId,
          collectionName: widget.collectionName,
          target: target,
        );

    if (!mounted) return;
    setState(() => _pending = null);
    _handle(outcome);
  }

  /// Deletes the collection together with all its saved items.
  ///
  /// This is the destructive disposition presented by the sheet. It does
  /// not require a second confirmation.
  Future<void> _deleteItems() async {
    setState(() {
      _pending = _PendingAction.delete;
      _uncertain = false;
    });

    final outcome = await ref
        .read(collectionDeletionProvider.notifier)
        .deleteDiscardingItems(
          collectionId: widget.collectionId,
          collectionName: widget.collectionName,
        );

    if (!mounted) return;
    setState(() => _pending = null);
    _handle(outcome);
  }

  /// Handles the outcome and closes the sheet only when no further decision
  /// is needed here.
  ///
  /// Successful deletion and an already-missing collection both close the
  /// route. Known refusals that leave the collection in place keep the sheet
  /// open so the user can choose again. If the outcome is ambiguous, the
  /// sheet also stays open and changes its dismissal label to "Close".
  ///
  /// A concurrent insert can make the collection non-empty again before
  /// deletion completes. In that case, the deletion is rolled back and the
  /// sheet closes because its original item count is no longer reliable.
  void _handle(CollectionDeletionOutcome outcome) {
    switch (outcome) {
      case CollectionDeletionSucceeded():
      case CollectionDeletionSourceNotFound():
        _close(DeleteCollectionSheetResult.deleted);

      case CollectionDeletionNotEmpty():
      case CollectionDeletionProtected():
        _close(DeleteCollectionSheetResult.dismissed);

      case CollectionDeletionTargetNotFound():
      case CollectionDeletionFailed():
      case CollectionDeletionIgnored():
        break;

      case CollectionDeletionUnconfirmed():
        setState(() => _uncertain = true);
    }
  }

  void _close(DeleteCollectionSheetResult result) {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) navigator.pop(result);
  }
}

/// Opens the decision sheet for deleting a non-empty collection.
///
/// Barrier and drag dismissal are disabled because the sheet itself collects
/// the deletion decision. `useSafeArea` avoids system intrusions, while
/// `isScrollControlled` allows the sheet to accommodate longer content on
/// shorter screens.
Future<DeleteCollectionSheetResult> showDeleteCollectionSheet(
  BuildContext context, {
  required String collectionId,
  required String collectionName,
  required int? itemCount,
}) async {
  final tokens = AppTheme.tokensOf(context);

  final result = await showModalBottomSheet<DeleteCollectionSheetResult>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    isDismissible: false,
    enableDrag: false,
    backgroundColor: tokens.surface,
    clipBehavior: Clip.antiAlias,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppMetrics.radius2),
      ),
    ),
    builder: (_) => DeleteCollectionSheet(
      collectionId: collectionId,
      collectionName: collectionName,
      itemCount: itemCount,
    ),
  );

  // System Back can dismiss the route without a result when no request is
  // in flight. Treat that as a dismissal, not as a completed deletion.
  return result ?? DeleteCollectionSheetResult.dismissed;
}
