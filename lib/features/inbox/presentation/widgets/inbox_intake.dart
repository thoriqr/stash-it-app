import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stash_it_app/app/theme/app_theme.dart';
import 'package:stash_it_app/features/saved_items/application/save_url_controller.dart';
import 'package:stash_it_app/shared/widgets/app_button.dart';
import 'package:stash_it_app/shared/widgets/app_field.dart';

/// The Inbox's URL intake — `design-system.md` §6.1 and D25.
///
/// **Save URL is wired; Paste is still not.** The button submits what is in the
/// field, exactly once per tap, through `SaveUrl`; the field is cleared only when
/// the server confirms the create, so a refusal leaves the value there to correct
/// and send again. **Paste remains a visible, deliberately unwired control**: there
/// is no clipboard package in `pubspec.yaml` (AGENTS.md §4 lists it as a known
/// gap), and a home-grown substitute would be worse than an obvious gap. Rendering
/// it disabled would be an invented "not yet" state the design system does not
/// have, so it keeps its specified appearance and does nothing.
///
/// The two buttons stay visually distinct on purpose: **Paste** is secondary and
/// **Save URL** is the screen's only filled button, so pasting can never be read
/// as saving (**D25** — pasting alone does not save, and this widget never submits
/// without a tap on Save URL).
///
/// **Two gates, in two places.** This widget refuses to submit an empty or
/// whitespace-only field. The *shape* of the URL is judged once, by `SaveUrl`,
/// before it touches the transport (`isSubmittableUrl`, `saved_item_url.dart`): a
/// value that cannot be a URL is reported through the app-wide notice and left in
/// the field, and the server keeps the final say on everything a local check cannot
/// see — whether the host resolves, domain rules, and its own length cap (§2.9,
/// Q13).
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
  /// The clear is guarded by `mounted` because `submit` returns after an await
  /// that a route change can outlive: the feedback notice is published whether or
  /// not this screen is still on screen (the notifier is app-level), but a
  /// disposed `TextEditingController` must not be touched.
  Future<void> _save() async {
    final saved = await ref
        .read(saveUrlProvider.notifier)
        .submit(_controller.text);

    if (!mounted) return;
    if (!saved) return;

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
          ),
          const SizedBox(height: AppMetrics.space2),
          Row(
            children: [
              // Paste keeps its natural width; Save URL takes the rest.
              //
              // The empty callback is the documented gap, not an oversight: the
              // platform clipboard needs a dependency this client does not have
              // (§4), and pasting on its own must never submit anything.
              AppButton(
                label: 'Paste',
                variant: AppButtonVariant.secondary,
                block: false,
                onPressed: () {},
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
