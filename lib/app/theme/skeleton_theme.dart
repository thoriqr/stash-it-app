import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:stash_it_app/app/theme/app_tokens.dart';

/// The loading treatment for data-driven lists, resolved for [brightness].
///
/// **Why this is one call and not a widget.** Every screen that loads a listing
/// needs the same two decisions — which grey the bones are, and whether they
/// move — and none of them is a per-screen choice. A wrapper widget would add a
/// layer to every call site and a second thing to keep in step with the tokens,
/// so the configuration is a plain function and `StashItApp` installs it once.
///
/// **Colours come from the tokens, not from the package's defaults.** The
/// package ships its own greys; this app has an approved palette, and a shimmer
/// in the wrong grey reads as a different product. `surfaceSunken` is already
/// the well / mock-data grey and `surfaceInset` the recessed band above it, so
/// base and highlight are one step apart in both themes — the same small delta
/// the package defaults use — and both are neutral greys. No accent, per
/// `ux-discovery` §5: *"Initial loading … Neutral skeleton rows."*
///
/// **Reduced motion is honoured.** `MediaQuery.disableAnimations` is the
/// platform's own "I do not want animation" signal; when it is set the bones are
/// painted in one flat colour instead. `SolidColorEffect` has a zero duration,
/// and `Skeletonizer` never starts a ticker for one, so the static treatment
/// really is static rather than a shimmer frozen at frame zero.
SkeletonizerConfigData appSkeletonizerConfig(
  Brightness brightness, {
  bool reducedMotion = false,
}) {
  return SkeletonizerConfigData(
    // Set explicitly rather than left to the package's
    // `MediaQuery.platformBrightnessOf` fallback: the app knows which theme is
    // in force, and it is the same answer for both.
    brightness: brightness,

    // Top-level tear-offs, not closures. `SkeletonizerConfigData` compares its
    // resolver by identity, so a closure rebuilt each build would make the
    // config unequal every frame — and an unequal config restarts the shimmer.
    effectResolver: reducedMotion ? _staticEffect : _shimmerEffect,
  );
}

/// One pass of the sweep.
///
/// Under the package's two seconds: it crosses a row-sized rectangle, and a
/// faster pass reads as motion rather than as a progress indicator — which
/// matters, because the backend never signals that anything has begun
/// (`decisions.md` §2.2).
const Duration _shimmerDuration = Duration(milliseconds: 1600);

PaintingEffect _shimmerEffect(Brightness brightness) {
  final tokens = brightness == Brightness.dark
      ? AppTokens.dark
      : AppTokens.light;

  return ShimmerEffect(
    baseColor: tokens.surfaceSunken,
    highlightColor: tokens.surfaceInset,
    duration: _shimmerDuration,
  );
}

/// The reduced-motion treatment: the resting colour, held still.
PaintingEffect _staticEffect(Brightness brightness) {
  final tokens = brightness == Brightness.dark
      ? AppTokens.dark
      : AppTokens.light;

  return SolidColorEffect(color: tokens.surfaceSunken);
}
