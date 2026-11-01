import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:stash_it_app/app/theme/app_theme.dart';
import 'package:stash_it_app/features/saved_items/domain/saved_item_summary.dart';

/// Shared preview widget for saved-item rows and the detail screen.
///
/// The preview has four visual states:
///
/// - **Pending:** A static 45-degree hatch with a hollow accent marker.
///   Pending enrichment does not guarantee that work is still progressing,
///   so this state does not use a spinner or shimmer.
/// - **No usable URL:** An empty well with a dashed marker.
/// - **Loaded image:** The image returned by the supplied URL.
/// - **Failed image load:** The same empty well used when no usable URL is
///   available. The client cannot determine why the image is unavailable,
///   so both cases use the same presentation.
///
/// A missing or unreachable preview is a normal state, not an error. The
/// well always reserves its space, preventing layout shifts and keeping the
/// surrounding row stable and tappable.
///
/// Image loading failures are presentational only. They do not modify the
/// domain model or change what the enrichment status reports.
///
/// The well is excluded from skeletonization. Without `Skeleton.keep`,
/// `CustomPaint` can be treated as a skeleton bone and have its background
/// replaced by the shimmer gradient. Keeping the subtree outside that
/// painting preserves the same appearance during loading and in normal use.
///
/// Both the saved-item row and detail screen use the same states and painters.
/// Callers control only the dimensions and [fit].
class SavedItemPreview extends StatelessWidget {
  const SavedItemPreview({
    required this.imageUrl,
    required this.enrichmentStatus,
    this.width = AppMetrics.slotThumbSize,
    this.height = AppMetrics.slotThumbSize,
    this.fit = BoxFit.cover,
    super.key,
  });

  /// Identifies the pending-enrichment placeholder.
  ///
  /// Provides a stable identifier for tests without coupling them to the
  /// placeholder's painting implementation.
  static const Key pendingPlaceholderKey = ValueKey(
    'saved-item-preview-pending',
  );

  /// Identifies the unavailable-image placeholder.
  static const Key unavailablePlaceholderKey = ValueKey(
    'saved-item-preview-unavailable',
  );

  /// Preview URL exactly as reported by the response.
  ///
  /// Null and blank values are valid. The URL is loaded only when it is an
  /// absolute `http` or `https` URL and enrichment is not pending.
  final String? imageUrl;

  /// Enrichment state reported by the server.
  ///
  /// Pending takes precedence over [imageUrl]. Even if a pending item
  /// unexpectedly includes a URL, the pending placeholder is shown and no
  /// image request is made. Completed and failed states are treated alike:
  /// a usable URL is attempted, while its absence shows the unavailable
  /// placeholder.
  final EnrichmentStatus enrichmentStatus;

  final double width;
  final double height;

  /// How the image fills the reserved preview area.
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final tokens = AppTheme.tokensOf(context);

    if (enrichmentStatus == EnrichmentStatus.pending) {
      return _well(
        tokens: tokens,
        child: _PendingPlaceholder(
          key: pendingPlaceholderKey,
          first: tokens.slotHatch1,
          second: tokens.slotHatch2,
          marker: tokens.accent,
        ),
      );
    }

    final url = _loadableUrl(imageUrl);
    if (url == null) return _unavailable(tokens);

    // Resize during decoding rather than painting. One axis is sufficient
    // to preserve the aspect ratio while avoiding unnecessarily large
    // decoded images. Infinite or invalid dimensions cannot be used.
    final pixelRatio = MediaQuery.devicePixelRatioOf(context);
    final cacheWidth = _decodeExtent(width, pixelRatio);
    final cacheHeight = cacheWidth == null
        ? _decodeExtent(height, pixelRatio)
        : null;

