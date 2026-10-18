import 'package:flutter/material.dart';

/// The approved design system's **type roles** — `design-system.md` §3.
///
/// Every role in the specification has a name here, so a widget asks for a role
/// rather than restating a size. Sizes, line heights, weights and families come
/// from the specification; colours do **not** live here — they are applied once
/// from the active [ThemeData], and a widget overrides a single colour with
/// `copyWith` when it needs a quieter step.
///
/// **The pixel face is restrained on purpose.** [display] carries the wordmark,
/// screen titles and small section labels — nothing else. Saved-item titles,
/// descriptions, domains and metadata never use it. **The mono face is for
/// machine text**: domains, URLs, timestamps and mock-data markers, never prose.
///
/// Both [ui] and [mono] ship as **variable** fonts. A `TextStyle` therefore sets
/// `fontVariations` alongside `fontWeight`, or Flutter would render every weight
/// from the font's default instance. The weights are also declared in
/// `pubspec.yaml` so font matching finds an exact match and never synthesises a
/// faux bold on top of a real weight.
abstract final class AppTypography {
  /// Silkscreen. Display only — see the class doc.
  static const String displayFamily = 'Silkscreen';

  /// Inter. All UI copy and saved-item content.
  static const String uiFamily = 'Inter';

  /// JetBrains Mono. Machine text only — see the class doc.
  static const String monoFamily = 'JetBrains Mono';

  /// Builds a style on a **variable** face at a real weight.
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

  /// Builds a style on a **static** face, which needs no weight axis.
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

  // ---- display roles (Silkscreen) ----

  /// Wordmark — 10 / 1 / 700, tracking .20em.
  ///
  /// Written uppercase at the call site: Flutter has no text-transform.
  static final TextStyle wordmark = staticFace(
    displayFamily,
    10,
    1,
    FontWeight.w700,
    tracking: 2.0,
  );

  /// Screen title — 15 / 1 / 700, tracking .02em. The app bar.
  static final TextStyle screenTitle = staticFace(
    displayFamily,
    15,
    1,
    FontWeight.w700,
    tracking: 0.3,
  );

  /// Section label (eyebrow) — 9.5 / 1 / 700, tracking .14em.
  static final TextStyle sectionLabel = staticFace(
    displayFamily,
    9.5,
    1,
    FontWeight.w700,
    tracking: 1.33,
  );

  // ---- UI roles (Inter) ----

  /// Screen heading — 19 / 1.1 / 600, tracking -.02em. Auth and profile headings.
  static final TextStyle screenHeading = variable(
    uiFamily,
    19,
    1.1,
    FontWeight.w600,
    tracking: -0.38,
  );

  /// Item title — 15 / 1.3 / 600, tracking -.012em. Two-line clamp.
  static final TextStyle itemTitle = variable(
    uiFamily,
    15,
    1.3,
    FontWeight.w600,
    tracking: -0.18,
  );

  /// Body — 13 / 1.5 / 400. Descriptions, two-line clamp.
  static final TextStyle body = variable(uiFamily, 13, 1.5, FontWeight.w400);

  /// Label — 10.5 / 1 / 600. Field labels, chips.
  static final TextStyle label = variable(uiFamily, 10.5, 1, FontWeight.w600);

  /// Meta — 11.5 / 1.35 / 500. State lines, hints.
  static final TextStyle meta = variable(uiFamily, 11.5, 1.35, FontWeight.w500);

  /// Button label — 12.5 / 1 / 600, tracking .01em.
  static final TextStyle button = variable(
    uiFamily,
    12.5,
    1,
    FontWeight.w600,
    tracking: 0.125,
  );

  /// Navigation label — 9.5 / 1 / 600, tracking .03em.
  static final TextStyle navigationLabel = variable(
    uiFamily,
    9.5,
    1,
    FontWeight.w600,
    tracking: 0.285,
  );

  // ---- machine-text roles (JetBrains Mono) ----

  /// Mono — 11 / 1.3 / 500. Domains, URLs.
  static final TextStyle mono = variable(monoFamily, 11, 1.3, FontWeight.w500);

  /// Mono small — 10 / 1.25 / 500. Saved-time labels.
  static final TextStyle monoSmall = variable(
    monoFamily,
    10,
    1.25,
    FontWeight.w500,
  );

  /// Micro — 9 / 1.2 / 500. Mock markers, timers, notices.
  static final TextStyle micro = variable(monoFamily, 9, 1.2, FontWeight.w500);

  /// The specification's roles mapped onto the [TextTheme] slots Material and the
  /// existing widgets actually read.
  ///
  /// Colours are deliberately absent: [ThemeData] applies them from the active
  /// token set so there is one source for both brightnesses.
  static const TextTheme textTheme = TextTheme(
    // The screen heading, and the biggest UI type in the system.
    headlineSmall: TextStyle(
      fontFamily: uiFamily,
      fontSize: 19,
      height: 1.1,
      fontWeight: FontWeight.w600,
      fontVariations: [FontVariation.weight(600)],
      letterSpacing: -0.38,
    ),
    // A saved item's title.
    titleSmall: TextStyle(
      fontFamily: uiFamily,
      fontSize: 15,
      height: 1.3,
      fontWeight: FontWeight.w600,
      fontVariations: [FontVariation.weight(600)],
      letterSpacing: -0.18,
    ),
    // Body copy: descriptions and ledes.
    bodyMedium: TextStyle(
      fontFamily: uiFamily,
      fontSize: 13,
      height: 1.5,
      fontWeight: FontWeight.w400,
      fontVariations: [FontVariation.weight(400)],
    ),
    // State lines and hints.
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
    // A screen title, where a slot cannot take the app bar style directly.
    titleMedium: TextStyle(
      fontFamily: displayFamily,
      fontSize: 15,
      height: 1,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.3,
    ),
  );
}
