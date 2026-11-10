import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stash_it_app/app/theme/app_theme.dart';
import 'package:stash_it_app/features/inbox/presentation/inbox_note_draft.dart';
import 'package:stash_it_app/features/saved_items/application/save_url_controller.dart';
import 'package:stash_it_app/features/saved_items/domain/saved_item_url.dart';
import 'package:stash_it_app/l10n/app_localizations.dart';
import 'package:stash_it_app/shared/widgets/app_button.dart';
import 'package:stash_it_app/shared/widgets/app_field.dart';

import 'inbox_note_composer_sheet.dart';
import 'inbox_note_entry.dart';
import 'save_with_note_dialog.dart';

/// URL intake for the Inbox.
///
/// Paste reads plain text from the platform clipboard and fills the field
/// without submitting. Save URL submits the field's current value through
/// [SaveUrl] and clears it only after a confirmed save.
///
/// Empty, non-text, or failed clipboard reads leave the field unchanged and
/// produce no feedback. Pasted content is inserted as-is; URL validation is
/// handled by the save flow rather than during paste.
///
/// Paste and Save URL remain visually distinct: Paste is a secondary action,
/// while Save URL is the primary action. Pasting never saves without an
/// explicit tap on Save URL.
///
/// Clearing the field is also separate from saving. The inline clear control
/// only empties the field and is unavailable while a save is in progress.
///
/// The widget prevents empty or whitespace-only submissions. URL shape
/// validation is handled by [SaveUrl] before the request is sent, while the
/// server remains authoritative for checks that cannot be performed locally.
///
/// Both actions are disabled while a save is in progress. After a confirmed
/// save, the field is cleared only if it still contains the submitted value,
/// preserving any newer input.
///
/// An optional note draft lives in this widget's state, so it survives switching
/// Inbox tabs while the shell keeps the branch mounted. It is not persisted and
/// never reaches another intake. A meaningful draft triggers one confirmation
/// before the single create request; the user can save with it, save without it,
/// or cancel.
class InboxIntake extends ConsumerStatefulWidget {
  const InboxIntake({super.key});

  @override
  ConsumerState<InboxIntake> createState() => _InboxIntakeState();
}

class _InboxIntakeState extends ConsumerState<InboxIntake> {
  final _controller = TextEditingController();

  /// The current manual-intake note draft.
  ///
  /// Null or meaningful text only; whitespace-only composer output is
  /// normalized to null when Done is pressed. It stays local to this retained
  /// Inbox branch and is never persisted.
  String? _noteDraft;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Opens the local composer and applies its result to the draft.
  ///
  /// A dismissed sheet returns null and leaves the existing draft untouched.
  /// Done returns the entered text; whitespace-only text clears the draft.
  Future<void> _editNote() async {
    final result = await showInboxNoteComposer(
      context,
      initialNote: _noteDraft ?? '',
    );
    if (!mounted || result == null) return;

    setState(() => _noteDraft = inboxNoteDraftText(result));
  }

  /// Submits the field's value and clears it only after a confirmed save.
  ///
  /// Captures the submitted value before awaiting the request. This prevents a
  /// successful response from clearing different content entered while the
  /// request was in progress. The mounted check also prevents access to a
  /// disposed controller after navigation.
  ///
  /// When a meaningful note draft exists and the URL passes the same local
  /// shape check the controller uses, the user chooses whether to include it.
  /// The chosen payload is still submitted through one [SaveUrl.submit] call.
  Future<void> _save() async {
    if (ref.read(saveUrlProvider)) return;

    final submitted = _controller.text;
    final draftNote = inboxNoteDraftText(_noteDraft);
    var noteToSend = draftNote;

    if (draftNote != null && isSubmittableUrl(submitted)) {
      final decision = await showSaveWithNoteDialog(context, note: draftNote);
      if (!mounted) return;
      if (decision == SaveWithNoteDecision.cancel) return;
      if (decision == SaveWithNoteDecision.saveWithoutNote) {
        noteToSend = null;
      }
    }

    final saved = await ref
        .read(saveUrlProvider.notifier)
        .submit(submitted, note: noteToSend);

    if (!mounted) return;
    if (!saved) return;

    setState(() {
      // Preserve newer URL input, matching the existing clear rule.
      if (_controller.text == submitted) _controller.clear();

      // A confirmed save clears the draft in both save-with and save-without
      // paths, so the next independent intake always starts without a note.
      _noteDraft = null;
    });
  }

  /// Fills the field from the platform clipboard without submitting it.
  ///
  /// The clipboard content is inserted as-is. Empty or whitespace-only content
  /// is ignored. No URL validation or feedback is performed during paste.
  Future<void> _paste() async {
    final ClipboardData? data;
    try {
      data = await Clipboard.getData(Clipboard.kTextPlain);
    } catch (_) {
      // Leave the field unchanged when the clipboard cannot be read.
      return;
    }

    // Do not update the field if the screen was disposed during the read.
    if (!mounted) return;

    final text = data?.text;
    if (text == null || text.trim().isEmpty) return;

    _controller.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
    setState(() {});
  }

  /// Clears the field without submitting or publishing feedback.
  ///
  /// The clear control is available only when the field has content and no
  /// save is in progress.
  void _clear() {
    _controller.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTheme.tokensOf(context);
    final isSaving = ref.watch(saveUrlProvider);
    final hasValue = _controller.text.trim().isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppMetrics.space4,
        vertical: AppMetrics.space3,
      ),
      decoration: BoxDecoration(
        color: tokens.surfaceInset,
        border: Border(bottom: BorderSide(color: tokens.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              // Uppercase section label using the shared typography style.
              Text(
                l10n.inboxSaveUrlSection,
                style: AppTypography.sectionLabel.copyWith(
                  color: tokens.textSecondary,
                ),
              ),
              const SizedBox(width: AppMetrics.space2),
              Expanded(
                child: Text(
                  switch ((isSaving, hasValue)) {
                    (true, _) => l10n.inboxSaving,
                    (false, true) => l10n.inboxIntakeReady,
                    (false, false) => l10n.inboxIntakeHint,
                  },
                  textAlign: TextAlign.right,
                  style: AppTypography.label.copyWith(
                    color: tokens.textTertiary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppMetrics.space2),
          AppField(
            controller: _controller,
            mono: true,
            placeholder: 'https://',
            textInputAction: TextInputAction.done,
            onChanged: (_) => setState(() {}),
            // Whitespace-only input is treated as empty. Clearing is disabled
            // while the submitted value is unresolved.
            onClear: hasValue && !isSaving ? _clear : null,
          ),
          const SizedBox(height: AppMetrics.space2),
          // Optional and compact: either the add affordance or a two-line
          // preview of the current local draft.
          InboxNoteEntry(note: _noteDraft, onTap: isSaving ? null : _editNote),
          const SizedBox(height: AppMetrics.space2),
          Row(
            children: [
              // Paste only fills the field. Both actions are disabled while
              // saving to prevent overlapping interactions.
              AppButton(
                label: l10n.inboxPaste,
                variant: AppButtonVariant.secondary,
                block: false,
                onPressed: isSaving ? null : _paste,
              ),
              const SizedBox(width: AppMetrics.space2),
              Expanded(
                child: AppButton(
                  label: l10n.inboxSaveAction,
                  variant: AppButtonVariant.primary,
                  busy: isSaving,
                  onPressed: hasValue && !isSaving ? _save : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