    return _well(
      tokens: tokens,
      child: Image.network(
        url,
        fit: fit,
        cacheWidth: cacheWidth,
        cacheHeight: cacheHeight,
        // The image is decorative. The surrounding title, domain, and status
        // already communicate the item's meaning.
        excludeFromSemantics: true,
        // Keep the hatch visible until the first image frame is available.
        // This prevents an empty flash while the image loads. Synchronously
        // cached images skip the placeholder.
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded || frame != null) return child;
          return _Hatch(first: tokens.slotHatch1, second: tokens.slotHatch2);
        },
        errorBuilder: (context, error, stackTrace) => _UnavailablePlaceholder(
          key: unavailablePlaceholderKey,
          square: tokens.borderStrong,
        ),
      ),
    );
  }

  Widget _unavailable(AppTokens tokens) => _well(
    tokens: tokens,
    child: _UnavailablePlaceholder(
      key: unavailablePlaceholderKey,
      square: tokens.borderStrong,
    ),
  );

  /// Builds the shared preview frame with a reserved size, border, radius,
  /// clipping, and background fill.
  Widget _well({required AppTokens tokens, required Widget child}) {
    return Container(
      width: width,
      height: height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: tokens.canvas,
        border: Border.all(color: tokens.border, width: AppMetrics.borderWidth),
        borderRadius: const BorderRadius.all(AppMetrics.controlRadius),
      ),
      child: child,
    );
  }

  /// Returns a URL suitable for loading, or null when it cannot be used.
  ///
  /// Only absolute `http` and `https` URLs with a host are accepted.
  /// Relative URLs are not resolved against `Uri.base`, because the client
  /// has no defined base against which to interpret them. Blank, malformed,
  /// and unsupported-scheme values use the same unavailable presentation.
  static String? _loadableUrl(String? raw) {
    final value = raw?.trim();
    if (value == null || value.isEmpty) return null;

    final uri = Uri.tryParse(value);
    if (uri == null) return null;
    if (uri.scheme != 'http' && uri.scheme != 'https') return null;
    if (!uri.hasAuthority || uri.host.isEmpty) return null;

    return value;
  }

  /// Converts a logical dimension to physical pixels for image decoding.
  ///
  /// Returns null when the dimension or pixel ratio is non-finite or
  /// non-positive. In that case, the image is decoded without an explicit
  /// extent.
  static int? _decodeExtent(double logical, double pixelRatio) {
    if (!logical.isFinite || logical <= 0) return null;
    if (!pixelRatio.isFinite || pixelRatio <= 0) return null;

    final physical = (logical * pixelRatio).round();
    return physical > 0 ? physical : null;
  }
}

/// Static placeholder for pending enrichment.
///
/// Uses the same hatch as the loading placeholder, with a hollow accent
/// marker matching the pending indicator in the enrichment status line.
/// Pending work may remain unresolved, so the placeholder does not animate.
class _PendingPlaceholder extends StatelessWidget {
  const _PendingPlaceholder({
    required this.first,
    required this.second,
    required this.marker,
    super.key,
  });

  final Color first;
  final Color second;
  final Color marker;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        _Hatch(first: first, second: second),
        Center(
          child: Skeleton.keep(
            child: SizedBox(
              width: 6,
              height: 6,
              // The hollow shape distinguishes pending without relying
              // on color alone.
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(color: marker, width: 1.4),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Shared 45-degree hatch used for pending and image-loading states.
class _Hatch extends StatelessWidget {
  const _Hatch({required this.first, required this.second});

  final Color first;
  final Color second;

  @override
  Widget build(BuildContext context) {
    return Skeleton.keep(
      child: CustomPaint(
        painter: _HatchPainter(first: first, second: second),
      ),
    );
  }
}

/// Placeholder for an unavailable preview image.
///
/// Used when no usable URL is available or when loading fails. The client
/// cannot reliably distinguish between these cases, so they share the same
/// neutral presentation.
class _UnavailablePlaceholder extends StatelessWidget {
  const _UnavailablePlaceholder({required this.square, super.key});

  final Color square;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 9,
        height: 9,
        child: Skeleton.keep(
          child: CustomPaint(painter: _DashedSquarePainter(color: square)),
        ),
      ),
    );
  }
}

/// Painter for the repeating diagonal preview hatch.
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

    // Clip the bands to the well's bounds.
    canvas.save();
    canvas.clipRect(Offset.zero & size);

    paint.color = second;
    paint.strokeWidth = 9;
    paint.style = PaintingStyle.stroke;

    // Measure the repeating bands along the well's diagonal.
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

/// Painter for the dashed square in an unavailable preview well.
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

    // Draw 3-pixel segments separated by 2-pixel gaps.
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
