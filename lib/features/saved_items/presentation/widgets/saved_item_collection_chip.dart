import 'package:flutter/material.dart';
import 'package:stash_it_app/app/theme/app_theme.dart';

/// The item's current collection — the Inbox's stated reason for existing (D26).
///
/// The one place the accent fills a surface in a row, so collection identity
/// reads immediately against the neutral metadata beside it.
///
/// **Shared by the row and the detail screen.** The detail reports the same
/// collection the row does, from the same `{id, name}` response object, so the
/// two must not drift into different chip treatments. The name is whatever the
/// server reports, including `Unsorted`; **D2** forbids inferring anything from
/// that display name.
class SavedItemCollectionChip extends StatelessWidget {
  const SavedItemCollectionChip({
    required this.name,
    this.maxWidth = 140,
    super.key,
  });

  final String name;

  /// A row has 140 px for the chip so the metadata line stays on one line. The
  /// detail screen has the full content width and passes a wider bound.
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final tokens = AppTheme.tokensOf(context);

    return Container(
      constraints: BoxConstraints(maxWidth: maxWidth),
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
