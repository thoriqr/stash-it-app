import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/error/api_failure.dart';
import '../../../core/error/api_failure_messages.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_refresh_button.dart';
import '../../../shared/widgets/desktop_layout.dart';
import '../../../shared/widgets/destination_app_bar.dart';
import '../application/collections_controller.dart';
import '../application/collections_state.dart';
import 'widgets/collection_skeleton.dart';
import 'widgets/collection_tile.dart';

/// The Collections destination.
///
/// Displays collections in server-provided order. Unsorted is identified by
/// its system key rather than its display name. Saved-item counts show `99+`
/// when the count exceeds the display limit.
class CollectionsScreen extends ConsumerStatefulWidget {
  const CollectionsScreen({super.key});

  @override
  ConsumerState<CollectionsScreen> createState() => _CollectionsScreenState();
}

class _CollectionsScreenState extends ConsumerState<CollectionsScreen> {
  final _scrollController = ScrollController();
  bool _refreshing = false;

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

  Future<void> _refresh() async {
    if (_refreshing || ref.read(collectionsProvider).isLoading) return;

    setState(() => _refreshing = true);
    try {
      await ref.read(collectionsProvider.notifier).refresh();
    } finally {
      if (mounted) setState(() => _refreshing = false);
    }
  }

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
    final l10n = AppLocalizations.of(context);
    final tokens = AppTheme.tokensOf(context);
    final listing = ref.watch(collectionsProvider);

    String currentSort = 'newest';
    if (listing case AsyncData(:final value)) {
      currentSort = value.sort;
    }

    return Scaffold(
      appBar: DestinationAppBar(
        title: l10n.collectionsTitle,
        actions: usesDesktopLayout
            ? [
                AppRefreshButton(
                  refreshing: _refreshing,
                  onPressed: listing.isLoading ? null : _refresh,
                ),
              ]
            : const [],
      ),
      body: DesktopContentFrame(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
              child: Row(
                children: [
                  Text(
                    l10n.collectionsTitle,
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
                      items: [
                        DropdownMenuItem(
                          value: 'newest',
                          child: Text(l10n.collectionsSortNewest),
                        ),
                        DropdownMenuItem(
                          value: 'oldest',
                          child: Text(l10n.collectionsSortOldest),
                        ),
                        DropdownMenuItem(
                          value: 'name',
                          child: Text(l10n.collectionsSortName),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: _body(context, listing)),
          ],
        ),
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
        gridDelegate: usesDesktopLayout
            ? const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 260,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.3,
              )
            : const SliverGridDelegateWithFixedCrossAxisCount(
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
          return CollectionTile(
            item: state.items[index],
            onTap: () =>
                context.push(AppRoutes.collectionDetail(state.items[index].id)),
          );
        },
      ),
    );
  }
}

class _CollectionsEmpty extends StatelessWidget {
  const _CollectionsEmpty();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTheme.tokensOf(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.collectionsEmptyTitle,
              textAlign: TextAlign.center,
              style: AppTypography.screenHeading.copyWith(
                fontSize: 15,
                color: tokens.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.collectionsEmptyBody,
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
    final l10n = AppLocalizations.of(context);
    final tokens = AppTheme.tokensOf(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _messageFor(failure, l10n),
              textAlign: TextAlign.center,
              style: AppTypography.body.copyWith(color: tokens.textPrimary),
            ),
            const SizedBox(height: 16),
            AppButton(
              label: l10n.collectionsRetry,
              variant: AppButtonVariant.secondary,
              block: false,
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }

  static String _messageFor(Object failure, AppLocalizations localizations) =>
      switch (failure) {
        ApiFailureSessionEnded() => localizations.collectionsSessionEnded,
        ApiFailureAuthRequired() => localizations.collectionsSignInRequired,
        ApiFailureServerUnavailable() => localizations.collectionsUnavailable,
        ApiFailureTransport() => localizations.collectionsLoadTransport,
        _ =>
          genericReadFailureMessage(failure, localizations) ??
              localizations.collectionsLoadGeneric,
      };
}
