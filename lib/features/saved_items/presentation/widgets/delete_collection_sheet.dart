import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stash_it_app/app/theme/app_theme.dart';
import 'package:stash_it_app/features/collections/domain/collection_summary.dart';
import 'package:stash_it_app/features/saved_items/application/delete_collection_controller.dart';
import 'package:stash_it_app/shared/widgets/app_button.dart';

import 'move_collection_picker_sheet.dart';

/// What one visit to the delete-collection decision surface produced.
///
/// The screen uses this only to decide whether the route it is showing still
/// exists. Every explanation is published by the controller, so the sheet never
/// carries backend prose or re-derives an outcome.
enum DeleteCollectionSheetResult {
  /// Closed without deleting anything: Keep collection, or a known refusal that
  /// left the collection in place.
  dismissed,

  /// The delete transaction committed, or the collection was already gone. Both
  /// mean this route has nothing left to show.
  deleted,
}

/// The one decision a non-empty collection's deletion needs.
///
/// **One surface, three actions, no second confirmation.** The sheet states what
/// happens to the items and lets the user pick the disposition the backend's
/// `saved_items_action` names: move them, or delete them with the collection.
/// Choosing Move opens the same cursor-paginated picker the single-item move
/// uses, and the destination it returns is sent with the delete in **one**
/// request. A destination is a selection, not another confirmation.
///
/// **Not dismissible by barrier or drag.** A stray tap outside must not discard
/// the decision the sheet exists to collect. `Keep collection` and the system
/// Back gesture are the ways out, and Back is blocked while a request is in
/// flight so the sheet cannot disappear underneath one.
///
/// **The count is only stated when it is a total.** [itemCount] is null whenever
/// the loaded listing does not cover the whole collection; the sheet then says
/// that the collection has saved items without inventing a number from a partial
/// page.
class DeleteCollectionSheet extends ConsumerStatefulWidget {
  const DeleteCollectionSheet({
    required this.collectionId,
    required this.collectionName,
    required this.itemCount,
    super.key,
  });

  /// The collection being deleted, and the id excluded from the destination
  /// picker.
  final String collectionId;

  /// The server's name for it, as the loaded listing reported it.
  final String collectionName;

  /// The collection's exact number of saved items, or null when the listing has
  /// more pages and therefore does not know the total.
  final int? itemCount;

  @override
  ConsumerState<DeleteCollectionSheet> createState() =>
      _DeleteCollectionSheetState();
}

/// Which action owns the in-flight state, so only its button shows the spinner.
enum _PendingAction { move, delete }

class _DeleteCollectionSheetState extends ConsumerState<DeleteCollectionSheet> {
  _PendingAction? _pending;

  /// Set after an outcome that may have committed but cannot be confirmed. The
  /// dismissal label stops saying "Keep collection" at that point: the sheet no
  /// longer knows that the collection was kept.
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

  /// Opens the full picker and sends the destination it returns as the bulk
  /// move's target.
  ///
  /// Dismissing the picker sends nothing: the sheet stays open with the same
  /// three actions. The picker excludes this collection by id and includes
  /// Unsorted, which the backend accepts as a destination.
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

  /// Sends the `delete` disposition: the collection and every item in it are
  /// removed. For a non-empty collection this is the destructive choice the
  /// sheet names explicitly; there is no second confirmation.
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

  /// Closes the sheet for outcomes that leave nothing more to decide here.
  ///
  /// A known refusal keeps it open so the user can choose again — after a
  /// missing destination, in particular, the source is untouched and another
  /// destination is the only correction. An ambiguous outcome also stays: the
  /// controller kept every cache entry, and leaving would imply the deletion
  /// completed (**D15**).
  void _handle(CollectionDeletionOutcome outcome) {
    switch (outcome) {
      case CollectionDeletionSucceeded():
      case CollectionDeletionSourceNotFound():
        _close(DeleteCollectionSheetResult.deleted);

      // A concurrent insert rolled the whole transaction back and the contents
      // are refreshing. The count this sheet opened with is no longer true, so
      // it closes rather than asking again from a stale premise.
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

/// Opens the non-empty collection's decision sheet.
///
/// Barrier and drag dismissal are disabled deliberately: the sheet is the
/// confirmation, and tapping outside it must not be mistaken for a disposition.
/// `useSafeArea` keeps it clear of system intrusions and `isScrollControlled`
/// lets it grow with long copy on a short screen.
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

  // A system Back that arrives while no request is in flight pops the route
  // without a value. That is a dismissal, not a delete.
  return result ?? DeleteCollectionSheetResult.dismissed;
}
