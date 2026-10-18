import 'package:flutter/material.dart';
import 'package:stash_it_app/app/theme/app_theme.dart';

/// Placeholder rows shown while the Inbox listing is loading.
///
/// **The same geometry as [SavedItemRow]**, to the pixel: the same card border,
/// corner, padding and shadow, the same 56 px well on the left, the same
/// two-line title block, the same mono-width source line, the same two-line
/// description and the same metadata row. When the real rows replace these, the
/// list does not change size and nothing jumps.
///
/// Hand-built rather than pulled from a shimmer/skeleton package. The thing that
/// makes a skeleton read correctly is matching the real layout, and that layout
/// is six boxes in this project's own tokens; a generic package would need as
/// much configuration and would add a dependency for it.
class SavedItemSkeleton extends StatelessWidget {
  const SavedItemSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = AppTheme.tokensOf(context);
    final fill = tokens.surfaceSunken;

    Widget bar(double width, double height) => Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: fill,
        borderRadius: const BorderRadius.all(AppMetrics.controlRadius),
      ),
    );

    Widget line(double fraction) => LayoutBuilder(
      builder: (context, constraints) =>
          bar(constraints.maxWidth * fraction, 10),
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: tokens.surface,
        border: Border.all(color: tokens.border),
        borderRadius: const BorderRadius.all(AppMetrics.slotRadius),
        boxShadow: [
          BoxShadow(
            color: tokens.slotShadowColor,
            offset: tokens.slotShadowInset ? Offset.zero : const Offset(0, 1),
            blurRadius: tokens.slotShadowInset ? 0 : 2,
          ),
        ],
      ),
      child: Padding(
        padding: AppMetrics.slotPadding,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // The reserved thumbnail well, hatched exactly as a real preview is.
            Container(
              width: AppMetrics.slotThumbSize,
              height: AppMetrics.slotThumbSize,
              decoration: BoxDecoration(
                border: Border.all(color: tokens.border),
                borderRadius: const BorderRadius.all(AppMetrics.controlRadius),
              ),
              clipBehavior: Clip.antiAlias,
              child: CustomPaint(
                painter: _SkeletonHatchPainter(
                  first: tokens.surfaceSunken,
                  second: tokens.surfaceInset,
                ),
              ),
            ),
            const SizedBox(width: AppMetrics.slotGap),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Two title lines, matching the real two-line clamp, then the
                  // mono source line, then the two-line description, then the
                  // metadata row. The gaps are the real row's `space` tokens.
                  bar(double.infinity, 12),
                  const SizedBox(height: AppMetrics.space2),
                  bar(double.infinity, 12),
                  const SizedBox(height: AppMetrics.space1),
                  line(0.45),
                  const SizedBox(height: 6),
                  line(0.92),
                  const SizedBox(height: AppMetrics.space1),
                  line(0.62),
                  const SizedBox(height: AppMetrics.space2),
                  bar(96, 18),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The 45° hatch, matching the real preview placeholder.
class _SkeletonHatchPainter extends CustomPainter {
  const _SkeletonHatchPainter({required this.first, required this.second});

  final Color first;
  final Color second;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    canvas.drawRect(Offset.zero & size, paint..color = first);

    canvas.save();
    canvas.clipRect(Offset.zero & size);

    paint
      ..color = second
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9;

    final span = size.width + size.height;
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
  bool shouldRepaint(_SkeletonHatchPainter oldDelegate) =>
      oldDelegate.first != first || oldDelegate.second != second;
}

/// A block of skeleton rows, for the Inbox's loading state.
class SavedItemSkeletonList extends StatelessWidget {
  const SavedItemSkeletonList({super.key, this.count = 4});

  /// How many placeholder rows to draw.
  ///
  /// Fixed rather than derived from a screen size: a skeleton that changes its
  /// own height is a second layout rule, and four rows already fill the space
  /// before the real rows arrive.
  final int count;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        AppMetrics.space3,
        AppMetrics.space2,
        AppMetrics.space3,
        AppMetrics.space4,
      ),
      itemCount: count,
      separatorBuilder: (context, index) => const SizedBox(height: 9),
      itemBuilder: (context, index) => const SavedItemSkeleton(),
    );
  }
}
