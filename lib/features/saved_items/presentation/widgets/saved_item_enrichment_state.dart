import 'package:flutter/material.dart';
import 'package:stash_it_app/app/theme/app_theme.dart';
import 'package:stash_it_app/features/saved_items/domain/saved_item_summary.dart';

/// Restrained enrichment status, shared by the saved-item row and detail screen.
///
/// A successful enrichment says nothing when the item has metadata: the title,
/// description and image already speak for it, so no state line is rendered. That
/// keeps `completed`-with-metadata quiet and makes the two remaining states
/// genuinely distinguishable.
///
/// **`completed` does not mean metadata was found (D8, D17).** A completed item
/// with nothing to show renders a neutral "No details on this page", never a
/// failure colour: the backend did what it was asked and the page exposed
/// nothing.
///
/// The wording is the row's wording on purpose. The detail screen must describe
/// the server's `pending` state without implying that opening it started a read,
/// and a static status line does not; it is the disabled control beside it that
/// must avoid an in-flight label.
class SavedItemEnrichmentState extends StatelessWidget {
  const SavedItemEnrichmentState({required this.item, super.key});

  final SavedItemSummary item;

  @override
  Widget build(BuildContext context) {
    final tokens = AppTheme.tokensOf(context);

    final lineStyle = AppTypography.meta.copyWith(color: tokens.textTertiary);

    switch (item.enrichmentStatus) {
      case EnrichmentStatus.pending:
        return Row(
          children: [
            _StatePip(color: tokens.accent, filled: false),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                'Reading page…',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: lineStyle.copyWith(color: tokens.accent),
              ),
            ),
          ],
        );

      case EnrichmentStatus.completed:
        if (!item.hasNoMetadata) return const SizedBox.shrink();

        // Success with nothing to show. Deliberately not styled as a problem.
        return Text(
          'No details on this page',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: lineStyle,
        );

      case EnrichmentStatus.failed:
        return Row(
          children: [
            _StatePip(color: tokens.danger, filled: true),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                "Couldn't read this page",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: lineStyle.copyWith(color: tokens.danger),
              ),
            ),
          ],
        );
    }
  }
}

/// Hollow while reading, filled when the read failed. Shape carries the
/// distinction so colour is never the only signal.
class _StatePip extends StatelessWidget {
  const _StatePip({required this.color, required this.filled});

  final Color color;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        color: filled ? color : Colors.transparent,
        border: filled ? null : Border.all(color: color, width: 1.4),
      ),
    );
  }
}
