import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stash_it_app/app/theme/app_theme.dart';
import 'package:stash_it_app/features/saved_items/application/note_edit_decision.dart';
import 'package:stash_it_app/features/saved_items/application/note_mutation_controller.dart';
import 'package:stash_it_app/features/saved_items/domain/saved_item_summary.dart';
import 'package:stash_it_app/l10n/app_localizations.dart';
import 'package:stash_it_app/shared/widgets/app_button.dart';
import 'package:stash_it_app/shared/widgets/app_confirm_dialog.dart';
import 'package:stash_it_app/shared/widgets/app_field.dart';
import 'package:stash_it_app/shared/widgets/desktop_layout.dart';

/// The backend's maximum note length, in characters.
const int savedItemNoteMaxLength = 5000;

/// The note section in Saved Item Detail.
///
/// An existing note shows a compact two-line preview. Without one, the same
/// surface offers a compact add affordance. Both open the one editor sheet.
class SavedItemDetailNote extends StatelessWidget {
  const SavedItemDetailNote({
    required this.note,
    required this.onTap,
    super.key,
  });

  final String? note;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTheme.tokensOf(context);
    final hasNote = note?.trim().isNotEmpty ?? false;

    return Material(
      color: tokens.surfaceInset,
      borderRadius: const BorderRadius.all(AppMetrics.controlRadius),
      child: InkWell(
        borderRadius: const BorderRadius.all(AppMetrics.controlRadius),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppMetrics.space2,
            vertical: 8,
          ),
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
            ],
          ),
        ),
      ),
    );
  }
}

/// Opens the one read-and-edit surface for this item's note.
///
/// The existing note is prepopulated exactly as stored, including line breaks.
/// The same sheet is used for adding and editing. It has one Save action and,
/// only when a persisted note already exists, a dedicated Delete shortcut.
Future<void> showSavedItemNoteEditor(
  BuildContext context, {
  required SavedItemSummary item,
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
    builder: (_) => SavedItemNoteEditorSheet(item: item),
  );
}

/// The add/edit note editor.
class SavedItemNoteEditorSheet extends ConsumerStatefulWidget {
  const SavedItemNoteEditorSheet({required this.item, super.key});

  final SavedItemSummary item;

  @override
  ConsumerState<SavedItemNoteEditorSheet> createState() =>
      _SavedItemNoteEditorSheetState();
}

class _SavedItemNoteEditorSheetState
    extends ConsumerState<SavedItemNoteEditorSheet> {
  late final TextEditingController _controller;
  late final String? _initialNote;

  @override
  void initState() {
    super.initState();
    _initialNote = widget.item.note;
    _controller = TextEditingController(text: _initialNote ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// The snapshot of the note that was persisted when this editor opened.
  ///
  /// This is deliberately not the live draft: the shortcut is available only
  /// for an existing server note, never because the user typed into a new one.
  bool get _hasPersistedNote => noteDeleteAvailable(_initialNote);

  Future<void> _save() async {
    if (ref.read(noteMutationProvider)) return;

    final decision = noteSaveDecision(
      initialNote: _initialNote,
      enteredText: _controller.text,
    );

    switch (decision) {
      case NoteSaveDecision.none:
        Navigator.of(context).pop();

      case NoteSaveDecision.delete:
        await _confirmDelete();

      case NoteSaveDecision.save:
        final outcome = await ref
            .read(noteMutationProvider.notifier)
            .save(widget.item, _controller.text);
        if (!mounted) return;
        if (outcome.closesEditor) Navigator.of(context).pop();
    }
  }

  /// The header shortcut for deleting the note that is already persisted.
  Future<void> _deleteExistingNote() async {
    if (ref.read(noteMutationProvider) || !_hasPersistedNote) return;
    await _confirmDelete();
  }

  /// Confirms and, if accepted, performs the one note deletion.
  ///
  /// Keeping the note restores the persisted snapshot in the open editor. This
  /// matters most for clear-all-and-Save, where the draft is empty, and keeps
  /// both deletion entry points consistent.
  Future<void> _confirmDelete() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showAppConfirmDialog(
      context: context,
      title: l10n.savedItemNoteDeleteTitle,
      message: l10n.savedItemNoteDeleteMessage,
      cancelLabel: l10n.savedItemNoteKeepAction,
      confirmLabel: l10n.savedItemNoteDeleteConfirmAction,
      destructive: true,
    );

    if (!mounted) return;

    if (confirmed != true) {
      _restoreInitialNote();
      return;
    }

    final outcome = await ref
        .read(noteMutationProvider.notifier)
        .delete(widget.item);
    if (!mounted) return;
    if (outcome.closesEditor) Navigator.of(context).pop();
  }

  /// Restores the persisted snapshot without closing or reopening the editor.
  ///
  /// Assigning the controller value does not fire `onChanged`, so the explicit
  /// rebuild also updates the character counter.
  void _restoreInitialNote() {
    final restored = restoredNoteText(_initialNote);
    _controller.value = TextEditingValue(
      text: restored,
      selection: TextSelection.collapsed(offset: restored.length),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTheme.tokensOf(context);
    final busy = ref.watch(noteMutationProvider);
    final viewInsets = MediaQuery.viewInsetsOf(context);
    final availableHeight =
        MediaQuery.sizeOf(context).height - viewInsets.bottom;
    final count = _controller.text.runes.length;

    return PopScope(
      canPop: !busy,
      child: SafeArea(
        top: false,
        child: Padding(
          // The sheet rises with the keyboard rather than covering the editor.
          padding: EdgeInsets.only(bottom: viewInsets.bottom),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: availableHeight > 0 ? availableHeight * 0.9 : 0,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppMetrics.screenPadding,
                AppMetrics.space4,
                AppMetrics.screenPadding,
                AppMetrics.space5,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
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
                      Expanded(
                        child: Text(
                          l10n.inboxYourNote,
                          style: AppTypography.screenHeading.copyWith(
                            color: tokens.textPrimary,
                          ),
                        ),
                      ),
                      // A shortcut only. The existing clear-all-and-Save path
                      // remains available for the same persisted note.
                      if (_hasPersistedNote)
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          iconSize: AppMetrics.iconSize,
                          color: tokens.danger,
                          tooltip: l10n.savedItemNoteDeleteConfirmAction,
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 36,
                            minHeight: 36,
                          ),
                          onPressed: busy ? null : _deleteExistingNote,
                        ),
                    ],
                  ),
                  const SizedBox(height: AppMetrics.space5),
                  AppField(
                    controller: _controller,
                    enabled: !busy,
                    placeholder: l10n.savedItemNotePlaceholder,
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.newline,
                    minLines: 4,
                    maxLines: 8,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(savedItemNoteMaxLength),
                    ],
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: AppMetrics.space2),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      l10n.savedItemNoteCharacterCount(
                        count,
                        savedItemNoteMaxLength,
                      ),
                      style: AppTypography.meta.copyWith(
                        color: tokens.textTertiary,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppMetrics.space5),
                  AppButton(
                    label: l10n.savedItemNoteSaveAction,
                    variant: AppButtonVariant.primary,
                    busy: busy,
                    onPressed: busy ? null : _save,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
