import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stash_it_app/app/router/routes.dart';
import 'package:stash_it_app/app/theme/app_theme.dart';
import 'package:stash_it_app/core/storage/secure_credential_store.dart';
import 'package:stash_it_app/features/auth/application/session_controller.dart';
import 'package:stash_it_app/features/auth/data/models/auth_tokens.dart';
import 'package:stash_it_app/features/pending_urls/data/pending_url_store.dart';
import 'package:stash_it_app/features/pending_urls/domain/pending_url.dart';
import 'package:stash_it_app/features/pending_urls/presentation/pending_urls_screen.dart';
import 'package:stash_it_app/shared/widgets/app_button.dart';

import '../../../support/fake_http.dart';
import '../../../support/pending_urls.dart';

class _FailingReadStore extends PendingUrlStore {
  _FailingReadStore(super.preferences);

  int _remainingFailures = 1;

  @override
  Future<PendingUrlSnapshot> readAll() async {
    if (_remainingFailures > 0) {
      _remainingFailures--;
      throw StateError('simulated read failure');
    }
    return PendingUrlSnapshot.empty;
  }
}

void main() {
  const url = 'https://example.com/articles/crdts-explained';

  Future<ProviderContainer> makeContainer(
    PendingUrlStore store, {
    AuthTokens? session,
  }) async {
    final backend = InMemorySecureStorage();
    final credentials = SecureCredentialStore(backend);
    if (session != null) await credentials.write(session);

    final container = ProviderContainer(
      overrides: [
        credentialStoreProvider.overrideWithValue(credentials),
        restoredTokensProvider.overrideWithValue(session),
        pendingUrlStoreProvider.overrideWithValue(store),
      ],
      retry: (_, _) => null,
    );
    addTearDown(container.dispose);
    return container;
  }

  Future<void> pumpScreen(
    WidgetTester tester,
    ProviderContainer container, {
    GoRouter? router,
  }) async {
    final app = router == null
        ? MaterialApp(
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            home: const PendingUrlsScreen(),
          )
        : MaterialApp.router(
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            routerConfig: router,
          );

    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: app),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows the empty state when nothing is kept', (tester) async {
    final store = await testPendingUrlStore();
    final container = await makeContainer(store);

    await pumpScreen(tester, container);

    expect(find.text('SAVED ON THIS DEVICE'), findsOneWidget);
    expect(find.text('Nothing saved on this device'), findsOneWidget);
    expect(find.byType(AppButton), findsNothing);
  });

  testWidgets('lists URLs and marks an unconfirmed save', (tester) async {
    final twoDaysAgo = DateTime.now().toUtc().subtract(const Duration(days: 2));
    final store = await testPendingUrlStore(now: () => twoDaysAgo);
    await store.upsert(url: url, uncertain: true);
    await store.upsert(
      url: 'https://example.com/another?x=1',
      uncertain: false,
    );
    final container = await makeContainer(store);

    await pumpScreen(tester, container);

    expect(find.text(url), findsOneWidget);
    expect(find.text('https://example.com/another?x=1'), findsOneWidget);
    expect(find.textContaining('Kept 2 days ago'), findsNWidgets(2));
    expect(find.text('Save not confirmed'), findsOneWidget);
    expect(find.byType(AppButton), findsNothing);
  });

  testWidgets('shows an error and can retry', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final store = _FailingReadStore(preferences);
    final container = await makeContainer(store);

    await pumpScreen(tester, container);

    expect(
      find.text("We couldn't read the links saved on this device."),
      findsOneWidget,
    );
    expect(find.widgetWithText(AppButton, 'Retry'), findsOneWidget);

    await tester.tap(find.widgetWithText(AppButton, 'Retry'));
    await tester.pumpAndSettle();

    expect(find.text('Nothing saved on this device'), findsOneWidget);
    expect(
      find.text("We couldn't read the links saved on this device."),
      findsNothing,
    );
  });

  testWidgets('a direct signed-out entry falls back to sign-in', (
    tester,
  ) async {
    final store = await testPendingUrlStore();
    final container = await makeContainer(store);
    final router = GoRouter(
      initialLocation: AppRoutes.savedOnDevice,
      routes: [
        GoRoute(
          path: AppRoutes.savedOnDevice,
          builder: (_, _) => const PendingUrlsScreen(),
        ),
        GoRoute(
          path: AppRoutes.auth,
          builder: (_, _) => const Scaffold(body: Text('AUTH STUB')),
        ),
        GoRoute(
          path: AppRoutes.inbox,
          builder: (_, _) => const Scaffold(body: Text('INBOX STUB')),
        ),
      ],
    );
    addTearDown(router.dispose);

    await pumpScreen(tester, container, router: router);

    expect(find.byTooltip('Back to sign in'), findsOneWidget);
    await tester.tap(find.byTooltip('Back to sign in'));
    await tester.pumpAndSettle();

    expect(find.text('AUTH STUB'), findsOneWidget);
  });

  testWidgets('a direct signed-in entry falls back to the Inbox', (
    tester,
  ) async {
    final store = await testPendingUrlStore();
    final container = await makeContainer(
      store,
      session: const AuthTokens(
        accessToken: 'access-1',
        refreshToken: 'refresh-1',
      ),
    );
    final router = GoRouter(
      initialLocation: AppRoutes.savedOnDevice,
      routes: [
        GoRoute(
          path: AppRoutes.savedOnDevice,
          builder: (_, _) => const PendingUrlsScreen(),
        ),
        GoRoute(
          path: AppRoutes.auth,
          builder: (_, _) => const Scaffold(body: Text('AUTH STUB')),
        ),
        GoRoute(
          path: AppRoutes.inbox,
          builder: (_, _) => const Scaffold(body: Text('INBOX STUB')),
        ),
      ],
    );
    addTearDown(router.dispose);

    await pumpScreen(tester, container, router: router);

    expect(find.byTooltip('Back to Inbox'), findsOneWidget);
    await tester.tap(find.byTooltip('Back to Inbox'));
    await tester.pumpAndSettle();

    expect(find.text('INBOX STUB'), findsOneWidget);
  });
}
