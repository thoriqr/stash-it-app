import 'package:flutter/material.dart';
import 'package:stash_it_app/app/theme/app_theme.dart';
import 'package:stash_it_app/shared/widgets/app_button.dart';
import 'package:stash_it_app/shared/widgets/app_field.dart';

/// The Inbox's URL intake — `design-system.md` §6.1 and D25.
///
/// **Visual only.** D25 requires a URL field on the Inbox with separate **Paste**
/// and **Save URL** actions, and requires that pasting alone does not save. Both
/// controls are rendered exactly as specified, but neither is wired: there is no
/// clipboard package in `pubspec.yaml`, no submission, and no `POST /saved-items`
/// client. Rendering a control that does nothing is a deliberate, visible gap —
/// it says the design exists before the behaviour does, and it cannot be mistaken
/// for working intake.
///
/// The buttons are kept visually distinct on purpose: **Paste** is secondary and
/// **Save URL** is the screen's only filled button, so pasting can never be read
/// as saving.
class InboxIntake extends StatefulWidget {
  const InboxIntake({super.key});

  @override
  State<InboxIntake> createState() => _InboxIntakeState();
}

class _InboxIntakeState extends State<InboxIntake> {
  final _controller = TextEditingController();

  /// A typed value, so the disabled state of Save URL is reachable in a
  /// prototype and the editable-before-submission rule (D25) is visible.
  final _demoValue =
      'https://example.com/a-long-article-about-distributed-systems?ref=share';

  @override
  void initState() {
    super.initState();
    _controller.text = _demoValue;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AppTheme.tokensOf(context);
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
                  hasValue
                      ? 'Check or edit the link before saving.'
                      : 'Paste fills the field. Save URL sends it.',
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
                  onPressed: hasValue ? () {} : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
