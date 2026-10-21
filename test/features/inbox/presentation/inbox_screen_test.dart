import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:stash_it_app/app/feedback/app_feedback.dart';
import 'package:stash_it_app/app/feedback/feedback_controller.dart';
import 'package:stash_it_app/app/feedback/feedback_host.dart';
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
    bool withFeedbackHost = false,
  }) async {
    final container = await makeContainer(session: session);
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          home: withFeedbackHost
              ? const FeedbackHost(child: InboxScreen())
              : const InboxScreen(),
        ),
      ),
    );
    return container;
  }

  setUp(() => adapter = FakeHttpAdapter());

  /// What the URL field currently holds.
  String fieldText(WidgetTester tester) =>
      tester.widget<TextField>(find.byType(TextField)).controller!.text;

  /// The filled button, found by **variant** rather than by label: `Save URL`'s
  /// label is replaced by a spinner while a save is in flight.
  AppButton saveButton(WidgetTester tester) => tester
      .widgetList<AppButton>(find.byType(AppButton))
      .firstWhere((button) => button.variant == AppButtonVariant.primary);

  int postCount() =>
      adapter.requests.where((request) => request.method == 'POST').length;

  /// Scripts Flutter's own platform clipboard for one test.
  ///
  /// `Clipboard.getData` is a method call on `SystemChannels.platform`, so the
  /// test binding's mock handler exercises the real production call. No package
  /// and no production seam are involved. `text: null` simulates an empty or
  /// non-text clipboard; [error] simulates a platform refusal.
  void mockClipboard(WidgetTester tester, {String? text, Object? error}) {
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.getData') {
          if (error != null) throw error;
          return text == null ? null : <String, dynamic>{'text': text};
        }
        return null;
      },
    );
    addTearDown(() {
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      );
    });
  }

  group('loading', () {
    testWidgets('shows a skeleton while the listing is in flight', (
      tester,
    ) async {
      useTallSurface(tester);
      adapter.onBlocking(
        '/saved-items',
        FakeReply(200, SavedItemsFixtures.emptyPage()),
      );

      final container = await pumpInbox(tester);
      await tester.pump();

      expect(find.byType(SavedItemSkeletonList), findsOneWidget);

      // The placeholder **is** a `SavedItemRow`, so "no row widgets yet" stopped
      // being the thing worth asserting when the skeleton moved onto the real
      // widget. What has to hold instead is that every row on screen is a
      // skeletonized placeholder: none of the listing's own rows can exist
      // before the page arrives, and the provider is genuinely still loading.
      //
      // Matched by predicate rather than by type: `Skeletonizer` is a factory
      // for a private class, and `find.byType` compares the runtime type.
      expect(
        find.descendant(
          of: find.byWidgetPredicate((widget) => widget is Skeletonizer),
          matching: find.byType(SavedItemRow),
        ),
        findsNWidgets(4),
      );
      expect(container.read(savedItemsProvider), isA<AsyncLoading>());

      adapter.releaseBlocked();
      await tester.pumpAndSettle();

      expect(find.byType(SavedItemSkeletonList), findsNothing);
      expect(
        find.byWidgetPredicate((widget) => widget is Skeletonizer),
        findsNothing,
        reason: 'the shimmer goes with the placeholder',
      );
    });

    testWidgets('the placeholder is the card, not a copy of one', (
      tester,
    ) async {
      useTallSurface(tester);
      adapter.onBlocking(
        '/saved-items',
        FakeReply(200, SavedItemsFixtures.emptyPage()),
      );

      final container = await pumpInbox(tester);
      await tester.pump();

      final placeholder = find.byType(SavedItemSkeleton).first;
      final placeholderHeight = tester.getSize(placeholder).height;
      // The thumbnail well is the one dimension the card cannot vary.
      final placeholderWell = tester.getSize(
        find
            .descendant(of: placeholder, matching: find.byType(CustomPaint))
            .first,
      );

      adapter.releaseBlocked();
      await tester.pumpAndSettle();

      // A real row filling the same content shape: a two-line title, a two-line
      // description and a state line. The placeholder is built from the same
      // widget, so this is an equality rather than a band — which is the whole
      // point of skeletonizing the row instead of restating its layout.
      adapter.on(
        '/saved-items',
        body: SavedItemsFixtures.page(
          items: [
            SavedItemsFixtures.item(
              title: 'A page title about as long as a real one tends to run',
              description:
                  'A description long enough to fill the two-line clamp, so '
                  'the placeholder keeps the height a real row occupies.',
              enrichmentStatus: 'pending',
            ),
          ],
        ),
      );
      await container.read(savedItemsProvider.notifier).retry();
      await tester.pumpAndSettle();

      final realRow = find.byType(SavedItemRow);
      final realWell = tester.getSize(
        find.descendant(of: realRow, matching: find.byType(CustomPaint)).first,
      );

      // The measured box is the well's paint area. Its 1 px border is painted
      // inside the 56 px slot, so the hatch itself is that much smaller — the
      // same arithmetic a real row gets, unchanged by skeletonization.
      final paintedWell = const Size.square(
        AppMetrics.slotThumbSize - 2 * AppMetrics.borderWidth,
      );

      expect(
        placeholderWell,
        paintedWell,
        reason: 'the reserved well survives being skeletonized',
      );
      expect(
        realWell,
        placeholderWell,
        reason: 'and it is the very same well the real row draws',
      );
      expect(
        placeholderHeight,
        tester.getSize(realRow).height,
        reason: 'same widget, same content shape, same geometry',
      );
    });

    testWidgets('the placeholder reserves at least a minimal row', (
      tester,
    ) async {
      useTallSurface(tester);
      adapter.onBlocking(
        '/saved-items',
        FakeReply(200, SavedItemsFixtures.emptyPage()),
      );

      final container = await pumpInbox(tester);
      await tester.pump();
      final placeholderHeight = tester
          .getSize(find.byType(SavedItemSkeleton).first)
          .height;

      adapter.releaseBlocked();
      await tester.pumpAndSettle();

      adapter.on(
        '/saved-items',
        body: SavedItemsFixtures.page(
          items: [SavedItemsFixtures.item(title: null, description: null)],
        ),
      );
      await container.read(savedItemsProvider.notifier).retry();
      await tester.pumpAndSettle();

      // The placeholder is the *largest* shape a row can take. A short real row
      // is therefore shorter, which is the safe direction: the card is already
      // the right size when the data lands, so nothing below it is pushed down.
      expect(
        placeholderHeight,
        greaterThan(tester.getSize(find.byType(SavedItemRow)).height),
      );
    });

    testWidgets('the placeholder keeps every part of a saved-item card', (
      tester,
    ) async {
      useTallSurface(tester);
      adapter.onBlocking(
        '/saved-items',
        FakeReply(200, SavedItemsFixtures.emptyPage()),
      );

      await pumpInbox(tester);
      await tester.pump();
      final placeholder = find.byType(SavedItemSkeleton).first;

      // The hand-drawn placeholder had to restate these and could drift from the
      // row; here they are the row's own widgets.
      expect(
        find.descendant(of: placeholder, matching: find.byType(InkWell)),
        findsOneWidget,
        reason: 'the card is still the card',
      );
      expect(
        find.descendant(of: placeholder, matching: find.byType(CustomPaint)),
        findsOneWidget,
        reason: 'the hatched thumbnail well is built by the row itself',
      );
      expect(
        tester
            .widgetList<Text>(
              find.descendant(of: placeholder, matching: find.byType(Text)),
            )
            .length,
        greaterThanOrEqualTo(5),
        reason: 'title, saved time, source, description, chip and state',
      );

      // Released rather than left blocked: an unsent request leaves a pending
      // timer behind when the tree is torn down.
      adapter.releaseBlocked();
      await tester.pumpAndSettle();
    });

    testWidgets('the thumbnail keeps its hatching under the shimmer', (
      tester,
    ) async {
      useTallSurface(tester);
      adapter.onBlocking(
        '/saved-items',
        FakeReply(200, SavedItemsFixtures.emptyPage()),
      );

      await pumpInbox(tester);
      await tester.pump();

      // `Skeletonizer` treats a childless `CustomPaint` as a bone, which would
      // repaint the hatch's base fill with the shimmer gradient and then draw the
      // solid bands over the top of it. `Skeleton.keep` is the exemption, and it
      // only exists here because the integration required it.
      expect(
        find.descendant(
          of: find.byType(SavedItemSkeleton).first,
          matching: find.byWidgetPredicate((widget) => widget is Skeleton),
        ),
        findsOneWidget,
      );

      adapter.releaseBlocked();
      // A paint or clip assertion in the well would surface here.
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('the placeholder survives a narrow surface', (tester) async {
      tester.view.physicalSize = const Size(320, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      adapter.onBlocking(
        '/saved-items',
        FakeReply(200, SavedItemsFixtures.emptyPage()),
      );

      await pumpInbox(tester);
      await tester.pump();

      expect(
        find.byType(SavedItemSkeleton),
        findsWidgets,
        reason: 'rows are still built at phone width',
      );
      expect(tester.takeException(), isNull);

      adapter.releaseBlocked();
      await tester.pumpAndSettle();
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

  group('pull to refresh', () {
    /// Drags [scrollable] far enough to arm the RefreshIndicator, then pumps
    /// through its snap animation so `onRefresh` has been called.
    Future<void> pull(WidgetTester tester, Finder scrollable) async {
      // The test surface is tall, and RefreshIndicator arms at a fraction of
      // the viewport height. A drag shorter than that fraction never calls
      // `onRefresh`, however far it looks in a screenshot.
      await tester.drag(scrollable, const Offset(0, 800));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      // The snap animation finishing is one frame; the provider's request is
      // handed to a zero-delay timer after that, so a second frame is needed
      // before the transport sees it.
      await tester.pump(Duration.zero);
    }

    testWidgets(
      'a short populated list stays pullable and keeps its rows while refreshing',
      (tester) async {
        useTallSurface(tester);
        adapter.on(
          '/saved-items',
          body: SavedItemsFixtures.page(
            items: [
              SavedItemsFixtures.item(id: 'old', title: 'Already loaded'),
            ],
          ),
        );

        final container = await pumpInbox(tester);
        await tester.pumpAndSettle();

        // One row does not fill the viewport, which is exactly the case
        // always-scrollable physics exists for.
        expect(find.byType(SavedItemRow), findsOneWidget);
        expect(find.byType(SavedItemSkeletonList), findsNothing);

        adapter.onBlocking(
          '/saved-items',
          FakeReply(
            200,
            SavedItemsFixtures.page(
              items: [SavedItemsFixtures.item(id: 'new', title: 'Refreshed')],
            ),
          ),
        );

        await pull(tester, find.byType(ListView));

        expect(adapter.countFor('/saved-items'), 2);
        expect(
          find.text('Already loaded'),
          findsOneWidget,
          reason: 'a manual refresh keeps the current rows in the tree',
        );
        expect(
          find.byType(SavedItemSkeletonList),
          findsNothing,
          reason: 'the skeleton is only for a genuine first load or Retry',
        );
        expect(
          find.byType(RefreshProgressIndicator),
          findsOneWidget,
          reason: 'the indicator is the progress UI for a manual refresh',
        );

        // The rest of the screen is untouched by the gesture.
        expect(find.text('INBOX'), findsOneWidget);
        expect(find.text('RECENTLY SAVED'), findsOneWidget);
        expect(find.text('Paste'), findsOneWidget);
        expect(find.text('Save URL'), findsOneWidget);

        adapter.releaseBlocked();
        await tester.pumpAndSettle();

        expect(find.text('Already loaded'), findsNothing);
        expect(find.text('Refreshed'), findsOneWidget);
        expect(find.byType(SavedItemSkeletonList), findsNothing);
        expect(
          container.read(feedbackProvider),
          isNull,
          reason: 'a successful refresh has nothing to report',
        );
      },
    );

    testWidgets('an empty listing is pullable and can become populated', (
      tester,
    ) async {
      useTallSurface(tester);
      adapter.on('/saved-items', body: SavedItemsFixtures.emptyPage());

      await pumpInbox(tester);
      await tester.pumpAndSettle();
      expect(find.text('Nothing saved yet'), findsOneWidget);

      adapter.on(
        '/saved-items',
        body: SavedItemsFixtures.page(
          items: [SavedItemsFixtures.item(id: 'new', title: 'Refreshed')],
        ),
      );

      await pull(tester, find.byType(SingleChildScrollView));
      await tester.pumpAndSettle();

      expect(adapter.countFor('/saved-items'), 2);
      expect(find.text('Nothing saved yet'), findsNothing);
      expect(find.text('Refreshed'), findsOneWidget);
      expect(find.byType(SavedItemSkeletonList), findsNothing);
    });

    testWidgets('an initial error is pullable and can recover', (tester) async {
      useTallSurface(tester);
      adapter.on(
        '/saved-items',
        status: 500,
        body: errorBody('INTERNAL_SERVER_ERROR'),
      );

      final container = await pumpInbox(tester);
      await tester.pumpAndSettle();
      expect(
        find.text('We could not reach the server. Try again shortly.'),
        findsOneWidget,
      );
      expect(
        container.read(feedbackProvider),
        isNull,
        reason: 'an initial-load failure is not a manual refresh',
      );

      adapter.on(
        '/saved-items',
        body: SavedItemsFixtures.page(
          items: [SavedItemsFixtures.item(id: 'new', title: 'Recovered')],
        ),
      );

      await pull(tester, find.byType(SingleChildScrollView));
      await tester.pumpAndSettle();

      expect(adapter.countFor('/saved-items'), 2);
      expect(find.text('Recovered'), findsOneWidget);
      expect(find.widgetWithText(AppButton, 'Retry'), findsNothing);
      expect(
        container.read(feedbackProvider),
        isNull,
        reason: 'a successful manual refresh announces nothing',
      );
    });

    testWidgets('a failed refresh keeps the populated rows on screen', (
      tester,
    ) async {
      useTallSurface(tester);
      adapter.on(
        '/saved-items',
        body: SavedItemsFixtures.page(
          items: [
            SavedItemsFixtures.item(id: 'a', title: 'Still here'),
            SavedItemsFixtures.item(id: 'b', title: 'Also here'),
          ],
        ),
      );

      final container = await pumpInbox(tester, withFeedbackHost: true);
      await tester.pumpAndSettle();

      adapter.on(
        '/saved-items',
        status: 500,
        body: errorBody('INTERNAL_SERVER_ERROR'),
      );

      await pull(tester, find.byType(SavedItemRow).first);
      await tester.pumpAndSettle();

      expect(adapter.countFor('/saved-items'), 2);
      expect(find.text('Still here'), findsOneWidget);
      expect(find.text('Also here'), findsOneWidget);
      expect(find.byType(SavedItemSkeletonList), findsNothing);
      expect(find.widgetWithText(AppButton, 'Retry'), findsNothing);
      expect(
        find.text('We could not reach the server. Try again shortly.'),
        findsNothing,
      );

      final notice = container.read(feedbackProvider)!;
      expect(notice.tone, FeedbackTone.uncertain);
      expect(notice.copy, "Couldn't refresh. Check your connection.");
      expect(
        find.text("Couldn't refresh. Check your connection."),
        findsOneWidget,
        reason: 'the notice is shown through the app-wide feedback host',
      );

      // Run the notice's clock out so its dismissal timer does not outlive the
      // test body.
      await tester.pump(
        feedbackVisibleDuration + const Duration(milliseconds: 1),
      );
      await tester.pumpAndSettle();
      expect(
        find.text("Couldn't refresh. Check your connection."),
        findsNothing,
      );
    });

    testWidgets('a failed refresh on an empty listing shows the retry state', (
      tester,
    ) async {
      useTallSurface(tester);
      adapter.on('/saved-items', body: SavedItemsFixtures.emptyPage());

      final container = await pumpInbox(tester);
      await tester.pumpAndSettle();

      adapter.on(
        '/saved-items',
        status: 500,
        body: errorBody('INTERNAL_SERVER_ERROR'),
      );

      await pull(tester, find.byType(SingleChildScrollView));
      await tester.pumpAndSettle();

      expect(
        find.text('We could not reach the server. Try again shortly.'),
        findsOneWidget,
      );
      expect(find.widgetWithText(AppButton, 'Retry'), findsOneWidget);
      expect(find.text('Nothing saved yet'), findsNothing);
      expect(find.byType(SavedItemSkeletonList), findsNothing);
      expect(
        container.read(feedbackProvider)?.copy,
        "Couldn't refresh. Check your connection.",
        reason: 'this was still a manual refresh, even with no rows to keep',
      );
    });

    testWidgets('Retry still uses the initial-load skeleton', (tester) async {
      useTallSurface(tester);
      adapter.on(
        '/saved-items',
        status: 500,
        body: errorBody('INTERNAL_SERVER_ERROR'),
      );

      final container = await pumpInbox(tester);
      await tester.pumpAndSettle();
      expect(
        container.read(feedbackProvider),
        isNull,
        reason: 'the initial failure is reported inline, not globally',
      );

      adapter.onBlocking(
        '/saved-items',
        FakeReply(
          200,
          SavedItemsFixtures.page(
            items: [SavedItemsFixtures.item(id: 'new', title: 'Recovered')],
          ),
        ),
      );

      await tester.tap(find.widgetWithText(AppButton, 'Retry'));
      await tester.pump();
      await tester.pump(Duration.zero);

      expect(adapter.countFor('/saved-items'), 2);
      expect(
        container.read(savedItemsProvider).isLoading,
        isTrue,
        reason: 'Riverpod keeps the old failure while Retry rebuilds',
      );
      expect(
        find.byType(SavedItemSkeletonList),
        findsOneWidget,
        reason: 'an explicit Retry is a first load, not a manual refresh',
      );

      adapter.releaseBlocked();
      await tester.pumpAndSettle();

      expect(find.text('Recovered'), findsOneWidget);
      expect(find.byType(SavedItemSkeletonList), findsNothing);
      expect(
        container.read(feedbackProvider),
        isNull,
        reason: 'a Retry is reported inline, not through global feedback',
      );
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

    testWidgets('the inline clear action empties the field without saving', (
      tester,
    ) async {
      useTallSurface(tester);
      adapter.on('/saved-items', body: SavedItemsFixtures.emptyPage());

      final container = await pumpInbox(tester);
      await tester.pumpAndSettle();

      // Nothing to clear, and whitespace is not a value.
      expect(find.byIcon(Icons.close), findsNothing);
      await tester.enterText(find.byType(TextField), '   ');
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.close), findsNothing);
      expect(saveButton(tester).onPressed, isNull);

      await tester.enterText(
        find.byType(TextField),
        'https://example.com/to-clear',
      );
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.close), findsOneWidget);
      expect(saveButton(tester).onPressed, isNotNull);

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(fieldText(tester), isEmpty);
      expect(find.byIcon(Icons.close), findsNothing);
      expect(saveButton(tester).onPressed, isNull);
      expect(
        find.text('Paste fills the field. Save URL sends it.'),
        findsOneWidget,
      );
      expect(postCount(), 0);
      expect(
        container.read(feedbackProvider),
        isNull,
        reason: 'clearing is not an outcome worth announcing',
      );
    });

    testWidgets('the field starts empty, so Save URL starts disabled', (
      tester,
    ) async {
      // The prototype pre-filled this field with a demo value to make the
      // enabled state visible. Now that the button submits, a pre-filled field
      // would be a value the user never typed and might never look at.
      useTallSurface(tester);
      adapter.on('/saved-items', body: SavedItemsFixtures.emptyPage());

      await pumpInbox(tester);
      await tester.pumpAndSettle();

      expect(fieldText(tester), isEmpty);
      expect(
        tester
            .widget<AppButton>(find.widgetWithText(AppButton, 'Save URL'))
            .onPressed,
        isNull,
      );

      await tester.enterText(find.byType(TextField), 'https://example.com/new');
      await tester.pumpAndSettle();

      expect(fieldText(tester), 'https://example.com/new');
      expect(
        tester
            .widget<AppButton>(find.widgetWithText(AppButton, 'Save URL'))
            .onPressed,
        isNotNull,
      );
    });

    testWidgets('Paste fills the field but does not save the URL', (
      tester,
    ) async {
      // [D25]: pasting alone does not save. The clipboard is seeded so this
      // proves the fill happened *and* that no POST followed it; with an empty
      // clipboard the same assertions would pass without a working Paste.
      useTallSurface(tester);
      adapter.on('/saved-items', body: SavedItemsFixtures.emptyPage());
      mockClipboard(tester, text: 'https://example.com/pasted');

      final container = await pumpInbox(tester);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Paste'));
      await tester.pumpAndSettle();

      expect(fieldText(tester), 'https://example.com/pasted');
      expect(
        saveButton(tester).onPressed,
        isNotNull,
        reason: 'the pasted value makes the field submittable',
      );
      expect(postCount(), 0);
      expect(
        container.read(feedbackProvider),
        isNull,
        reason: 'pasting is not an outcome worth announcing',
      );
    });

    for (final (label, text) in <(String, String?)>[
      ('null', null),
      ('empty', ''),
      ('whitespace-only', '  \n\t '),
    ]) {
      testWidgets(
        'Paste with $label clipboard content leaves the field alone',
        (tester) async {
          useTallSurface(tester);
          adapter.on('/saved-items', body: SavedItemsFixtures.emptyPage());
          mockClipboard(tester, text: text);

          final container = await pumpInbox(tester);
          await tester.pumpAndSettle();

          await tester.enterText(
            find.byType(TextField),
            'https://example.com/typed',
          );
          await tester.pumpAndSettle();

          await tester.tap(find.text('Paste'));
          await tester.pumpAndSettle();

          expect(
            fieldText(tester),
            'https://example.com/typed',
            reason: 'nothing was on the clipboard, so nothing was replaced',
          );
          expect(postCount(), 0);
          expect(container.read(feedbackProvider), isNull);
        },
      );
    }

    testWidgets(
      'a clipboard read failure changes nothing and is not reported',
      (tester) async {
        useTallSurface(tester);
        adapter.on('/saved-items', body: SavedItemsFixtures.emptyPage());
        mockClipboard(
          tester,
          error: PlatformException(code: 'clipboard', message: 'unavailable'),
        );

        final container = await pumpInbox(tester);
        await tester.pumpAndSettle();

        await tester.tap(find.text('Paste'));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(fieldText(tester), isEmpty);
        expect(postCount(), 0);
        expect(
          container.read(feedbackProvider),
          isNull,
          reason: 'Q13 leaves a clipboard-failure state undecided',
        );
      },
    );

    testWidgets('Paste does not validate; Save URL still refuses the text', (
      tester,
    ) async {
      useTallSurface(tester);
      adapter.on('/saved-items', body: SavedItemsFixtures.emptyPage());
      mockClipboard(tester, text: 'not a url');

      final container = await pumpInbox(tester);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Paste'));
      await tester.pumpAndSettle();

      expect(
        fieldText(tester),
        'not a url',
        reason: 'paste places the text it was given, without judging it',
      );
      expect(saveButton(tester).onPressed, isNotNull);
      expect(postCount(), 0);
      expect(container.read(feedbackProvider), isNull);

      await tester.tap(find.widgetWithText(AppButton, 'Save URL'));
      await tester.pumpAndSettle();

      expect(
        postCount(),
        0,
        reason: 'the local gate refuses it before the POST',
      );
      expect(fieldText(tester), 'not a url');
      final notice = container.read(feedbackProvider)!;
      expect(notice.tone, FeedbackTone.danger);
      expect(notice.copy, contains('http:// or https://'));
    });

    testWidgets('Paste and clear are unavailable while a save is in flight', (
      tester,
    ) async {
      useTallSurface(tester);
      const url = 'https://example.com/in-flight';

      adapter.onMethod(
        'GET',
        '/saved-items',
        body: SavedItemsFixtures.emptyPage(),
      );
      adapter.onBlocking(
        '/saved-items',
        FakeReply(201, SavedItemsFixtures.created(url: url)),
      );

      final container = await pumpInbox(tester);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), url);
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(AppButton, 'Save URL'));
      await tester.pump(Duration.zero);

      expect(
        tester
            .widget<AppButton>(find.widgetWithText(AppButton, 'Paste'))
            .onPressed,
        isNull,
        reason: 'both actions are disabled while the POST is unresolved',
      );
      expect(
        find.byIcon(Icons.close),
        findsNothing,
        reason: 'clearing must not race the submitted value',
      );
      expect(find.text('Saving…'), findsOneWidget);

      adapter.releaseBlocked();
      await tester.pumpAndSettle();

      expect(postCount(), 1);
      expect(fieldText(tester), isEmpty);
      expect(container.read(feedbackProvider)!.copy, 'Saved.');
    });

    testWidgets(
      'a save does not clear a value entered while it was in flight',
      (tester) async {
        useTallSurface(tester);
        const submitted = 'https://example.com/submitted';
        const newer = 'https://example.com/newer';

        adapter.onMethod(
          'GET',
          '/saved-items',
          body: SavedItemsFixtures.emptyPage(),
        );
        adapter.onBlocking(
          '/saved-items',
          FakeReply(201, SavedItemsFixtures.created(url: submitted)),
        );

        final container = await pumpInbox(tester);
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField), submitted);
        await tester.pumpAndSettle();
        await tester.tap(find.widgetWithText(AppButton, 'Save URL'));
        await tester.pump(Duration.zero);

        await tester.enterText(find.byType(TextField), newer);
        await tester.pump();

        adapter.releaseBlocked();
        await tester.pumpAndSettle();

        expect(postCount(), 1);
        expect(
          fieldText(tester),
          newer,
          reason:
              'the confirmation belongs to the submitted value, not this one',
        );
        expect(container.read(feedbackProvider)!.copy, 'Saved.');
      },
    );

    testWidgets('a confirmed save says so, clears the field, and shows the item', (
      tester,
    ) async {
      useTallSurface(tester);
      const url = 'https://example.com/new';

      adapter.onMethod(
        'POST',
        '/saved-items',
        status: 201,
        body: SavedItemsFixtures.created(url: url),
      );
      adapter.onSequence('/saved-items', [
        FakeReply(200, SavedItemsFixtures.emptyPage()),
        FakeReply(
          200,
          SavedItemsFixtures.page(
            items: [
              SavedItemsFixtures.item(
                id: 'new',
                url: url,
                title: 'Saved from the intake',
              ),
            ],
          ),
        ),
      ]);

      final container = await pumpInbox(tester);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), url);
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(AppButton, 'Save URL'));
      await tester.pumpAndSettle();

      expect(postCount(), 1);
      expect(
        fieldText(tester),
        isEmpty,
        reason: 'only a confirmed create clears',
      );

      final notice = container.read(feedbackProvider)!;
      expect(notice.tone, FeedbackTone.success);
      expect(notice.copy, 'Saved.');

      // And the confirmation is only half of it: the list this screen is for has
      // to show the row, which the head refresh brings in without discarding the
      // page already loaded.
      expect(find.text('Saved from the intake'), findsOneWidget);
    });

    testWidgets('a refused save keeps the value so it can be corrected', (
      tester,
    ) async {
      useTallSurface(tester);
      // Locally valid, so it is the server that refuses it — the copy has to be
      // the server's, and the request has to have happened.
      const url = 'https://example.com/broken';
      adapter.on('/saved-items', body: SavedItemsFixtures.emptyPage());
      adapter.onMethod(
        'POST',
        '/saved-items',
        status: 400,
        body: errorBody('INVALID_URL'),
      );

      final container = await pumpInbox(tester);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), url);
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(AppButton, 'Save URL'));
      await tester.pumpAndSettle();

      expect(
        postCount(),
        1,
        reason: 'the local gate is a shape check, not the contract',
      );
      expect(
        fieldText(tester),
        url,
        reason: 'the user has to be able to fix it and send it again',
      );

      final notice = container.read(feedbackProvider)!;
      expect(notice.tone, FeedbackTone.danger);
      expect(notice.copy, contains('Check the URL'));
    });

    testWidgets('a value that cannot be a URL is refused before any request', (
      tester,
    ) async {
      useTallSurface(tester);
      adapter.on('/saved-items', body: SavedItemsFixtures.emptyPage());

      final container = await pumpInbox(tester);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'example');
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(AppButton, 'Save URL'));
      await tester.pumpAndSettle();

      expect(postCount(), 0, reason: 'nothing was sent to refuse');
      expect(
        fieldText(tester),
        'example',
        reason: 'the value is kept so the user can fix it',
      );
      expect(find.text('Saving…'), findsNothing);
      expect(saveButton(tester).busy, isFalse);
      expect(
        saveButton(tester).onPressed,
        isNotNull,
        reason: 'and the button is ready for the corrected value',
      );

      final notice = container.read(feedbackProvider)!;
      expect(notice.tone, FeedbackTone.danger);
      expect(notice.copy, contains('http:// or https://'));
    });

    testWidgets('a corrected link is sent once after a local refusal', (
      tester,
    ) async {
      useTallSurface(tester);
      const url = 'https://example.com/new';

      adapter.onMethod(
        'POST',
        '/saved-items',
        status: 201,
        body: SavedItemsFixtures.created(url: url),
      );
      adapter.onSequence('/saved-items', [
        FakeReply(200, SavedItemsFixtures.emptyPage()),
        FakeReply(
          200,
          SavedItemsFixtures.page(
            items: [
              SavedItemsFixtures.item(
                id: 'new',
                url: url,
                title: 'Saved from the intake',
              ),
            ],
          ),
        ),
      ]);

      final container = await pumpInbox(tester);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'example');
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(AppButton, 'Save URL'));
      await tester.pumpAndSettle();
      expect(postCount(), 0);

      await tester.enterText(find.byType(TextField), url);
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(AppButton, 'Save URL'));
      await tester.pumpAndSettle();

      expect(postCount(), 1);
      expect(fieldText(tester), isEmpty);
      expect(container.read(feedbackProvider)!.copy, 'Saved.');
      expect(find.text('Saved from the intake'), findsOneWidget);
    });

    testWidgets('a save in flight is visible, and a second tap sends nothing', (
      tester,
    ) async {
      useTallSurface(tester);
      const url = 'https://example.com/new';

      adapter.onMethod(
        'GET',
        '/saved-items',
        body: SavedItemsFixtures.emptyPage(),
      );
      adapter.onBlocking(
        '/saved-items',
        FakeReply(201, SavedItemsFixtures.created(url: url)),
      );

      final container = await pumpInbox(tester);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), url);
      await tester.pumpAndSettle();

      // Two taps with no frame between them, which is the case the in-flight
      // guard exists for: the second tap still sees an enabled button, because
      // nothing has rebuilt yet.
      await tester.tap(find.widgetWithText(AppButton, 'Save URL'));
      await tester.tap(find.widgetWithText(AppButton, 'Save URL'));

      // A *timed* pump, not a bare one. Riverpod hands provider-to-provider work
      // to a zero-delay timer, so the request has not left the client yet when
      // the frame that shows the busy button is drawn.
      await tester.pump(Duration.zero);

      expect(postCount(), 1, reason: 'one insert, and duplicates are allowed');
      expect(find.text('Saving…'), findsOneWidget);
      expect(saveButton(tester).busy, isTrue);
      expect(
        saveButton(tester).onPressed,
        isNull,
        reason: 'disabled while in flight, whatever the field holds',
      );

      adapter.releaseBlocked();
      await tester.pumpAndSettle();

      expect(postCount(), 1);
      expect(fieldText(tester), isEmpty);
      expect(container.read(feedbackProvider)!.copy, 'Saved.');
    });
  });
}
