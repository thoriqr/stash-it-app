import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:stash_it_app/app/app.dart';
import 'package:stash_it_app/app/network/network_providers.dart';
import 'package:stash_it_app/app/router/app_router.dart';
import 'package:stash_it_app/app/theme/app_theme.dart';
import 'package:stash_it_app/core/storage/secure_credential_store.dart';
import 'package:stash_it_app/features/auth/application/session_controller.dart';
import 'package:stash_it_app/features/pending_urls/data/pending_url_store.dart';

import '../../support/fake_http.dart';
import '../../support/pending_urls.dart';
import '../../support/saved_items_fixtures.dart';

/// The shared loading treatment, and the fact that the app installs it.
void main() {
  group('resolved for a brightness', () {
    test('a light shimmer is the light palette one step apart', () {
      final effect = appSkeletonizerConfig(
        Brightness.light,
      ).resolveEffect(Brightness.light);

      expect(effect, isA<ShimmerEffect>());
      expect(
        (effect as ShimmerEffect).colors,
        [
          AppTokens.light.surfaceSunken,
          AppTokens.light.surfaceInset,
          AppTokens.light.surfaceSunken,
        ],
        reason: 'base, highlight, base — and both greys are the approved ones',
      );
      expect(
        effect.duration,
        isNot(Duration.zero),
        reason: 'a zero duration would be the reduced-motion treatment',
      );
    });

    test('a dark shimmer is the dark palette one step apart', () {
      final effect = appSkeletonizerConfig(
        Brightness.dark,
      ).resolveEffect(Brightness.dark);

      expect((effect as ShimmerEffect).colors, [
        AppTokens.dark.surfaceSunken,
        AppTokens.dark.surfaceInset,
        AppTokens.dark.surfaceSunken,
      ]);
    });

    test('no accent appears in either theme', () {
      // `ux-discovery` §5: initial loading is *neutral* skeleton rows. A tint
      // would read as a progress signal the backend never sends.
      for (final brightness in Brightness.values) {
        final colors =
            (appSkeletonizerConfig(brightness).resolveEffect(brightness)
                    as ShimmerEffect)
                .colors;

        expect(
          colors,
          isNot(contains(AppTokens.light.accent)),
          reason: '$brightness must not tint the bones',
        );
      }
    });

    test('the resolver is resolved per brightness, not baked in', () {
      // The resolver takes a brightness precisely so one config serves both
      // themes; a closure that captured tokens would have forced two.
      final config = appSkeletonizerConfig(Brightness.dark);

      expect(config.resolveEffect(Brightness.light), isA<ShimmerEffect>());
      expect((config.resolveEffect(Brightness.light) as ShimmerEffect).colors, [
        AppTokens.light.surfaceSunken,
        AppTokens.light.surfaceInset,
        AppTokens.light.surfaceSunken,
      ]);
    });
  });

  group('reduced motion', () {
    test('resolves to a static effect in the resting colour', () {
      final effect = appSkeletonizerConfig(
        Brightness.dark,
        reducedMotion: true,
      ).resolveEffect(Brightness.dark);

      expect(effect, isA<SolidColorEffect>());
      expect((effect as SolidColorEffect).color, AppTokens.dark.surfaceSunken);
    });

    test('the static effect never starts a ticker', () {
      // This is why `SolidColorEffect` and not a frozen shimmer: the package
      // only creates an `AnimationController` when the duration is non-zero,
      // so a zero duration means genuinely still rather than paused.
      expect(
        appSkeletonizerConfig(
          Brightness.light,
          reducedMotion: true,
        ).resolveEffect(Brightness.light).duration,
        Duration.zero,
      );
    });
  });

  group('config stability', () {
    test('the same inputs produce an equal config', () {
      // `SkeletonizerConfigData` compares its resolver by identity, so a
      // closure rebuilt on every build would make the config unequal each time
      // — and an unequal config restarts the animation. Top-level tear-offs
      // are what make this hold.
      expect(
        appSkeletonizerConfig(Brightness.light),
        appSkeletonizerConfig(Brightness.light),
      );
      expect(
        appSkeletonizerConfig(Brightness.light, reducedMotion: true),
        appSkeletonizerConfig(Brightness.light, reducedMotion: true),
      );
    });

    test('a different brightness is a different config', () {
      expect(
        appSkeletonizerConfig(Brightness.light),
        isNot(appSkeletonizerConfig(Brightness.dark)),
      );
    });
  });

  group('installed by the app', () {
    /// Pumps the whole application and returns the config its screens inherit.
    ///
    /// `media` replaces the platform's media query outright, which is the only
    /// way to state "this platform asked for reduced motion" from a test.
    Future<SkeletonizerConfigData> pumpApp(
      WidgetTester tester, {
      MediaQueryData media = const MediaQueryData(
        size: Size(900, 1600),
        platformBrightness: Brightness.light,
      ),
    }) async {
      final adapter = FakeHttpAdapter();
      adapter.on('/saved-items', body: SavedItemsFixtures.emptyPage());
      final pendingStore = await testPendingUrlStore();

      final container = ProviderContainer(
        // The app root keeps the session boundary alive, and `createAppRouter`
        // bypasses auth; the controller still needs a store it never reads here.
        overrides: [
          credentialStoreProvider.overrideWithValue(
            SecureCredentialStore(InMemorySecureStorage()),
          ),
          pendingUrlStoreProvider.overrideWithValue(pendingStore),
        ],
        // An unscripted provider would leave one of Riverpod's retry timers
        // pending past the end of the test body.
        retry: (_, _) => null,
      );
      addTearDown(container.dispose);
      container.read(appDioProvider).httpClientAdapter = adapter;
      container.read(refreshDioProvider).httpClientAdapter = adapter;

      final router = createAppRouter();
      addTearDown(router.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MediaQuery(
            data: media,
            child: StashItApp(router: router),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final installed = SkeletonizerConfig.maybeOf(
        tester.element(find.byType(Navigator).first),
      );

      expect(
        installed,
        isNotNull,
        reason: 'every route must inherit one shared skeleton treatment',
      );

      return installed!;
    }

    testWidgets('a light platform gets the light treatment', (tester) async {
      final config = await pumpApp(tester);

      expect(config.brightness, Brightness.light);
      expect((config.resolveEffect(Brightness.light) as ShimmerEffect).colors, [
        AppTokens.light.surfaceSunken,
        AppTokens.light.surfaceInset,
        AppTokens.light.surfaceSunken,
      ]);
    });

    testWidgets('a dark platform gets the dark treatment', (tester) async {
      final config = await pumpApp(
        tester,
        media: const MediaQueryData(
          size: Size(900, 1600),
          platformBrightness: Brightness.dark,
        ),
      );

      expect(config.brightness, Brightness.dark);
      expect((config.resolveEffect(Brightness.dark) as ShimmerEffect).colors, [
        AppTokens.dark.surfaceSunken,
        AppTokens.dark.surfaceInset,
        AppTokens.dark.surfaceSunken,
      ]);
    });

    testWidgets('reduced motion reaches the treatment', (tester) async {
      final config = await pumpApp(
        tester,
        media: const MediaQueryData(
          size: Size(900, 1600),
          platformBrightness: Brightness.light,
          disableAnimations: true,
        ),
      );

      expect(
        config.resolveEffect(Brightness.light),
        isA<SolidColorEffect>(),
        reason: "the platform's own reduce-animation signal has to be honoured",
      );
    });
  });
}
