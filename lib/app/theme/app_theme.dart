import 'package:flutter/material.dart';
import 'package:stash_it_app/app/theme/app_metrics.dart';
import 'package:stash_it_app/app/theme/app_tokens.dart';
import 'package:stash_it_app/app/theme/app_typography.dart';

export 'app_metrics.dart';
export 'app_tokens.dart';
export 'app_typography.dart';
export 'skeleton_theme.dart';

/// The approved design system's Material themes — B · Inventory (light) and
/// B-Dark (dark).
///
/// Both themes are built from one [AppTokens] instance and one [AppTypography],
/// so a value can only ever be changed in one place. The Material 3 [ColorScheme]
/// is derived from the tokens rather than being a second, parallel palette.
///
/// **Theme selection.** `StashItApp` passes [light] and [dark] to `MaterialApp`
/// and supplies the mode chosen in Settings. On a fresh installation that mode is
/// System, so the **system brightness** chooses exactly as it did before the
/// setting existed; Light and Dark override it explicitly.
abstract final class AppTheme {
  /// The approved light theme.
  static ThemeData light() => _theme(AppTokens.light, Brightness.light);

  /// The approved dark theme.
  static ThemeData dark() => _theme(AppTokens.dark, Brightness.dark);

  /// The tokens for the brightness currently in force.
  ///
  /// Widgets must read colour through this. The extension is always present
  /// because both themes register [AppTokens], so the `?? AppTheme.light`
  /// fallback the previous prototype carried is not needed — and would have been
  /// a bug in dark mode, silently substituting light colours.
  static AppTokens tokensOf(BuildContext context) =>
      Theme.of(context).extension<AppTokens>() ?? AppTokens.light;

  static ThemeData _theme(AppTokens tokens, Brightness brightness) {
    return ThemeData(
      colorScheme: _scheme(tokens, brightness),
      scaffoldBackgroundColor: tokens.canvas,
      dividerColor: tokens.border,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      focusColor: Colors.transparent,
      extensions: [tokens],
      textTheme: AppTypography.textTheme.apply(
        bodyColor: tokens.textPrimary,
        displayColor: tokens.textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: tokens.surface,
        surfaceTintColor: Colors.transparent,
        foregroundColor: tokens.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleSpacing: AppMetrics.screenPadding,
        // The screen title is the restrained pixel face, uppercase — written at
        // the call site, because Flutter has no text-transform.
        titleTextStyle: AppTypography.screenTitle.copyWith(
          color: tokens.textPrimary,
        ),
        shape: Border(bottom: BorderSide(color: tokens.border)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: tokens.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: tokens.selectedSoft,
        elevation: 0,
        height: 68,
        indicatorShape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(AppMetrics.controlRadius),
        ),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return AppTypography.navigationLabel.copyWith(
            color: selected ? tokens.selected : tokens.textTertiary,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            size: AppMetrics.iconSize,
            color: selected ? tokens.selected : tokens.textTertiary,
          );
        }),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: tokens.surface,
        // The shared vertical inset, so a Material field not built on AppField
        // still reads as a filled control rather than a text bar.
        contentPadding: AppMetrics.fieldContentPadding,
        border: _fieldBorder(tokens.border),
        enabledBorder: _fieldBorder(tokens.border),
        disabledBorder: _fieldBorder(tokens.disabledBorder),
        focusedBorder: _fieldBorder(tokens.accent, emphasis: true),
        errorBorder: _fieldBorder(tokens.danger, emphasis: true),
        focusedErrorBorder: _fieldBorder(tokens.danger, emphasis: true),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.disabled)
                ? tokens.disabledBg
                : tokens.accent,
          ),
          foregroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.disabled)
                ? tokens.disabledText
                : tokens.accentContrast,
          ),
          side: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.disabled)
                ? BorderSide(color: tokens.disabledBorder)
                : BorderSide(color: tokens.accent),
          ),
          shape: const WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.all(AppMetrics.controlRadius),
            ),
          ),
          minimumSize: const WidgetStatePropertyAll(
            Size(0, AppMetrics.buttonHeight),
          ),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: AppMetrics.space3),
          ),
          textStyle: WidgetStatePropertyAll(
            AppTypography.button.copyWith(color: tokens.accentContrast),
          ),
          splashFactory: NoSplash.splashFactory,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStatePropertyAll(tokens.surface),
          foregroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.disabled)
                ? tokens.disabledText
                : tokens.textPrimary,
          ),
          side: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.disabled)
                ? BorderSide(color: tokens.disabledBorder)
                : BorderSide(color: tokens.borderStrong),
          ),
          shape: const WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.all(AppMetrics.controlRadius),
            ),
          ),
          minimumSize: const WidgetStatePropertyAll(
            Size(0, AppMetrics.buttonHeight),
          ),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: AppMetrics.space3),
          ),
          textStyle: WidgetStatePropertyAll(
            AppTypography.button.copyWith(color: tokens.textPrimary),
          ),
          splashFactory: NoSplash.splashFactory,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.disabled)
                ? tokens.disabledText
                : tokens.accent,
          ),
          shape: const WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.all(AppMetrics.controlRadius),
            ),
          ),
          textStyle: WidgetStatePropertyAll(
            AppTypography.button.copyWith(color: tokens.accent),
          ),
          splashFactory: NoSplash.splashFactory,
        ),
      ),
    );
  }

  static OutlineInputBorder _fieldBorder(Color color, {bool emphasis = false}) {
    return OutlineInputBorder(
      borderRadius: const BorderRadius.all(AppMetrics.controlRadius),
      borderSide: BorderSide(
        color: color,
        width: emphasis
            ? AppMetrics.borderWidthEmphasis
            : AppMetrics.borderWidth,
      ),
    );
  }

  /// The M3 scheme, derived so that a Material widget which reaches for
  /// `colorScheme` lands on the approved palette instead of its own defaults.
  static ColorScheme _scheme(AppTokens tokens, Brightness brightness) {
    return ColorScheme(
      brightness: brightness,
      primary: tokens.accent,
      onPrimary: tokens.accentContrast,
      primaryContainer: tokens.accentSoft,
      onPrimaryContainer: tokens.accent,
      secondary: tokens.accent,
      onSecondary: tokens.accentContrast,
      secondaryContainer: tokens.accentSoft,
      onSecondaryContainer: tokens.accent,
      tertiary: tokens.accent,
      onTertiary: tokens.accentContrast,
      tertiaryContainer: tokens.accentSoft,
      onTertiaryContainer: tokens.accent,
      error: tokens.danger,
      onError: tokens.textInverse,
      errorContainer: tokens.dangerSoft,
      onErrorContainer: tokens.danger,
      surface: tokens.surface,
      onSurface: tokens.textPrimary,
      onSurfaceVariant: tokens.textSecondary,
      surfaceContainerLowest: tokens.canvas,
      surfaceContainerLow: tokens.surface,
      surfaceContainer: tokens.surface,
      surfaceContainerHigh: tokens.surfaceRaised,
      surfaceContainerHighest: tokens.surfaceRaised,
      surfaceDim: tokens.canvas,
      surfaceBright: tokens.surfaceRaised,
      surfaceTint: Colors.transparent,
      outline: tokens.borderStrong,
      outlineVariant: tokens.border,
      shadow: Colors.transparent,
      scrim: Colors.transparent,
      inverseSurface: tokens.textPrimary,
      onInverseSurface: tokens.canvas,
      inversePrimary: tokens.accent,
    );
  }
}
