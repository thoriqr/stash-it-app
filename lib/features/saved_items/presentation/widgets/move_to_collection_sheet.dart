import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stash_it_app/app/theme/app_theme.dart';
import 'package:stash_it_app/features/collections/domain/collection_name.dart';
import 'package:stash_it_app/features/collections/domain/collection_summary.dart';
import 'package:stash_it_app/features/saved_items/application/move_destinations_provider.dart';
import 'package:stash_it_app/features/saved_items/application/move_to_collection_controller.dart';
import 'package:stash_it_app/features/saved_items/domain/saved_item_summary.dart';
import 'package:stash_it_app/shared/widgets/app_button.dart';
import 'package:stash_it_app/shared/widgets/app_field.dart';

/// Opens the destination picker for one saved item.
///
/// `isScrollControlled` lets the sheet grow with a long collection list and make
/// room for the keyboard; `useSafeArea` keeps it clear of system intrusions. The
/// sheet owns no outcome copy of its own beyond the two inline name errors: the
/// notifier publishes the app-wide confirmation or neutral notice.
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
/// list itself contains every collection the provider returns, including system
/// collections: nothing is filtered by `type`, name, or `system_key` here
/// (**D2**).
///
/// A row submits immediately with the server's stored name. The text field offers
/// the second path — type a name, then either move to the loaded collection it
/// matches (case-insensitively) or create it. The backend remains authoritative
/// for uniqueness, including when the list failed to load.
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
    final loaded = switch (destinations) {
      AsyncData(:final value) => value,
      _ => const <CollectionSummary>[],
    };
    final match = _loadedMatch(loaded, typed);
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
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Move to a collection',
                          style: AppTypography.screenHeading.copyWith(
                            color: tokens.textPrimary,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: busy ? null : _close,
                        tooltip: 'Close',
                        icon: const Icon(Icons.close),
                        iconSize: AppMetrics.iconSize,
                        color: tokens.textTertiary,
                      ),
                    ],
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
                  _destinations(destinations, busy),
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
                        _submit();
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
                    onPressed: canSubmit ? _submit : null,
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
    AsyncValue<List<CollectionSummary>> destinations,
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

    final rows = destinations.requireValue
        .where((collection) => collection.id != widget.item.collectionId)
        .toList(growable: false);

    if (rows.isEmpty) {
      return Text(
        'No other collections yet. Create one below.',
        style: AppTypography.body.copyWith(color: tokens.textTertiary),
      );
    }

    return Column(
      children: [
        for (var i = 0; i < rows.length; i++) ...[
          if (i > 0) const SizedBox(height: AppMetrics.space2),
          _DestinationRow(
            collection: rows[i],
            enabled: !busy,
            onTap: () => _submit(collectionName: rows[i].name),
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

  String _helperCopy(AsyncValue<List<CollectionSummary>> destinations) {
    if (destinations.hasError && !destinations.isLoading) {
      return "You can still create one by name. The server decides whether that "
          'name already exists.';
    }
    return 'Names are matched without regard to case. A new collection is '
        'created when the name does not exist.';
  }

  Future<void> _submit({String? collectionName}) async {
    if (ref.read(moveToCollectionProvider)) return;

    final raw = collectionName ?? _nameController.text;
    final outcome = await ref
        .read(moveToCollectionProvider.notifier)
        .submit(savedItemId: widget.item.id, collectionName: raw);

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
      case MoveToCollectionNameReserved():
        setState(
          () => _nameError =
              'That collection name is reserved. Choose a different name.',
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

/// One tappable destination. The current collection never reaches this widget.
class _DestinationRow extends StatelessWidget {
  const _DestinationRow({
    required this.collection,
    required this.enabled,
    required this.onTap,
  });

  final CollectionSummary collection;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = AppTheme.tokensOf(context);
    final radius = const BorderRadius.all(AppMetrics.controlRadius);

    return Material(
      color: tokens.surfaceInset,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(color: tokens.border),
      ),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: radius,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppMetrics.space3,
            vertical: AppMetrics.space3,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  collection.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.body.copyWith(
                    color: enabled ? tokens.textPrimary : tokens.textDisabled,
                  ),
                ),
              ),
              const SizedBox(width: AppMetrics.space2),
              Icon(
                Icons.arrow_forward,
                size: AppMetrics.iconSize,
                color: enabled ? tokens.textTertiary : tokens.textDisabled,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
