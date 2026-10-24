import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stash_it_app/app/feedback/app_feedback.dart';
import 'package:stash_it_app/app/theme/app_theme.dart';
import 'package:stash_it_app/features/profile/application/display_name_update_controller.dart';
import 'package:stash_it_app/features/profile/domain/display_name.dart';
import 'package:stash_it_app/shared/widgets/app_button.dart';
import 'package:stash_it_app/shared/widgets/app_field.dart';

/// Opens the display-name editor for the profile currently on screen.
///
/// [initialName] is the **raw** stored value, not the trimmed display form: the
/// endpoint does not trim, so pre-filling a trimmed value would silently propose a
/// different name from the one that is actually saved.
Future<void> showDisplayNameSheet(
  BuildContext context, {
  required String initialName,
}) {
  final tokens = AppTheme.tokensOf(context);

  return showModalBottomSheet<void>(
    context: context,
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
    builder: (_) => DisplayNameSheet(initialName: initialName),
  );
}

/// The Edit display name sheet.
///
/// One field, pre-filled with the stored value and editable before submission.
/// The 2–100-rune check mirrors the backend; the server still owns the rule, so a
/// `VALIDATION_ERROR` arrives as the same inline message rather than as a second
/// kind of error.
///
/// **The value is never trimmed**, here or at the repository boundary. The typed
/// name is submitted exactly as it stands, whitespace included.
///
/// A known not-changed refusal keeps the sheet open so the typed value survives.
/// An ambiguous outcome closes it and lets the controller refetch: the outcome is
/// unconfirmed, and the sheet must not invite a blind resubmission.
class DisplayNameSheet extends ConsumerStatefulWidget {
  const DisplayNameSheet({required this.initialName, super.key});

  final String initialName;

  @override
  ConsumerState<DisplayNameSheet> createState() => _DisplayNameSheetState();
}

class _DisplayNameSheetState extends ConsumerState<DisplayNameSheet> {
  late final TextEditingController _controller;
  String? _fieldError;
  ({String copy, FeedbackTone tone})? _notice;

  @override
  void initState() {
    super.initState();
    // Raw, untrimmed pre-fill.
    _controller = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (ref.read(displayNameUpdateProvider)) return;

    final problem = displayNameProblem(_controller.text);
    if (problem != null) {
      setState(() {
        _fieldError = _messageFor(problem);
        _notice = null;
      });
      return;
    }

    setState(() {
      _fieldError = null;
      _notice = null;
    });

    final outcome = await ref
        .read(displayNameUpdateProvider.notifier)
        .save(_controller.text);

    if (!mounted) return;

    switch (outcome) {
      case DisplayNameUpdateSucceeded() ||
          DisplayNameUpdateAccountUnavailable() ||
          DisplayNameUpdateUncertain() ||
          DisplayNameUpdateSessionRefused():
        Navigator.of(context).pop();

      case DisplayNameUpdateValidation():
        setState(() => _fieldError = 'Use between 2 and 100 characters.');

      case DisplayNameUpdateRejected(:final message, :final tone):
        setState(() => _notice = (copy: message, tone: tone));

      case DisplayNameUpdateIgnored():
        break;
    }
  }

  void _cancel() {
    if (ref.read(displayNameUpdateProvider)) return;
    Navigator.of(context).pop();
  }

  void _clearErrors() {
    if (_fieldError == null && _notice == null) return;
    setState(() {
      _fieldError = null;
      _notice = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AppTheme.tokensOf(context);
    final busy = ref.watch(displayNameUpdateProvider);
    final viewInsets = MediaQuery.viewInsetsOf(context);
    final availableHeight =
        MediaQuery.sizeOf(context).height - viewInsets.bottom;

    return PopScope(
      canPop: !busy,
      child: SafeArea(
        top: false,
        child: Padding(
          // The sheet rises with the keyboard rather than covering the field.
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
                  Text(
                    'Edit display name',
                    style: AppTypography.screenHeading.copyWith(
                      color: tokens.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppMetrics.space5),
                  AppField(
                    label: 'Display name',
                    controller: _controller,
                    enabled: !busy,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _save(),
                    onChanged: (_) => _clearErrors(),
                    errorText: _fieldError,
                  ),
                  if (_notice case final notice?) ...[
                    const SizedBox(height: AppMetrics.space3),
                    _SheetNotice(notice: notice, tokens: tokens),
                  ],
                  const SizedBox(height: AppMetrics.space5),
                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          label: 'Cancel',
                          variant: AppButtonVariant.secondary,
                          onPressed: busy ? null : _cancel,
                        ),
                      ),
                      const SizedBox(width: AppMetrics.space3),
                      Expanded(
                        child: AppButton(
                          label: 'Save',
                          variant: AppButtonVariant.primary,
                          busy: busy,
                          onPressed: busy ? null : _save,
                        ),
                      ),
                    ],
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

/// A known not-changed refusal that is not about the field's shape.
///
/// The treatment follows the tone: a budget or session-layer problem is a
/// warning, a confirmed failure is danger. The copy is always the caller's.
class _SheetNotice extends StatelessWidget {
  const _SheetNotice({required this.notice, required this.tokens});

  final ({String copy, FeedbackTone tone}) notice;
  final AppTokens tokens;

  @override
  Widget build(BuildContext context) {
    final (fill, border, mark) = switch (notice.tone) {
      FeedbackTone.warning => (
        tokens.warningSoft,
        tokens.warningBorder,
        tokens.warning,
      ),
      _ => (tokens.dangerSoft, tokens.dangerBorder, tokens.danger),
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppMetrics.space3),
      decoration: BoxDecoration(
        color: fill,
        border: Border.all(color: border),
        borderRadius: const BorderRadius.all(AppMetrics.controlRadius),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Container(width: 5, height: 5, color: mark),
          ),
          const SizedBox(width: AppMetrics.space2),
          Expanded(
            child: Text(
              notice.copy,
              style: AppTypography.meta.copyWith(color: tokens.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

String _messageFor(DisplayNameProblem problem) => switch (problem) {
  DisplayNameProblem.tooShort ||
  DisplayNameProblem.tooLong => 'Use between 2 and 100 characters.',
};
