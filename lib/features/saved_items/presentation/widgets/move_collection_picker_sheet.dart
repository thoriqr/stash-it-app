import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stash_it_app/app/theme/app_theme.dart';
import 'package:stash_it_app/features/collections/domain/collection_summary.dart';
import 'package:stash_it_app/features/saved_items/application/move_collection_picker_controller.dart';
import 'package:stash_it_app/shared/widgets/app_button.dart';

import 'collection_destination_row.dart';

/// Opens the full, cursor-paginated collection picker.
///
/// Selection is returned to the caller rather than submitted here, so the
/// existing move path in the main sheet remains the only place that sends
/// `PUT /saved-items/{id}/collection` with the `existing` intent.
Future<CollectionSummary?> showMoveCollectionPickerSheet(
  BuildContext context, {
  required String currentCollectionId,
  String? description,
}) {
  final tokens = AppTheme.tokensOf(context);

  return showModalBottomSheet<CollectionSummary>(
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
    builder: (_) => MoveCollectionPickerSheet(
      currentCollectionId: currentCollectionId,
      description: description,
    ),
  );
}

/// The full collection browser.
///
/// One page is read on open; further pages load as the list approaches its end.
/// The footer's `Retry` is the only manual pagination control, and it appears
/// only after a page failed. The current collection is excluded by id because it
/// is context, not a destination.
class MoveCollectionPickerSheet extends ConsumerWidget {
  const MoveCollectionPickerSheet({
    required this.currentCollectionId,
    this.description,
    super.key,
  });

  final String currentCollectionId;

  /// What the picker is choosing a destination for.
  ///
  /// Omitted by the single-item move, which keeps its established copy. A bulk
  /// move supplies wording that names its items rather than one item, without
  /// duplicating the rest of the picker.
  final String? description;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = AppTheme.tokensOf(context);
    final picker = ref.watch(moveCollectionPickerProvider);

    return SafeArea(
      top: false,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.82,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppMetrics.screenPadding,
            AppMetrics.space3,
            AppMetrics.screenPadding,
            AppMetrics.space5,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'All collections',
                style: AppTypography.screenHeading.copyWith(
                  color: tokens.textPrimary,
                ),
              ),
              const SizedBox(height: AppMetrics.space2),
              Text(
                description ?? 'Choose a collection to move this item into.',
                style: AppTypography.body.copyWith(color: tokens.textSecondary),
              ),
              const SizedBox(height: AppMetrics.space4),
              Flexible(child: _content(context, ref, picker)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _content(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<MoveCollectionPickerState> picker,
  ) {
    final tokens = AppTheme.tokensOf(context);

    return switch (picker) {
      AsyncData(:final value) => _LoadedPicker(
        state: value,
        currentCollectionId: currentCollectionId,
      ),
      AsyncError() => Column(
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
            onPressed: () => ref.invalidate(moveCollectionPickerProvider),
          ),
        ],
      ),
      _ => const Padding(
        padding: EdgeInsets.symmetric(vertical: AppMetrics.space6),
        child: Center(child: CircularProgressIndicator()),
      ),
    };
  }
}

class _LoadedPicker extends ConsumerStatefulWidget {
  const _LoadedPicker({required this.state, required this.currentCollectionId});

  final MoveCollectionPickerState state;
  final String currentCollectionId;

  @override
  ConsumerState<_LoadedPicker> createState() => _LoadedPickerState();
}

class _LoadedPickerState extends ConsumerState<_LoadedPicker> {
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

  /// Requests the next page as the list approaches its end.
  ///
  /// Same threshold as the Inbox, Collections and the collection detail: 320
  /// logical pixels. Throttled by what is loaded rather than by the offset — the
  /// controller refuses a page it cannot use, one already in flight, and one
  /// waiting for the footer's Retry — so a notification that arrives several
  /// times costs nothing and cannot retry a failed cursor.
  void _onScrolled() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 320) {
      ref.read(moveCollectionPickerProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AppTheme.tokensOf(context);
    final collections = widget.state.items
        .where((collection) => collection.id != widget.currentCollectionId)
        .toList(growable: false);

    // The footer exists only while something is happening: a page in flight, or a
    // failed page waiting for its Retry. The end of the walk leaves nothing to
    // render, and there is no manual control to offer.
    final showFooter =
        widget.state.isLoadingMore || widget.state.loadMoreFailed;

    if (collections.isEmpty && !showFooter) {
      return Text(
        'No other collections yet.',
        style: AppTypography.body.copyWith(color: tokens.textTertiary),
      );
    }

    return ListView.separated(
      controller: _scrollController,
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      itemCount: collections.length + (showFooter ? 1 : 0),
      separatorBuilder: (_, _) => const SizedBox(height: AppMetrics.space2),
      itemBuilder: (context, index) {
        if (index == collections.length) {
          return _footer(tokens);
        }

        final collection = collections[index];
        return CollectionDestinationRow(
          collection: collection,
          enabled: true,
          onTap: () => Navigator.of(context).pop(collection),
        );
      },
    );
  }

  Widget _footer(AppTokens tokens) {
    if (widget.state.loadMoreFailed) {
      // The only manual pagination control, and the only path that may resume a
      // failed cursor: `loadMore` refuses one by design.
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "We couldn't load more collections.",
            style: AppTypography.body.copyWith(color: tokens.textSecondary),
          ),
          const SizedBox(height: AppMetrics.space2),
          AppButton(
            label: 'Retry',
            variant: AppButtonVariant.secondary,
            small: true,
            block: false,
            onPressed: () =>
                ref.read(moveCollectionPickerProvider.notifier).retryLoadMore(),
          ),
        ],
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppMetrics.space2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(strokeWidth: 2),
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
