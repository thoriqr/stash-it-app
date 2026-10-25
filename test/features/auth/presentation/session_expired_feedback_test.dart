import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// `Override` is not part of flutter_riverpod's main export surface in 3.4.x.
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_it_app/app/app.dart';
import 'package:stash_it_app/app/network/network_providers.dart';
import 'package:stash_it_app/app/theme/app_theme.dart';
import 'package:stash_it_app/core/storage/secure_credential_store.dart';
import 'package:stash_it_app/features/auth/application/auth_state.dart';
import 'package:stash_it_app/features/auth/application/session_controller.dart';
import 'package:stash_it_app/features/auth/data/models/auth_tokens.dart';
import 'package:stash_it_app/features/auth/presentation/auth_entry_screen.dart';
import 'package:stash_it_app/features/auth/presentation/auth_messages.dart';
import 'package:stash_it_app/features/auth/presentation/sign_in_screen.dart';
import 'package:stash_it_app/shared/widgets/app_button.dart';

import '../../../support/fake_http.dart';
import '../../../support/saved_items_fixtures.dart';

/// Telling the user *why* they are on the auth entry screen.
///
/// A session can end while they are somewhere else entirely: a renewal the backend
/// refuses terminally clears the credentials, `AuthState` follows, and the router
/// moves them here. Without an explanation the entry screen gives no reason for
/// appearing, and the natural reading is that they did something wrong.
///
/// These drive the **real** graph — session controller, interceptor and the
/// router built by `appRouterProvider` — against a scripted transport, so the
/// message depends on the same path that produces it in the app. No socket is
/// opened.
///
/// **The app is pumped as [StashItApp] with no injected router**, which is the
/// production shape. That is load-bearing rather than stylistic: `StashItApp`
/// watches `appRouterProvider`, and the auth `refreshListenable` only delivers
/// while that provider is watched. Injecting a router — the seam
/// `auth_redirect_widget_test.dart` uses — skips the watch, and the redirect then
/// never fires. That test can get away with it because it only asserts states
/// that were true before the first transition; this file's subject *is* the
/// transition.
void main() {
  /// The entry screen's heading, used as its stable on-screen identity.
  const entryHeading = 'A place for things you find on the internet.';

  const accessKey = 'stash_it.auth.access_token';
  const refreshKey = 'stash_it.auth.refresh_token';
  const session = AuthTokens(
    accessToken: 'access-1',
    refreshToken: 'refresh-1',
  );

  late InMemorySecureStorage backend;
  late FakeHttpAdapter adapter;

  setUp(() {
    backend = InMemorySecureStorage();
    // The session goes into the **store**, not only into `restoredTokensProvider`,
    // because that is where the interceptor reads the bearer and the session
    // controller reads the refresh token from.
    backend.values[accessKey] = session.accessToken;
    backend.values[refreshKey] = session.refreshToken;
    adapter = FakeHttpAdapter();
  });

  /// The overrides a signed-in container needs. The router comes from the
  /// provider, so `StashItApp` builds it exactly as `main` does.
  List<Override> signedIn() => [
    credentialStoreProvider.overrideWithValue(SecureCredentialStore(backend)),
    restoredTokensProvider.overrideWithValue(session),
  ];

  /// The Inbox's listing, which issues the first protected request and so
  /// surfaces the expired access token.
  void scriptExpiredListing() {
    adapter.on(
      '/saved-items',
      status: 401,
      body: errorBody('ACCESS_TOKEN_EXPIRED'),
    );
  }

  void scriptRenewal(int status, String code) {
    adapter.on('/auth/refresh', status: status, body: errorBody(code));
  }

  Future<ProviderContainer> pumpApp(WidgetTester tester) async {
    final container = ProviderContainer(
      overrides: signedIn(),
      // Not the subject here, but Riverpod would otherwise leave retry timers
      // pending past the end of a test whose listing fails on purpose.
      retry: (_, _) => null,
    );
    addTearDown(container.dispose);
    container.read(appDioProvider).httpClientAdapter = adapter;
    container.read(refreshDioProvider).httpClientAdapter = adapter;

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const StashItApp(),
      ),
    );
    await tester.pumpAndSettle();
    return container;
  }

  /// Whether anything is still owed an explanation of a session ending.
  bool unannounced(ProviderContainer container) =>
      container.read(sessionControllerProvider.notifier).consumeSessionEnded();

  group('a terminal session-ending outcome', () {
    for (final code in const [
      'REFRESH_TOKEN_INVALID',
      'SESSION_REVOKED',
      'SESSION_EXPIRED',
    ]) {
      testWidgets(
        '$code redirects to the auth entry screen and explains itself once',
        (tester) async {
          scriptExpiredListing();
          scriptRenewal(401, code);

          final container = await pumpApp(tester);

          // The router did its job...
          expect(find.text(entryHeading), findsOneWidget);
          expect(find.byType(NavigationBar), findsNothing);
          // ...and the reason came with it, exactly once.
          expect(find.text(sessionEndedMessage), findsOneWidget);
          expect(
            unannounced(container),
            isFalse,
            reason: 'the reason is consumed when the screen reads it',
          );
        },
      );
    }

    testWidgets('a rebuild does not repeat the message', (tester) async {
      scriptExpiredListing();
      scriptRenewal(401, 'SESSION_REVOKED');

      final container = await pumpApp(tester);
      expect(find.text(sessionEndedMessage), findsOneWidget);

      // Same widget, same position: the State survives, so initState does not
      // run again and nothing is re-derived.
      await tester.pump();
      await tester.pumpAndSettle();
      expect(find.text(sessionEndedMessage), findsOneWidget);

      // A fresh mount is the stronger case — a new State runs initState again,
      // and only the consumed flag stops the message coming back.
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            home: const AuthEntryScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.text(sessionEndedMessage),
        findsNothing,
        reason:
            'the reason was consumed, so a later visit is a plain entry screen',
      );
      expect(find.text(entryHeading), findsOneWidget);
    });
  });

  group('outcomes that must NOT claim the session ended', () {
    testWidgets('an ambiguous renewal failure produces no message', (
      tester,
    ) async {
      // The server failed without the client learning whether the rotation
      // committed, so nothing ended and nothing is owed an explanation. The
      // session is deliberately kept — see `ApiFailureRefreshUncertain`.
      scriptExpiredListing();
      scriptRenewal(500, 'INTERNAL_SERVER_ERROR');

      final container = await pumpApp(tester);

      expect(unannounced(container), isFalse);
      expect(
        container.read(authStateProvider),
        AuthStatus.signedIn,
        reason: 'an ambiguous failure must not sign the user out',
      );
      expect(find.text(entryHeading), findsNothing);
      expect(find.text(sessionEndedMessage), findsNothing);
      // The evidence is kept, which is the whole point of the policy.
      expect(backend.values[refreshKey], 'refresh-1');
    });

    testWidgets('a transport failure produces no message', (tester) async {
      scriptExpiredListing();
      adapter.on('/auth/refresh', status: 0, body: '');

      final container = await pumpApp(tester);

      expect(unannounced(container), isFalse);
      expect(container.read(authStateProvider), AuthStatus.signedIn);
      expect(find.text(sessionEndedMessage), findsNothing);
    });

    testWidgets('a deliberate sign-out is not reported as an expiry', (
      tester,
    ) async {
      adapter.on('/saved-items', body: SavedItemsFixtures.emptyPage());
      adapter.on('/auth/logout', body: {'data': null, 'message': 'bye'});

      final container = await pumpApp(tester);
      expect(container.read(authStateProvider), AuthStatus.signedIn);

      // Not awaited. A `testWidgets` body runs in the fake-async zone, so awaiting
      // a Dio round-trip inline deadlocks; the project's pattern is to start the
      // action and let `pumpAndSettle` drive it to completion.
      unawaited(container.read(authStateProvider.notifier).signOut());
      await tester.pumpAndSettle();

      expect(find.text(entryHeading), findsOneWidget);
      expect(
        unannounced(container),
        isFalse,
        reason: 'asking to be signed out is not an expiry',
      );
      expect(find.text(sessionEndedMessage), findsNothing);
    });
  });

  group('the treatment matches the design system', () {
    // `design-system.md` §6.5 files **expiry** under Warning
    // (`warning-soft` + `warning-border`) and reserves the danger treatment for a
    // **known failure**. A session that lapsed is not something the user did
    // wrong, so it must not be presented as if it were.

    /// The band carrying [message]: the nearest ancestor `Container` whose
    /// decoration is coloured *and* bordered. Identified by its shape rather
    /// than by its private type, which a test cannot name.
    Container bandWidget(WidgetTester tester, String message) => tester
        .widgetList<Container>(
          find.ancestor(
            of: find.text(message),
            matching: find.byType(Container),
          ),
        )
        .firstWhere((c) {
          final d = c.decoration;
          return d is BoxDecoration && d.color != null && d.border != null;
        });

    ({Color fill, Color border}) bandFor(WidgetTester tester, String message) {
      final decoration =
          bandWidget(tester, message).decoration! as BoxDecoration;
      return (
        fill: decoration.color!,
        border: (decoration.border! as Border).top.color,
      );
    }

    /// The small mark at the leading edge of the band.
    ///
    /// A **sibling** of the message text rather than an ancestor, so it is found
    /// by descending into the band. The mark is the descendant `Container`
    /// carrying a `color` of its own: `Container` keeps `color` in its own field
    /// and resolves it into a decoration in `build`, so the widget's `decoration`
    /// is still null and it is distinguishable from the band above it.
    Color markFor(WidgetTester tester, String message) => tester
        .widgetList<Container>(
          find.descendant(
            of: find.byWidget(bandWidget(tester, message)),
            matching: find.byType(Container),
          ),
        )
        .firstWhere((c) => c.decoration == null && c.color != null)
        .color!;

    Future<ProviderContainer> pumpExpiredSession(WidgetTester tester) async {
      scriptExpiredListing();
      scriptRenewal(401, 'SESSION_REVOKED');
      return pumpApp(tester);
    }

    Future<ProviderContainer> pumpInvalidCredentials(
      WidgetTester tester,
    ) async {
      adapter.on(
        '/auth/login',
        status: 401,
        body: errorBody('INVALID_CREDENTIALS'),
      );

      final container = ProviderContainer(
        overrides: [
          credentialStoreProvider.overrideWithValue(
            SecureCredentialStore(backend),
          ),
          restoredTokensProvider.overrideWithValue(null),
        ],
      );
      addTearDown(container.dispose);
      container.read(appDioProvider).httpClientAdapter = adapter;
      container.read(refreshDioProvider).httpClientAdapter = adapter;

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            home: const SignInScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'a@b.c');
      await tester.enterText(find.byType(TextField).last, 'password12');
      await tester.tap(find.widgetWithText(AppButton, 'Sign in'));
      await tester.pumpAndSettle();
      return container;
    }

    testWidgets('an expired session wears the warning treatment', (
      tester,
    ) async {
      await pumpExpiredSession(tester);

      final band = bandFor(tester, sessionEndedMessage);
      expect(band.fill, AppTokens.light.warningSoft);
      expect(band.border, AppTokens.light.warningBorder);
      expect(
        markFor(tester, sessionEndedMessage),
        AppTokens.light.warning,
        reason: 'the Warning row carries a filled `--warning` mark',
      );
      expect(
        band.fill,
        isNot(AppTokens.light.dangerSoft),
        reason: 'an expiry is not a failure the user caused',
      );
    });

    testWidgets('invalid credentials keep the danger treatment', (
      tester,
    ) async {
      await pumpInvalidCredentials(tester);

      const message = "That doesn't look like a valid email or password.";
      final band = bandFor(tester, message);
      expect(band.fill, AppTokens.light.dangerSoft);
      expect(band.border, AppTokens.light.dangerBorder);
      expect(markFor(tester, message), AppTokens.light.danger);
      expect(band.fill, isNot(AppTokens.light.warningSoft));
    });

    testWidgets('the two treatments are genuinely different colours', (
      tester,
    ) async {
      await pumpExpiredSession(tester);
      final expiry = bandFor(tester, sessionEndedMessage);

      // The same screen, a second run, now showing the other failure.
      backend = InMemorySecureStorage();
      adapter = FakeHttpAdapter();
      await pumpInvalidCredentials(tester);

      const message = "That doesn't look like a valid email or password.";
      final failure = bandFor(tester, message);

      expect(expiry.fill, isNot(failure.fill));
      expect(expiry.border, isNot(failure.border));
    });
  });

  group('ordinary sign-in feedback is unaffected', () {
    testWidgets('invalid credentials show their own message, not this one', (
      tester,
    ) async {
      adapter.on(
        '/auth/login',
        status: 401,
        body: errorBody('INVALID_CREDENTIALS'),
      );

      final container = ProviderContainer(
        overrides: [
          credentialStoreProvider.overrideWithValue(
            SecureCredentialStore(backend),
          ),
          restoredTokensProvider.overrideWithValue(null),
        ],
      );
      addTearDown(container.dispose);
      container.read(appDioProvider).httpClientAdapter = adapter;
      container.read(refreshDioProvider).httpClientAdapter = adapter;

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            home: const SignInScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'a@b.c');
      await tester.enterText(find.byType(TextField).last, 'password12');
      await tester.tap(find.widgetWithText(AppButton, 'Sign in'));
      await tester.pumpAndSettle();

      expect(
        find.text("That doesn't look like a valid email or password."),
        findsOneWidget,
      );
      expect(
        find.text(sessionEndedMessage),
        findsNothing,
        reason: 'a wrong password is not an expired session',
      );
    });

    test('nothing is owed an explanation before any session ends', () {
      final container = ProviderContainer(overrides: signedIn());
      addTearDown(container.dispose);

      final controller = container.read(sessionControllerProvider.notifier);

      expect(controller.consumeSessionEnded(), isFalse);
      expect(
        controller.consumeSessionEnded(),
        isFalse,
        reason: 'reading twice must not invent a second event',
      );
    });
  });
}
