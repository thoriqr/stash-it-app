import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:stash_it_app/app/router/routes.dart';
import 'package:stash_it_app/app/theme/app_theme.dart';
import 'package:stash_it_app/l10n/app_localizations.dart';

import '../application/language_preference_controller.dart';
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
      body: ListView(
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
                    ref.read(themeModeControllerProvider.notifier).select(mode),
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
                border: Border(bottom: BorderSide(color: tokens.borderSubtle)),
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
        ],
      ),
    );
  }
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
