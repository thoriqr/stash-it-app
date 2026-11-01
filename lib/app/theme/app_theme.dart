import 'package:flutter/material.dart';
import 'package:stash_it_app/app/theme/app_metrics.dart';
import 'package:stash_it_app/app/theme/app_tokens.dart';
import 'package:stash_it_app/app/theme/app_typography.dart';

export 'app_metrics.dart';
export 'app_tokens.dart';
export 'app_typography.dart';
export 'skeleton_theme.dart';

/// Material themes built from shared color tokens and typography.
///
/// Both brightness variants use the same [AppTypography]. Their colors come
/// from [AppTokens], which also provides the values used to derive the
/// Material 3 [ColorScheme].
///
/// Theme selection is handled by `MaterialApp` using the mode chosen in
/// Settings. System mode follows the device brightness; Light and Dark
/// explicitly select their respective themes.
abstract final class AppTheme {
  /// Light theme.
  static ThemeData light() => _theme(AppTokens.light, Brightness.light);

  /// Dark theme.
  static ThemeData dark() => _theme(AppTokens.dark, Brightness.dark);

  /// Returns the color tokens registered by the active theme.
  ///
  /// Both themes register [AppTokens], so widgets can use this extension
  /// without needing a separate brightness check or fallback palette.
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
        // Screen titles are styled at the call site because Flutter does not
        // provide a text-transform property for uppercase styling.
        titleTextStyle: AppTypography.screenTitle.copyWith(
          color: tokens.textPrimary,
        ),
        shape: Border(bottom: BorderSide(color: tokens.border)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        dragHandleColor: tokens.borderStrong,
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
        // Apply vertical padding to all Material fields, including those that
        // do not use the shared AppField component.
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

  /// Builds the Material 3 color scheme from the active theme's tokens.
  ///
  /// This keeps Material widgets that read [ColorScheme] aligned with the
  /// application's palette instead of relying on Material's default colors.
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
