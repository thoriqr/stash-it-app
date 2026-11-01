import 'package:flutter/material.dart';
import 'package:stash_it_app/app/theme/app_theme.dart';
import 'package:stash_it_app/features/saved_items/domain/saved_item_summary.dart';
import 'package:stash_it_app/shared/widgets/app_button.dart';

import 'saved_item_collection_chip.dart';
import 'saved_item_enrichment_state.dart';
import 'saved_item_preview.dart';

/// Displays one saved item as a compact inventory card.
///
/// The card combines a preview, title, saved time, source domain,
/// optional description, and a metadata line containing the item's
/// collection and enrichment state.
///
/// Accent color is reserved for identity and progress indicators, such as
/// the collection chip and pending marker. Factual information remains
/// neutral, while danger color is reserved for known failures.
///
/// A missing or unavailable preview is a normal state. Its space remains
/// reserved and uses a neutral dashed placeholder rather than error styling.
///
/// The displayed state wording and retry label are user-facing copy and may
/// need further language review.
class SavedItemRow extends StatelessWidget {
  const SavedItemRow({
    super.key,
    required this.item,
    this.onTap,
    this.onRetry,
    this.showCollectionChip = true,
  });

  final SavedItemSummary item;

  final VoidCallback? onTap;

  /// Callback for retrying enrichment.
  ///
  /// The retry action is available for both pending and failed items.
  final VoidCallback? onRetry;

  /// Whether the metadata line displays the item's collection.
  ///
  /// Enable this when a listing can contain items from multiple collections.
  /// Disable it for a single-collection listing, where the collection name
  /// is already shown in the screen header. When hidden, the metadata line
  /// starts with the enrichment state rather than reserving empty space.
  final bool showCollectionChip;

  @override
  Widget build(BuildContext context) {
    final tokens = AppTheme.tokensOf(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: tokens.surface,
        border: Border.all(color: tokens.border),
        borderRadius: const BorderRadius.all(AppMetrics.slotRadius),
        boxShadow: [
          BoxShadow(
            color: tokens.slotShadowColor,
            // Use an inset hairline in dark mode, where a drop shadow
            // would not provide enough contrast against the canvas.
            offset: tokens.slotShadowInset ? Offset.zero : const Offset(0, 1),
            blurRadius: tokens.slotShadowInset ? 0 : 2,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: const BorderRadius.all(AppMetrics.slotRadius),
          child: Padding(
            padding: AppMetrics.slotPadding,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SavedItemPreview(
                  imageUrl: item.imageUrl,
                  enrichmentStatus: item.enrichmentStatus,
                ),
                const SizedBox(width: AppMetrics.slotGap),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              item.displayTitle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.itemTitle.copyWith(
                                // Fallback titles remain neutral rather than
                                // implying an error or warning.
                                color: item.usesFallbackTitle
                                    ? tokens.textTertiary
                                    : tokens.textPrimary,
                                fontWeight: item.usesFallbackTitle
                                    ? FontWeight.w400
                                    : FontWeight.w600,
                              ),
                            ),
                          ),
                          if (item.savedTimeLabel case final savedAt?) ...[
                            const SizedBox(width: AppMetrics.space2),
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(
                                savedAt,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.monoSmall.copyWith(
                                  color: tokens.textTertiary,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: AppMetrics.space1),
                      Text(
                        item.displaySource,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.mono.copyWith(
                          color: tokens.textTertiary,
                        ),
                      ),
                      if (item.description case final description?) ...[
                        const SizedBox(height: 6),
                        Text(
                          description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.body.copyWith(
                            fontSize: 12.5,
                            height: 1.48,
                            color: tokens.textSecondary,
                          ),
                        ),
                      ],
                      const SizedBox(height: AppMetrics.space2),
                      _MetadataLine(
                        item: item,
                        onRetry: onRetry,
                        showCollectionChip: showCollectionChip,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Displays the item's collection and enrichment state, with an optional
/// retry action.
class _MetadataLine extends StatelessWidget {
  const _MetadataLine({
    required this.item,
    required this.onRetry,
    required this.showCollectionChip,
  });

  final SavedItemSummary item;
  final VoidCallback? onRetry;
  final bool showCollectionChip;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (showCollectionChip) ...[
          SavedItemCollectionChip(name: item.collectionName),
          const SizedBox(width: AppMetrics.space2),
        ],
        Expanded(child: SavedItemEnrichmentState(item: item)),
        if (_showsRetry) ...[
          const SizedBox(width: AppMetrics.space1),
          AppButton(
            label: 'Retry',
            variant: AppButtonVariant.quiet,
            small: true,
            block: false,
            onPressed: onRetry,
          ),
        ],
      ],
    );
  }

  /// Retry is shown only when a callback is available and enrichment
  /// is either pending or failed.
  bool get _showsRetry =>
      onRetry != null &&
      (item.enrichmentStatus == EnrichmentStatus.pending ||
          item.enrichmentStatus == EnrichmentStatus.failed);
}
