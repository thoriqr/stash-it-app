import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:stash_it_app/app/app.dart';
import 'package:stash_it_app/app/feedback/app_feedback.dart';
import 'package:stash_it_app/app/feedback/feedback_controller.dart';
import 'package:stash_it_app/app/feedback/feedback_host.dart';
import 'package:stash_it_app/app/network/network_providers.dart';
import 'package:stash_it_app/app/router/app_router.dart';
import 'package:stash_it_app/app/router/routes.dart';
import 'package:stash_it_app/app/theme/app_theme.dart';
import 'package:stash_it_app/core/storage/secure_credential_store.dart';
import 'package:stash_it_app/features/auth/application/session_controller.dart';

import '../../support/fake_http.dart';
import '../../support/saved_items_fixtures.dart';

/// The feedback presenter, in the app's **real** widget tree.
///
/// Position is the whole subject here, so the tree under test is the real one:
/// `StashItApp`, the real `StatefulShellRoute` shell `Scaffold` with its
/// `NavigationBar`, and a real destination `Scaffold` with a real `AppBar`
/// (`app_router.dart`, `inbox_screen.dart`). A simplified harness could not
/// establish any of what these tests claim — the whole reason the notice is
/// hosted in `MaterialApp.router`'s builder is what the surrounding Scaffolds
/// are.
///
/// Only the transport is scripted, so the Inbox's `GET /saved-items` never
/// reaches a socket (`AGENTS.md` §5).
void main() {
  /// Pumps the app with its own router and container, and returns both.
  ///
  /// Its own router per test so navigation history cannot leak between cases,
  /// and its own container so a notice published by one test cannot be showing
  /// in the next.
  Future<({ProviderContainer container, GoRouter router})> pumpApp(
    WidgetTester tester,
  ) async {
    final adapter = FakeHttpAdapter();
    adapter.on('/saved-items', body: SavedItemsFixtures.emptyPage());

    final container = ProviderContainer(
      // The app root keeps the session boundary alive, and `createAppRouter`
      // bypasses auth; the controller still needs a store it never reads here.
      overrides: [
        credentialStoreProvider.overrideWithValue(
          SecureCredentialStore(InMemorySecureStorage()),
        ),
      ],
      // Riverpod 3 retries a failed provider with backoff; an unscripted listing
      // would leave one of those timers pending past the test body.
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
        child: StashItApp(router: router),
      ),
    );
    await tester.pumpAndSettle();

    return (container: container, router: router);
  }

  /// Publishes a notice exactly as a feature would, and settles its transition.
  Future<void> publish(
    WidgetTester tester,
    ProviderContainer container, {
    FeedbackTone tone = FeedbackTone.danger,
    String copy = 'Something happened.',
  }) async {
    container
        .read(feedbackProvider.notifier)
        .show(AppFeedback(tone: tone, copy: copy));
    await tester.pumpAndSettle();
  }

  /// Runs the notice's clock out, so no dismissal timer outlives the test body.
  Future<void> expireNotice(WidgetTester tester) async {
    await tester.pump(
      feedbackVisibleDuration + const Duration(milliseconds: 1),
    );
    await tester.pumpAndSettle();
  }

  Future<void> tapDestination(WidgetTester tester, String label) async {
    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text(label),
      ),
    );
    await tester.pumpAndSettle();
  }

  Rect noticeRect(WidgetTester tester) =>
      tester.getRect(find.byType(FeedbackNotice));

  group('placement', () {
    testWidgets('the notice sits below the destination app bar', (
      WidgetTester tester,
    ) async {
      final app = await pumpApp(tester);
      await publish(
        tester,
        app.container,
        tone: FeedbackTone.success,
        copy: 'Saved.',
      );

      // Only the Inbox branch has been built, so there is exactly one app bar
      // and it is the one the notice has to clear.
      expect(find.byType(AppBar), findsOneWidget);
      final appBar = tester.getRect(find.byType(AppBar));
      final notice = noticeRect(tester);

      expect(
        notice.top,
        greaterThanOrEqualTo(appBar.bottom),
        reason: 'the notice must not be drawn over the screen title',
      );
      expect(
        notice.top,
        lessThan(appBar.bottom + AppMetrics.space4),
        reason:
            'it belongs at the top of the content area, not floating mid-screen',
      );
      expect(
        notice.left,
        AppMetrics.screenPadding,
        reason: 'it is inset like the content it sits above',
      );
      expect(
        notice.right,
        appBar.right - AppMetrics.screenPadding,
        reason: 'and inset by the same amount on the other side',
      );

      await expireNotice(tester);
    });

    testWidgets('the notice clears the system status bar', (
      WidgetTester tester,
    ) async {
      // A device with a status bar. `SafeArea` in the host is what turns this
      // inset into the notice's own offset, and the offset has to survive the
      // Scaffolds below consuming the same inset for their own layout.
      //
      // `TestFlutterView` measures padding in **physical** pixels, so the ratio
      // is pinned to 1 and the physical size restated: otherwise a `top: 24`
      // inset would arrive as 8 logical pixels on the default 3× view and these
      // numbers would mean something other than what they say.
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(800, 600);
      tester.view.padding = const FakeViewPadding(top: 24);
      addTearDown(tester.view.reset);

      final app = await pumpApp(tester);
      await publish(tester, app.container, copy: 'Saved.');

      final appBar = tester.getRect(find.byType(AppBar));
      final notice = noticeRect(tester);

      expect(
        appBar.bottom,
        24 + kToolbarHeight,
        reason:
            'the app bar spans the status-bar inset plus its toolbar, so the '
            'inset reached the tree',
      );
      expect(
        notice.top,
        greaterThan(24),
        reason: 'the notice is not drawn under the status bar',
      );
      // The assertion that would fail without the host's `SafeArea`: without it
      // the notice would start at `kToolbarHeight + space2` = 64, above the app
      // bar's bottom edge at 80.
      expect(
        notice.top,
        greaterThanOrEqualTo(appBar.bottom),
        reason:
            'clearing the status bar must not put the notice back over the app '
            'bar',
      );

      await expireNotice(tester);
    });

    testWidgets('a notice also appears on the route outside the shell', (
      WidgetTester tester,
    ) async {
      // The documented trade-off in `feedback_host.dart`: the band is a fixed
      // toolbar height on every route, so a route without an app bar simply gets
      // a gap rather than a different position. Sign-in is that route, and it is
      // also the proof that the host sits above the router rather than inside a
      // destination.
      final app = await pumpApp(tester);
      app.router.go(AppRoutes.signIn);
      await tester.pumpAndSettle();
      expect(find.text('Sign in to Stash It'), findsOneWidget);

      await publish(tester, app.container, copy: 'Saved.');

      expect(
        noticeRect(tester).top,
        kToolbarHeight + AppMetrics.space2,
        reason:
            'the same band as every other route, with nothing to collide with',
      );

      await expireNotice(tester);
    });

    testWidgets('a long notice wraps and still clears the navigation bar', (
      WidgetTester tester,
    ) async {
      final app = await pumpApp(tester);
      final copy = List.generate(40, (index) => 'word$index').join(' ');
      await publish(tester, app.container, copy: copy);

      final notice = noticeRect(tester);
      final navigationBar = tester.getRect(find.byType(NavigationBar));

      expect(
        notice.height,
        greaterThan(kToolbarHeight),
        reason:
            'the copy wraps onto several lines, so this is the tallest a notice '
            'gets and the case that could reach the bottom of the screen',
      );
      expect(
        notice.bottom,
        lessThan(navigationBar.top),
        reason: 'the notice must not cover or crowd the navigation bar',
      );
      expect(
        tester.takeException(),
        isNull,
        reason: 'the band lays out without overflowing or erroring',
      );

      await expireNotice(tester);
    });
  });

  group('lifecycle', () {
    testWidgets('a notice does not block the screen beneath it', (
      WidgetTester tester,
    ) async {
      final app = await pumpApp(tester);
      await publish(tester, app.container, copy: 'Saved.');

      // Something the notice does not cover, reached while it is showing. This
      // is the difference between "app-level" and "modal": the shell's
      // navigation bar is usable throughout.
      await tapDestination(tester, 'Profile');

      expect(find.widgetWithText(AppBar, 'PROFILE'), findsOneWidget);
      expect(
        find.byType(FeedbackNotice),
        findsOneWidget,
        reason:
            'one notice serves every route: a destination change must neither '
            'duplicate it nor take it away',
      );
      expect(find.text('Saved.'), findsOneWidget);

      await expireNotice(tester);
    });

    testWidgets('tapping the notice dismisses it', (WidgetTester tester) async {
      final app = await pumpApp(tester);
      await publish(tester, app.container, copy: 'Saved.');

      await tester.tap(find.byType(FeedbackNotice));
      await tester.pumpAndSettle();

      expect(find.byType(FeedbackNotice), findsNothing);
      expect(
        app.container.read(feedbackProvider),
        isNull,
        reason: 'dismissal goes through the channel, not around it',
      );
    });

    testWidgets('the notice dismisses itself after its time on screen', (
      WidgetTester tester,
    ) async {
      final app = await pumpApp(tester);
      await publish(tester, app.container, copy: 'Saved.');

      expect(find.byType(FeedbackNotice), findsOneWidget);

      await expireNotice(tester);

      expect(find.byType(FeedbackNotice), findsNothing);
      expect(app.container.read(feedbackProvider), isNull);
    });

    testWidgets('a second notice replaces the first rather than stacking', (
      WidgetTester tester,
    ) async {
      final app = await pumpApp(tester);
      await publish(
        tester,
        app.container,
        tone: FeedbackTone.success,
        copy: 'First.',
      );
      await publish(
        tester,
        app.container,
        tone: FeedbackTone.danger,
        copy: 'Second.',
      );

      expect(find.text('Second.'), findsOneWidget);
      expect(
        find.text('First.'),
        findsNothing,
        reason: 'a dismissed or replaced notice must not linger in the tree',
      );
      expect(find.byType(FeedbackNotice), findsOneWidget);

      await expireNotice(tester);
    });

    testWidgets('the same copy published twice is shown twice', (
      WidgetTester tester,
    ) async {
      // The sharp assertion for this lives in `feedback_controller_test.dart`
      // (two identical values are two changes). What this adds is that the
      // *presenter* is not holding on to the first one: an equal-but-new notice
      // is presented again rather than treated as already showing.
      final app = await pumpApp(tester);
      await publish(tester, app.container, copy: 'Saved.');

      await expireNotice(tester);
      expect(find.byType(FeedbackNotice), findsNothing);

      await publish(tester, app.container, copy: 'Saved.');
      expect(find.byType(FeedbackNotice), findsOneWidget);
      expect(find.text('Saved.'), findsOneWidget);

      await expireNotice(tester);
    });

    testWidgets('a dismissed notice is not replayed by an app-level rebuild', (
      WidgetTester tester,
    ) async {
      final app = await pumpApp(tester);
      await publish(tester, app.container, copy: 'Saved.');
      await expireNotice(tester);
      expect(find.byType(FeedbackNotice), findsNothing);

      // Rebuild the whole app: the same container and router, a new widget. This
      // is the shape a brightness change, a locale change or any rebuild of
      // `StashItApp` by its parent takes — `MaterialApp`'s builder runs again and
      // the host's element updates in place.
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: app.container,
          child: StashItApp(router: app.router),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byType(FeedbackNotice),
        findsNothing,
        reason:
            'a listener that fired on rebuild rather than on change would '
            're-present a notice the user has already seen and dismissed',
      );
    });

    testWidgets(
      'navigating repeatedly neither replays nor duplicates a notice',
      (WidgetTester tester) async {
        final app = await pumpApp(tester);
        await publish(tester, app.container, copy: 'Saved.');

        for (final destination in const ['Collections', 'Search', 'Inbox']) {
          await tapDestination(tester, destination);

          expect(find.byType(FeedbackNotice), findsOneWidget);
          expect(find.text('Saved.'), findsOneWidget);
        }

        await expireNotice(tester);
        expect(find.byType(FeedbackNotice), findsNothing);
      },
    );
  });

  group('the copy it draws', () {
    testWidgets('carries no decoration from the ambient error text style', (
      WidgetTester tester,
    ) async {
      // The host is mounted above the router, so the notice is the one piece of
      // text in the app with no `Material` ancestor. `MaterialApp` hands
      // `WidgetsApp` a deliberate *error* text style for exactly that case —
      // 48 px red monospace with a **double yellow underline**
      // (`material/app.dart`, `_errorTextStyle`) — and `Text` merges its own
      // style *over* the ambient one, so a face and size of our own still let the
      // underline and its colour through. That is the yellow underline this test
      // exists to keep out.
      //
      // Asserted on the **resolved** span the render object paints, not on the
      // `Text` widget's `style`: the widget's own style never carried the
      // decoration, so asserting on it could not fail for the reason this bug
      // existed.
      final app = await pumpApp(tester);
      await publish(tester, app.container, copy: 'Saved.');

      final paragraph = tester.renderObject<RenderParagraph>(
        find.text('Saved.'),
      );
      final style = (paragraph.text as TextSpan).style!;

      expect(
        style.decoration ?? TextDecoration.none,
        TextDecoration.none,
        reason: 'a fallback text style is not this band\'s typography',
      );
      expect(
        style.decorationColor,
        isNot(const Color(0xFFFFFF00)),
        reason:
            'the error style\'s yellow would show through a default underline',
      );
      expect(
        style.decorationStyle,
        isNot(TextDecorationStyle.double),
        reason: 'the double underline is the error style\'s signature',
      );
      expect(
        style.fontFamily,
        AppTypography.uiFamily,
        reason:
            'the copy keeps the app\'s UI face, not the error style\'s mono',
      );
      expect(style.color, AppTokens.light.textPrimary);
      expect(
        style.fontSize,
        AppTypography.meta.fontSize,
        reason: 'and the size the band chose, not the error style\'s 48 px',
      );

      await expireNotice(tester);
    });
  });

  group('theme integration', () {
    testWidgets('the notice follows the system brightness in the real app', (
      WidgetTester tester,
    ) async {
      // `AppTheme` leaves `themeMode` at its default, so the system decides
      // (`app_theme.dart`). Driving that choice here is what proves the host
      // resolves tokens per brightness rather than picking one palette.
      tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

      final app = await pumpApp(tester);
      await publish(
        tester,
        app.container,
        tone: FeedbackTone.success,
        copy: 'Saved.',
      );

      final decoration =
          tester
                  .widgetList<Container>(
                    find.descendant(
                      of: find.byType(FeedbackNotice),
                      matching: find.byType(Container),
                    ),
                  )
                  .firstWhere((container) => container.decoration != null)
                  .decoration!
              as BoxDecoration;

      expect(decoration.color, AppTokens.dark.successSoft);
      expect(
        decoration.color,
        isNot(AppTokens.light.successSoft),
        reason: 'the light palette would mean the brightness was ignored',
      );

      await expireNotice(tester);
    });
  });
}
