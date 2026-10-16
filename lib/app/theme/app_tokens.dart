import 'package:flutter/material.dart';

/// Provisional design tokens for the **Paper & Ink** direction.
///
/// Paper-white surfaces, crisp dark type, one deep pine accent used sparingly. These
/// are prototype values chosen to evaluate a visual direction, not approved brand
/// tokens — the visual language is still undesigned
/// (`docs/product-discovery/decisions.md` §6).
///
/// Exposed as a [ThemeExtension] so widgets read colours from the theme instead of
/// hard-coding hex values. Material's [ColorScheme] does not carry a warm-neutral
/// canvas, a secondary neutral, or a hairline border, which is what this direction is
/// built from.
@immutable
class AppTokens extends ThemeExtension<AppTokens> {
  const AppTokens({
    required this.background,
    required this.surface,
    required this.surfaceMuted,
    required this.textPrimary,
    required this.textMuted,
    required this.accent,
    required this.accentSoft,
    required this.border,
    required this.danger,
  });

  /// The paper canvas. Maps to the M3 `surface` so screens sit on it.
  final Color background;

  /// Clean white foreground surface: app bar, navigation bar, the mock-data notice.
  final Color surface;

  /// Secondary neutral: image placeholders and other inert fills.
  final Color surfaceMuted;

  /// Titles and body copy.
  final Color textPrimary;

  /// Secondary copy — source lines, descriptions, state lines, saved-time labels.
  /// Neutral charcoal-grey, checked for small-text contrast against both
  /// [background] and [surface].
  final Color textMuted;

  /// The single accent. Carries identity and progress, never decoration:
  /// the collection pill, the pending marker, the selection state, the retry action.
  final Color accent;

  /// Restrained pale green-grey. The accent's only filled surface.
  final Color accentSoft;

  /// Hairline separators. Neutral, not beige.
  final Color border;

  /// Semantic failure colour. Carried over unchanged from the previous iteration;
  /// it still meets contrast on [surface] and adds no new hue to the palette.
  final Color danger;

  @override
  AppTokens copyWith({
    Color? background,
    Color? surface,
    Color? surfaceMuted,
    Color? textPrimary,
    Color? textMuted,
    Color? accent,
    Color? accentSoft,
    Color? border,
    Color? danger,
  }) {
    return AppTokens(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceMuted: surfaceMuted ?? this.surfaceMuted,
      textPrimary: textPrimary ?? this.textPrimary,
      textMuted: textMuted ?? this.textMuted,
      accent: accent ?? this.accent,
      accentSoft: accentSoft ?? this.accentSoft,
      border: border ?? this.border,
      danger: danger ?? this.danger,
    );
  }

  @override
  AppTokens lerp(covariant AppTokens? other, double t) {
    if (other == null) return this;

    return AppTokens(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceMuted: Color.lerp(surfaceMuted, other.surfaceMuted, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentSoft: Color.lerp(accentSoft, other.accentSoft, t)!,
      border: Color.lerp(border, other.border, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
    );
  }
}
