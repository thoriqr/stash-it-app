import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_it_app/shared/widgets/desktop_layout.dart';

void main() {
  tearDown(() => debugDefaultTargetPlatformOverride = null);

  test('Windows and macOS use the desktop layout', () {
    for (final platform in [TargetPlatform.windows, TargetPlatform.macOS]) {
      debugDefaultTargetPlatformOverride = platform;
      expect(usesDesktopLayout, isTrue, reason: platform.name);
    }
  });

  test('Android keeps the mobile layout', () {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    expect(usesDesktopLayout, isFalse);
  });
}
