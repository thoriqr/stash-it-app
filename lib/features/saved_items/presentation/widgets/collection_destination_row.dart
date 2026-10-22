import 'package:flutter/material.dart';
import 'package:stash_it_app/app/theme/app_theme.dart';
import 'package:stash_it_app/features/collections/domain/collection_summary.dart';

/// One tappable collection destination.
///
/// Shared by the bounded preview in the Move to a collection sheet and the
/// paginated full picker, so the two paths cannot drift visually. The current
/// collection never reaches this widget.
class CollectionDestinationRow extends StatelessWidget {
  const CollectionDestinationRow({
    required this.collection,
    required this.enabled,
    required this.onTap,
    super.key,
  });

  final CollectionSummary collection;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = AppTheme.tokensOf(context);
    final radius = const BorderRadius.all(AppMetrics.controlRadius);

    return Material(
      color: tokens.surfaceInset,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(color: tokens.border),
      ),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: radius,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppMetrics.space3,
            vertical: AppMetrics.space3,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  collection.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.body.copyWith(
                    color: enabled ? tokens.textPrimary : tokens.textDisabled,
                  ),
                ),
              ),
              const SizedBox(width: AppMetrics.space2),
              Icon(
                Icons.arrow_forward,
                size: AppMetrics.iconSize,
                color: enabled ? tokens.textTertiary : tokens.textDisabled,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
