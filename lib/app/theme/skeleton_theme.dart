import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:stash_it_app/app/theme/app_tokens.dart';

/// Creates the shared skeleton loading configuration for the active theme.
///
/// A function is used instead of a wrapper widget because every screen shares
/// the same color and animation decisions. The configuration is installed
/// centrally by the application rather than repeated at individual call sites.
///
/// Colors come from [AppTokens] instead of the package defaults so skeletons
/// remain consistent with the application's light and dark palettes. The
/// effect uses neutral surface colors rather than the accent color.
SkeletonizerConfigData appSkeletonizerConfig(
  Brightness brightness, {
  bool reducedMotion = false,
}) {
  return SkeletonizerConfigData(
    // Use the active application theme instead of relying on the package's
    // platform-brightness fallback.
    brightness: brightness,

    // Use top-level functions to keep the resolver identity stable.
    // Recreating a closure on each build could make the configuration unequal
    // and cause the shimmer animation to restart.
    effectResolver: reducedMotion ? _staticEffect : _shimmerEffect,
  );
}

/// Duration of one shimmer pass across the loading content.
///
/// Kept shorter than the package's default so the effect reads as subtle
/// movement rather than a progress indicator. Loading does not represent
/// measurable progress.
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

/// Returns a static skeleton effect when reduced motion is requested.
///
/// Uses the resting surface color without starting a shimmer animation.
PaintingEffect _staticEffect(Brightness brightness) {
  final tokens = brightness == Brightness.dark
      ? AppTokens.dark
      : AppTokens.light;

  return SolidColorEffect(color: tokens.surfaceSunken);
}
