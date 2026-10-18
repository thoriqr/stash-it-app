import 'package:flutter/material.dart';

/// The approved design system's **semantic colour** — `design-system.md` §2.
///
/// This is the Flutter mirror of `docs/design-explorations/assets/tokens.css`. It
/// carries the tokens Material 3's [ColorScheme] has no slot for: the inset and
/// sunken surfaces, the hairline borders, the accent's tinted surfaces, the
/// selected-navigation triple, and the slot hatch.
///
/// Two instances exist, [light] and [dark]. The accent is **Dusty Sage** in both:
/// one hue at two lightnesses, because only lightness survives both surfaces.
///
/// **Contrast.** Every text step used for copy meets WCAG AA (4.5:1) on both
/// [surface] and [surfaceInset]. [textDisabled] and [disabledText] are the only
/// steps below it and are reserved for disabled controls, which WCAG exempts.
/// The accent reaches 5.87:1 on white in light and 6.10:1 on `#1B1F23` in dark,
/// so it is safe as small chip, label and button text.
///
/// Exposed as a [ThemeExtension] so widgets read colour from the theme instead of
/// hard-coding hex values. Read it with `AppTheme.tokensOf(context)`.
@immutable
class AppTokens extends ThemeExtension<AppTokens> {
  const AppTokens({
    required this.canvas,
    required this.surface,
    required this.surfaceRaised,
    required this.surfaceInset,
    required this.surfaceSunken,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.textDisabled,
    required this.textInverse,
    required this.border,
    required this.borderStrong,
    required this.borderSubtle,
    required this.accent,
    required this.accentStrong,
    required this.accentSoft,
    required this.accentBorder,
    required this.accentContrast,
    required this.selected,
    required this.selectedSoft,
    required this.selectedMark,
    required this.success,
    required this.successSoft,
    required this.successBorder,
    required this.warning,
    required this.warningSoft,
    required this.warningBorder,
    required this.danger,
    required this.dangerSoft,
    required this.dangerBorder,
    required this.disabledBg,
    required this.disabledBorder,
    required this.disabledText,
    required this.focusRing,
    required this.slotHatch1,
    required this.slotHatch2,
    required this.slotShadowColor,
    required this.slotShadowInset,
    required this.mockText,
    required this.mockBorder,
  });

  /// The approved light theme (B · Inventory). Cool white-grey, never cream.
  static const AppTokens light = AppTokens(
    canvas: Color(0xFFF5F7F9),
    surface: Color(0xFFFFFFFF),
    surfaceRaised: Color(0xFFFFFFFF),
    surfaceInset: Color(0xFFEEF1F4),
    surfaceSunken: Color(0xFFE4E9ED),
    textPrimary: Color(0xFF222A34),
    textSecondary: Color(0xFF4A545F),
    textTertiary: Color(0xFF5F6975),
    textDisabled: Color(0xFFA6AFBA),
    textInverse: Color(0xFFFFFFFF),
    border: Color(0xFFDBE1E7),
    borderStrong: Color(0xFFC3CCD6),
    borderSubtle: Color(0xFFE9EDF1),
    accent: Color(0xFF4C6B5F),
    accentStrong: Color(0xFF3F5B50),
    accentSoft: Color(0xFFEBF1EE),
    accentBorder: Color(0xFFBDCFC6),
    accentContrast: Color(0xFFFFFFFF),
    selected: Color(0xFF4C6B5F),
    selectedSoft: Color(0xFFEBF1EE),
    selectedMark: Color(0xFF4C6B5F),
    success: Color(0xFF1D6E5E),
    successSoft: Color(0xFFE6F1EE),
    successBorder: Color(0xFFBBD8D0),
    warning: Color(0xFF8A6A2F),
    warningSoft: Color(0xFFF6F0E2),
    warningBorder: Color(0xFFE0D2B4),
    danger: Color(0xFFA8463A),
    dangerSoft: Color(0xFFF6E9E6),
    dangerBorder: Color(0xFFE4C4BE),
    disabledBg: Color(0xFFEFF2F5),
    disabledBorder: Color(0xFFE2E7EC),
    disabledText: Color(0xFFA6AFBA),
    focusRing: Color(0x384C6B5F),
    slotHatch1: Color(0xFFEEF1F4),
    slotHatch2: Color(0xFFE4E9ED),
    slotShadowColor: Color(0x0D101418),
    slotShadowInset: false,
    mockText: Color(0xFF5F6975),
    mockBorder: Color(0xFFC3CCD6),
  );

