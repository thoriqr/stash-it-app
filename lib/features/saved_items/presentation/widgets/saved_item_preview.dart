import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:stash_it_app/app/theme/app_theme.dart';
import 'package:stash_it_app/features/saved_items/domain/saved_item_summary.dart';

/// The reserved preview well shared by the saved-item row and the detail screen.
///
/// Four states, decided here so no screen can render them differently:
///
/// * **pending** — the 45° hatch plus a hollow accent pip. The space is
///   reserved and work is acknowledged, but nothing is promised: a `pending`
///   item can be permanently stuck (**D8** has no reconciliation pass), so this
///   is a static mark, never a spinner or a shimmer.
/// * **no usable URL** — a dashed, empty well. Neutral by decision
///   (`decisions` §2.12): a missing preview is routine, never an error, and the
///   status line already explains a pending or failed item.
/// * **URL that loads** — the network image.
/// * **URL that fails to load or decode** — the same dashed well as above.
///   Identical on purpose: the client cannot establish whether the source
///   deleted the image, blocked a hotlink, or never had one, so it does not
///   pretend to know.
///
/// **A missing or unreachable preview is a normal state.** The space is always
/// reserved and never coloured as an error, so rows never shift and the row
/// stays tappable.
///
/// A failed load is purely presentational. It never mutates the domain model:
/// `SavedItemSummary.hasPreviewImage` keeps saying the response reported an
/// image, so an unreachable image cannot make [SavedItemSummary.hasNoMetadata]
/// claim enrichment found nothing.
///
/// **The well is exempt from skeletonization.** `Skeletonizer` treats any
/// childless render object — which is what a `CustomPaint` is — as a bone, so it
/// would repaint the hatch's base fill with the shimmer gradient and then draw
/// the solid bands over the top of it. `Skeleton.keep` paints the subtree
/// through an ordinary context instead, so a skeletonized row or detail shows
/// the well exactly as the real one does. It costs nothing when not
/// skeletonized: the annotation is inert outside a `Skeletonizer`.
///
/// Two consumers exist: the 56 px row thumbnail and the wider detail band. Both
/// use the same painters and the same states, so the detail cannot drift from
/// the row. Only the dimensions and [fit] are the caller's.
class SavedItemPreview extends StatelessWidget {
  const SavedItemPreview({
    required this.imageUrl,
    required this.enrichmentStatus,
    this.width = AppMetrics.slotThumbSize,
    this.height = AppMetrics.slotThumbSize,
    this.fit = BoxFit.cover,
    super.key,
  });

  /// Identifies the pending-enrichment placeholder subtree.
  ///
  /// A stable key rather than a painter type: tests should be able to say "the
  /// pending placeholder is showing" without depending on how it is painted.
  static const Key pendingPlaceholderKey = ValueKey(
    'saved-item-preview-pending',
  );

  /// Identifies the unavailable-image placeholder subtree.
  static const Key unavailablePlaceholderKey = ValueKey(
    'saved-item-preview-unavailable',
  );

  /// The preview URL exactly as the response reported it.
  ///
  /// `null` and blank are ordinary. The value is only loaded when it is an
  /// absolute `http`/`https` URL **and** the item is not pending.
  final String? imageUrl;

  /// The server's enrichment state.
  ///
  /// **Pending takes precedence over [imageUrl].** A pending item is expected to
  /// report no URL, so one that does is anomalous; showing the pending
  /// placeholder and skipping the request keeps the UI honest and costs one
  /// avoided fetch. `failed` and `completed` are treated alike here — in both,
  /// a URL is worth trying and its absence is simply no image.
  final EnrichmentStatus enrichmentStatus;

  final double width;
  final double height;

  /// How the image fills the well. The frame itself is this widget's.
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

    // Resize at decode time, not at paint time. A single axis is enough: it
    // preserves the aspect ratio, and a third-party image may be far larger than
    // the well it lands in. Only finite dimensions can be expressed this way; the
    // detail band's width is `double.infinity`, so it resizes by height alone.
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
        // Decorative. The row's title, domain and status line carry the meaning;
        // an unlabelled image must not add a second, competing announcement.
        excludeFromSemantics: true,
        // Keep the hatch until the first frame is available, so a slow or large
        // image never flashes an empty box or shifts the layout. A synchronously
        // cached image skips it entirely.
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

  /// The frame every state shares: reserved size, hairline border, 2 px radius
  /// and clipping. The fill is the well colour, so the hatch and the image sit on
  /// the same base.
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

  /// The URL this client is willing to load, or `null`.
  ///
  /// **Absolute `http`/`https` only.** A relative value is not resolved against
  /// `Uri.base`: the contract never said it was relative to anything, and
  /// inventing a base would turn an unusable value into a request to somewhere
  /// the app never intended. A blank, malformed or unsupported-scheme value is
  /// simply unavailable — the same outcome as no URL at all, which the well
  /// already renders.
  static String? _loadableUrl(String? raw) {
    final value = raw?.trim();
    if (value == null || value.isEmpty) return null;

    final uri = Uri.tryParse(value);
    if (uri == null) return null;
    if (uri.scheme != 'http' && uri.scheme != 'https') return null;
    if (!uri.hasAuthority || uri.host.isEmpty) return null;

    return value;
  }

  /// A decode extent in physical pixels, or `null` when it cannot be expressed.
  ///
  /// `width` is `double.infinity` on the detail band, and a non-positive value
  /// means nothing usable, so both yield `null` and leave the image to decode at
  /// its own size.
  static int? _decodeExtent(double logical, double pixelRatio) {
    if (!logical.isFinite || logical <= 0) return null;
    if (!pixelRatio.isFinite || pixelRatio <= 0) return null;

    final physical = (logical * pixelRatio).round();
    return physical > 0 ? physical : null;
  }
}

/// The pending state: the hatch, plus the same hollow accent pip the enrichment
/// line uses for `pending`.
///
/// The mark is static. A pending item is queued, not necessarily progressing —
/// it can stay pending indefinitely — so an animation would promise an update
/// this client cannot observe (**D8**, `decisions` §2.1).
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
              // Hollow, like the status line's pending pip: shape carries the
              // distinction, so colour is never the only signal.
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

/// The 45° hatch, kept out of skeletonization. Used for `pending` and as the
/// image-loading placeholder, so both read as "an image belongs here".
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

/// The unavailable-image state: an empty well with a small dashed square.
///
/// Deliberately identical for "enrichment found no image", "this client will not
/// load that URL" and "the image failed to load". The client cannot tell the
/// user which happened, so it does not imply one.
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
