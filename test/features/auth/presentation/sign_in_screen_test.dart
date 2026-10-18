import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_it_app/app/network/network_providers.dart';
import 'package:stash_it_app/app/theme/app_theme.dart';
import 'package:stash_it_app/core/storage/secure_credential_store.dart';
import 'package:stash_it_app/features/auth/application/auth_state.dart';
import 'package:stash_it_app/features/auth/application/session_controller.dart';
import 'package:stash_it_app/features/auth/presentation/sign_in_screen.dart';
import 'package:stash_it_app/shared/widgets/app_button.dart';
import 'package:stash_it_app/shared/widgets/app_field.dart';

import '../../../support/fake_http.dart';

/// Manual sign-in, under the approved design system.
///
/// Covers the **behaviour** that must survive the restyle — the validators, the
/// error mapping, the dismiss-not-retry rule — and asserts on what the user can
/// see. No socket is opened: the transport is scripted, so the interceptor and
/// the response mapping run exactly as they do in production.
void main() {
  late InMemorySecureStorage backend;
  late FakeHttpAdapter adapter;
  late ProviderContainer container;

  setUp(() {
    backend = InMemorySecureStorage();
    adapter = FakeHttpAdapter();
    container = ProviderContainer(
      overrides: [
        credentialStoreProvider.overrideWithValue(
          SecureCredentialStore(backend),
        ),
        restoredTokensProvider.overrideWithValue(null),
      ],
      retry: (_, _) => null,
    );
    addTearDown(container.dispose);
  });

  /// Pumps the screen with the app's real themes, so the styling under test is
  /// the one that ships.
  Future<void> pumpSignIn(WidgetTester tester) async {
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
  }

  void scriptSuccessfulLogin() {
    adapter.on(
      '/auth/login',
      body: {
        'data': {
          'access_token': 'access-1',
          'refresh_token': 'refresh-1',
          'user': {'id': 'u1', 'email': 'a@b.c', 'display_name': 'Test'},
        },
        'message': 'login successful',
      },
    );
  }

  /// Fills both fields and taps the primary action.
  Future<void> submit(WidgetTester tester) async {
    await tester.enterText(
      find.byType(TextFormField).at(0),
      'reader@example.com',
    );
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'correct-horse-battery-staple',
    );
    await tester.tap(find.widgetWithText(AppButton, 'Sign in'));
    await tester.pumpAndSettle();
  }

  group('layout', () {
    testWidgets('shows the heading and a labelled field per credential', (
      tester,
    ) async {
      await pumpSignIn(tester);

      expect(find.text('Sign in to Stash It'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2));

      // The labels sit above the fields, per the specification.
      final labelY = tester.getTopLeft(find.text('Email')).dy;
      final fieldY = tester.getTopLeft(find.byType(TextFormField).first).dy;
      expect(labelY, lessThan(fieldY));
    });

    testWidgets('auth carries no bottom navigation', (tester) async {
      // Auth sits outside the four destinations (D1), so the shell's navigation
      // bar must not appear here.
      await pumpSignIn(tester);
      expect(find.byType(NavigationBar), findsNothing);
    });

    testWidgets('the password field is obscured and the email field is not', (
      tester,
    ) async {
      await pumpSignIn(tester);

      expect(
        tester.widget<TextField>(find.byType(TextField).at(0)).obscureText,
        isFalse,
      );
      expect(
        tester.widget<TextField>(find.byType(TextField).at(1)).obscureText,
        isTrue,
      );
    });

    testWidgets('reads the tokens of the theme in force', (tester) async {
      tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

      await pumpSignIn(tester);

      final context = tester.element(find.text('Sign in to Stash It'));
      expect(
        AppTheme.tokensOf(context).accent,
        AppTokens.dark.accent,
        reason: 'a dark platform must not render light-token colours',
      );
    });
  });

  group('client-side validation', () {
    testWidgets('an empty form does not reach the network', (tester) async {
      await pumpSignIn(tester);

      await tester.tap(find.widgetWithText(AppButton, 'Sign in'));
      await tester.pumpAndSettle();

      expect(find.text('Enter your email address.'), findsOneWidget);
      expect(adapter.requests, isEmpty);
    });

    testWidgets('a malformed address is caught before the network', (
      tester,
    ) async {
      await pumpSignIn(tester);

      await tester.enterText(find.byType(TextFormField).at(0), 'not-an-email');
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'correct-horse-battery-staple',
      );
      await tester.tap(find.widgetWithText(AppButton, 'Sign in'));
      await tester.pumpAndSettle();

      expect(find.text('Enter a valid email address.'), findsOneWidget);
      expect(adapter.requests, isEmpty);
    });

    testWidgets('a short password is caught before the network', (
      tester,
    ) async {
      await pumpSignIn(tester);

      await tester.enterText(
        find.byType(TextFormField).at(0),
        'reader@example.com',
      );
      await tester.enterText(find.byType(TextFormField).at(1), 'short');
      await tester.tap(find.widgetWithText(AppButton, 'Sign in'));
      await tester.pumpAndSettle();

      expect(
        find.text('Your password is at least 8 characters.'),
        findsOneWidget,
      );
      expect(adapter.requests, isEmpty);
    });
  });

  group('sign-in', () {
    testWidgets('a successful attempt adopts the session and stores both '
        'credentials', (tester) async {
      await pumpSignIn(tester);
      scriptSuccessfulLogin();

      await submit(tester);

      expect(container.read(authStateProvider), AuthStatus.signedIn);
      expect(backend.values['stash_it.auth.access_token'], 'access-1');
      expect(backend.values['stash_it.auth.refresh_token'], 'refresh-1');
      expect(container.read(sessionControllerProvider), isNotNull);
    });

    testWidgets('a refused sign-in stays signed out and stores nothing', (
      tester,
    ) async {
      await pumpSignIn(tester);
      adapter.on(
        '/auth/login',
        status: 401,
        body: errorBody('INVALID_CREDENTIALS'),
      );

      await submit(tester);

      expect(container.read(authStateProvider), AuthStatus.signedOut);
      expect(backend.values, isEmpty);
    });

    testWidgets('a failure is shown in client copy, never the server message', (
      tester,
    ) async {
      await pumpSignIn(tester);
      adapter.on(
        '/auth/login',
        status: 401,
        body: errorBody('INVALID_CREDENTIALS'),
      );

      await submit(tester);

      // [D22] the copy is selected from the typed failure, not from
      // `error.message` — which the fake sets to something no user should see.
      expect(
        find.text("That doesn't look like a valid email or password."),
        findsOneWidget,
      );
      expect(find.textContaining('redacted for tests'), findsNothing);
    });

    testWidgets('dismissing a failure clears it without retrying', (
      tester,
    ) async {
      await pumpSignIn(tester);
      adapter.on(
        '/auth/login',
        status: 401,
        body: errorBody('INVALID_CREDENTIALS'),
      );

      await submit(tester);
      final attemptsAfterFirst = adapter.countFor('/auth/login');

      await tester.tap(find.widgetWithText(TextButton, 'Dismiss'));
      await tester.pumpAndSettle();

      expect(
        find.text("That doesn't look like a valid email or password."),
        findsNothing,
      );
      expect(
        adapter.countFor('/auth/login'),
        attemptsAfterFirst,
        reason:
            'a dismissal is not a retry: retrying the same credentials would '
            'spend another attempt against the budget that just refused one',
      );
    });

    testWidgets('a rate-limited attempt shows the countdown the server sent', (
      tester,
    ) async {
      await pumpSignIn(tester);
      // The mapper branches on the backend *code*, never the status, so the code
      // is what has to be right here.
      adapter.on(
        '/auth/login',
        status: 429,
        body: errorBody('LOGIN_RATE_LIMIT_EXCEEDED'),
        headers: {
          'retry-after': ['42'],
        },
      );

      await submit(tester);

      expect(
        find.text('Too many attempts. Try again in 42 seconds.'),
        findsOneWidget,
      );
    });

    testWidgets('a rate-limited attempt without a server countdown invents '
        'none', (tester) async {
      await pumpSignIn(tester);
      adapter.on(
        '/auth/login',
        status: 429,
        body: errorBody('IP_RATE_LIMIT_EXCEEDED'),
      );

      await submit(tester);

      expect(
        find.text('Too many attempts. Try again shortly.'),
        findsOneWidget,
      );
    });

    testWidgets('the form is disabled while a sign-in is in flight', (
      tester,
    ) async {
      await pumpSignIn(tester);
      adapter.onBlocking(
        '/auth/login',
        const FakeReply(200, {
          'data': {
            'access_token': 'a',
            'refresh_token': 'r',
            'user': {'id': 'u1', 'email': 'a@b.c', 'display_name': 'Test'},
          },
          'message': 'login successful',
        }),
      );

      await tester.enterText(
        find.byType(TextFormField).at(0),
        'reader@example.com',
      );
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'correct-horse-battery-staple',
      );
      await tester.tap(find.widgetWithText(AppButton, 'Sign in'));
      await tester.pump();

      // Found by type, not by label: a busy button replaces its label with a
      // spinner, so `widgetWithText` would find nothing at exactly the moment
      // this test needs to look.
      final button = tester.widget<AppButton>(find.byType(AppButton));
      expect(button.busy, isTrue);
      expect(
        button.onPressed,
        isNotNull,
        reason: 'the handler stays; `busy` is what suppresses the tap',
      );
      expect(
        tester.widgetList<AppField>(find.byType(AppField)).first.enabled,
        isFalse,
        reason: 'the credentials cannot be edited mid-flight',
      );

      adapter.releaseBlocked();
      await tester.pumpAndSettle();
    });
    testWidgets('a long failure message wraps without clipping or overflowing', (
      tester,
    ) async {
      // A narrow phone, and the longest copy this screen produces. The message
      // is the flexible child and Dismiss is not, so the text wraps rather than
      // the row overflowing.
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await pumpSignIn(tester);
      adapter.on(
        '/auth/login',
        status: 429,
        body: errorBody('LOGIN_RATE_LIMIT_EXCEEDED'),
        headers: {
          'retry-after': ['42'],
        },
      );

      await submit(tester);

      expect(
        find.text('Too many attempts. Try again in 42 seconds.'),
        findsOneWidget,
      );
      expect(find.widgetWithText(TextButton, 'Dismiss'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('the failure band groups its message and dismiss action', (
      tester,
    ) async {
      // They were stacked, and Material's 48 px minimum target made the dismiss
      // row taller than the sentence above it — roughly a hundred pixels for a
      // one-line failure, with an empty gap under the text.
      await pumpSignIn(tester);
      adapter.on(
        '/auth/login',
        status: 401,
        body: errorBody('INVALID_CREDENTIALS'),
      );
      await submit(tester);

      final message = tester.getRect(
        find.text("That doesn't look like a valid email or password."),
      );
      final dismiss = tester.getRect(
        find.widgetWithText(TextButton, 'Dismiss'),
      );

      // Vertical intersection only: they sit side by side, so they deliberately do
      // not overlap horizontally.
      final sharesRow =
          message.top < dismiss.bottom && dismiss.top < message.bottom;

      expect(
        sharesRow,
        isTrue,
        reason: 'Dismiss must share the message\'s row, not sit below it',
      );
      expect(
        dismiss.height,
        lessThan(48),
        reason: 'a dismiss target inside a message band need not be 48 px tall',
      );
      expect(
        dismiss.top - message.top,
        lessThan(message.height),
        reason: 'Dismiss is aligned to the message, not parked below it',
      );
    });
  });
}
