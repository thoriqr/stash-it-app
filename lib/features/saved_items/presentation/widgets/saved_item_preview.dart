import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:stash_it_app/app/theme/app_theme.dart';

/// The reserved preview well shared by the saved-item row and the detail screen.
///
/// A preview image is a 45° hatch: there is no image loading in this iteration,
/// and a hatch says "an image belongs here" without pretending to show one. With
/// no image the well is dashed and empty. **A missing preview is a normal state**
/// — the space is always reserved and never coloured as an error
/// (`decisions` §2.12).
///
/// **The hatching is exempt from skeletonization.** `Skeletonizer` treats any
/// childless render object — which is what a `CustomPaint` is — as a bone, so it
/// would repaint the hatch's base fill with the shimmer gradient and then draw
/// the solid bands over the top of it. `Skeleton.keep` paints the subtree
/// through an ordinary context instead, so a skeletonized row or detail shows
/// the well exactly as the real one does. It costs nothing when not
/// skeletonized: the annotation is inert outside a `Skeletonizer`.
///
/// Two consumers exist: the 56 px row thumbnail and the wider detail band. Both
/// use the same painters and the same two states, so the detail cannot drift
/// from the row.
class SavedItemPreview extends StatelessWidget {
  const SavedItemPreview({
    required this.hasPreviewImage,
    this.width = AppMetrics.slotThumbSize,
    this.height = AppMetrics.slotThumbSize,
    super.key,
  });

  /// Whether the item reports a usable `image_url`.
  ///
  /// The remote image is **not** loaded in this iteration; the flag only chooses
  /// between the hatch and the empty well.
  final bool hasPreviewImage;

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final tokens = AppTheme.tokensOf(context);

    final border = Border.all(
      color: tokens.border,
      width: AppMetrics.borderWidth,
    );

    if (hasPreviewImage) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          border: border,
          borderRadius: const BorderRadius.all(AppMetrics.controlRadius),
        ),
        clipBehavior: Clip.antiAlias,
        child: Skeleton.keep(
          child: CustomPaint(
            painter: _HatchPainter(
              first: tokens.slotHatch1,
              second: tokens.slotHatch2,
            ),
          ),
        ),
      );
    }

    return Container(
      width: width,
      height: height,
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
        child: Skeleton.keep(
          child: CustomPaint(
            painter: _DashedSquarePainter(color: tokens.borderStrong),
          ),
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
