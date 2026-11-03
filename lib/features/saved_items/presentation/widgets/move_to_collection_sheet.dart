import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stash_it_app/app/theme/app_theme.dart';
import 'package:stash_it_app/features/collections/domain/collection_name.dart';
import 'package:stash_it_app/features/collections/domain/collection_page.dart';
import 'package:stash_it_app/features/collections/domain/collection_summary.dart';
import 'package:stash_it_app/features/saved_items/application/move_destinations_provider.dart';
import 'package:stash_it_app/features/saved_items/application/move_to_collection_controller.dart';
import 'package:stash_it_app/features/saved_items/domain/move_to_collection_intent.dart';
import 'package:stash_it_app/features/saved_items/domain/saved_item_summary.dart';
import 'package:stash_it_app/l10n/app_localizations.dart';
import 'package:stash_it_app/shared/widgets/app_button.dart';
import 'package:stash_it_app/shared/widgets/app_field.dart';
import 'package:stash_it_app/shared/widgets/desktop_layout.dart';

import 'collection_destination_row.dart';
import 'move_collection_picker_sheet.dart';

/// Maximum number of destinations shown in the sheet preview.
/// Additional destinations are available through the paginated picker.
const int _visibleDestinationLimit = 5;

/// Opens the destination picker for a saved item.
///
/// The sheet can expand to accommodate its content and the keyboard.
/// Its drag handle also provides the dismissal gesture, so no separate
/// close button is needed. Operation feedback is published by the
/// controller; this sheet only displays inline collection-name errors.
Future<void> showMoveToCollectionSheet(
  BuildContext context, {
  required SavedItemSummary item,
}) {
  final tokens = AppTheme.tokensOf(context);

  return showModalBottomSheet<void>(
    context: context,
    constraints: desktopSheetConstraints,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: tokens.surface,
    clipBehavior: Clip.antiAlias,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppMetrics.radius2),
      ),
    ),
    builder: (_) => MoveToCollectionSheet(item: item),
  );
}

/// Sheet for moving a saved item to another collection.
///
/// The current collection is not a valid destination. It is excluded from
/// the destination list and a matching typed name is rejected locally.
/// Other collections, including system collections, remain eligible.
///
/// The preview shows at most five destinations. When more are available,
/// `Browse all collections` opens the cursor-paginated picker rather than
/// loading every page into this sheet.
///
/// Typed names are matched only against collections already loaded by the
/// client. A match uses the `existing` intent; otherwise, the submission
/// uses `create`. An unmatched name does not prove that the collection does
/// not exist elsewhere, so browsing remains available. The server remains
/// authoritative for name uniqueness, and a duplicate-name response is
/// shown as an inline error rather than silently reusing that collection.
///
/// Selecting a preview row submits the move immediately using the
/// collection's stored name. A selection from the paginated picker follows
/// the same move path.
class MoveToCollectionSheet extends ConsumerStatefulWidget {
  const MoveToCollectionSheet({required this.item, super.key});

  final SavedItemSummary item;

  @override
  ConsumerState<MoveToCollectionSheet> createState() =>
      _MoveToCollectionSheetState();
}

class _MoveToCollectionSheetState extends ConsumerState<MoveToCollectionSheet> {
  final _nameController = TextEditingController();
  String? _nameError;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTheme.tokensOf(context);
    final destinations = ref.watch(moveDestinationsProvider);
    final busy = ref.watch(moveToCollectionProvider);
    final viewInsets = MediaQuery.viewInsetsOf(context);
    final availableHeight =
        MediaQuery.sizeOf(context).height - viewInsets.bottom;

    final typed = normalizedCollectionName(_nameController.text);
    final isCurrent =
        typed.isNotEmpty &&
        sameCollectionName(typed, widget.item.collectionName);
    final shapeProblem = collectionNameProblem(typed);
    final preview = switch (destinations) {
      AsyncData(:final value) => value,
      _ => null,
    };
    final loaded =
        preview?.items
            .where((collection) => collection.id != widget.item.collectionId)
            .toList(growable: false) ??
        const <CollectionSummary>[];
    final visible = loaded
        .take(_visibleDestinationLimit)
        .toList(growable: false);
    final hasMoreDestinations =
        preview != null &&
        (loaded.length > _visibleDestinationLimit || preview.hasMore);
    final match = _loadedMatch(loaded, typed);
    final showBrowse =
        hasMoreDestinations ||
        destinations.hasError ||
        (typed.isNotEmpty && match == null);
    final submitIntent = _typedIntent(match);
    final canSubmit =
        typed.isNotEmpty && shapeProblem == null && !isCurrent && !busy;
    final visibleNameError =
        _nameError ??
        (shapeProblem == CollectionNameProblem.tooLong
            ? l10n.savedItemCollectionNameTooLong
            : null);

