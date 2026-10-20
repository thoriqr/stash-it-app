import 'package:flutter/material.dart';

import '../../../../app/theme/app_theme.dart';
import '../../domain/collection_summary.dart';

/// Collection tile matching the design reference (collections.html).
class CollectionTile extends StatelessWidget {
  const CollectionTile({super.key, required this.item, this.onTap});

  final CollectionSummary item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = AppTheme.tokensOf(context);

    final borderColor = item.isUnsorted ? tokens.accent : tokens.border;
    final borderWidth = item.isUnsorted ? 1.5 : 1.0;

    return Material(
      color: tokens.surface,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(3)),
        side: BorderSide(color: borderColor, width: borderWidth),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(11),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Simple chest icon placeholder
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 18,
                    color: tokens.textTertiary,
                  ),
                  const Spacer(),
                  // Count badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: tokens.accentSoft,
                      border: Border.all(color: tokens.accentBorder),
                      borderRadius: const BorderRadius.all(Radius.circular(2)),
                    ),
                    child: Text(
                      item.displayCount,
                      style: AppTypography.label.copyWith(
                        color: tokens.accent,
                        fontSize: 10.5,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              if (item.isUnsorted) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 1,
                  ),
                  margin: const EdgeInsets.only(bottom: 4),
                  decoration: BoxDecoration(
                    color: tokens.accentSoft,
                    border: Border.all(color: tokens.accentBorder),
                    borderRadius: const BorderRadius.all(Radius.circular(2)),
                  ),
                  child: Text(
                    'system',
                    style: AppTypography.micro.copyWith(
                      color: tokens.accent,
                      fontSize: 9,
                    ),
                  ),
                ),
              ],
              Text(
                item.name,
                style: AppTypography.itemTitle.copyWith(
                  color: tokens.textPrimary,
                  fontSize: 13,
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
