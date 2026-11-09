import 'package:flutter/material.dart';
import 'package:stash_it_app/app/theme/app_theme.dart';
import 'package:stash_it_app/l10n/app_localizations.dart';
import 'package:stash_it_app/shared/widgets/desktop_layout.dart';

/// Opens a read-only view of the complete note already loaded for an item.
///
/// No request is made and no navigation to the saved-item detail screen occurs;
/// the sheet renders the value the Inbox already holds.
Future<void> showSavedItemNoteSheet(
  BuildContext context, {
  required String note,
}) {
  final tokens = AppTheme.tokensOf(context);

  return showModalBottomSheet<void>(
    context: context,
    constraints: desktopSheetConstraints,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: tokens.surface,
    clipBehavior: Clip.antiAlias,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppMetrics.radius2),
      ),
    ),
    builder: (_) => SavedItemNoteSheet(note: note),
  );
}

/// The compact note preview shown below the row's metadata line.
///
/// The whole preview is the tap target. Its own [InkWell] wins the gesture
/// against the surrounding card, so opening the note does not also open the
/// saved-item detail screen.
class SavedItemNotePreview extends StatelessWidget {
  const SavedItemNotePreview({required this.note, super.key});

  final String note;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTheme.tokensOf(context);

    return Padding(
      padding: const EdgeInsets.only(top: AppMetrics.space2),
      child: Material(
        color: tokens.surfaceInset,
        borderRadius: const BorderRadius.all(AppMetrics.controlRadius),
        child: InkWell(
          borderRadius: const BorderRadius.all(AppMetrics.controlRadius),
          onTap: () => showSavedItemNoteSheet(context, note: note),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppMetrics.space2,
              vertical: 6,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 1),
                  child: Icon(
                    Icons.sticky_note_2_outlined,
                    size: 14,
                    color: tokens.textTertiary,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Column(
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
                        note,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.body.copyWith(
                          fontSize: 12.5,
                          height: 1.4,
                          color: tokens.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The complete note, with its line breaks preserved and scrollable so long
/// content remains readable.
class SavedItemNoteSheet extends StatelessWidget {
  const SavedItemNoteSheet({required this.note, super.key});

  final String note;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTheme.tokensOf(context);
    final availableHeight = MediaQuery.sizeOf(context).height * 0.9;

    return SafeArea(
      top: false,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: availableHeight),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppMetrics.screenPadding,
            AppMetrics.space4,
            AppMetrics.screenPadding,
            AppMetrics.space5,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.sticky_note_2_outlined,
                    size: AppMetrics.iconSize,
                    color: tokens.textTertiary,
                  ),
                  const SizedBox(width: AppMetrics.space2),
                  Text(
                    l10n.inboxYourNote,
                    style: AppTypography.screenHeading.copyWith(
                      color: tokens.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppMetrics.space4),
              SelectableText(
                note,
                style: AppTypography.body.copyWith(color: tokens.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
