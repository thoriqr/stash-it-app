import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:stash_it_app/app/theme/app_theme.dart';
import 'package:stash_it_app/features/saved_items/domain/saved_item_summary.dart';
import 'package:stash_it_app/shared/widgets/app_button.dart';

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
  const SavedItemRow({super.key, required this.item, this.onTap, this.onRetry});

  final SavedItemSummary item;

  final VoidCallback? onTap;

  /// Shown for `pending` and `failed`. D8 [Confirmed]: retry is available on both,
  /// because a stuck item has no other recourse.
  final VoidCallback? onRetry;

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
                _Thumbnail(hasPreviewImage: item.hasPreviewImage),
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
                      _MetadataLine(item: item, onRetry: onRetry),
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

/// The reserved 56 px well.
///
/// A preview image is a 45° hatch: there is no image loading in this milestone,
/// and a hatch says "an image belongs here" without pretending to show one. With
/// no image the well is dashed and empty.
class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.hasPreviewImage});

  final bool hasPreviewImage;

  @override
  Widget build(BuildContext context) {
    final tokens = AppTheme.tokensOf(context);

    final border = Border.all(
      color: tokens.border,
      width: AppMetrics.borderWidth,
    );

    if (hasPreviewImage) {
      return Container(
        width: AppMetrics.slotThumbSize,
        height: AppMetrics.slotThumbSize,
        decoration: BoxDecoration(
          border: border,
          borderRadius: const BorderRadius.all(AppMetrics.controlRadius),
        ),
        clipBehavior: Clip.antiAlias,
        child: CustomPaint(
          painter: _HatchPainter(
            first: tokens.slotHatch1,
            second: tokens.slotHatch2,
          ),
        ),
      );
    }

    return Container(
      width: AppMetrics.slotThumbSize,
      height: AppMetrics.slotThumbSize,
      decoration: BoxDecoration(
        color: tokens.canvas,
        border: Border.all(color: tokens.border, width: 1),
        borderRadius: const BorderRadius.all(AppMetrics.controlRadius),
      ),
      // A small dashed square, centred: the well reads as "nothing here yet".
      alignment: Alignment.center,
      child: SizedBox(
        width: 9,
        height: 9,
        child: CustomPaint(
          painter: _DashedSquarePainter(color: tokens.borderStrong),
        ),
      ),
    );
  }
}

/// The 45° hatch that stands in for a preview image: 4 px of one step, 5 px of
/// the next, repeating.
class _HatchPainter extends CustomPainter {
  const _HatchPainter({required this.first, required this.second});

  final Color first;
  final Color second;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 0;

    canvas.drawRect(Offset.zero & size, paint..color = first);

    // Clip to the well so the bands cannot bleed past its rounded corners.
    canvas.save();
    canvas.clipRect(Offset.zero & size);

    paint.color = second;
    paint.strokeWidth = 9;
    paint.style = PaintingStyle.stroke;

    // Bands run corner to corner, so the step is measured along the diagonal.
    final span = math.sqrt(size.width * size.width + size.height * size.height);
    for (var offset = -span; offset < span; offset += 9) {
      canvas.drawLine(
        Offset(offset, span),
        Offset(offset + span, -span),
        paint,
      );
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(_HatchPainter oldDelegate) =>
      oldDelegate.first != first || oldDelegate.second != second;
}

/// The dashed square inside an empty well.
class _DashedSquarePainter extends CustomPainter {
  const _DashedSquarePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = AppMetrics.borderWidth
      ..color = color;

    final path = Path()..addRect(Offset.zero & size);

    // 3 on, 2 off.
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(
          metric.extractPath(distance, math.min(distance + 3, metric.length)),
          paint,
        );
        distance += 5;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedSquarePainter oldDelegate) =>
      oldDelegate.color != color;
}

/// Collection plus enrichment state.
class _MetadataLine extends StatelessWidget {
  const _MetadataLine({required this.item, required this.onRetry});

  final SavedItemSummary item;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _CollectionChip(name: item.collectionName),
        const SizedBox(width: AppMetrics.space2),
        Expanded(child: _EnrichmentState(item: item)),
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

/// The item's current collection — the Inbox's stated reason for existing (D26).
///
/// The one place the accent fills a surface in a row, so collection identity
/// reads immediately against the neutral metadata beside it.
class _CollectionChip extends StatelessWidget {
  const _CollectionChip({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final tokens = AppTheme.tokensOf(context);

    return Container(
      constraints: const BoxConstraints(maxWidth: 140),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: tokens.accentSoft,
        border: Border.all(color: tokens.accentBorder),
        borderRadius: const BorderRadius.all(AppMetrics.controlRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 5, height: 5, color: tokens.accent),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.label.copyWith(color: tokens.accent),
            ),
          ),
        ],
      ),
    );
  }
}

/// Restrained enrichment status.
///
/// A successful enrichment says nothing: when the item has metadata, the title,
/// description and image already speak for it, so no state line is rendered. That
/// keeps `completed`-with-metadata quiet and makes the two remaining states
/// genuinely distinguishable.
class _EnrichmentState extends StatelessWidget {
  const _EnrichmentState({required this.item});

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
