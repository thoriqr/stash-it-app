import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_it_app/app/feedback/app_feedback.dart';
import 'package:stash_it_app/app/feedback/feedback_controller.dart';
import 'package:stash_it_app/app/network/network_providers.dart';
import 'package:stash_it_app/core/error/api_failure.dart';
import 'package:stash_it_app/core/storage/secure_credential_store.dart';
import 'package:stash_it_app/features/auth/data/models/auth_tokens.dart';
import 'package:stash_it_app/features/auth/application/session_controller.dart';
import 'package:stash_it_app/features/saved_items/application/saved_items_controller.dart';
import 'package:stash_it_app/features/saved_items/application/saved_items_state.dart';
import 'package:stash_it_app/features/saved_items/domain/saved_item_summary.dart';

import '../../../support/fake_http.dart';
import '../../../support/saved_items_fixtures.dart';

/// The Inbox listing controller: first page, retry, and cursor pagination.
///
/// Drives the **real** provider graph � repository, Retrofit client and
/// `appDio` � against a scripted transport. No socket is opened.
void main() {
  late FakeHttpAdapter adapter;

  /// A container with a scripted transport and no automatic provider retry.
  ///
  /// [session] is written to the **credential store**, because that is where
  /// the auth interceptor reads the bearer token from � seeding
  /// `restoredTokensProvider` alone would leave the store empty and every
  /// request would go out unauthenticated.
  ///
  /// `retry: (_, _) => null` because Riverpod 3 retries a failed provider up to
  /// ten times with backoff, which would slow the error cases and corrupt the
  /// request counts asserted here.
  Future<ProviderContainer> makeContainer({AuthTokens? session}) async {
    final store = InMemorySecureStorage();
    if (session != null) {
      await SecureCredentialStore(store).write(session);
    }

    final made = ProviderContainer(
      overrides: [
        credentialStoreProvider.overrideWithValue(SecureCredentialStore(store)),
        restoredTokensProvider.overrideWithValue(session),
      ],
      retry: (_, _) => null,
    );
    made.read(appDioProvider).httpClientAdapter = adapter;
    made.read(refreshDioProvider).httpClientAdapter = adapter;
    return made;
  }

  /// The loaded state, or a failure if the provider is not in a success state.
  SavedItemsState stateOf(ProviderContainer container) =>
      switch (container.read(savedItemsProvider)) {
        AsyncData(:final value) => value,
        final other => throw StateError('expected data, got $other'),
      };

  /// The app-wide notice currently showing, if any.
  AppFeedback? noticeOf(ProviderContainer container) =>
      container.read(feedbackProvider);

  setUp(() {
    adapter = FakeHttpAdapter();
  });

  /// Scripts pages in order. The last entry repeats once exhausted, so a test can
  /// walk a sequence without counting requests by hand.
  void scriptPages(List<Map<String, dynamic>> pages) {
    adapter.onSequence('/saved-items', [
      for (final page in pages) FakeReply(200, page),
    ]);
  }

  group('first page', () {
    test('loads rows, cursor and has_more', () async {
      final container = await makeContainer();
      addTearDown(container.dispose);

      scriptPages([
        SavedItemsFixtures.page(
          items: [
            SavedItemsFixtures.item(id: 'a', title: 'First'),
            SavedItemsFixtures.item(id: 'b', title: 'Second'),
          ],
          nextCursor: 'cursor-2',
          hasMore: true,
        ),
      ]);

      await container.read(savedItemsProvider.future);

      final state = stateOf(container);
      expect(state.items.map((i) => i.id).toList(), ['a', 'b']);
      expect(state.nextCursor, 'cursor-2');
      expect(state.hasMore, isTrue);
      expect(state.isLoadingMore, isFalse);
    });

    test('an empty page is a successful empty result', () async {
      final container = await makeContainer();
      addTearDown(container.dispose);

      scriptPages([SavedItemsFixtures.emptyPage()]);

      await container.read(savedItemsProvider.future);

      expect(stateOf(container).items, isEmpty);
      expect(stateOf(container).hasMore, isFalse);
    });
  });

  group('retry', () {
    test('refetches rather than re-reading the cached page', () async {
      final container = await makeContainer();
      addTearDown(container.dispose);

      scriptPages([
        SavedItemsFixtures.page(items: [SavedItemsFixtures.item(id: 'a')]),
        SavedItemsFixtures.page(items: [SavedItemsFixtures.item(id: 'b')]),
      ]);

      await container.read(savedItemsProvider.future);
      expect(stateOf(container).items.map((i) => i.id), ['a']);

      await container.read(savedItemsProvider.notifier).retry();
      await container.read(savedItemsProvider.future);

      expect(stateOf(container).items.map((i) => i.id), [
        'b',
      ], reason: 'retry must replace what is on screen, not replay page one');
      expect(adapter.countFor('/saved-items'), 2);
    });

    test('recovers from a failed first page', () async {
      final container = await makeContainer();
      addTearDown(container.dispose);

      adapter.on(
        '/saved-items',
        status: 500,
        body: errorBody('INTERNAL_SERVER_ERROR'),
      );
      await expectLater(
        container.read(savedItemsProvider.future),
        throwsA(isA<Object>()),
      );
      expect(
        noticeOf(container),
        isNull,
        reason: 'an initial-load failure is not a manual refresh',
      );

      scriptPages([
        SavedItemsFixtures.page(items: [SavedItemsFixtures.item(id: 'a')]),
      ]);
      await container.read(savedItemsProvider.notifier).retry();
      await container.read(savedItemsProvider.future);

      expect(stateOf(container).items.map((i) => i.id), ['a']);
      expect(
        noticeOf(container),
        isNull,
        reason: 'an explicit retry reports through the screen, not feedback',
      );
    });

    test(
      'a failed retry leaves the inline error and publishes no notice',
      () async {
        final container = await makeContainer();
        addTearDown(container.dispose);

        adapter.on(
          '/saved-items',
          status: 500,
          body: errorBody('INTERNAL_SERVER_ERROR'),
        );
        await expectLater(
          container.read(savedItemsProvider.future),
          throwsA(isA<Object>()),
        );

        await container.read(savedItemsProvider.notifier).retry();
        await expectLater(
          container.read(savedItemsProvider.future),
          throwsA(isA<Object>()),
        );

        expect(container.read(savedItemsProvider), isA<AsyncError>());
        expect(
          noticeOf(container),
          isNull,
          reason:
              'Retry is recovered on the screen, not through global feedback',
        );
      },
    );
  });

  group('pagination', () {
    /// Page one (a, b, more), page two (c, more), page three (d, final).
    Future<ProviderContainer> threePages() async {
      final container = await makeContainer();
      addTearDown(container.dispose);

      scriptPages([
        SavedItemsFixtures.page(
          items: [
            SavedItemsFixtures.item(id: 'a', title: 'First'),
            SavedItemsFixtures.item(id: 'b', title: 'Second'),
          ],
          nextCursor: 'cursor-2',
          hasMore: true,
        ),
        SavedItemsFixtures.page(
          items: [SavedItemsFixtures.item(id: 'c', title: 'Third')],
          nextCursor: 'cursor-3',
          hasMore: true,
        ),
        SavedItemsFixtures.page(
          items: [SavedItemsFixtures.item(id: 'd', title: 'Fourth')],
          hasMore: false,
        ),
      ]);

      await container.read(savedItemsProvider.future);
      return container;
    }

    test('appends the next page and advances the cursor', () async {
      final container = await threePages();

      await container.read(savedItemsProvider.notifier).loadMore();

      final state = stateOf(container);
      expect(state.items.map((i) => i.id), ['a', 'b', 'c']);
      expect(state.nextCursor, 'cursor-3');
      expect(state.hasMore, isTrue);
      expect(state.isLoadingMore, isFalse);
    });

    test('sends the cursor it was given, unchanged', () async {
      final container = await threePages();
      await container.read(savedItemsProvider.notifier).loadMore();

      final cursors = adapter.requests
          .map((r) => Uri.parse(r.path).queryParameters['cursor'])
          .toList();

      expect(cursors, [null, 'cursor-2']);
    });

    test(
      'skips an id already on screen instead of duplicating the row',
      () async {
        final container = await makeContainer();
        addTearDown(container.dispose);

        // An item saved again between two page fetches can appear in both.
        scriptPages([
          SavedItemsFixtures.page(
            items: [SavedItemsFixtures.item(id: 'a')],
            nextCursor: 'cursor-2',
            hasMore: true,
          ),
          SavedItemsFixtures.page(
            items: [
              SavedItemsFixtures.item(id: 'a'),
              SavedItemsFixtures.item(id: 'b'),
            ],
            hasMore: false,
          ),
        ]);

        await container.read(savedItemsProvider.future);
        await container.read(savedItemsProvider.notifier).loadMore();

        expect(stateOf(container).items.map((i) => i.id), ['a', 'b']);
      },
    );

    test('stops on the final page when has_more is false', () async {
      final container = await threePages();
      final notifier = container.read(savedItemsProvider.notifier);

      await notifier.loadMore();
      await notifier.loadMore();

      expect(stateOf(container).items.map((i) => i.id), ['a', 'b', 'c', 'd']);
      expect(stateOf(container).hasMore, isFalse);
      expect(stateOf(container).nextCursor, isNull);

      final requestsAfterFinal = adapter.countFor('/saved-items');
      await notifier.loadMore();

      expect(
        adapter.countFor('/saved-items'),
        requestsAfterFinal,
        reason: 'a finished listing must not ask again',
      );
    });

    test('stops on has_more alone when the contract is violated', () async {
      // The contract ties `has_more: false` to a null `next_cursor`, so on a
      // conforming server either check stops the listing and neither is
      // observable alone. This case — `has_more: false` but a cursor still
      // present — cannot happen without the server breaking its own contract,
      // and it is the only thing that makes the `has_more` check observable.
      // Handled defensively rather than assumed away (`AGENTS.md` §3).
      final container = await makeContainer();

      scriptPages([
        SavedItemsFixtures.page(
          items: [SavedItemsFixtures.item(id: 'a')],
          nextCursor: 'cursor-that-should-not-be-used',
          hasMore: false,
        ),
      ]);

      await container.read(savedItemsProvider.future);
      final before = adapter.countFor('/saved-items');

      await container.read(savedItemsProvider.notifier).loadMore();

      expect(
        adapter.countFor('/saved-items'),
        before,
        reason: 'has_more false ends the listing even with a cursor present',
      );
    });

    test('stops when has_more is true but next_cursor is null', () async {
      // Either signal ends the listing; checking only one would start a request
      // that cannot succeed.
      final container = await makeContainer();
      addTearDown(container.dispose);

      scriptPages([
        SavedItemsFixtures.page(
          items: [SavedItemsFixtures.item(id: 'a')],
          hasMore: true,
        ),
      ]);

      await container.read(savedItemsProvider.future);
      final before = adapter.countFor('/saved-items');

      await container.read(savedItemsProvider.notifier).loadMore();

      expect(adapter.countFor('/saved-items'), before);
    });

    test('does not stack requests while a page is in flight', () async {
      final container = await makeContainer();
      addTearDown(container.dispose);

      adapter.onSequence('/saved-items', [
        FakeReply(
          200,
          SavedItemsFixtures.page(
            items: [SavedItemsFixtures.item(id: 'a')],
            nextCursor: 'cursor-2',
            hasMore: true,
          ),
        ),
        FakeReply(
          200,
          SavedItemsFixtures.page(
            items: [SavedItemsFixtures.item(id: 'b')],
            hasMore: false,
          ),
        ),
      ]);

      await container.read(savedItemsProvider.future);

      final notifier = container.read(savedItemsProvider.notifier);

      // Issued back to back, the way repeated scroll notifications arrive. The
      // first sets `isLoadingMore` before it yields, so the second must decline.
      final first = notifier.loadMore();
      final second = notifier.loadMore();

      await Future.wait([first, second]);

      expect(
        adapter.countFor('/saved-items'),
        2,
        reason: 'one request for page one and one for page two, not three',
      );
      expect(stateOf(container).items.map((i) => i.id), ['a', 'b']);
    });

    test('keeps the loaded rows when a later page fails', () async {
      // The list is the user's history; page two failing must not throw away
      // page one.
      final container = await makeContainer();
      addTearDown(container.dispose);

      scriptPages([
        SavedItemsFixtures.page(
          items: [SavedItemsFixtures.item(id: 'a')],
          nextCursor: 'cursor-2',
          hasMore: true,
        ),
      ]);
      await container.read(savedItemsProvider.future);

      adapter.on(
        '/saved-items',
        status: 500,
        body: errorBody('INTERNAL_SERVER_ERROR'),
      );
      await container.read(savedItemsProvider.notifier).loadMore();

      final state = stateOf(container);
      expect(state.items.map((i) => i.id), ['a']);
      expect(state.isLoadingMore, isFalse);
      expect(container.read(savedItemsProvider).hasError, isFalse);
      expect(
        noticeOf(container),
        isNull,
        reason: 'a pagination failure is not a manual refresh',
      );
    });
  });

  group('in-place collection update', () {
    test('changes only the matching row and keeps list state', () async {
      final container = await makeContainer();
      addTearDown(container.dispose);

      scriptPages([
        SavedItemsFixtures.page(
          items: [
            SavedItemsFixtures.item(id: 'a', collectionName: 'Camera Gear'),
            SavedItemsFixtures.item(id: 'b', collectionName: 'Camera Gear'),
            SavedItemsFixtures.item(id: 'c', collectionName: 'Camera Gear'),
          ],
          nextCursor: 'cursor-2',
          hasMore: true,
        ),
      ]);
      await container.read(savedItemsProvider.future);

      container
          .read(savedItemsProvider.notifier)
          .applyCollection(
            savedItemId: 'b',
            collectionId: 'wishlist-id',
            collectionName: 'Wishlist',
          );

      final state = stateOf(container);
      expect(state.items.map((item) => item.id), ['a', 'b', 'c']);
      expect(state.items[0].collectionName, 'Camera Gear');
      expect(state.items[1].collectionId, 'wishlist-id');
      expect(state.items[1].collectionName, 'Wishlist');
      expect(state.items[2].collectionName, 'Camera Gear');
      expect(
        state.items[1].title,
        'Understanding CRDTs',
        reason: 'a move is not an enrichment and must not rewrite the row',
      );
      expect(state.items[1].enrichmentStatus, EnrichmentStatus.completed);
      expect(state.nextCursor, 'cursor-2');
      expect(state.hasMore, isTrue);
      expect(state.isLoadingMore, isFalse);
      expect(
        adapter.countFor('/saved-items'),
        1,
        reason: 'the row update is local, not another listing read',
      );
    });

    test('does nothing when the row is not loaded', () async {
      final container = await makeContainer();
      addTearDown(container.dispose);

      scriptPages([
        SavedItemsFixtures.page(items: [SavedItemsFixtures.item(id: 'a')]),
      ]);
      await container.read(savedItemsProvider.future);
      final before = stateOf(container);

      container
          .read(savedItemsProvider.notifier)
          .applyCollection(
            savedItemId: 'not-loaded',
            collectionId: 'wishlist-id',
            collectionName: 'Wishlist',
          );

      expect(stateOf(container), before);
      expect(adapter.countFor('/saved-items'), 1);
    });
  });

  group('the head refresh that follows a save', () {
    test('puts the newest page in front and keeps the loaded rows', () async {
      final container = await makeContainer();
      addTearDown(container.dispose);

      scriptPages([
        SavedItemsFixtures.page(
          items: [
            SavedItemsFixtures.item(id: 'a'),
            SavedItemsFixtures.item(id: 'b'),
          ],
          nextCursor: 'cursor-2',
          hasMore: true,
        ),
        // The head as it looks after the save: the new row on top, and a row the
        // page below already holds.
        SavedItemsFixtures.page(
          items: [
            SavedItemsFixtures.item(id: 'new'),
            SavedItemsFixtures.item(id: 'a'),
          ],
          hasMore: true,
          nextCursor: 'cursor-2',
        ),
      ]);

      await container.read(savedItemsProvider.future);
      await container.read(savedItemsProvider.notifier).refreshHead();

      final state = stateOf(container);
      expect(state.items.map((i) => i.id), ['new', 'a', 'b']);
      expect(
        state.nextCursor,
        'cursor-2',
        reason:
            'the loaded pages keep their own continuation point, so the next '
            'loadMore does not re-fetch what is already here',
      );
      expect(state.hasMore, isTrue);
      expect(
        adapter.countFor('/saved-items'),
        2,
        reason: 'one page-one read before the save, one after',
      );
      expect(
        adapter.requests.last.path,
        isNot(contains('cursor')),
        reason: 'a head refresh asks for page one, never a cursor',
      );
    });

    test('adopts a continuation point when the list had none', () async {
      // The case a fully-loaded history is in when a save pushes it past a page
      // boundary: page one was the only page, and now there is a second.
      final container = await makeContainer();
      addTearDown(container.dispose);

      scriptPages([
        SavedItemsFixtures.page(items: [SavedItemsFixtures.item(id: 'a')]),
        SavedItemsFixtures.page(
          items: [
            SavedItemsFixtures.item(id: 'new'),
            SavedItemsFixtures.item(id: 'a'),
          ],
          nextCursor: 'cursor-2',
          hasMore: true,
        ),
      ]);

      await container.read(savedItemsProvider.future);
      await container.read(savedItemsProvider.notifier).refreshHead();

      final state = stateOf(container);
      expect(state.items.map((i) => i.id), ['new', 'a']);
      expect(state.hasMore, isTrue);
      expect(state.nextCursor, 'cursor-2');
    });

    test('a failed refresh throws nothing and leaves the list alone', () async {
      // A save the server confirmed is not turned into a failure by a read that
      // did not arrive. The rows stay, and the screen reports no error.
      final container = await makeContainer();
      addTearDown(container.dispose);

      scriptPages([
        SavedItemsFixtures.page(items: [SavedItemsFixtures.item(id: 'a')]),
      ]);
      await container.read(savedItemsProvider.future);

      adapter.on(
        '/saved-items',
        status: 500,
        body: errorBody('INTERNAL_SERVER_ERROR'),
      );

      await expectLater(
        container.read(savedItemsProvider.notifier).refreshHead(),
        completes,
      );

      expect(stateOf(container).items.map((i) => i.id), ['a']);
      expect(container.read(savedItemsProvider).hasError, isFalse);
      expect(
        noticeOf(container),
        isNull,
        reason: 'a background head refresh is not a manual refresh',
      );
    });

    test('refetches page one when nothing is loaded yet', () async {
      // A save can land while the first page is still in flight, and that page's
      // query may already have run. Invalidating re-runs `build`, so the fetch
      // that lands is one issued *after* the save.
      final container = await makeContainer();
      addTearDown(container.dispose);

      scriptPages([
        SavedItemsFixtures.page(items: [SavedItemsFixtures.item(id: 'a')]),
        SavedItemsFixtures.page(items: [SavedItemsFixtures.item(id: 'b')]),
      ]);

      final notifier = container.read(savedItemsProvider.notifier);
      await notifier.refreshHead();
      await container.read(savedItemsProvider.future);

      expect(stateOf(container).items.map((i) => i.id), ['b']);
      expect(adapter.countFor('/saved-items'), 2);
    });

    test('a page in flight when the head lands keeps both', () async {
      // Race one: `loadMore` is issued first and answered last. Its merge has to
      // read the state as it stands *then*, or the row the refresh prepended is
      // dropped on the floor.
      final container = await makeContainer();
      addTearDown(container.dispose);

      adapter.onSequenceHolding('/saved-items', [
        // 1: page one.
        FakeReply(
          200,
          SavedItemsFixtures.page(
            items: [SavedItemsFixtures.item(id: 'a')],
            nextCursor: 'cursor-2',
            hasMore: true,
          ),
        ),
        // 2: page two, held until the refresh has written.
        FakeReply(
          200,
          SavedItemsFixtures.page(items: [SavedItemsFixtures.item(id: 'b')]),
        ),
        // 3: the head the save produced.
        FakeReply(
          200,
          SavedItemsFixtures.page(
            items: [
              SavedItemsFixtures.item(id: 'new'),
              SavedItemsFixtures.item(id: 'a'),
            ],
          ),
        ),
      ], holdAt: 2);

      await container.read(savedItemsProvider.future);
      final notifier = container.read(savedItemsProvider.notifier);

      final more = notifier.loadMore();
      await notifier.refreshHead();

      expect(stateOf(container).items.map((i) => i.id), ['new', 'a']);

      adapter.releaseBlocked();
      await more;

      final state = stateOf(container);
      expect(state.items.map((i) => i.id), ['new', 'a', 'b']);
      expect(state.isLoadingMore, isFalse);
      expect(state.hasMore, isFalse, reason: 'page two was the last page');
    });

    test('a head refresh in flight when the page lands keeps both', () async {
      // Race two: the refresh is issued last and answered last, so it has to
      // re-read the state rather than merge into the snapshot it took before the
      // page arrived.
      final container = await makeContainer();
      addTearDown(container.dispose);

      adapter.onSequenceHolding('/saved-items', [
        // 1: page one.
        FakeReply(
          200,
          SavedItemsFixtures.page(
            items: [SavedItemsFixtures.item(id: 'a')],
            nextCursor: 'cursor-2',
            hasMore: true,
          ),
        ),
        // 2: page two.
        FakeReply(
          200,
          SavedItemsFixtures.page(items: [SavedItemsFixtures.item(id: 'b')]),
        ),
        // 3: the head, held until page two has been written.
        FakeReply(
          200,
          SavedItemsFixtures.page(
            items: [
              SavedItemsFixtures.item(id: 'new'),
              SavedItemsFixtures.item(id: 'a'),
            ],
          ),
        ),
      ], holdAt: 3);

      await container.read(savedItemsProvider.future);
      final notifier = container.read(savedItemsProvider.notifier);

      final more = notifier.loadMore();
      final head = notifier.refreshHead();
      await untilCalled(() => adapter.countFor('/saved-items') == 3);

      await more;
      expect(stateOf(container).items.map((i) => i.id), [
        'a',
        'b',
      ], reason: 'page two landed on its own, before the head was answered');

      adapter.releaseBlocked();
      await head;

      final state = stateOf(container);
      expect(state.items.map((i) => i.id), ['new', 'a', 'b']);
      expect(state.isLoadingMore, isFalse);
    });
  });

  group('manual refresh', () {
    test(
      'fetches page one and replaces the rows, cursor and has_more',
      () async {
        final container = await makeContainer();
        addTearDown(container.dispose);

        scriptPages([
          SavedItemsFixtures.page(
            items: [
              SavedItemsFixtures.item(id: 'a'),
              SavedItemsFixtures.item(id: 'b'),
            ],
            nextCursor: 'cursor-2',
            hasMore: true,
          ),
          SavedItemsFixtures.page(
            items: [
              SavedItemsFixtures.item(id: 'fresh-a'),
              SavedItemsFixtures.item(id: 'fresh-b'),
            ],
            nextCursor: 'cursor-fresh',
            hasMore: true,
          ),
        ]);

        await container.read(savedItemsProvider.future);
        await container.read(savedItemsProvider.notifier).refresh();

        final state = stateOf(container);
        expect(state.items.map((i) => i.id), ['fresh-a', 'fresh-b']);
        expect(
          state.nextCursor,
          'cursor-fresh',
          reason: 'the old continuation point belonged to the old list',
        );
        expect(state.hasMore, isTrue);
        expect(state.isLoadingMore, isFalse);
        expect(
          Uri.parse(adapter.requests.last.path).queryParameters,
          isNot(contains('cursor')),
          reason: 'a refresh asks for page one, never the old cursor',
        );
        expect(adapter.countFor('/saved-items'), 2);
        expect(
          noticeOf(container),
          isNull,
          reason: 'a successful refresh has no failure to announce',
        );
      },
    );

    test('loadMore continues from the refreshed cursor', () async {
      final container = await makeContainer();
      addTearDown(container.dispose);

      scriptPages([
        SavedItemsFixtures.page(
          items: [SavedItemsFixtures.item(id: 'old')],
          nextCursor: 'cursor-old',
          hasMore: true,
        ),
        SavedItemsFixtures.page(
          items: [SavedItemsFixtures.item(id: 'fresh')],
          nextCursor: 'cursor-fresh',
          hasMore: true,
        ),
        SavedItemsFixtures.page(
          items: [SavedItemsFixtures.item(id: 'next')],
          hasMore: false,
        ),
      ]);

      await container.read(savedItemsProvider.future);
      final notifier = container.read(savedItemsProvider.notifier);
      await notifier.refresh();
      await notifier.loadMore();

      final state = stateOf(container);
      expect(state.items.map((i) => i.id), ['fresh', 'next']);
      expect(state.nextCursor, isNull);
      expect(state.hasMore, isFalse);
      expect(
        adapter.requests
            .map((r) => Uri.parse(r.path).queryParameters['cursor'])
            .toList(),
        [null, null, 'cursor-fresh'],
        reason: 'the page after a refresh uses the refresh cursor, not the old',
      );
    });

    test('concurrent refreshes share one request', () async {
      final container = await makeContainer();
      addTearDown(container.dispose);

      adapter.onSequenceHolding('/saved-items', [
        FakeReply(
          200,
          SavedItemsFixtures.page(
            items: [SavedItemsFixtures.item(id: 'a')],
            nextCursor: 'cursor-2',
            hasMore: true,
          ),
        ),
        FakeReply(
          200,
          SavedItemsFixtures.page(
            items: [SavedItemsFixtures.item(id: 'fresh')],
            hasMore: false,
          ),
        ),
      ], holdAt: 2);

      await container.read(savedItemsProvider.future);
      final notifier = container.read(savedItemsProvider.notifier);

      final first = notifier.refresh();
      final second = notifier.refresh();

      await untilCalled(() => adapter.countFor('/saved-items') == 2);
      expect(
        adapter.countFor('/saved-items'),
        2,
        reason: 'two gestures, one refresh request',
      );

      adapter.releaseBlocked();
      await Future.wait([first, second]);

      expect(stateOf(container).items.map((i) => i.id), ['fresh']);
      expect(adapter.countFor('/saved-items'), 2);
    });

    test('a coalesced failed refresh publishes one notice', () async {
      final container = await makeContainer();
      addTearDown(container.dispose);

      adapter.onSequenceHolding('/saved-items', [
        FakeReply(
          200,
          SavedItemsFixtures.page(
            items: [SavedItemsFixtures.item(id: 'a')],
            nextCursor: 'cursor-2',
            hasMore: true,
          ),
        ),
        FakeReply.error(500, 'INTERNAL_SERVER_ERROR'),
      ], holdAt: 2);

      await container.read(savedItemsProvider.future);
      final notifier = container.read(savedItemsProvider.notifier);

      final notices = <AppFeedback>[];
      container.listen<AppFeedback?>(feedbackProvider, (previous, next) {
        if (next != null) notices.add(next);
      });

      final first = notifier.refresh();
      final second = notifier.refresh();

      await untilCalled(() => adapter.countFor('/saved-items') == 2);
      adapter.releaseBlocked();
      await Future.wait([first, second]);

      expect(
        adapter.countFor('/saved-items'),
        2,
        reason: 'the second gesture joined the request already in flight',
      );
      expect(
        notices,
        hasLength(1),
        reason: 'two gestures shared one request, so they share one notice',
      );
      expect(notices.single.copy, "Couldn't refresh. Check your connection.");

      final state = stateOf(container);
      expect(state.items.map((i) => i.id), ['a']);
      expect(state.nextCursor, 'cursor-2');
    });

    test('blocks loadMore while the refresh is in flight', () async {
      final container = await makeContainer();
      addTearDown(container.dispose);

      adapter.onSequenceHolding('/saved-items', [
        FakeReply(
          200,
          SavedItemsFixtures.page(
            items: [SavedItemsFixtures.item(id: 'a')],
            nextCursor: 'cursor-2',
            hasMore: true,
          ),
        ),
        FakeReply(
          200,
          SavedItemsFixtures.page(
            items: [SavedItemsFixtures.item(id: 'fresh')],
            hasMore: false,
          ),
        ),
      ], holdAt: 2);

      await container.read(savedItemsProvider.future);
      final notifier = container.read(savedItemsProvider.notifier);

      final refresh = notifier.refresh();
      await untilCalled(() => adapter.countFor('/saved-items') == 2);

      await notifier.loadMore();

      expect(
        adapter.countFor('/saved-items'),
        2,
        reason: 'a page requested now would belong to the old list',
      );
      expect(stateOf(container).items.map((i) => i.id), ['a']);
      expect(stateOf(container).isLoadingMore, isFalse);

      adapter.releaseBlocked();
      await refresh;

      expect(stateOf(container).items.map((i) => i.id), ['fresh']);
    });

    test('a loadMore in flight cannot append to a refreshed list', () async {
      final container = await makeContainer();
      addTearDown(container.dispose);

      adapter.onSequenceHolding('/saved-items', [
        FakeReply(
          200,
          SavedItemsFixtures.page(
            items: [SavedItemsFixtures.item(id: 'a')],
            nextCursor: 'cursor-2',
            hasMore: true,
          ),
        ),
        // Held page two, belonging to the list the refresh replaces.
        FakeReply(
          200,
          SavedItemsFixtures.page(
            items: [SavedItemsFixtures.item(id: 'old-page')],
            hasMore: true,
          ),
        ),
        FakeReply(
          200,
          SavedItemsFixtures.page(
            items: [SavedItemsFixtures.item(id: 'fresh')],
            nextCursor: 'cursor-fresh',
            hasMore: true,
          ),
        ),
      ], holdAt: 2);

      await container.read(savedItemsProvider.future);
      final notifier = container.read(savedItemsProvider.notifier);

      final more = notifier.loadMore();
      await untilCalled(() => adapter.countFor('/saved-items') == 2);

      final refresh = notifier.refresh();
      await refresh;

      expect(stateOf(container).items.map((i) => i.id), ['fresh']);
      expect(stateOf(container).nextCursor, 'cursor-fresh');
      expect(stateOf(container).isLoadingMore, isFalse);

      adapter.releaseBlocked();
      await more;

      final state = stateOf(container);
      expect(state.items.map((i) => i.id), ['fresh']);
      expect(
        state.nextCursor,
        'cursor-fresh',
        reason: 'the old page cannot move the refreshed cursor',
      );
      expect(state.isLoadingMore, isFalse);
    });

    test(
      'a failed loadMore in flight cannot overwrite a refreshed list',
      () async {
        final container = await makeContainer();
        addTearDown(container.dispose);

        adapter.onSequenceHolding('/saved-items', [
          FakeReply(
            200,
            SavedItemsFixtures.page(
              items: [SavedItemsFixtures.item(id: 'a')],
              nextCursor: 'cursor-2',
              hasMore: true,
            ),
          ),
          FakeReply.error(500, 'INTERNAL_SERVER_ERROR'),
          FakeReply(
            200,
            SavedItemsFixtures.page(
              items: [SavedItemsFixtures.item(id: 'fresh')],
              nextCursor: 'cursor-fresh',
              hasMore: true,
            ),
          ),
        ], holdAt: 2);

        await container.read(savedItemsProvider.future);
        final notifier = container.read(savedItemsProvider.notifier);

        final more = notifier.loadMore();
        await untilCalled(() => adapter.countFor('/saved-items') == 2);

        final refresh = notifier.refresh();
        await refresh;

        adapter.releaseBlocked();
        await more;

        final listing = container.read(savedItemsProvider);
        expect(listing.hasError, isFalse);
        expect(stateOf(container).items.map((i) => i.id), ['fresh']);
        expect(stateOf(container).nextCursor, 'cursor-fresh');
        expect(stateOf(container).isLoadingMore, isFalse);
      },
    );

    test('a failed refresh keeps populated rows and the cursor', () async {
      final container = await makeContainer();
      addTearDown(container.dispose);

      scriptPages([
        SavedItemsFixtures.page(
          items: [
            SavedItemsFixtures.item(id: 'a'),
            SavedItemsFixtures.item(id: 'b'),
          ],
          nextCursor: 'cursor-2',
          hasMore: true,
        ),
      ]);
      await container.read(savedItemsProvider.future);

      adapter.on(
        '/saved-items',
        status: 500,
        body: errorBody('INTERNAL_SERVER_ERROR'),
      );
      await container.read(savedItemsProvider.notifier).refresh();

      final state = stateOf(container);
      expect(state.items.map((i) => i.id), ['a', 'b']);
      expect(state.nextCursor, 'cursor-2');
      expect(state.hasMore, isTrue);
      expect(state.isLoadingMore, isFalse);
      expect(
        container.read(savedItemsProvider).hasError,
        isFalse,
        reason: 'a failed refresh does not make the rows already shown wrong',
      );
      expect(adapter.countFor('/saved-items'), 2);

      final notice = noticeOf(container)!;
      expect(notice.tone, FeedbackTone.uncertain);
      expect(notice.copy, "Couldn't refresh. Check your connection.");
    });

    test(
      'a failed refresh without rows becomes the retryable error state',
      () async {
        final container = await makeContainer();
        addTearDown(container.dispose);

        scriptPages([SavedItemsFixtures.emptyPage()]);
        await container.read(savedItemsProvider.future);

        adapter.on(
          '/saved-items',
          status: 500,
          body: errorBody('INTERNAL_SERVER_ERROR'),
        );
        await container.read(savedItemsProvider.notifier).refresh();

        final listing = container.read(savedItemsProvider);
        expect(listing, isA<AsyncError>());
        expect(listing.error, isA<ApiFailureServerFault>());
        expect(listing.isLoading, isFalse);
        expect(adapter.countFor('/saved-items'), 2);
        expect(
          noticeOf(container)?.copy,
          "Couldn't refresh. Check your connection.",
        );
      },
    );

    test('a failed refresh from an error state leaves it retryable', () async {
      final container = await makeContainer();
      addTearDown(container.dispose);

      adapter.on(
        '/saved-items',
        status: 500,
        body: errorBody('INTERNAL_SERVER_ERROR'),
      );
      await expectLater(
        container.read(savedItemsProvider.future),
        throwsA(isA<Object>()),
      );

      await container.read(savedItemsProvider.notifier).refresh();

      expect(container.read(savedItemsProvider), isA<AsyncError>());
      expect(adapter.countFor('/saved-items'), 2);
      expect(
        noticeOf(container)?.copy,
        "Couldn't refresh. Check your connection.",
      );
    });

    test('a failed refresh clears an in-flight load-more marker', () async {
      final container = await makeContainer();
      addTearDown(container.dispose);

      adapter.onSequenceHolding('/saved-items', [
        FakeReply(
          200,
          SavedItemsFixtures.page(
            items: [SavedItemsFixtures.item(id: 'a')],
            nextCursor: 'cursor-2',
            hasMore: true,
          ),
        ),
        // Held page two, which will never be used.
        FakeReply(
          200,
          SavedItemsFixtures.page(
            items: [SavedItemsFixtures.item(id: 'old-page')],
            hasMore: true,
          ),
        ),
        // The failed refresh.
        FakeReply.error(500, 'INTERNAL_SERVER_ERROR'),
      ], holdAt: 2);

      await container.read(savedItemsProvider.future);
      final notifier = container.read(savedItemsProvider.notifier);

      final more = notifier.loadMore();
      await untilCalled(() => adapter.countFor('/saved-items') == 2);

      await notifier.refresh();

      final afterFailure = stateOf(container);
      expect(afterFailure.items.map((i) => i.id), ['a']);
      expect(afterFailure.nextCursor, 'cursor-2');
      expect(afterFailure.isLoadingMore, isFalse);
      expect(container.read(savedItemsProvider).hasError, isFalse);

      adapter.releaseBlocked();
      await more;

      expect(stateOf(container).items.map((i) => i.id), ['a']);
      expect(stateOf(container).isLoadingMore, isFalse);
    });

    test(
      'a head refresh in flight is dropped when a manual refresh wins',
      () async {
        final container = await makeContainer();
        addTearDown(container.dispose);

        adapter.onSequenceHolding('/saved-items', [
          FakeReply(
            200,
            SavedItemsFixtures.page(
              items: [SavedItemsFixtures.item(id: 'a')],
              nextCursor: 'cursor-2',
              hasMore: true,
            ),
          ),
          // The head the save produced, held until the manual refresh lands.
          FakeReply(
            200,
            SavedItemsFixtures.page(
              items: [
                SavedItemsFixtures.item(id: 'saved'),
                SavedItemsFixtures.item(id: 'a'),
              ],
              nextCursor: 'cursor-2',
              hasMore: true,
            ),
          ),
          FakeReply(
            200,
            SavedItemsFixtures.page(
              items: [SavedItemsFixtures.item(id: 'fresh')],
              nextCursor: 'cursor-fresh',
              hasMore: true,
            ),
          ),
        ], holdAt: 2);

        await container.read(savedItemsProvider.future);
        final notifier = container.read(savedItemsProvider.notifier);

        final head = notifier.refreshHead();
        await untilCalled(() => adapter.countFor('/saved-items') == 2);

        await notifier.refresh();

        expect(stateOf(container).items.map((i) => i.id), ['fresh']);

        adapter.releaseBlocked();
        await head;

        final state = stateOf(container);
        expect(
          state.items.map((i) => i.id),
          ['fresh'],
          reason:
              'the manual refresh started a new list; the old head is stale',
        );
        expect(state.nextCursor, 'cursor-fresh');
        expect(state.isLoadingMore, isFalse);
      },
    );

    test('a stale refresh failure cannot overwrite a newer build', () async {
      final container = await makeContainer();
      addTearDown(container.dispose);

      adapter.onSequenceHolding('/saved-items', [
        FakeReply(
          200,
          SavedItemsFixtures.page(
            items: [SavedItemsFixtures.item(id: 'a')],
            nextCursor: 'cursor-2',
            hasMore: true,
          ),
        ),
        // The refresh, held until a rebuild has replaced the list.
        FakeReply.error(500, 'INTERNAL_SERVER_ERROR'),
        FakeReply(
          200,
          SavedItemsFixtures.page(
            items: [SavedItemsFixtures.item(id: 'rebuilt')],
            nextCursor: 'cursor-rebuilt',
            hasMore: true,
          ),
        ),
      ], holdAt: 2);

      await container.read(savedItemsProvider.future);
      final notifier = container.read(savedItemsProvider.notifier);

      final refresh = notifier.refresh();
      await untilCalled(() => adapter.countFor('/saved-items') == 2);

      await notifier.retry();
      await container.read(savedItemsProvider.future);

      expect(stateOf(container).items.map((i) => i.id), ['rebuilt']);

      adapter.releaseBlocked();
      await refresh;

      final state = stateOf(container);
      expect(state.items.map((i) => i.id), [
        'rebuilt',
      ], reason: 'the newer build owns the list; the old failure is stale');
      expect(state.nextCursor, 'cursor-rebuilt');
      expect(container.read(savedItemsProvider).hasError, isFalse);
      expect(
        noticeOf(container),
        isNull,
        reason: 'a stale failure must not announce itself over a newer list',
      );
    });
  });

  group('integration with the protected pipeline', () {
    const session = AuthTokens(
      accessToken: 'access-1',
      refreshToken: 'refresh-1',
    );

    test('the request carries the bearer token from the session', () async {
      // Issued over `appDio`, so the interceptor attaches the token. This feature
      // does not know that, and must not re-implement it.
      final container = await makeContainer(session: session);

      scriptPages([SavedItemsFixtures.emptyPage()]);
      await container.read(savedItemsProvider.future);

      expect(adapter.lastRequestTo('/saved-items')!.bearer, 'access-1');
    });

    test('an expired token is renewed and replayed without help from this '
        'feature', () async {
      final container = await makeContainer(session: session);

      adapter.onExpiring(
        '/saved-items',
        FakeReply.error(401, 'ACCESS_TOKEN_EXPIRED'),
        FakeReply(200, SavedItemsFixtures.emptyPage()),
        retriedMarker: 'auth_retried',
      );
      adapter.on(
        '/auth/refresh',
        body: {
          'data': {'access_token': 'access-2', 'refresh_token': 'refresh-2'},
          'message': 'token refreshed successfully',
        },
      );

      await container.read(savedItemsProvider.future);

      expect(
        adapter.countFor('/auth/refresh'),
        1,
        reason: 'the interceptor renewed on its own; nothing here asked it to',
      );
      expect(container.read(savedItemsProvider).hasError, isFalse);
    });
  });
}
