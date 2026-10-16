import 'package:flutter/material.dart';
import 'package:stash_it_app/app/theme/app_theme.dart';
import 'package:stash_it_app/app/theme/app_tokens.dart';
import 'package:stash_it_app/features/saved_items/domain/saved_item_summary.dart';

/// One saved item in a list — the reusable row described in
/// `docs/wireframes/02-item-presentation.html`.
///
/// Structure follows the approved wireframe anatomy: optional thumbnail, title,
/// compact source with the saved-time label, optional description, then a metadata
/// line carrying the item's current collection and its enrichment state.
///
/// Design intent: no card, no shadow. Separation comes from a hairline divider drawn
/// by the parent list, so consecutive rows read as one document on paper.
///
/// Colour carries one rule: the accent marks identity and progress (the collection
/// pill, the pending marker, retry); everything factual — source, saved time, state
/// wording — is neutral. Only failure uses the danger colour.
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
    final theme = Theme.of(context);
    final tokens = theme.extension<AppTokens>() ?? AppTheme.tokens;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.hasPreviewImage) ...[
              _Thumbnail(tokens: tokens),
              const SizedBox(width: 14),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.displayTitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      // A fallback title is neutral copy, never a warning colour.
                      color: item.usesFallbackTitle
                          ? tokens.textMuted
                          : tokens.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Expanded(
                        child: Text(
                          item.displaySource,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                      if (item.savedTimeLabel case final savedAt?) ...[
                        const SizedBox(width: 10),
                        // Bounded so a long label can never push the source line into
                        // an overflow; the source keeps its share.
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 130),
                          child: Text(
                            savedAt,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              // Held a step quieter than the source so the domain
                              // keeps the left edge of this line.
                              color: tokens.textMuted.withValues(alpha: 0.85),
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (item.description case final description?) ...[
                    const SizedBox(height: 7),
                    Text(
                      description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                  const SizedBox(height: 9),
                  _MetadataLine(item: item, tokens: tokens, onRetry: onRetry),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Reserved slot for a preview image.
///
/// No image loading exists yet, so this renders a neutral placeholder rather than
/// pretending to show content. The box is always the same size, so rows never shift
/// when an image is present (`decisions` §2.12: broken preview images are routine,
/// reserve the space, show no error, offer no retry).
class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.tokens});

  final AppTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: tokens.surfaceMuted,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: tokens.border),
      ),
      child: Icon(
        Icons.image_outlined,
        size: 17,
        color: tokens.textMuted.withValues(alpha: 0.5),
      ),
    );
  }
}

/// Collection plus enrichment state.
class _MetadataLine extends StatelessWidget {
  const _MetadataLine({
    required this.item,
    required this.tokens,
    required this.onRetry,
  });

  final SavedItemSummary item;
  final AppTokens tokens;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _CollectionPill(name: item.collectionName, tokens: tokens),
        const SizedBox(width: 10),
        Expanded(
          child: _EnrichmentState(item: item, tokens: tokens),
        ),
        if (_showsRetry) ...[
          const SizedBox(width: 4),
          _RetryButton(onPressed: onRetry, tokens: tokens),
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
/// The one place the accent appears in a row, so collection identity reads
/// immediately against the neutral metadata beside it.
class _CollectionPill extends StatelessWidget {
  const _CollectionPill({required this.name, required this.tokens});

  final String name;
  final AppTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 150),
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: tokens.accentSoft,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(
          context,
        ).textTheme.labelSmall?.copyWith(color: tokens.accent),
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
  const _EnrichmentState({required this.item, required this.tokens});

  final SavedItemSummary item;
  final AppTokens tokens;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    switch (item.enrichmentStatus) {
      case EnrichmentStatus.pending:
        return Row(
          children: [
            _StateDot(color: tokens.accent, filled: false),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                'Reading page…',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall,
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
          style: theme.textTheme.bodySmall,
        );

      case EnrichmentStatus.failed:
        return Row(
          children: [
            _StateDot(color: tokens.danger, filled: true),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                "Couldn't read this page",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: tokens.danger,
                ),
              ),
            ),
          ],
        );
    }
  }
}

/// Hollow while reading, filled when the read failed. Shape carries the distinction
/// so colour is never the only signal.
class _StateDot extends StatelessWidget {
  const _StateDot({required this.color, required this.filled});

  final Color color;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: filled ? color : Colors.transparent,
        border: filled ? null : Border.all(color: color, width: 1.4),
      ),
    );
  }
}

class _RetryButton extends StatelessWidget {
  const _RetryButton({required this.onPressed, required this.tokens});

  final VoidCallback? onPressed;
  final AppTokens tokens;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: tokens.accent,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        minimumSize: const Size(0, 30),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        textStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: tokens.accent,
        ),
      ),
      child: const Text('Retry'),
    );
  }
}
