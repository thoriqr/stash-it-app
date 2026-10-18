import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_it_app/app/network/network_providers.dart';
import 'package:stash_it_app/app/theme/app_theme.dart';
import 'package:stash_it_app/core/storage/secure_credential_store.dart';
import 'package:stash_it_app/features/auth/application/auth_state.dart';
import 'package:stash_it_app/features/auth/application/session_controller.dart';
import 'package:stash_it_app/features/auth/data/models/auth_tokens.dart';
import 'package:stash_it_app/features/inbox/presentation/inbox_screen.dart';
import 'package:stash_it_app/features/saved_items/application/saved_items_controller.dart';
import 'package:stash_it_app/features/saved_items/presentation/widgets/saved_item_row.dart';
import 'package:stash_it_app/features/saved_items/presentation/widgets/saved_item_skeleton.dart';
import 'package:stash_it_app/shared/widgets/app_button.dart';
import 'package:stash_it_app/shared/widgets/app_field.dart';

import '../../../support/fake_http.dart';
import '../../../support/saved_items_fixtures.dart';

/// The Inbox against the real listing provider, driven by a scripted transport.
void main() {
  late FakeHttpAdapter adapter;

  /// The default 800x600 surface hides the lower rows, so anything asserting on
  /// the list needs a taller one.
  void useTallSurface(WidgetTester tester) {
    tester.view.physicalSize = const Size(900, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
  }

  /// The credential store behind the container, so a test can seed it and check
  /// what the session layer did to it.
  late InMemorySecureStorage backend;

  /// A container with a scripted transport.
  ///
  /// [session] is written to the **store**, not only to `restoredTokensProvider`,
  /// because that is where `AuthInterceptor` reads the bearer from and where
  /// `SessionController` reads the refresh token from. A test that needs the
  /// renewal path must therefore start with a session, or there is nothing to
  /// renew and the run takes a different branch entirely.
  Future<ProviderContainer> makeContainer({AuthTokens? session}) async {
    backend = InMemorySecureStorage();
    final store = SecureCredentialStore(backend);
    if (session != null) await store.write(session);

    final made = ProviderContainer(
      overrides: [
        credentialStoreProvider.overrideWithValue(store),
        restoredTokensProvider.overrideWithValue(session),
      ],
      retry: (_, _) => null,
    );
    made.read(appDioProvider).httpClientAdapter = adapter;
    made.read(refreshDioProvider).httpClientAdapter = adapter;
    return made;
  }

  Future<ProviderContainer> pumpInbox(
    WidgetTester tester, {
    AuthTokens? session,
  }) async {
    final container = await makeContainer(session: session);
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          home: const InboxScreen(),
        ),
      ),
    );
    return container;
  }

  setUp(() => adapter = FakeHttpAdapter());

  group('loading', () {
    testWidgets('shows a skeleton while the listing is in flight', (
      tester,
    ) async {
      useTallSurface(tester);
      adapter.onBlocking(
        '/saved-items',
        FakeReply(200, SavedItemsFixtures.emptyPage()),
      );

      await pumpInbox(tester);
      await tester.pump();

      expect(find.byType(SavedItemSkeletonList), findsOneWidget);
      expect(find.byType(SavedItemRow), findsNothing);

      adapter.releaseBlocked();
      await tester.pumpAndSettle();

      expect(find.byType(SavedItemSkeletonList), findsNothing);
    });

    testWidgets('the skeleton occupies the saved-item card layout', (
      tester,
    ) async {
      useTallSurface(tester);
      adapter.onBlocking(
        '/saved-items',
        FakeReply(200, SavedItemsFixtures.emptyPage()),
      );

      final container = await pumpInbox(tester);
      await tester.pump();

      // The thumbnail well is the one dimension the card cannot vary.
      final skeletonWell = tester.getSize(
        find
            .descendant(
              of: find.byType(SavedItemSkeleton).first,
              matching: find.byType(CustomPaint),
            )
            .first,
      );
      final skeletonHeight = tester
          .getSize(find.byType(SavedItemSkeleton).first)
          .height;

      adapter.releaseBlocked();
      await tester.pumpAndSettle();

      adapter.on(
        '/saved-items',
        body: SavedItemsFixtures.page(items: [SavedItemsFixtures.item()]),
      );
      await container.read(savedItemsProvider.notifier).retry();
      await tester.pumpAndSettle();

      final rowHeight = tester.getSize(find.byType(SavedItemRow)).height;
      final realWell = tester.getSize(
        find
            .descendant(
              of: find.byType(SavedItemRow),
              matching: find.byType(CustomPaint),
            )
            .first,
      );

      expect(
        skeletonWell,
        realWell,
        reason: 'the placeholder keeps the reserved 56 px well',
      );

      // Height cannot be equal for every content shape — the real row grows
      // with its title and description — so this pins the card to the same
      // order of magnitude rather than a false exactness.
      expect(skeletonHeight, greaterThan(rowHeight * 0.8));
      expect(skeletonHeight, lessThan(rowHeight * 1.3));
    });
  });

  group('success', () {
    testWidgets('renders the returned rows in the order the API gave them', (
      tester,
    ) async {
      useTallSurface(tester);
      adapter.on(
        '/saved-items',
        body: SavedItemsFixtures.page(
          items: [
            SavedItemsFixtures.item(id: 'a', title: 'Newest item'),
            SavedItemsFixtures.item(id: 'b', title: 'Older item'),
            SavedItemsFixtures.item(
              id: 'c',
              title: 'Oldest item',
              collectionName: 'Wishlist',
            ),
          ],
        ),
      );

      await pumpInbox(tester);
      await tester.pumpAndSettle();

      expect(find.byType(SavedItemRow), findsNWidgets(3));
      expect(find.byType(SavedItemSkeletonList), findsNothing);

      final titles = tester
          .widgetList<SavedItemRow>(find.byType(SavedItemRow))
          .map((w) => w.item.id)
          .toList();
      expect(titles, ['a', 'b', 'c'], reason: 'the client never re-sorts');

      // Each row names the collection the item currently sits in — D26's whole
      // reason for the Inbox existing.
      expect(find.text('Camera Gear'), findsNWidgets(2));
      expect(find.text('Wishlist'), findsOneWidget);
    });

    testWidgets('an empty listing shows an empty state, not an error', (
      tester,
    ) async {
      useTallSurface(tester);
      adapter.on('/saved-items', body: SavedItemsFixtures.emptyPage());

      await pumpInbox(tester);
      await tester.pumpAndSettle();

      expect(find.text('Nothing saved yet'), findsOneWidget);
      expect(find.byType(SavedItemRow), findsNothing);
      expect(find.byType(SavedItemSkeletonList), findsNothing);
    });

    testWidgets(
      'a row with null metadata renders its URL fallback, not a fault',
      (tester) async {
        useTallSurface(tester);
        adapter.on(
          '/saved-items',
          body: SavedItemsFixtures.page(
            items: [
              SavedItemsFixtures.item(
                url: 'https://archive.example.net/specs/build-notes',
                title: null,
                description: null,
                imageUrl: null,
              ),
            ],
          ),
        );

        await pumpInbox(tester);
        await tester.pumpAndSettle();

        expect(
          find.text('https://archive.example.net/specs/build-notes'),
          findsOneWidget,
        );
        expect(find.text('archive.example.net'), findsOneWidget);
        expect(find.textContaining('error'), findsNothing);
      },
    );

    testWidgets('shows the enrichment states the listing reports', (
      tester,
    ) async {
      useTallSurface(tester);
      adapter.on(
        '/saved-items',
        body: SavedItemsFixtures.page(
          items: [
            SavedItemsFixtures.item(id: 'p', enrichmentStatus: 'pending'),
            SavedItemsFixtures.item(
              id: 'f',
              enrichmentStatus: 'failed',
              title: null,
            ),
            SavedItemsFixtures.item(
              id: 'n',
              enrichmentStatus: 'completed',
              title: null,
              description: null,
              imageUrl: null,
            ),
          ],
        ),
      );

      await pumpInbox(tester);
      await tester.pumpAndSettle();

      expect(find.text('Reading page…'), findsOneWidget);
      expect(find.text("Couldn't read this page"), findsOneWidget);
      // A completed row with nothing to show says so in neutral copy — it is not
      // styled as a problem and never filtered out.
      expect(find.text('No details on this page'), findsOneWidget);
    });
  });

  group('failure', () {
    testWidgets('shows an inline error with a Retry action', (tester) async {
      useTallSurface(tester);
      adapter.on(
        '/saved-items',
        status: 500,
        body: errorBody('INTERNAL_SERVER_ERROR'),
      );

      await pumpInbox(tester);
      await tester.pumpAndSettle();

      expect(
        find.text('We could not reach the server. Try again shortly.'),
        findsOneWidget,
      );
      expect(find.widgetWithText(AppButton, 'Retry'), findsOneWidget);
      expect(find.byType(SavedItemRow), findsNothing);
    });

    testWidgets('never shows the backend message', (tester) async {
      useTallSurface(tester);
      adapter.on(
        '/saved-items',
        status: 500,
        body: errorBody('INTERNAL_SERVER_ERROR'),
      );

      await pumpInbox(tester);
      await tester.pumpAndSettle();

      expect(find.textContaining('redacted for tests'), findsNothing);
      expect(find.textContaining('INTERNAL_SERVER_ERROR'), findsNothing);
    });

    testWidgets('Retry genuinely refetches', (tester) async {
      useTallSurface(tester);
      adapter.on(
        '/saved-items',
        status: 500,
        body: errorBody('INTERNAL_SERVER_ERROR'),
      );

      await pumpInbox(tester);
      await tester.pumpAndSettle();
      expect(adapter.countFor('/saved-items'), 1);

      adapter.on(
        '/saved-items',
        body: SavedItemsFixtures.page(
          items: [SavedItemsFixtures.item(id: 'a', title: 'Recovered')],
        ),
      );

      await tester.tap(find.widgetWithText(AppButton, 'Retry'));
      await tester.pumpAndSettle();

      expect(adapter.countFor('/saved-items'), 2, reason: 'a real second call');
      expect(find.text('Recovered'), findsOneWidget);
      expect(find.widgetWithText(AppButton, 'Retry'), findsNothing);
    });

    testWidgets('a session that cannot be renewed reads as a sign-in problem', (
      tester,
    ) async {
      useTallSurface(tester);

      // The contract: `GET /saved-items` only ever answers the three
      // bearer-guard codes, and `SESSION_REVOKED` comes from `POST /auth/refresh`.
      // An earlier version of this test scripted the terminal code straight off
      // the listing, which no protected route can produce — the client "passed"
      // without ever exercising the interceptor or the session layer.
      adapter.on(
        '/saved-items',
        status: 401,
        body: errorBody('ACCESS_TOKEN_EXPIRED'),
      );
      adapter.on(
        '/auth/refresh',
        status: 401,
        body: errorBody('SESSION_REVOKED'),
      );

      final container = await pumpInbox(
        tester,
        session: const AuthTokens(
          accessToken: 'access-1',
          refreshToken: 'refresh-1',
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Sign in again'),
        findsOneWidget,
        reason: 'the copy is selected from the typed failure, never the code',
      );

      // The run really did go through the renewal, so the interceptor was the
      // thing that produced the failure rather than the scripted listing.
      expect(
        adapter.countFor('/auth/refresh'),
        1,
        reason: 'an expired access token must trigger exactly one renewal',
      );
      expect(backend.values, isEmpty, reason: 'the session really was ended');
      expect(
        container.read(authStateProvider),
        AuthStatus.signedOut,
        reason: 'the Inbox has no router; the auth state is what it can see',
      );
    });

    testWidgets('a plain 401 does not attempt a renewal', (tester) async {
      useTallSurface(tester);

      // The bearer guard's other refusals. Renewing for these cannot succeed,
      // and the user still has to sign in again — so the copy matches while the
      // behaviour behind it differs from the terminal case above.
      adapter.on(
        '/saved-items',
        status: 401,
        body: errorBody('INVALID_ACCESS_TOKEN'),
      );

      final container = await pumpInbox(
        tester,
        session: const AuthTokens(
          accessToken: 'access-1',
          refreshToken: 'refresh-1',
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Sign in again'),
        findsOneWidget,
        reason: 'a refused token is still a sign-in problem',
      );
      expect(
        adapter.countFor('/auth/refresh'),
        0,
        reason: 'only ACCESS_TOKEN_EXPIRED authorises a renewal attempt',
      );
      expect(
        backend.values,
        isNotEmpty,
        reason: 'nothing ended the session, so nothing was cleared',
      );
      expect(container.read(authStateProvider), AuthStatus.signedIn);
    });

    testWidgets('an ambiguous renewal failure does not read as signed out', (
      tester,
    ) async {
      useTallSurface(tester);

      // The renewal fails without the client learning whether the server
      // committed the rotation. The policy is to keep the credentials and let the
      // user decide, so the listing must not claim the session is over — that is
      // the outcome this test exists to pin, and it is invisible to the screen if
      // the transport is scripted as a plain 500 on the listing.
      adapter.on(
        '/saved-items',
        status: 401,
        body: errorBody('ACCESS_TOKEN_EXPIRED'),
      );
      adapter.on(
        '/auth/refresh',
        status: 500,
        body: errorBody('INTERNAL_SERVER_ERROR'),
      );

      final container = await pumpInbox(
        tester,
        session: const AuthTokens(
          accessToken: 'access-1',
          refreshToken: 'refresh-1',
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Sign in again'),
        findsNothing,
        reason:
            'an uncertain outcome must not be presented as an ended session',
      );
      expect(
        find.text('We could not load your saved items. Try again.'),
        findsOneWidget,
      );
      expect(find.widgetWithText(AppButton, 'Retry'), findsOneWidget);
      expect(backend.values, isNotEmpty, reason: 'the evidence is kept');
      expect(container.read(authStateProvider), AuthStatus.signedIn);
    });
  });

  group('URL intake', () {
    testWidgets('renders Paste and Save URL as separate actions', (
      tester,
    ) async {
      useTallSurface(tester);
      adapter.on('/saved-items', body: SavedItemsFixtures.emptyPage());

      await pumpInbox(tester);
      await tester.pumpAndSettle();

      expect(find.text('Paste'), findsOneWidget);
      expect(find.text('Save URL'), findsOneWidget);
      expect(find.byType(AppField), findsOneWidget);
    });

    testWidgets('Save URL is the only filled action', (tester) async {
      useTallSurface(tester);
      adapter.on('/saved-items', body: SavedItemsFixtures.emptyPage());

      await pumpInbox(tester);
      await tester.pumpAndSettle();

      AppButtonVariant variantOf(String label) => tester
          .widgetList<AppButton>(find.byType(AppButton))
          .firstWhere((b) => b.label == label)
          .variant;

      expect(variantOf('Save URL'), AppButtonVariant.primary);
      expect(variantOf('Paste'), AppButtonVariant.secondary);
    });

    testWidgets('clearing the field disables Save URL', (tester) async {
      useTallSurface(tester);
      adapter.on('/saved-items', body: SavedItemsFixtures.emptyPage());

      await pumpInbox(tester);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '   ');
      await tester.pumpAndSettle();

      expect(
        tester
            .widget<AppButton>(find.widgetWithText(AppButton, 'Save URL'))
            .onPressed,
        isNull,
      );
    });
  });
}
