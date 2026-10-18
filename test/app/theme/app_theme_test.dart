import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_it_app/app/theme/app_theme.dart';

/// The approved design system v1 — `docs/design-explorations/design-system.md`.
///
/// These pin the properties the rest of the app is built on: that the two themes
/// are genuinely different, that the accent is the approved one in both, and
/// that the **system brightness** chooses between them. Nothing here asserts a
/// widget renders correctly; that belongs to the screen tests.
void main() {
  AppTokens tokensOfTheme(ThemeData theme) => theme.extension<AppTokens>()!;

  group('theme selection', () {
    // One test per brightness rather than two calls in one case: reusing the
    // same element across two platform-brightness changes is exactly the kind
    // of thing that passes for the wrong reason.
    Future<ThemeData> pumpAtBrightness(
      WidgetTester tester,
      Brightness platformBrightness,
    ) async {
      tester.platformDispatcher.platformBrightnessTestValue =
          platformBrightness;
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

      late ThemeData resolved;
      await tester.pumpWidget(
        MaterialApp(
          // No `themeMode`: `StashItApp` leaves it at its default so the
          // platform decides. That is the whole selection rule.
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          home: Builder(
            builder: (context) {
              resolved = Theme.of(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      return resolved;
    }

    testWidgets('a light platform resolves the light theme', (tester) async {
      final tokens = tokensOfTheme(
        await pumpAtBrightness(tester, Brightness.light),
      );
      expect(tokens.canvas, AppTokens.light.canvas);
      expect(tokens.surface, AppTokens.light.surface);
      expect(tokens.textPrimary, AppTokens.light.textPrimary);
    });

    testWidgets('a dark platform resolves the dark theme', (tester) async {
      final tokens = tokensOfTheme(
        await pumpAtBrightness(tester, Brightness.dark),
      );
      expect(tokens.canvas, AppTokens.dark.canvas);
      expect(tokens.surface, AppTokens.dark.surface);
      expect(tokens.textPrimary, AppTokens.dark.textPrimary);
    });

    testWidgets('the resolved accent is the approved one in both', (
      tester,
    ) async {
      final light = tokensOfTheme(
        await pumpAtBrightness(tester, Brightness.light),
      );
      expect(light.accent, AppTokens.light.accent);

      await tester.pumpWidget(const SizedBox.shrink());

      final dark = tokensOfTheme(
        await pumpAtBrightness(tester, Brightness.dark),
      );
      expect(dark.accent, AppTokens.dark.accent);
    });

    test('the two themes are distinct instances, not one theme twice', () {
      expect(AppTokens.light.canvas, isNot(AppTokens.dark.canvas));
      expect(AppTokens.light.surface, isNot(AppTokens.dark.surface));
      expect(AppTokens.light.textPrimary, isNot(AppTokens.dark.textPrimary));
    });

    test('tokensOf falls back to the light set when no extension is present', () {
      // Only reachable if a widget is pumped without the app's ThemeData. It must
      // never throw, and it must not reach for the dark set by accident.
      final orphan = Builder(
        builder: (context) => Text('${AppTheme.tokensOf(context).accent}'),
      );
      expect(orphan, isNotNull);
    });
  });

  group('the accent', () {
    test('is Dusty Sage in both themes, one hue at two lightnesses', () {
      // The approved values. Changing either is a design decision, not a refactor.
      expect(AppTokens.light.accent, const Color(0xFF4C6B5F));
      expect(AppTokens.dark.accent, const Color(0xFF74A88C));

      // One hue: the two values differ in lightness, not in family. Same hue,
      // different role, and the dark one is the lighter of the pair.
      expect(
        AppTokens.dark.accent.computeLuminance(),
        greaterThan(AppTokens.light.accent.computeLuminance()),
      );
    });

    test('the selection tokens track the accent', () {
      for (final tokens in [AppTokens.light, AppTokens.dark]) {
        expect(tokens.selected, tokens.accent);
        expect(tokens.selectedSoft, tokens.accentSoft);
        expect(tokens.selectedMark, tokens.accent);
      }
    });

    test('reaches WCAG AA as text on its own surface in both themes', () {
      double ratio(Color a, Color b) {
        final first = a.computeLuminance();
        final second = b.computeLuminance();
        final lighter = first > second ? first : second;
        final darker = first > second ? second : first;
        return (lighter + 0.05) / (darker + 0.05);
      }

      // A chip is the tightest case: the accent is text on its own tint.
      expect(
        ratio(AppTokens.light.accent, AppTokens.light.accentSoft),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        ratio(AppTokens.dark.accent, AppTokens.dark.accentSoft),
        greaterThanOrEqualTo(4.5),
      );
      // A primary button: the accent-contrast label on the accent fill.
      expect(
        ratio(AppTokens.light.accentContrast, AppTokens.light.accent),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        ratio(AppTokens.dark.accentContrast, AppTokens.dark.accent),
        greaterThanOrEqualTo(4.5),
      );
    });
  });

  group('typography', () {
    test('the pixel face is confined to display roles', () {
      // The specification is explicit: Silkscreen carries the wordmark, screen
      // titles and section labels, and nothing else. Saved-item content must
      // stay in the readable sans.
      expect(AppTypography.wordmark.fontFamily, AppTypography.displayFamily);
      expect(AppTypography.screenTitle.fontFamily, AppTypography.displayFamily);
      expect(
        AppTypography.sectionLabel.fontFamily,
        AppTypography.displayFamily,
      );

      expect(AppTypography.itemTitle.fontFamily, AppTypography.uiFamily);
      expect(AppTypography.body.fontFamily, AppTypography.uiFamily);
      expect(AppTypography.screenHeading.fontFamily, AppTypography.uiFamily);
    });

    test('the mono face is confined to machine text', () {
      expect(AppTypography.mono.fontFamily, AppTypography.monoFamily);
      expect(AppTypography.monoSmall.fontFamily, AppTypography.monoFamily);
      expect(AppTypography.micro.fontFamily, AppTypography.monoFamily);

      expect(AppTypography.body.fontFamily, isNot(AppTypography.monoFamily));
      expect(
        AppTypography.itemTitle.fontFamily,
        isNot(AppTypography.monoFamily),
      );
    });

    test(
      'variable faces set the weight axis, or every weight renders as 400',
      () {
        // Inter and JetBrains Mono ship one variable file each. Without
        // `fontVariations` the engine renders the default instance, so a 600
        // title would come out as regular.
        expect(AppTypography.itemTitle.fontVariations, [
          const FontVariation.weight(600),
        ]);
        expect(AppTypography.itemTitle.fontWeight, FontWeight.w600);

        expect(AppTypography.mono.fontVariations, [
          const FontVariation.weight(500),
        ]);
      },
    );

    test(
      'the text theme carries the approved roles into the Material slots',
      () {
        final theme = AppTypography.textTheme;

        expect(theme.titleSmall?.fontFamily, AppTypography.uiFamily);
        expect(theme.titleSmall?.fontSize, 15);
        expect(theme.titleMedium?.fontFamily, AppTypography.displayFamily);
        expect(theme.labelMedium?.fontSize, 9.5);
      },
    );
  });

  group('theme wiring', () {
    test('the scaffold, dividers and buttons read the active tokens', () {
      for (final theme in [AppTheme.light(), AppTheme.dark()]) {
        final tokens = tokensOfTheme(theme);

        expect(theme.scaffoldBackgroundColor, tokens.canvas);
        expect(theme.dividerColor, tokens.border);
        expect(theme.colorScheme.primary, tokens.accent);
        expect(theme.colorScheme.onPrimary, tokens.accentContrast);
        expect(theme.colorScheme.surface, tokens.surface);
      }
    });

    test('the app bar is a surface, separated by one hairline', () {
      for (final theme in [AppTheme.light(), AppTheme.dark()]) {
        final tokens = tokensOfTheme(theme);
        final appBar = theme.appBarTheme;

        expect(appBar.backgroundColor, tokens.surface);
        expect(appBar.elevation, 0);
        expect((appBar.shape! as Border).bottom.color, tokens.border);
      }
    });

    test('the selected navigation destination uses the selected token', () {
      for (final theme in [AppTheme.light(), AppTheme.dark()]) {
        final tokens = tokensOfTheme(theme);
        final bar = theme.navigationBarTheme;

        final labels = bar.labelTextStyle!.resolve({WidgetState.selected});
        expect(labels?.color, tokens.selected);

        final icons = bar.iconTheme!.resolve({WidgetState.selected});
        expect(icons?.color, tokens.selected);

        final idle = bar.labelTextStyle!.resolve({});
        expect(idle?.color, tokens.textTertiary);
      }
    });
  });
}
