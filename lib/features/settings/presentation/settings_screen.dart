import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:stash_it_app/app/config/developer_contact_config.dart';
import 'package:stash_it_app/app/feedback/app_feedback.dart';
import 'package:stash_it_app/app/feedback/feedback_controller.dart';
import 'package:stash_it_app/app/router/routes.dart';
import 'package:stash_it_app/app/theme/app_theme.dart';
import 'package:stash_it_app/l10n/app_localizations.dart';
import 'package:stash_it_app/shared/widgets/app_button.dart';
import 'package:stash_it_app/shared/widgets/desktop_layout.dart';
import 'package:url_launcher/url_launcher.dart';

import '../application/language_preference_controller.dart';
import '../application/package_info_provider.dart';
import '../application/theme_mode_controller.dart';
import '../domain/language_preference.dart';

/// The app-wide Settings screen.
///
/// Settings is a secondary route, not a fifth destination: it sits above the
/// shell and is reached with `push`, so returning restores the selected tab and
/// its retained state. Its own app bar deliberately has no Settings action.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTheme.tokensOf(context);
    final themeMode = ref.watch(themeModeControllerProvider);
    final language = ref.watch(languagePreferenceControllerProvider);

    // Direct entry (for example a future deep link) has no shell page beneath it
    // to pop to. The fallback is shown only in that case; a Settings route pushed
    // from a destination keeps the ordinary back affordance.
    final canPop = Navigator.of(context).canPop();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsTitle),
        leading: canPop
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back, size: AppMetrics.iconSize),
                tooltip: l10n.settingsBackToInbox,
                onPressed: () => context.go(AppRoutes.inbox),
              ),
      ),
      body: DesktopContentFrame(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            _SectionLabelRow(label: l10n.settingsAppearance, tokens: tokens),
            Material(
              color: tokens.surface,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: tokens.border)),
                ),
                child: RadioGroup<ThemeMode>(
                  groupValue: themeMode,
                  onChanged: (mode) {
                    if (mode == null) return;
                    unawaited(
                      ref
                          .read(themeModeControllerProvider.notifier)
                          .select(mode),
                    );
                  },
                  child: Column(
                    children: [
                      for (
                        var index = 0;
                        index < _themeChoices.length;
                        index++
                      ) ...[
                        if (index > 0) _RowDivider(tokens: tokens),
                        _SettingsRadioOption<ThemeMode>(
                          value: _themeChoices[index],
                          label: switch (_themeChoices[index]) {
                            ThemeMode.light => l10n.themeLight,
                            ThemeMode.dark => l10n.themeDark,
                            ThemeMode.system => l10n.themeSystem,
                          },
                          selected: themeMode == _themeChoices[index],
                          tokens: tokens,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            _SectionLabelRow(label: l10n.settingsLanguage, tokens: tokens),
            Material(
              color: tokens.surface,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: tokens.borderSubtle),
                  ),
                ),
                child: RadioGroup<LanguagePreference>(
                  groupValue: language,
                  onChanged: (preference) {
                    if (preference == null) return;
                    unawaited(
                      ref
                          .read(languagePreferenceControllerProvider.notifier)
                          .select(preference),
                    );
                  },
                  child: Column(
                    children: [
                      for (
                        var index = 0;
                        index < _languageChoices.length;
                        index++
                      ) ...[
                        if (index > 0) _RowDivider(tokens: tokens),
                        _SettingsRadioOption<LanguagePreference>(
                          value: _languageChoices[index],
                          label: switch (_languageChoices[index]) {
                            LanguagePreference.system =>
                              l10n.languageSystemDefault,
                            LanguagePreference.english => l10n.languageEnglish,
                            LanguagePreference.indonesian =>
                              l10n.languageIndonesian,
                          },
                          selected: language == _languageChoices[index],
                          tokens: tokens,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            _SectionLabelRow(label: l10n.settingsAbout, tokens: tokens),
            Material(
              color: tokens.surface,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: tokens.borderSubtle),
                  ),
                ),
                child: Column(
                  children: [
                    FutureBuilder<PackageInfo>(
                      future: ref.watch(packageInfoProvider),
                      builder: (context, snapshot) {
                        final version = snapshot.hasData
                            ? snapshot.data!.version
                            : (snapshot.hasError ? '—' : '…');
                        return _SettingsValueRow(
                          label: l10n.settingsVersion,
                          value: version,
                          tokens: tokens,
                        );
                      },
                    ),
                    if (DeveloperContactConfig.hasAnyContact) ...[
                      _RowDivider(tokens: tokens),
                      _SettingsLinkRow(
                        label: l10n.settingsContact,
                        tokens: tokens,
                        trailingIcon: Icons.chevron_right,
                        onTap: () => _showContactDialog(context, ref, tokens),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Opens a developer contact link in the platform's browser or app.
///
/// A refused launch is reported through the app-wide feedback host rather than
/// leaving the tap without a response.
Future<void> _openDeveloperLink(WidgetRef ref, String value) async {
  final url = Uri.tryParse(value);
  if (url == null || !url.hasAuthority) return;

  bool accepted;
  try {
    accepted = await launchUrl(url, mode: LaunchMode.externalApplication);
  } on Exception {
    accepted = false;
  }

  if (!accepted) {
    ref
        .read(feedbackProvider.notifier)
        .show(
          AppFeedback.localized(
            tone: FeedbackTone.danger,
            message: (l10n) => l10n.linkLaunchFailed,
          ),
        );
  }
}

/// Shows the developer's name and contact links in a compact dialog.
Future<void> _showContactDialog(
  BuildContext context,
  WidgetRef ref,
  AppTokens tokens,
) {
  final l10n = AppLocalizations.of(context);

  return showDialog<void>(
    context: context,
    builder: (dialogContext) => Dialog(
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.settingsContact,
                style: AppTypography.screenHeading.copyWith(
                  color: tokens.textPrimary,
                ),
              ),
              const SizedBox(height: AppMetrics.space3),
              if (DeveloperContactConfig.githubUrl.isNotEmpty)
                _SettingsLinkRow(
                  label: l10n.settingsGithub,
                  tokens: tokens,
                  contentPadding: EdgeInsets.zero,
                  onTap: () =>
                      _openDeveloperLink(ref, DeveloperContactConfig.githubUrl),
                ),
              if (DeveloperContactConfig.githubUrl.isNotEmpty &&
                  DeveloperContactConfig.instagramUrl.isNotEmpty)
                _RowDivider(tokens: tokens),
              if (DeveloperContactConfig.instagramUrl.isNotEmpty)
                _SettingsLinkRow(
                  label: l10n.settingsInstagram,
                  tokens: tokens,
                  contentPadding: EdgeInsets.zero,
                  onTap: () => _openDeveloperLink(
                    ref,
                    DeveloperContactConfig.instagramUrl,
                  ),
                ),
              const SizedBox(height: AppMetrics.space4),
              AppButton(
                label: l10n.settingsCloseAction,
                variant: AppButtonVariant.secondary,
                onPressed: () => Navigator.of(dialogContext).pop(),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

const List<ThemeMode> _themeChoices = [
  ThemeMode.light,
  ThemeMode.dark,
  ThemeMode.system,
];

const List<LanguagePreference> _languageChoices = [
  LanguagePreference.system,
  LanguagePreference.english,
  LanguagePreference.indonesian,
];

/// A read-only label and value row, used for the app version.
class _SettingsValueRow extends StatelessWidget {
  const _SettingsValueRow({
    required this.label,
    required this.value,
    required this.tokens,
  });

  final String label;
  final String value;
  final AppTokens tokens;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: AppMetrics.space4),
      title: Text(
        label,
        style: AppTypography.itemTitle.copyWith(color: tokens.textPrimary),
      ),
      trailing: Text(
        value,
        style: AppTypography.body.copyWith(color: tokens.textSecondary),
      ),
    );
  }
}

/// A developer contact row that opens an external link.
class _SettingsLinkRow extends StatelessWidget {
  const _SettingsLinkRow({
    required this.label,
    required this.tokens,
    required this.onTap,
    this.trailingIcon = Icons.open_in_new,
    this.contentPadding = const EdgeInsets.symmetric(
      horizontal: AppMetrics.space4,
    ),
  });

  final String label;
  final AppTokens tokens;
  final VoidCallback onTap;
  final IconData trailingIcon;
  final EdgeInsetsGeometry contentPadding;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      contentPadding: contentPadding,
      title: Text(
        label,
        style: AppTypography.itemTitle.copyWith(color: tokens.textPrimary),
      ),
      trailing: Icon(
        trailingIcon,
        size: AppMetrics.iconSize,
        color: tokens.textTertiary,
      ),
      onTap: onTap,
    );
  }
}

class _SettingsRadioOption<T> extends StatelessWidget {
  const _SettingsRadioOption({
    required this.value,
    required this.label,
    required this.selected,
    required this.tokens,
  });

  final T value;
  final String label;
  final bool selected;
  final AppTokens tokens;

  @override
  Widget build(BuildContext context) {
    return RadioListTile<T>(
      value: value,
      selected: selected,
      activeColor: tokens.accent,
      selectedTileColor: tokens.accentSoft,
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: AppMetrics.space4),
      title: Text(
        label,
        style: AppTypography.itemTitle.copyWith(
          color: selected ? tokens.accent : tokens.textPrimary,
        ),
      ),
    );
  }
}

class _RowDivider extends StatelessWidget {
  const _RowDivider({required this.tokens});

  final AppTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: AppMetrics.borderWidth,
      thickness: AppMetrics.borderWidth,
      color: tokens.borderSubtle,
      indent: AppMetrics.space4,
      endIndent: AppMetrics.space4,
    );
  }
}

/// A section heading with the design system's rule running to the right edge.
class _SectionLabelRow extends StatelessWidget {
  const _SectionLabelRow({required this.label, required this.tokens});

  final String label;
  final AppTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppMetrics.space4,
        AppMetrics.space3,
        AppMetrics.space4,
        AppMetrics.space1,
      ),
      child: Row(
        children: [
          Text(
            label,
            style: AppTypography.sectionLabel.copyWith(
              color: tokens.textTertiary,
            ),
          ),
          const SizedBox(width: AppMetrics.space2),
          Expanded(
            child: Container(
              height: AppMetrics.borderWidth,
              color: tokens.border,
            ),
          ),
        ],
      ),
    );
  }
}
