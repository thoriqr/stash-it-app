import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// `Override` is not part of flutter_riverpod's main export surface in 3.4.x.
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_it_app/app/app.dart';
import 'package:stash_it_app/app/network/network_providers.dart';
import 'package:stash_it_app/app/router/app_router.dart';
import 'package:stash_it_app/app/router/routes.dart';
import 'package:stash_it_app/core/storage/secure_credential_store.dart';
import 'package:stash_it_app/features/auth/application/auth_state.dart';
import 'package:stash_it_app/features/auth/application/session_controller.dart';
import 'package:stash_it_app/features/auth/data/models/auth_tokens.dart';
import 'package:stash_it_app/features/pending_urls/data/pending_url_store.dart';
import 'package:stash_it_app/shared/widgets/app_button.dart';

import '../support/fake_http.dart';
import '../support/pending_urls.dart';
import '../support/saved_items_fixtures.dart';

void main() {
  /// The entry screen's heading, used as its stable on-screen identity.
  const entryHeading = 'A place for things you find on the internet.';

  /// The sign-in form's heading.
  const formHeading = 'Sign in to Stash It';

  /// The registration form's heading.
  const signUpHeading = 'Create your account';

  /// Overrides for a container that needs the auth state and nothing else.
  ///
  /// The credential store is required because the auth status is *derived from
  /// the session*, and the session holds it. `bootstrap` always supplies one, so
  /// a container without it is not a shape the app can be in.
  ///
  /// The container is `UnmanagedProviderScope` so nothing is disposed
  /// implicitly: [appRouterProvider] creates a `GoRouter` that holds a listener
  /// on the auth state, and disposing the container out from under it is what
  /// makes router tests leak between cases.
  List<Override> authOverrides(AuthStatus status) => [
    credentialStoreProvider.overrideWithValue(
      SecureCredentialStore(InMemorySecureStorage()),
    ),
    restoredTokensProvider.overrideWithValue(
      status == AuthStatus.signedIn
          ? const AuthTokens(accessToken: 'a', refreshToken: 'r')
          : null,
    ),
  ];

  /// Pumps the real app with the real router.
  ///
  /// The router comes from [appRouterProvider] rather than
  /// [createAppRouter], because only the provider-built one carries the redirect
  /// and the auth `refreshListenable` — which is exactly what is under test.
  Future<void> pumpApp(
    WidgetTester tester,
    AuthStatus status, {
    String initialLocation = AppRoutes.inbox,
  }) async {
    final adapter = FakeHttpAdapter();

    // The Inbox reads `GET /saved-items` now, so a signed-in container needs a
    // scripted transport. `AGENTS.md` §5: no test opens a socket.
    adapter.on('/saved-items', body: SavedItemsFixtures.emptyPage());

    // The device-local list is independent of the auth status, but the auth
    // entry screen and Inbox both watch its count, so every container needs a
    // real in-memory store.
    final pendingStore = await testPendingUrlStore();

    // `retry: (_, _) => null` because Riverpod 3 retries a failed provider up to
    // ten times with backoff; an unscripted listing would leave one of those
    // timers pending past the end of the test body.
    final container = ProviderContainer(
      overrides: [
        ...authOverrides(status),
        pendingUrlStoreProvider.overrideWithValue(pendingStore),
      ],
      retry: (_, _) => null,
    );
    addTearDown(container.dispose);

    container.read(appDioProvider).httpClientAdapter = adapter;
    container.read(refreshDioProvider).httpClientAdapter = adapter;

    final router = container.read(appRouterProvider);
    addTearDown(router.dispose);

    router.go(initialLocation);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: StashItApp(router: router),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('a signed-out user is redirected to the auth entry screen', (
    tester,
  ) async {
    await pumpApp(tester, AuthStatus.signedOut);

    expect(find.text(entryHeading), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets(
    'a signed-out user reaching /profile is redirected to the auth entry screen',
    (tester) async {
      await pumpApp(
        tester,
        AuthStatus.signedOut,
        initialLocation: AppRoutes.profile,
      );

      expect(find.text(entryHeading), findsOneWidget);
    },
  );

  testWidgets(
    'a signed-out user reaching /settings is redirected to the auth entry screen',
    (tester) async {
      await pumpApp(
        tester,
        AuthStatus.signedOut,
        initialLocation: AppRoutes.settings,
      );

      expect(find.text(entryHeading), findsOneWidget);
    },
  );

  testWidgets(
    'a signed-out user reaching a saved-item detail is redirected to the auth entry screen',
    (tester) async {
      await pumpApp(
        tester,
        AuthStatus.signedOut,
        initialLocation: AppRoutes.savedItemDetail('item-1'),
      );

      expect(find.text(entryHeading), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
    },
  );

  testWidgets('a signed-out user may stay on the auth entry screen', (
    tester,
  ) async {
    await pumpApp(
      tester,
      AuthStatus.signedOut,
      initialLocation: AppRoutes.auth,
    );

    expect(find.text(entryHeading), findsOneWidget);
    expect(find.text(formHeading), findsNothing);
  });

  testWidgets('a signed-out user may stay on the sign-in form', (tester) async {
    await pumpApp(
      tester,
      AuthStatus.signedOut,
      initialLocation: AppRoutes.signIn,
    );

    expect(find.text(formHeading), findsOneWidget);
    expect(find.text(entryHeading), findsNothing);
  });

  testWidgets('a signed-out user may stay on the sign-up form', (tester) async {
    await pumpApp(
      tester,
      AuthStatus.signedOut,
      initialLocation: AppRoutes.signUp,
    );

    expect(find.text(signUpHeading), findsOneWidget);
    expect(find.text(entryHeading), findsNothing);
    expect(find.text(formHeading), findsNothing);
  });

  testWidgets('a signed-out user may open the device-local URL list', (
    tester,
  ) async {
    await pumpApp(
      tester,
      AuthStatus.signedOut,
      initialLocation: AppRoutes.savedOnDevice,
    );

    expect(find.text('SAVED ON THIS DEVICE'), findsOneWidget);
    expect(find.text('Nothing saved on this device'), findsOneWidget);
    expect(find.text(entryHeading), findsNothing);
    expect(find.text(formHeading), findsNothing);
  });

  testWidgets('a signed-in user may open the device-local URL list', (
    tester,
  ) async {
    await pumpApp(
      tester,
      AuthStatus.signedIn,
      initialLocation: AppRoutes.savedOnDevice,
    );

    expect(find.text('SAVED ON THIS DEVICE'), findsOneWidget);
    expect(find.text('Nothing saved on this device'), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets('tapping Sign in opens the form without bouncing back', (
    tester,
  ) async {
    await pumpApp(
      tester,
      AuthStatus.signedOut,
      initialLocation: AppRoutes.auth,
    );

    await tester.tap(find.widgetWithText(AppButton, 'Sign in'));
    await tester.pumpAndSettle();

    expect(find.text(formHeading), findsOneWidget);
    expect(find.text(entryHeading), findsNothing);
  });

  testWidgets(
    'tapping Create an account opens the sign-up form without bouncing back',
    (tester) async {
      await pumpApp(
        tester,
        AuthStatus.signedOut,
        initialLocation: AppRoutes.auth,
      );

      await tester.tap(find.widgetWithText(AppButton, 'Create an account'));
      await tester.pumpAndSettle();

      expect(find.text(signUpHeading), findsOneWidget);
      expect(find.text(entryHeading), findsNothing);
      expect(find.text(formHeading), findsNothing);
    },
  );

  testWidgets('the sign-up form keeps the sign-in path reachable', (
    tester,
  ) async {
    await pumpApp(
      tester,
      AuthStatus.signedOut,
      initialLocation: AppRoutes.auth,
    );

    await tester.tap(find.widgetWithText(AppButton, 'Create an account'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(AppButton, 'Sign in'));
    await tester.pumpAndSettle();

    expect(find.text(formHeading), findsOneWidget);
    expect(find.text(signUpHeading), findsNothing);
  });

  testWidgets('a signed-in user sees the shell', (tester) async {
    await pumpApp(tester, AuthStatus.signedIn);

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text(formHeading), findsNothing);
    expect(find.text(entryHeading), findsNothing);
  });

  testWidgets('a signed-in user on /auth is sent into the app', (tester) async {
    await pumpApp(tester, AuthStatus.signedIn, initialLocation: AppRoutes.auth);

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text(entryHeading), findsNothing);
  });

  testWidgets('a signed-in user on /sign-in is sent into the app', (
    tester,
  ) async {
    await pumpApp(
      tester,
      AuthStatus.signedIn,
      initialLocation: AppRoutes.signIn,
    );

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text(formHeading), findsNothing);
  });

  testWidgets('a signed-in user on /sign-up is sent into the app', (
    tester,
  ) async {
    await pumpApp(
      tester,
      AuthStatus.signedIn,
      initialLocation: AppRoutes.signUp,
    );

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text(signUpHeading), findsNothing);
  });

  testWidgets('a signed-out user can open PIN entry with a real UUID', (
    tester,
  ) async {
    const uuid = '01a175e6-4a20-7649-b9b0-aa3b26237074';
    final adapter = FakeHttpAdapter();
    adapter.onMethod(
      'GET',
      '/auth/register/verification/$uuid',
      status: 200,
      body: {
        'data': {
          'verification_id': uuid,
          'status': 'pending',
          'pin_issued': true,
          'resend_in_seconds': 0,
        },
        'message': 'verification retrieved',
      },
    );

    final container = ProviderContainer(
      overrides: authOverrides(AuthStatus.signedOut),
      retry: (_, _) => null,
    );
    addTearDown(container.dispose);
    container.read(appDioProvider).httpClientAdapter = adapter;
    container.read(refreshDioProvider).httpClientAdapter = adapter;

    final router = container.read(appRouterProvider);
    addTearDown(router.dispose);
    router.go('/sign-up/verify/$uuid');

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: StashItApp(router: router),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Enter your PIN'), findsOneWidget);
    expect(find.widgetWithText(AppButton, 'Resend PIN'), findsOneWidget);
  });
}
