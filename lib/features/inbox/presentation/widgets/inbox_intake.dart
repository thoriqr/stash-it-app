import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stash_it_app/app/theme/app_theme.dart';
import 'package:stash_it_app/features/saved_items/application/save_url_controller.dart';
import 'package:stash_it_app/shared/widgets/app_button.dart';
import 'package:stash_it_app/shared/widgets/app_field.dart';

/// The Inbox's URL intake — `design-system.md` §6.1 and D25.
///
/// **Both actions are wired, and they stay separate.** **Paste** reads plain text
/// from the platform clipboard and replaces the field's contents; it never
/// submits, validates, or announces anything. **Save URL** submits what is in the
/// field, exactly once per tap, through `SaveUrl`; the field is cleared only when
/// the server confirms the create, so a refusal leaves the value there to correct
/// and send again.
///
/// The clipboard is Flutter's own [Clipboard] service
/// (`package:flutter/services.dart`), not a package: the engine implements it on
/// Android and iOS. **Empty, non-text, and failed reads leave the field untouched
/// and say nothing.** D25 leaves clipboard behaviour beyond "places it into the
/// input" open (Q13), and the discovery documents forbid inventing a
/// clipboard-failure or invalid-URL state, so there is no copy for those cases.
/// Invalid or unrelated text is placed as-is; `SaveUrl` owns the local shape
/// check, so paste does not pre-empt Q13 by validating.
///
/// The two buttons stay visually distinct on purpose: **Paste** is secondary and
/// **Save URL** is the screen's only filled button, so pasting can never be read
/// as saving (**D25** — pasting alone does not save, and this widget never submits
/// without a tap on Save URL).
///
/// **Clear is not an action.** The inline `X` in the field only empties it; it
/// never submits or announces anything, and it is unavailable while a save is in
/// flight.
///
/// **Two gates, in two places.** This widget refuses to submit an empty or
/// whitespace-only field. The *shape* of the URL is judged once, by `SaveUrl`,
/// before it touches the transport (`isSubmittableUrl`, `saved_item_url.dart`): a
/// value that cannot be a URL is reported through the app-wide notice and left in
/// the field, and the server keeps the final say on everything a local check cannot
/// see — whether the host resolves, domain rules, and its own length cap (§2.9,
/// Q13).
///
/// **While a save is in flight both actions are disabled**, matching the design
/// exploration's Saving state. A confirmed save clears the field only if it still
/// holds the value that was submitted; a value entered or pasted in the meantime
/// is kept.
class InboxIntake extends ConsumerStatefulWidget {
  const InboxIntake({super.key});

  @override
  ConsumerState<InboxIntake> createState() => _InboxIntakeState();
}

class _InboxIntakeState extends ConsumerState<InboxIntake> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Sends the field's value, and clears it only on a confirmed create.
  ///
  /// The value is captured before the await so a successful response cannot wipe
  /// a different value the user entered or pasted while the request was in
  /// flight. The clear is guarded by `mounted` because `submit` returns after an
  /// await that a route change can outlive: the feedback notice is published
  /// whether or not this screen is still on screen (the notifier is app-level),
  /// but a disposed `TextEditingController` must not be touched.
  Future<void> _save() async {
    final submitted = _controller.text;
    final saved = await ref.read(saveUrlProvider.notifier).submit(submitted);

    if (!mounted) return;
    if (!saved) return;

    // The confirmation belongs to `submitted`, not to whatever the field holds
    // now. Leaving the newer value alone keeps a second, unsent URL from being
    // silently discarded.
    if (_controller.text != submitted) return;

    _controller.clear();
    setState(() {});
  }

  /// Fills the field from the platform clipboard, and does nothing else.
  ///
  /// The read uses Flutter's built-in [Clipboard] service, so no package or
  /// platform code is involved and Android and iOS take the same path. The value
  /// is placed exactly as the clipboard supplied it; only content that is empty
  /// after trimming is refused, because there is nothing to place.
  ///
  /// **No validation, no submission, no feedback.** D25 says pasting fills the
  /// input and does not save it; Q13 leaves paste-time validation and
  /// clipboard-failure states open, and the discovery documents forbid inventing
  /// either. Invalid or unrelated text therefore goes into the field unchanged,
  /// where the user can inspect or edit it and `SaveUrl` can judge it on submit.
  Future<void> _paste() async {
    final ClipboardData? data;
    try {
      data = await Clipboard.getData(Clipboard.kTextPlain);
    } catch (_) {
      // A refused or failed clipboard read leaves the field exactly as it was.
      // `PlatformException` is the platform's usual failure; a missing plugin
      // arrives as null through `OptionalMethodChannel`. Announcing this would
      // invent the clipboard-failure state Q13 leaves undecided.
      return;
    }

    // A route change can outlive the platform round-trip.
    if (!mounted) return;

    final text = data?.text;
    if (text == null || text.trim().isEmpty) return;

    _controller.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
    setState(() {});
  }

  /// Empties the field without submitting anything.
  ///
  /// Clear is not Save: it never calls the save controller or publishes
  /// feedback. The inline `X` is only rendered when there is text and no save is
  /// in flight, so this cannot race a submitted value; `build` derives the hint
  /// and Save URL's enabled state from the controller.
  void _clear() {
    _controller.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
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
              // Section label — the restrained pixel face, uppercase at the
              // call site because Flutter has no text-transform.
              Text(
                'SAVE A URL',
                style: AppTypography.sectionLabel.copyWith(
                  color: tokens.textSecondary,
                ),
              ),
              const SizedBox(width: AppMetrics.space2),
              Expanded(
                child: Text(
                  switch ((isSaving, hasValue)) {
                    (true, _) => 'Saving…',
                    (false, true) => 'Check or edit the link before saving.',
                    (false, false) =>
                      'Paste fills the field. Save URL sends it.',
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
            // Whitespace is not a value, and clearing is unavailable while the
            // submitted value is unresolved.
            onClear: hasValue && !isSaving ? _clear : null,
          ),
          const SizedBox(height: AppMetrics.space2),
          Row(
            children: [
              // Paste keeps its natural width; Save URL takes the rest. Paste
              // only fills the field — it never submits — so the two actions
              // stay visibly distinct (D25). Both actions are disabled while a
              // save is in flight, as the design exploration's Saving state
              // specifies.
              AppButton(
                label: 'Paste',
                variant: AppButtonVariant.secondary,
                block: false,
                onPressed: isSaving ? null : _paste,
              ),
              const SizedBox(width: AppMetrics.space2),
              Expanded(
                child: AppButton(
                  label: 'Save URL',
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