    return PopScope(
      canPop: !busy,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(bottom: viewInsets.bottom),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: availableHeight > 0 ? availableHeight * 0.88 : 0,
            ),
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
                    l10n.savedItemMoveAction,
                    style: AppTypography.screenHeading.copyWith(
                      color: tokens.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppMetrics.space2),
                  Text(
                    l10n.savedItemCurrentlyIn(widget.item.collectionName),
                    style: AppTypography.body.copyWith(
                      color: tokens.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppMetrics.space5),
                  Text(
                    l10n.savedItemYourCollections,
                    style: AppTypography.sectionLabel.copyWith(
                      color: tokens.textTertiary,
                    ),
                  ),
                  const SizedBox(height: AppMetrics.space3),
                  _destinations(
                    l10n,
                    destinations,
                    visible,
                    hasMoreDestinations,
                    busy,
                  ),
                  if (showBrowse) ...[
                    const SizedBox(height: AppMetrics.space3),
                    AppButton(
                      label: l10n.savedItemBrowseAllCollections,
                      variant: AppButtonVariant.quiet,
                      small: true,
                      onPressed: busy ? null : _browseAll,
                    ),
                  ],
                  const SizedBox(height: AppMetrics.space5),
                  AppField(
                    label: l10n.savedItemNewCollection,
                    controller: _nameController,
                    placeholder: l10n.savedItemNewCollectionPlaceholder,
                    enabled: !busy,
                    textInputAction: TextInputAction.done,
                    errorText: visibleNameError,
                    onChanged: (_) => setState(() => _nameError = null),
                    onSubmitted: (_) {
                      if (canSubmit) {
                        _submit(intent: submitIntent);
                      } else if (shapeProblem != null) {
                        setState(
                          () =>
                              _nameError = _invalidNameCopy(l10n, shapeProblem),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: AppMetrics.space3),
                  Text(
                    _helperCopy(l10n, destinations),
                    style: AppTypography.meta.copyWith(
                      color: destinations.hasError && !destinations.isLoading
                          ? tokens.danger
                          : tokens.textTertiary,
                    ),
                  ),
                  const SizedBox(height: AppMetrics.space4),
                  AppButton(
                    label: _primaryLabel(
                      l10n: l10n,
                      typed: typed,
                      isCurrent: isCurrent,
                      match: match,
                    ),
                    variant: AppButtonVariant.primary,
                    busy: busy,
                    onPressed: canSubmit
                        ? () => _submit(intent: submitIntent)
                        : null,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _destinations(
    AppLocalizations l10n,
    AsyncValue<CollectionPage> destinations,
    List<CollectionSummary> visible,
    bool hasMoreDestinations,
    bool busy,
  ) {
    final tokens = AppTheme.tokensOf(context);

    if (destinations.isLoading) {
      return Row(
        children: [
          if (!busy) ...[
            const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: AppMetrics.space2),
          ],
          Text(
            l10n.savedItemLoadingCollections,
            style: AppTypography.meta.copyWith(color: tokens.textTertiary),
          ),
        ],
      );
    }

    if (destinations.hasError) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.savedItemLoadCollectionsFailed,
            style: AppTypography.body.copyWith(color: tokens.textSecondary),
          ),
          const SizedBox(height: AppMetrics.space2),
          AppButton(
            label: l10n.savedItemRetry,
            variant: AppButtonVariant.secondary,
            small: true,
            block: false,
            onPressed: busy
                ? null
                : () => ref.invalidate(moveDestinationsProvider),
          ),
        ],
      );
    }

    if (visible.isEmpty) {
      return Text(
        hasMoreDestinations
            ? l10n.savedItemBrowseAllHint
            : l10n.savedItemNoOtherCollectionsCreate,
        style: AppTypography.body.copyWith(color: tokens.textTertiary),
      );
    }

    return Column(
      children: [
        for (var i = 0; i < visible.length; i++) ...[
          if (i > 0) const SizedBox(height: AppMetrics.space2),
          CollectionDestinationRow(
            collection: visible[i],
            enabled: !busy,
            onTap: () => _submit(
              collectionName: visible[i].name,
              intent: MoveToCollectionIntent.existing,
            ),
          ),
        ],
      ],
    );
  }

