import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// `Override` is not part of flutter_riverpod's main export surface in 3.4.x.
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_it_app/app/app.dart';
import 'package:stash_it_app/app/router/app_router.dart';
import 'package:stash_it_app/app/router/routes.dart';
import 'package:stash_it_app/core/storage/secure_credential_store.dart';
import 'package:stash_it_app/features/auth/application/auth_state.dart';
import 'package:stash_it_app/features/auth/application/session_controller.dart';
import 'package:stash_it_app/features/auth/data/models/auth_tokens.dart';

import '../support/fake_http.dart';

void main() {
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
    final container = ProviderContainer(overrides: authOverrides(status));
    addTearDown(container.dispose);

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

  testWidgets('a signed-out user is redirected to sign-in', (tester) async {
    await pumpApp(tester, AuthStatus.signedOut);

    expect(find.text('Sign in to Stash It'), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets('a signed-out user reaching /profile is redirected to sign-in', (
    tester,
  ) async {
    await pumpApp(
      tester,
      AuthStatus.signedOut,
      initialLocation: AppRoutes.profile,
    );

    expect(find.text('Sign in to Stash It'), findsOneWidget);
  });

  testWidgets('a signed-in user sees the shell', (tester) async {
    await pumpApp(tester, AuthStatus.signedIn);

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Sign in to Stash It'), findsNothing);
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
    expect(find.text('Sign in to Stash It'), findsNothing);
  });
}
