import 'package:flutter/material.dart';
import 'package:stash_it_app/app/theme/app_tokens.dart';

/// Theme configuration for the **Paper & Ink** prototype direction.
///
/// Material 3 only (Flutter 3.47.7 has no `useMaterial3` flag). Clean paper-white
/// surfaces, crisp dark type, and one deep pine accent used sparingly. Not a design
/// system; see [AppTokens].
abstract final class AppTheme {
  /// The prototype values.
  static const Color background = Color(0xFFFAFBF9); // paper
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF0F2EF);
  static const Color textPrimary = Color(0xFF202522);

  /// Secondary copy: neutral charcoal-grey, ~6.2:1 on [background] and ~6.5:1 on
  /// [surface], so it is safe at small sizes.
  static const Color textMuted = Color(0xFF5B625C);

  static const Color accent = Color(0xFF315B49); // deep pine
  static const Color accentSoft = Color(0xFFE6EDE9);
  static const Color border = Color(0xFFE2E5E2);

  /// Semantic failure colour, unchanged from the previous iteration.
  static const Color danger = Color(0xFFA15C43);

  static const AppTokens tokens = AppTokens(
    background: background,
    surface: surface,
    surfaceMuted: surfaceMuted,
    textPrimary: textPrimary,
    textMuted: textMuted,
    accent: accent,
    accentSoft: accentSoft,
    border: border,
    danger: danger,
  );

  static ThemeData light() => _theme();

  /// Dark values are not part of this direction yet, so this currently returns the
  /// light theme rather than inventing a dark palette. Replace when dark is decided.
  static ThemeData dark() => _theme();

  static ThemeData _theme() {
    const scheme = ColorScheme.light(
      primary: accent,
      onPrimary: surface,
      primaryContainer: accentSoft,
      onPrimaryContainer: accent,
      secondary: accent,
      onSecondary: textPrimary,
      surface: background,
      onSurface: textPrimary,
      outlineVariant: border,
      error: danger,
    );

    return ThemeData(
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      dividerColor: border,
      extensions: const [tokens],
      appBarTheme: AppBarTheme(
        // White against the paper canvas: a brighter band, drawn off by a hairline.
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        foregroundColor: textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: const TextStyle(
          color: textPrimary,
          fontSize: 19,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
        ),
        shape: const Border(bottom: BorderSide(color: border)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: accentSoft,
        elevation: 0,
        height: 68,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          return TextStyle(
            fontSize: 11.5,
            letterSpacing: 0.1,
            color: states.contains(WidgetState.selected) ? accent : textMuted,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          return IconThemeData(
            size: 22,
            color: states.contains(WidgetState.selected) ? accent : textMuted,
          );
        }),
      ),
      textTheme: const TextTheme(
        // Crisp dark titles with tightened tracking; open line height on secondary
        // copy for reading comfort.
        titleSmall: TextStyle(
          fontSize: 15,
          height: 1.32,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.15,
          color: textPrimary,
        ),
        bodySmall: TextStyle(fontSize: 12.5, height: 1.4, color: textMuted),
        labelSmall: TextStyle(
          fontSize: 11,
          height: 1.2,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.4,
          color: textPrimary,
        ),
      ),
    );
  }
}
