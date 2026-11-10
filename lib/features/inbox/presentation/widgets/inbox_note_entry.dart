import 'package:flutter/material.dart';
import 'package:stash_it_app/app/theme/app_theme.dart';
import 'package:stash_it_app/l10n/app_localizations.dart';

/// The compact optional-note entry in the manual Inbox URL intake.
///
/// A null [note] shows the add affordance. A meaningful draft shows the same
/// two-line preview treatment used by the saved-item note card. Pass null for
/// [onTap] for a read-only preview, such as in the save confirmation dialog.
class InboxNoteEntry extends StatelessWidget {
  const InboxNoteEntry({required this.note, this.onTap, super.key});

  final String? note;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTheme.tokensOf(context);
    final hasNote = note?.trim().isNotEmpty ?? false;

    return Material(
      color: tokens.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(AppMetrics.controlRadius),
        side: BorderSide(color: tokens.border),
      ),
      child: InkWell(
        borderRadius: const BorderRadius.all(AppMetrics.controlRadius),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 1),
                child: Icon(
                  hasNote
                      ? Icons.sticky_note_2_outlined
                      : Icons.note_add_outlined,
                  size: 14,
                  color: tokens.textTertiary,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: hasNote
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.inboxYourNote,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.meta.copyWith(
                              color: tokens.textTertiary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            note!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.body.copyWith(
                              fontSize: 12.5,
                              height: 1.4,
                              color: tokens.textSecondary,
                            ),
                          ),
                        ],
                      )
                    : Text(
                        l10n.savedItemAddNote,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.meta.copyWith(
                          color: tokens.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
              if (onTap != null) ...[
                const SizedBox(width: AppMetrics.space1),
                Padding(
                  padding: const EdgeInsets.only(top: 1),
                  child: Icon(
                    Icons.chevron_right,
                    size: 16,
                    color: tokens.textTertiary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
