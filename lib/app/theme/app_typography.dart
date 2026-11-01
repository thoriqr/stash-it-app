import 'package:flutter/material.dart';

/// Typography roles used throughout the application.
///
/// Each role defines its own size, line height, weight, and font family.
/// Colors are applied separately by the active [ThemeData], keeping
/// typography consistent across light and dark themes.
///
/// The display face is reserved for the wordmark, screen titles, and section
/// labels. Saved-item content and general UI copy use the UI face. The
/// monospaced face is reserved for machine-oriented text such as domains,
/// URLs, timestamps, and mock-data markers.
///
/// Both [uiFamily] and [monoFamily] are variable fonts. Their styles specify
/// [FontVariation.weight] alongside [fontWeight] so Flutter selects the
/// intended variable-font weight. Font weights are also declared in
/// `pubspec.yaml` for accurate font matching.
abstract final class AppTypography {
  /// Font for the wordmark, screen titles, and section labels.
  static const String displayFamily = 'Silkscreen';

  /// Font for general UI copy and saved-item content.
  static const String uiFamily = 'Inter';

  /// Font for URLs, domains, timestamps, and other machine-oriented text.
  static const String monoFamily = 'JetBrains Mono';

  /// Creates a style using a variable font with an explicit weight axis.
  static TextStyle variable(
    String family,
    double size,
    double height,
    FontWeight weight, {
    double tracking = 0,
    Color? color,
  }) => TextStyle(
    fontFamily: family,
    fontSize: size,
    height: height,
    fontWeight: weight,
    fontVariations: [FontVariation.weight(weight.value.toDouble())],
    letterSpacing: tracking,
    color: color,
  );

  /// Creates a style using a static font without a variable weight axis.
  static TextStyle staticFace(
    String family,
    double size,
    double height,
    FontWeight weight, {
    double tracking = 0,
    Color? color,
  }) => TextStyle(
    fontFamily: family,
    fontSize: size,
    height: height,
    fontWeight: weight,
    letterSpacing: tracking,
    color: color,
  );

  // ---- display roles ----

  /// Wordmark style.
  ///
  /// Apply uppercase text at the call site because Flutter does not provide
  /// a text-transform property.
  static final TextStyle wordmark = staticFace(
    displayFamily,
    10,
    1,
    FontWeight.w700,
    tracking: 2.0,
  );

  /// App bar screen title style.
  static final TextStyle screenTitle = staticFace(
    displayFamily,
    15,
    1,
    FontWeight.w700,
    tracking: 0.3,
  );

  /// Small section label style.
  static final TextStyle sectionLabel = staticFace(
    displayFamily,
    9.5,
    1,
    FontWeight.w700,
    tracking: 1.33,
  );

  // ---- UI roles ----

  /// Heading style for authentication and profile screens.
  static final TextStyle screenHeading = variable(
    uiFamily,
    19,
    1.1,
    FontWeight.w600,
    tracking: -0.38,
  );

  /// Saved-item title style.
  static final TextStyle itemTitle = variable(
    uiFamily,
    15,
    1.3,
    FontWeight.w600,
    tracking: -0.18,
  );

  /// Body text for descriptions and other content.
  static final TextStyle body = variable(uiFamily, 13, 1.5, FontWeight.w400);

  /// Labels for fields and chips.
  static final TextStyle label = variable(uiFamily, 10.5, 1, FontWeight.w600);

  /// Supporting text for status lines and hints.
  static final TextStyle meta = variable(uiFamily, 11.5, 1.35, FontWeight.w500);

  /// Label style for buttons.
  static final TextStyle button = variable(
    uiFamily,
    12.5,
    1,
    FontWeight.w600,
    tracking: 0.125,
  );

  /// Label style for navigation destinations.
  static final TextStyle navigationLabel = variable(
    uiFamily,
    9.5,
    1,
    FontWeight.w600,
    tracking: 0.285,
  );

  // ---- machine-text roles ----

  /// Monospaced style for domains and URLs.
  static final TextStyle mono = variable(monoFamily, 11, 1.3, FontWeight.w500);

  /// Smaller monospaced style for saved-item timestamps.
  static final TextStyle monoSmall = variable(
    monoFamily,
    10,
    1.25,
    FontWeight.w500,
  );

  /// Small monospaced style for mock-data markers, timers, and notices.
  static final TextStyle micro = variable(monoFamily, 9, 1.2, FontWeight.w500);

  /// Maps typography roles to the [TextTheme] slots used by Material widgets.
  ///
  /// Colors are intentionally omitted. [ThemeData] applies them from the
  /// active theme so both brightness variants share the same typography.
  static const TextTheme textTheme = TextTheme(
    // Screen heading and largest UI text.
    headlineSmall: TextStyle(
      fontFamily: uiFamily,
      fontSize: 19,
      height: 1.1,
      fontWeight: FontWeight.w600,
      fontVariations: [FontVariation.weight(600)],
      letterSpacing: -0.38,
    ),
    // Saved-item title.
    titleSmall: TextStyle(
      fontFamily: uiFamily,
      fontSize: 15,
      height: 1.3,
      fontWeight: FontWeight.w600,
      fontVariations: [FontVariation.weight(600)],
      letterSpacing: -0.18,
    ),
    // Descriptions and other body content.
    bodyMedium: TextStyle(
      fontFamily: uiFamily,
      fontSize: 13,
      height: 1.5,
      fontWeight: FontWeight.w400,
      fontVariations: [FontVariation.weight(400)],
    ),
    // Status lines and hints.
    bodySmall: TextStyle(
      fontFamily: uiFamily,
      fontSize: 11.5,
      height: 1.35,
      fontWeight: FontWeight.w500,
      fontVariations: [FontVariation.weight(500)],
    ),
    // Field labels and chips.
    labelSmall: TextStyle(
      fontFamily: uiFamily,
      fontSize: 10.5,
      height: 1,
      fontWeight: FontWeight.w600,
      fontVariations: [FontVariation.weight(600)],
    ),
    // Navigation labels.
    labelMedium: TextStyle(
      fontFamily: uiFamily,
      fontSize: 9.5,
      height: 1,
      fontWeight: FontWeight.w600,
      fontVariations: [FontVariation.weight(600)],
      letterSpacing: 0.285,
    ),
    // App bar title where the dedicated screen-title style is not available.
    titleMedium: TextStyle(
      fontFamily: displayFamily,
      fontSize: 15,
      height: 1,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.3,
    ),
  );
}