  /// Returns the loaded collection whose name matches [typed], or null.
  ///
  /// The current collection is already excluded from [collections] by ID.
  /// The separate current-name check also handles cases where that
  /// collection is not loaded or is a system collection. Name comparison
  /// follows the same trim-and-case-insensitive rule used by the server.
  CollectionSummary? _loadedMatch(
    List<CollectionSummary> collections,
    String typed,
  ) {
    if (typed.isEmpty) return null;
    for (final collection in collections) {
      if (sameCollectionName(collection.name, typed)) return collection;
    }
    return null;
  }

  String _primaryLabel({
    required AppLocalizations l10n,
    required String typed,
    required bool isCurrent,
    required CollectionSummary? match,
  }) {
    if (typed.isEmpty) return l10n.savedItemMoveAction;
    if (isCurrent) return l10n.savedItemAlreadyIn(widget.item.collectionName);
    if (match != null) return l10n.savedItemMoveTo(match.name);
    return l10n.savedItemCreate(typed);
  }

  String _helperCopy(
    AppLocalizations l10n,
    AsyncValue<CollectionPage> destinations,
  ) {
    if (destinations.hasError && !destinations.isLoading) {
      return l10n.savedItemMoveHelperError;
    }
    return l10n.savedItemMoveHelper;
  }

  /// Determines whether a typed name targets an existing collection
  /// or requests creation of a new one.
  ///
  /// Only a match among the loaded collections uses the `existing` intent.
  /// Every unmatched name uses `create`, allowing the server to enforce
  /// uniqueness and report duplicate names without silently reusing them.
  MoveToCollectionIntent _typedIntent(CollectionSummary? match) => match == null
      ? MoveToCollectionIntent.create
      : MoveToCollectionIntent.existing;

  /// Opens the paginated picker and submits its selection through the same
  /// `existing` move path used by preview rows.
  Future<void> _browseAll() async {
    if (ref.read(moveToCollectionProvider)) return;

    FocusScope.of(context).unfocus();
    final selected = await showMoveCollectionPickerSheet(
      context,
      currentCollectionId: widget.item.collectionId,
    );

    if (!mounted || selected == null) return;

    await _submit(
      collectionName: selected.name,
      intent: MoveToCollectionIntent.existing,
    );
  }

  Future<void> _submit({
    String? collectionName,
    required MoveToCollectionIntent intent,
  }) async {
    if (ref.read(moveToCollectionProvider)) return;

    final raw = collectionName ?? _nameController.text;
    final outcome = await ref
        .read(moveToCollectionProvider.notifier)
        .submit(
          savedItemId: widget.item.id,
          collectionName: raw,
          intent: intent,
        );

    if (!mounted) return;

    switch (outcome) {
      case MoveToCollectionSucceeded():
      case MoveToCollectionItemNotFound():
      case MoveToCollectionUnconfirmed():
      case MoveToCollectionFailed():
        _close();
      case MoveToCollectionIgnored():
        // Another submission is already in progress. The controls are
        // disabled while busy, so this guard does not need a visible state.
        break;
      case MoveToCollectionNameInvalid(:final problem):
        setState(
          () => _nameError = _invalidNameCopy(
            AppLocalizations.of(context),
            problem,
          ),
        );
      case MoveToCollectionNameAlreadyExists():
        setState(
          () => _nameError = AppLocalizations.of(
            context,
          ).savedItemCollectionNameTaken,
        );
    }
  }

  String _invalidNameCopy(
    AppLocalizations l10n,
    CollectionNameProblem? problem,
  ) => switch (problem) {
    CollectionNameProblem.blank => l10n.savedItemCollectionNameRequired,
    CollectionNameProblem.tooLong => l10n.savedItemCollectionNameTooLong,
    null => l10n.savedItemCollectionNameRange,
  };

  void _close() {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) navigator.pop();
  }
}
