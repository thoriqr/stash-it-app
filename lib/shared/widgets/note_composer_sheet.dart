import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stash_it_app/app/theme/app_theme.dart';
import 'package:stash_it_app/l10n/app_localizations.dart';
import 'package:stash_it_app/shared/widgets/app_button.dart';
import 'package:stash_it_app/shared/widgets/app_field.dart';
import 'package:stash_it_app/shared/widgets/desktop_layout.dart';

/// The maximum note length, in characters.
const int _noteMaxLength = 5000;

/// Opens a local draft note editor.
///
/// Used by the manual URL intake and by the device-local URL list. It sends no
/// request and changes no saved item. Returns the entered text when Done is
/// pressed, including an empty string when the user cleared it. A null result
/// means the sheet was dismissed without applying changes.
Future<String?> showNoteComposerSheet(
  BuildContext context, {
  required String initialNote,
}) {
  final tokens = AppTheme.tokensOf(context);

  return showModalBottomSheet<String>(
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
    builder: (_) => NoteComposerSheet(initialNote: initialNote),
  );
}

/// A local draft editor. It is independent of any request or saved item.
class NoteComposerSheet extends StatefulWidget {
  const NoteComposerSheet({required this.initialNote, super.key});

  final String initialNote;

  @override
  State<NoteComposerSheet> createState() => _NoteComposerSheetState();
}

class _NoteComposerSheetState extends State<NoteComposerSheet> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialNote);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _clear() {
    _controller.clear();
    setState(() {});
  }

  void _done() => Navigator.of(context).pop(_controller.text);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTheme.tokensOf(context);
    final viewInsets = MediaQuery.viewInsetsOf(context);
    final availableHeight =
        MediaQuery.sizeOf(context).height - viewInsets.bottom;
    final hasText = _controller.text.isNotEmpty;
    final count = _controller.text.runes.length;

    return SafeArea(
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
                    Text(
                      l10n.inboxYourNote,
                      style: AppTypography.screenHeading.copyWith(
                        color: tokens.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppMetrics.space5),
                AppField(
                  controller: _controller,
                  placeholder: l10n.savedItemNotePlaceholder,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                  minLines: 4,
                  maxLines: 8,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(_noteMaxLength),
                  ],
                  onChanged: (_) => setState(() {}),
                  onClear: hasText ? _clear : null,
                ),
                const SizedBox(height: AppMetrics.space2),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    l10n.savedItemNoteCharacterCount(count, _noteMaxLength),
                    style: AppTypography.meta.copyWith(
                      color: tokens.textTertiary,
                    ),
                  ),
                ),
                const SizedBox(height: AppMetrics.space5),
                AppButton(
                  label: l10n.inboxNoteDoneAction,
                  variant: AppButtonVariant.primary,
                  onPressed: _done,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
