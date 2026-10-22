import 'package:flutter/material.dart';
import 'package:stash_it_app/app/theme/app_theme.dart';
import 'package:stash_it_app/features/saved_items/domain/saved_item_summary.dart';
import 'package:stash_it_app/shared/widgets/app_button.dart';

import 'saved_item_collection_chip.dart';
import 'saved_item_enrichment_state.dart';
import 'saved_item_preview.dart';

/// One saved item — the **inventory slot** of `design-system.md` §6.3.
///
/// A bordered card on the canvas: a 56 px thumbnail well, the title with the
/// saved time in its top-right corner, the domain in mono, a two-line
/// description, then a metadata line carrying the item's current collection, its
/// enrichment state and — when the state allows it — a quiet **Retry**.
///
/// **Colour carries one rule.** The accent marks identity and progress: the
/// collection chip and the pending marker. Everything factual — domain, saved
/// time, state wording — is neutral. Only a known failure uses `danger`.
///
/// **A missing preview is a normal state.** The space is always reserved so rows
/// never shift, and the empty well is drawn dashed and neutral: no error colour,
/// no retry (`decisions` §2.12).
///
/// Copy is a draft. The exact wording of the state line and the retry label is a
/// [Rec] in the discovery documents and needs native-speaker review before it is
/// treated as approved.
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

  /// Shown for `pending` and `failed`. D8 [Confirmed]: retry is available on both,
  /// because a stuck item has no other recourse.
  final VoidCallback? onRetry;

  /// Whether the metadata line names the item's collection.
  ///
  /// True wherever a listing spans collections, which is what the chip is for
  /// (**D26**). A listing of **one** collection passes false: every row would
  /// carry the same name, and the screen says it once, in its header. Hidden
  /// rather than blanked, so the metadata line starts at the enrichment state
  /// instead of holding an empty slot.
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
            // A drop shadow is invisible on a dark canvas, so dark lifts the
            // slot with an inset hairline instead.
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
                SavedItemPreview(hasPreviewImage: item.hasPreviewImage),
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
                                // A fallback title is neutral copy, never a
                                // warning colour.
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

/// Collection plus enrichment state.
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

  bool get _showsRetry =>
      onRetry != null &&
      (item.enrichmentStatus == EnrichmentStatus.pending ||
          item.enrichmentStatus == EnrichmentStatus.failed);
}