  /// The approved dark theme (B-Dark). Layered charcoal, never pure black.
  static const AppTokens dark = AppTokens(
    canvas: Color(0xFF14171A),
    surface: Color(0xFF1B1F23),
    surfaceRaised: Color(0xFF21262B),
    surfaceInset: Color(0xFF1E2328),
    surfaceSunken: Color(0xFF121518),
    textPrimary: Color(0xFFDAE0E5),
    textSecondary: Color(0xFFA3ACB5),
    textTertiary: Color(0xFF848E99),
    textDisabled: Color(0xFF5D6771),
    textInverse: Color(0xFF14171A),
    border: Color(0xFF2C333A),
    borderStrong: Color(0xFF3B434B),
    borderSubtle: Color(0xFF22272D),
    accent: Color(0xFF74A88C),
    accentStrong: Color(0xFF86BA9C),
    accentSoft: Color(0xFF1B2620),
    accentBorder: Color(0xFF3A5548),
    accentContrast: Color(0xFF10140F),
    selected: Color(0xFF74A88C),
    selectedSoft: Color(0xFF1B2620),
    selectedMark: Color(0xFF74A88C),
    success: Color(0xFF56BFA4),
    successSoft: Color(0xFF17241F),
    successBorder: Color(0xFF2E4C42),
    warning: Color(0xFFD9AE5F),
    warningSoft: Color(0xFF262115),
    warningBorder: Color(0xFF4A3F24),
    danger: Color(0xFFE08C7A),
    dangerSoft: Color(0xFF2B1F1C),
    dangerBorder: Color(0xFF4E322C),
    disabledBg: Color(0xFF1B1F23),
    disabledBorder: Color(0xFF262C33),
    disabledText: Color(0xFF5D6771),
    focusRing: Color(0x3D74A88C),
    slotHatch1: Color(0xFF1B2024),
    slotHatch2: Color(0xFF272D33),
    slotShadowColor: Color(0x09FFFFFF),
    slotShadowInset: true,
    mockText: Color(0xFF848E99),
    mockBorder: Color(0xFF3B434B),
  );

  // ---- surfaces ----

  /// The app background. Also the list canvas the slots sit on.
  final Color canvas;

  /// Raised surfaces: slots, app bar, navigation bar, buttons.
  final Color surface;

  /// Sheets and dialogs.
  final Color surfaceRaised;

  /// Recessed bands: the intake area, mock-data bars.
  final Color surfaceInset;

  /// Wells: the thumbnail placeholder.
  final Color surfaceSunken;

  // ---- text ----

  /// Titles and body copy. 13.3:1 light · 12.5:1 dark.
  final Color textPrimary;

  /// Descriptions. 7.7:1 light · 7.2:1 dark.
  final Color textSecondary;

  /// Domains, times, labels, hints. 5.6:1 light · 5.0:1 dark.
  final Color textTertiary;

  /// Disabled controls **only**. Below AA by design; WCAG exempts disabled
  /// controls from contrast minimums, and nothing else may use it.
  final Color textDisabled;

  /// Text on a filled accent.
  final Color textInverse;

  // ---- lines ----

  /// The default 1 px border.
  final Color border;

  /// A deliberate or emphasised border: button outlines, empty wells.
  final Color borderStrong;

  /// Hairline separators.
  final Color borderSubtle;

  // ---- accent ----

