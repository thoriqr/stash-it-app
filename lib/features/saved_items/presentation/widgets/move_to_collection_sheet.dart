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
import 'package:stash_it_app/shared/widgets/app_button.dart';
import 'package:stash_it_app/shared/widgets/app_field.dart';

import 'collection_destination_row.dart';
import 'move_collection_picker_sheet.dart';

/// Five rows are enough to cover the likely destinations without turning the
/// sheet into the collection browser; everything beyond that belongs in the
/// paginated picker.
const int _visibleDestinationLimit = 5;

/// Opens the destination picker for one saved item.
///
/// `isScrollControlled` lets the sheet grow with the bounded preview and make
/// room for the keyboard; `useSafeArea` keeps it clear of system intrusions.
/// `showDragHandle` supplies the centred handle and the framework's drag-to-
/// dismiss gesture, so the sheet needs no close icon. The sheet owns no outcome
/// copy of its own beyond the two inline name errors: the notifier publishes the
/// app-wide confirmation or neutral notice.
Future<void> showMoveToCollectionSheet(
  BuildContext context, {
  required SavedItemSummary item,
}) {
  final tokens = AppTheme.tokensOf(context);

  return showModalBottomSheet<void>(
    context: context,
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

/// The Move to a collection sheet.
///
/// **The current collection is context, not a destination.** It is never in the
/// tappable list, and typing its name is recognised and refused locally. The
/// preview contains at most five other collections, including system
/// collections: nothing is filtered by `type`, name, or `system_key` here
/// (**D2**).
///
/// The preview is deliberately bounded. When more collections exist, `Browse all
/// collections` opens the cursor-paginated picker rather than making this sheet
/// fetch every page. A typed name is matched only against collections the client
/// has already loaded: a match moves with the `existing` intent, while a
/// non-match offers `create` and keeps the browse path visible so the user need
/// not treat the loaded page as global proof that the name is new. The backend
/// remains authoritative for uniqueness; a duplicate name under `create` stays
/// in the sheet as an inline error.
///
/// A row submits immediately with the server's stored name and the `existing`
/// intent. The picker returns a selected collection to this sheet, so both row
/// paths share the same move action.
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
            ? 'Use 100 characters or fewer.'
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
                    'Move to a collection',
                    style: AppTypography.screenHeading.copyWith(
                      color: tokens.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppMetrics.space2),
                  Text(
                    'Currently in ${widget.item.collectionName}',
                    style: AppTypography.body.copyWith(
                      color: tokens.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppMetrics.space5),
                  Text(
                    'YOUR COLLECTIONS',
                    style: AppTypography.sectionLabel.copyWith(
                      color: tokens.textTertiary,
                    ),
                  ),
                  const SizedBox(height: AppMetrics.space3),
                  _destinations(
                    destinations,
                    visible,
                    hasMoreDestinations,
                    busy,
                  ),
                  if (showBrowse) ...[
                    const SizedBox(height: AppMetrics.space3),
                    AppButton(
                      label: 'Browse all collections',
                      variant: AppButtonVariant.quiet,
                      small: true,
                      onPressed: busy ? null : _browseAll,
                    ),
                  ],
                  const SizedBox(height: AppMetrics.space5),
                  AppField(
                    label: 'New collection',
                    controller: _nameController,
                    placeholder: 'e.g. Reading list',
                    enabled: !busy,
                    textInputAction: TextInputAction.done,
                    errorText: visibleNameError,
                    onChanged: (_) => setState(() => _nameError = null),
                    onSubmitted: (_) {
                      if (canSubmit) {
                        _submit(intent: submitIntent);
                      } else if (shapeProblem != null) {
                        setState(
                          () => _nameError = _invalidNameCopy(shapeProblem),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: AppMetrics.space3),
                  Text(
                    _helperCopy(destinations),
                    style: AppTypography.meta.copyWith(
                      color: destinations.hasError && !destinations.isLoading
                          ? tokens.danger
                          : tokens.textTertiary,
                    ),
                  ),
                  const SizedBox(height: AppMetrics.space4),
                  AppButton(
                    label: _primaryLabel(
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
            'Loading collections…',
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
            "We couldn't load your collections.",
            style: AppTypography.body.copyWith(color: tokens.textSecondary),
          ),
          const SizedBox(height: AppMetrics.space2),
          AppButton(
            label: 'Retry',
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
            ? 'Browse all collections to find a destination.'
            : 'No other collections yet. Create one below.',
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

  /// The loaded collection whose name matches [typed], or null.
  ///
  /// The current collection is excluded by id in the list already; the dedicated
  /// [isCurrent] check handles the case where it is not loaded or is a system
  /// collection. Comparison is the server's trim-and-ignore-case rule.
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
    required String typed,
    required bool isCurrent,
    required CollectionSummary? match,
  }) {
    if (typed.isEmpty) return 'Move to a collection';
    if (isCurrent) return 'Already in ${widget.item.collectionName}';
    if (match != null) return 'Move to ${match.name}';
    return 'Create $typed';
  }

  String _helperCopy(AsyncValue<CollectionPage> destinations) {
    if (destinations.hasError && !destinations.isLoading) {
      return 'You can still create one by name, or browse all collections. '
          'If the name is already taken, the server will ask you to choose '
          'another.';
    }
    return 'Names are matched without regard to case against the collections '
        'loaded for this sheet. A loaded match moves the item; any other name '
        'asks the server to create it. Browse all first if it may already '
        'exist elsewhere.';
  }

  /// What a typed submission means.
  ///
  /// A loaded collection the name matches is a destination, so it uses
  /// [MoveToCollectionIntent.existing]. Anything else asks the backend to create
  /// the collection, which is also what makes a duplicate name a `409` the user
  /// can correct instead of an accidental reuse.
  MoveToCollectionIntent _typedIntent(CollectionSummary? match) => match == null
      ? MoveToCollectionIntent.create
      : MoveToCollectionIntent.existing;

  /// Opens the paginated browser and routes its selection through the same
  /// `existing` move path as a preview row.
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
        // Another tap is already in flight. The controls are disabled, so this
        // is a guard rather than a visible state.
        break;
      case MoveToCollectionNameInvalid(:final problem):
        setState(() => _nameError = _invalidNameCopy(problem));
      case MoveToCollectionNameAlreadyExists():
        setState(
          () => _nameError =
              'That collection name is already taken. Choose a different name.',
        );
    }
  }

  String _invalidNameCopy(CollectionNameProblem? problem) => switch (problem) {
    CollectionNameProblem.blank => 'Enter a collection name.',
    CollectionNameProblem.tooLong => 'Use 100 characters or fewer.',
    null => 'Enter a collection name between 1 and 100 characters.',
  };

  void _close() {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) navigator.pop();
  }
}
