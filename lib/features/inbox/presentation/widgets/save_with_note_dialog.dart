import 'package:flutter/material.dart';
import 'package:stash_it_app/app/theme/app_theme.dart';
import 'package:stash_it_app/l10n/app_localizations.dart';
import 'package:stash_it_app/shared/widgets/app_button.dart';

import 'inbox_note_entry.dart';

/// The three choices when a manual save carries a note.
enum SaveWithNoteDecision { saveWithNote, saveWithoutNote, cancel }

/// Confirms how a drafted note should be handled for one manual save.
///
/// Dismissing the dialog through Back or a barrier is treated as Cancel. The
/// caller must not submit a request until this returns a save decision.
Future<SaveWithNoteDecision> showSaveWithNoteDialog(
  BuildContext context, {
  required String note,
}) async {
  final decision = await showDialog<SaveWithNoteDecision>(
    context: context,
    builder: (_) => SaveWithNoteDialog(note: note),
  );
  return decision ?? SaveWithNoteDecision.cancel;
}

/// A compact note reminder with one save-with, one save-without, and Cancel.
///
/// The note preview is read-only here; editing happened in the composer before
/// Save URL was pressed.
class SaveWithNoteDialog extends StatelessWidget {
  const SaveWithNoteDialog({required this.note, super.key});

  final String note;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTheme.tokensOf(context);

    return Dialog(
      backgroundColor: tokens.surfaceRaised,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: AppMetrics.space4,
        vertical: AppMetrics.space6,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(
          Radius.circular(AppMetrics.radius3),
        ),
        side: BorderSide(color: tokens.border),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(AppMetrics.space5),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.inboxSaveWithNoteTitle,
                style: AppTypography.screenHeading.copyWith(
                  color: tokens.textPrimary,
                ),
              ),
              const SizedBox(height: AppMetrics.space3),
              InboxNoteEntry(note: note),
              const SizedBox(height: AppMetrics.space5),
              AppButton(
                label: l10n.inboxSaveWithNoteAction,
                variant: AppButtonVariant.primary,
                onPressed: () => Navigator.of(
                  context,
                ).pop(SaveWithNoteDecision.saveWithNote),
              ),
              const SizedBox(height: AppMetrics.space2),
              AppButton(
                label: l10n.inboxSaveWithoutNoteAction,
                variant: AppButtonVariant.secondary,
                onPressed: () => Navigator.of(
                  context,
                ).pop(SaveWithNoteDecision.saveWithoutNote),
              ),
              const SizedBox(height: AppMetrics.space2),
              AppButton(
                label: l10n.savedItemCancelAction,
                variant: AppButtonVariant.quiet,
                onPressed: () =>
                    Navigator.of(context).pop(SaveWithNoteDecision.cancel),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
