import 'package:flutter/material.dart';
import 'package:stash_it_app/app/theme/app_theme.dart';

/// The one entry point to the device-local URL list.
///
/// Used by [AuthEntryScreen] and [InboxScreen] so the label, count, treatment,
/// and interaction cannot drift between them. The widget only renders and
/// reports a tap; the caller owns the route.
///
/// **Colour is semantic, not decorative.** A non-empty list uses the existing
/// `warning` / `warningSoft` / `warningBorder` tokens, which the token file
/// documents for expiry and uncertain outcomes. An empty Inbox entry uses the
/// neutral surface/border tokens because there is nothing needing attention.
/// No new colour token is introduced.
///
/// **The count is capped at the display boundary only.** `100` renders as
/// `99+`; the summaries elsewhere keep exact counts. The semantics label says
/// "more than 99" so a screen reader is not asked to read "99 plus".
class PendingUrlsEntry extends StatelessWidget {
  const PendingUrlsEntry({super.key, required this.count, required this.onTap});

  /// The number of locally kept URLs. Negative values are treated as zero.
  final int count;

  /// Opens the device-local list. The whole card is the target.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = AppTheme.tokensOf(context);
    final safeCount = count < 0 ? 0 : count;
    final active = safeCount > 0;

    final fill = active ? tokens.warningSoft : tokens.surface;
    final border = active ? tokens.warningBorder : tokens.border;
    final iconColor = active ? tokens.warning : tokens.textTertiary;

    return Semantics(
      button: true,
      container: true,
      label: _semanticLabel(safeCount),
      onTap: onTap,
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: fill,
          border: Border.all(color: border),
          borderRadius: const BorderRadius.all(AppMetrics.slotRadius),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: const BorderRadius.all(AppMetrics.slotRadius),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: AppMetrics.slotThumbSize,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppMetrics.space3,
                  vertical: AppMetrics.space3,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.bookmark_border,
                      size: AppMetrics.iconSize,
                      color: iconColor,
                    ),
                    const SizedBox(width: AppMetrics.space3),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  'Saved on this device',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTypography.itemTitle.copyWith(
                                    color: tokens.textPrimary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppMetrics.space2),
                              _CountBadge(count: safeCount, active: active),
                            ],
                          ),
                          const SizedBox(height: AppMetrics.space1),
                          Text(
                            active
                                ? 'Kept on this device. Open to review them.'
                                : "Links that couldn't be saved will appear "
                                      'here.',
                            style: AppTypography.meta.copyWith(
                              color: tokens.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppMetrics.space2),
                    Icon(
                      Icons.chevron_right,
                      size: AppMetrics.iconSize,
                      color: tokens.textTertiary,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  static String _semanticLabel(int count) {
    if (count <= 0) return 'Saved on this device';
    final value = count > 99 ? 'more than 99' : '$count';
    return 'Saved on this device, $value ${count == 1 ? 'link' : 'links'}';
  }
}

class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.count, required this.active});

  final int count;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final tokens = AppTheme.tokensOf(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: active ? tokens.surface : tokens.surfaceInset,
        border: Border.all(
          color: active ? tokens.warningBorder : tokens.border,
        ),
        borderRadius: const BorderRadius.all(AppMetrics.controlRadius),
      ),
      child: Text(
        pendingUrlCountLabel(count),
        style: AppTypography.label.copyWith(color: tokens.textPrimary),
      ),
    );
  }
}

/// The entry badge's count, capped at the display boundary.
String pendingUrlCountLabel(int count) {
  if (count <= 0) return '0';
  return count > 99 ? '99+' : '$count';
}