  /// Dusty Sage. Identity and progress only, never decoration.
  final Color accent;

  /// The accent one step deeper, for a pressed accent surface.
  final Color accentStrong;

  /// The accent's only filled surface — chips, the focused field halo's base.
  final Color accentSoft;

  /// A chip's or the system collection's accent border.
  final Color accentBorder;

  /// Text on a filled [accent].
  final Color accentContrast;

  // ---- selection ----

  /// The selected navigation destination: its icon and label.
  final Color selected;

  /// The selected destination's surface.
  final Color selectedSoft;

  /// The short accent marker on the navigation bar's top edge.
  final Color selectedMark;

  // ---- semantic states ----

  /// A save that was confirmed.
  final Color success;
  final Color successSoft;
  final Color successBorder;

  /// Budget spent, expiry, uncertain outcome.
  final Color warning;
  final Color warningSoft;
  final Color warningBorder;

  /// A failure that is known.
  final Color danger;
  final Color dangerSoft;
  final Color dangerBorder;

  // ---- disabled ----

  final Color disabledBg;
  final Color disabledBorder;

  /// Same value as [textDisabled], named for its role.
  final Color disabledText;

  // ---- focus ----

  /// The halo drawn outside a focused field's border. Carries its own alpha.
  final Color focusRing;

  // ---- inventory slot ----

  /// The 45° hatch that stands in for a preview image.
  final Color slotHatch1;

  /// The second step of that hatch.
  final Color slotHatch2;

  /// The slot's shadow colour, carrying its own alpha.
  final Color slotShadowColor;

  /// Light drops a shadow below the slot; dark lifts it with an inset hairline
  /// instead, because a drop shadow is invisible on a dark canvas.
  final bool slotShadowInset;

  // ---- mock-data marker ----

  /// The "this is not API data" line.
  final Color mockText;

  /// Its dashed border.
  final Color mockBorder;

  @override
  AppTokens copyWith({
    Color? canvas,
    Color? surface,
    Color? surfaceRaised,
    Color? surfaceInset,
    Color? surfaceSunken,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? textDisabled,
    Color? textInverse,
    Color? border,
    Color? borderStrong,
    Color? borderSubtle,
    Color? accent,
    Color? accentStrong,
    Color? accentSoft,
    Color? accentBorder,
    Color? accentContrast,
    Color? selected,
    Color? selectedSoft,
    Color? selectedMark,
    Color? success,
    Color? successSoft,
    Color? successBorder,
    Color? warning,
    Color? warningSoft,
    Color? warningBorder,
    Color? danger,
    Color? dangerSoft,
    Color? dangerBorder,
    Color? disabledBg,
    Color? disabledBorder,
    Color? disabledText,
    Color? focusRing,
    Color? slotHatch1,
    Color? slotHatch2,
    Color? slotShadowColor,
    bool? slotShadowInset,
    Color? mockText,
    Color? mockBorder,
  }) {
    return AppTokens(
      canvas: canvas ?? this.canvas,
      surface: surface ?? this.surface,
      surfaceRaised: surfaceRaised ?? this.surfaceRaised,
      surfaceInset: surfaceInset ?? this.surfaceInset,
      surfaceSunken: surfaceSunken ?? this.surfaceSunken,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      textDisabled: textDisabled ?? this.textDisabled,
      textInverse: textInverse ?? this.textInverse,
      border: border ?? this.border,
      borderStrong: borderStrong ?? this.borderStrong,
      borderSubtle: borderSubtle ?? this.borderSubtle,
      accent: accent ?? this.accent,
      accentStrong: accentStrong ?? this.accentStrong,
      accentSoft: accentSoft ?? this.accentSoft,
      accentBorder: accentBorder ?? this.accentBorder,
      accentContrast: accentContrast ?? this.accentContrast,
      selected: selected ?? this.selected,
      selectedSoft: selectedSoft ?? this.selectedSoft,
      selectedMark: selectedMark ?? this.selectedMark,
      success: success ?? this.success,
      successSoft: successSoft ?? this.successSoft,
      successBorder: successBorder ?? this.successBorder,
      warning: warning ?? this.warning,
      warningSoft: warningSoft ?? this.warningSoft,
      warningBorder: warningBorder ?? this.warningBorder,
      danger: danger ?? this.danger,
      dangerSoft: dangerSoft ?? this.dangerSoft,
      dangerBorder: dangerBorder ?? this.dangerBorder,
      disabledBg: disabledBg ?? this.disabledBg,
      disabledBorder: disabledBorder ?? this.disabledBorder,
      disabledText: disabledText ?? this.disabledText,
      focusRing: focusRing ?? this.focusRing,
      slotHatch1: slotHatch1 ?? this.slotHatch1,
      slotHatch2: slotHatch2 ?? this.slotHatch2,
      slotShadowColor: slotShadowColor ?? this.slotShadowColor,
      slotShadowInset: slotShadowInset ?? this.slotShadowInset,
      mockText: mockText ?? this.mockText,
      mockBorder: mockBorder ?? this.mockBorder,
    );
  }

