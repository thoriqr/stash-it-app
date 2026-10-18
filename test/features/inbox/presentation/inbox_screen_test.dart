import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_it_app/app/network/network_providers.dart';
import 'package:stash_it_app/app/theme/app_theme.dart';
import 'package:stash_it_app/core/storage/secure_credential_store.dart';
import 'package:stash_it_app/features/auth/application/session_controller.dart';
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

  Future<ProviderContainer> makeContainer() async {
    final made = ProviderContainer(
      overrides: [
        credentialStoreProvider.overrideWithValue(
          SecureCredentialStore(InMemorySecureStorage()),
        ),
      ],
      retry: (_, _) => null,
    );
    made.read(appDioProvider).httpClientAdapter = adapter;
    made.read(refreshDioProvider).httpClientAdapter = adapter;
    return made;
  }

  Future<ProviderContainer> pumpInbox(WidgetTester tester) async {
    final container = await makeContainer();
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

    testWidgets('an expired session reads as a sign-in problem', (
      tester,
    ) async {
      useTallSurface(tester);
      adapter.on(
        '/saved-items',
        status: 401,
        body: errorBody('SESSION_REVOKED'),
      );

      await pumpInbox(tester);
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Sign in again'),
        findsOneWidget,
        reason: 'the copy is selected from the typed failure, never the code',
      );
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
