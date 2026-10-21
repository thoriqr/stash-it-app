import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:stash_it_app/app/router/routes.dart';
import 'package:stash_it_app/app/theme/app_theme.dart';

import '../application/theme_mode_controller.dart';

/// The app-wide Settings screen.
///
/// Settings is a secondary route, not a fifth destination: it sits above the
/// shell and is reached with `push`, so returning restores the selected tab and
/// its retained state. Its own app bar deliberately has no Settings action.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = AppTheme.tokensOf(context);
    final themeMode = ref.watch(themeModeControllerProvider);

    // Direct entry (for example a future deep link) has no shell page beneath it
    // to pop to. The fallback is shown only in that case; a Settings route pushed
    // from a destination keeps the ordinary back affordance.
    final canPop = Navigator.of(context).canPop();

    return Scaffold(
      appBar: AppBar(
        title: const Text('SETTINGS'),
        leading: canPop
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back, size: AppMetrics.iconSize),
                tooltip: 'Back to Inbox',
                onPressed: () => context.go(AppRoutes.inbox),
              ),
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          _SectionLabelRow(label: 'APPEARANCE', tokens: tokens),
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
                      _ThemeOption(
                        mode: _themeChoices[index].mode,
                        label: _themeChoices[index].label,
                        selected: themeMode == _themeChoices[index].mode,
                        tokens: tokens,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          _SectionLabelRow(label: 'LANGUAGE', tokens: tokens),
          Material(
            color: tokens.surface,
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: tokens.borderSubtle)),
              ),
              child: Semantics(
                enabled: false,
                child: ListTile(
                  enabled: false,
                  dense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppMetrics.space4,
                  ),
                  title: Text(
                    'Language',
                    style: AppTypography.itemTitle.copyWith(
                      color: tokens.textDisabled,
                    ),
                  ),
                  trailing: Text(
                    'Coming soon',
                    style: AppTypography.meta.copyWith(
                      color: tokens.textDisabled,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

const List<({ThemeMode mode, String label})> _themeChoices = [
  (mode: ThemeMode.light, label: 'Light'),
  (mode: ThemeMode.dark, label: 'Dark'),
  (mode: ThemeMode.system, label: 'System'),
];

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.mode,
    required this.label,
    required this.selected,
    required this.tokens,
  });

  final ThemeMode mode;
  final String label;
  final bool selected;
  final AppTokens tokens;

  @override
  Widget build(BuildContext context) {
    return RadioListTile<ThemeMode>(
      value: mode,
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