  @override
  AppTokens lerp(covariant AppTokens? other, double t) {
    if (other == null) return this;

    return AppTokens(
      canvas: Color.lerp(canvas, other.canvas, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceRaised: Color.lerp(surfaceRaised, other.surfaceRaised, t)!,
      surfaceInset: Color.lerp(surfaceInset, other.surfaceInset, t)!,
      surfaceSunken: Color.lerp(surfaceSunken, other.surfaceSunken, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      textDisabled: Color.lerp(textDisabled, other.textDisabled, t)!,
      textInverse: Color.lerp(textInverse, other.textInverse, t)!,
      border: Color.lerp(border, other.border, t)!,
      borderStrong: Color.lerp(borderStrong, other.borderStrong, t)!,
      borderSubtle: Color.lerp(borderSubtle, other.borderSubtle, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentStrong: Color.lerp(accentStrong, other.accentStrong, t)!,
      accentSoft: Color.lerp(accentSoft, other.accentSoft, t)!,
      accentBorder: Color.lerp(accentBorder, other.accentBorder, t)!,
      accentContrast: Color.lerp(accentContrast, other.accentContrast, t)!,
      selected: Color.lerp(selected, other.selected, t)!,
      selectedSoft: Color.lerp(selectedSoft, other.selectedSoft, t)!,
      selectedMark: Color.lerp(selectedMark, other.selectedMark, t)!,
      success: Color.lerp(success, other.success, t)!,
      successSoft: Color.lerp(successSoft, other.successSoft, t)!,
      successBorder: Color.lerp(successBorder, other.successBorder, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningSoft: Color.lerp(warningSoft, other.warningSoft, t)!,
      warningBorder: Color.lerp(warningBorder, other.warningBorder, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      dangerSoft: Color.lerp(dangerSoft, other.dangerSoft, t)!,
      dangerBorder: Color.lerp(dangerBorder, other.dangerBorder, t)!,
      disabledBg: Color.lerp(disabledBg, other.disabledBg, t)!,
      disabledBorder: Color.lerp(disabledBorder, other.disabledBorder, t)!,
      disabledText: Color.lerp(disabledText, other.disabledText, t)!,
      focusRing: Color.lerp(focusRing, other.focusRing, t)!,
      slotHatch1: Color.lerp(slotHatch1, other.slotHatch1, t)!,
      slotHatch2: Color.lerp(slotHatch2, other.slotHatch2, t)!,
      slotShadowColor: Color.lerp(slotShadowColor, other.slotShadowColor, t)!,
      slotShadowInset: t < 0.5 ? slotShadowInset : other.slotShadowInset,
      mockText: Color.lerp(mockText, other.mockText, t)!,
      mockBorder: Color.lerp(mockBorder, other.mockBorder, t)!,
    );
  }
}
