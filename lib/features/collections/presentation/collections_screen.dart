import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/error/api_failure.dart';
import '../../../core/error/api_failure_messages.dart';
import '../../../shared/widgets/app_button.dart';
import '../application/collections_controller.dart';
import '../application/collections_state.dart';
import 'widgets/collection_skeleton.dart';
import 'widgets/collection_tile.dart';

/// The Collections destination.
///
/// Lists all collections in server-provided order. Unsorted is identified
/// by system_key (D2). Displays saved item counts with overflow as 99+.
class CollectionsScreen extends ConsumerStatefulWidget {
  const CollectionsScreen({super.key});

  @override
  ConsumerState<CollectionsScreen> createState() => _CollectionsScreenState();
}

class _CollectionsScreenState extends ConsumerState<CollectionsScreen> {
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

  void _onScrolled() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 320) {
      ref.read(collectionsProvider.notifier).loadMore();
    }
  }

  Future<void> _refresh() => ref.read(collectionsProvider.notifier).refresh();

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
    final listing = ref.watch(collectionsProvider);

    String currentSort = 'newest';
    if (listing case AsyncData(:final value)) {
      currentSort = value.sort;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('COLLECTIONS')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
            child: Row(
              children: [
                Text(
                  'COLLECTIONS',
                  style: AppTypography.sectionLabel.copyWith(
                    color: tokens.textTertiary,
                  ),
                ),
                const Spacer(),
                DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: currentSort,
                    isDense: true,
                    icon: Icon(
                      Icons.arrow_drop_down,
                      size: 16,
                      color: tokens.textTertiary,
                    ),
                    style: AppTypography.meta.copyWith(
                      color: tokens.textTertiary,
                    ),
                    onChanged: (value) {
                      if (value != null) {
                        ref.read(collectionsProvider.notifier).setSort(value);
                      }
                    },
                    items: const [
                      DropdownMenuItem(value: 'newest', child: Text('Newest')),
                      DropdownMenuItem(value: 'oldest', child: Text('Oldest')),
                      DropdownMenuItem(value: 'name', child: Text('Name')),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: _body(context, listing)),
        ],
      ),
    );
  }

  Widget _body(BuildContext context, AsyncValue<CollectionsState> listing) {
    return switch (listing) {
      AsyncData(:final value) => _rows(context, value),
      AsyncError(:final error, isLoading: false) => _refreshable(
        _CollectionsError(
          failure: error,
          onRetry: () => ref.read(collectionsProvider.notifier).retry(),
        ),
      ),
      AsyncError() => const CollectionSkeletonList(),
      _ => const CollectionSkeletonList(),
    };
  }

  Widget _rows(BuildContext context, CollectionsState state) {
    if (state.items.isEmpty) {
      return _refreshable(const _CollectionsEmpty());
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      child: GridView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.3,
        ),
        itemCount: state.items.length + (state.isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= state.items.length) {
            return const Center(
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          }
          return CollectionTile(item: state.items[index]);
        },
      ),
    );
  }
}

class _CollectionsEmpty extends StatelessWidget {
  const _CollectionsEmpty();

  @override
  Widget build(BuildContext context) {
    final tokens = AppTheme.tokensOf(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'No collections yet',
              textAlign: TextAlign.center,
              style: AppTypography.screenHeading.copyWith(
                fontSize: 15,
                color: tokens.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Collections appear when you save links or organize them.',
              textAlign: TextAlign.center,
              style: AppTypography.body.copyWith(color: tokens.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _CollectionsError extends StatelessWidget {
  const _CollectionsError({required this.failure, required this.onRetry});

  final Object failure;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final tokens = AppTheme.tokensOf(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _messageFor(failure),
              textAlign: TextAlign.center,
              style: AppTypography.body.copyWith(color: tokens.textPrimary),
            ),
            const SizedBox(height: 16),
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

  static String _messageFor(Object failure) => switch (failure) {
    ApiFailureSessionEnded() =>
      'Your session has ended. Sign in again to see your collections.',
    ApiFailureAuthRequired() => 'Sign in again to see your collections.',
    ApiFailureServerUnavailable() =>
      'Your collections are temporarily unavailable. Try again shortly.',
    ApiFailureTransport() =>
      'No connection to the server. We could not load your collections.',
    _ =>
      genericReadFailureMessage(failure) ??
          'We could not load your collections. Try again.',
  };
}
