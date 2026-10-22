import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_it_app/app/feedback/app_feedback.dart';
import 'package:stash_it_app/app/feedback/feedback_controller.dart';
import 'package:stash_it_app/app/network/network_providers.dart';
import 'package:stash_it_app/core/error/api_failure.dart';
import 'package:stash_it_app/core/storage/secure_credential_store.dart';
import 'package:stash_it_app/features/auth/application/session_controller.dart';
import 'package:stash_it_app/features/saved_items/application/collection_saved_items_controller.dart';
import 'package:stash_it_app/features/saved_items/application/collection_saved_items_state.dart';

import '../../../support/collection_saved_items_fixtures.dart';
import '../../../support/fake_http.dart';

/// The collection detail controller: first page, retry, refresh, pagination.
///
/// Drives the **real** provider graph — repository, Retrofit client and `appDio`
/// — against a scripted transport. No socket is opened, and the endpoint's path is
/// distinctive enough that no other route can answer for it.
void main() {
  const collectionId = 'collection-1';
  const path = '/collections/collection-1/saved-items';

  final provider = collectionSavedItemsProvider(collectionId);

  late FakeHttpAdapter adapter;

  /// A container with a scripted transport and no automatic provider retry.
  ///
  /// `retry: (_, _) => null` because Riverpod 3 retries a failed provider up to
  /// ten times with backoff, which would slow the error cases and corrupt the
  /// request counts asserted here.
  Future<ProviderContainer> makeContainer() async {
    final made = ProviderContainer(
      overrides: [
        credentialStoreProvider.overrideWithValue(
          SecureCredentialStore(InMemorySecureStorage()),
        ),
        restoredTokensProvider.overrideWithValue(null),
      ],
      retry: (_, _) => null,
    );
    made.read(appDioProvider).httpClientAdapter = adapter;
    made.read(refreshDioProvider).httpClientAdapter = adapter;
    // The provider is auto-dispose, so a bare `read` leaves nothing listening and
    // it would be thrown away at the end of the microtask — every assertion
    // afterwards would see a fresh `AsyncLoading` instead of the state under
    // test. A listener is what a mounted screen supplies in the app.
    made.listen(provider, (_, _) {});
    addTearDown(made.dispose);
    return made;
  }

  /// The loaded state, or a failure if the provider is not in a success state.
  CollectionSavedItemsState stateOf(ProviderContainer container) =>
      switch (container.read(provider)) {
        AsyncData(:final value) => value,
        final other => throw StateError('expected data, got $other'),
      };

  /// The app-wide notice currently showing, if any.
  AppFeedback? noticeOf(ProviderContainer container) =>
      container.read(feedbackProvider);

  /// The cursors sent, in order, with an absent parameter read as null.
  List<String?> sentCursors() => [
    for (final request in adapter.requests)
      Uri.parse(request.path).queryParameters['cursor'],
  ];

  Future<ProviderContainer> containerWith(String collectionName) async {
    final container = await makeContainer();
    adapter.onSequence(path, [
      FakeReply(
        200,
        CollectionSavedItemsFixtures.emptyPage(
          collectionId: collectionId,
          collectionName: collectionName,
        ),
      ),
    ]);
    await container.read(provider.future);
    return container;
  }

  FakeReply pageReply({
    List<Map<String, dynamic>> items = const [],
    String? nextCursor,
    bool hasMore = false,
    String collectionName = 'Camera Gear',
  }) => FakeReply(
    200,
    CollectionSavedItemsFixtures.page(
      items: items,
      collectionId: collectionId,
      collectionName: collectionName,
      nextCursor: nextCursor,
      hasMore: hasMore,
    ),
  );

  setUp(() {
    adapter = FakeHttpAdapter();
  });

  group('first page', () {
    test('loads the rows, the collection name and the cursor', () async {
      final container = await makeContainer();

      adapter.onSequence(path, [
        pageReply(
          items: [
            CollectionSavedItemsFixtures.item(id: 'a', title: 'First'),
            CollectionSavedItemsFixtures.item(id: 'b', title: 'Second'),
          ],
          nextCursor: 'cursor-2',
          hasMore: true,
          collectionName: 'Wishlist',
        ),
      ]);

      await container.read(provider.future);

      final state = stateOf(container);
      expect(state.collectionId, collectionId);
      expect(state.collectionName, 'Wishlist');
      expect(state.items.map((item) => item.id), ['a', 'b']);
      expect(state.nextCursor, 'cursor-2');
      expect(state.hasMore, isTrue);
      expect(state.isLoadingMore, isFalse);
      expect(state.loadMoreFailed, isFalse);
    });

    test('an empty collection is a successful empty result', () async {
      final container = await makeContainer();

      adapter.onSequence(path, [pageReply(collectionName: 'Empty Box')]);

      await container.read(provider.future);

      final state = stateOf(container);
      expect(state.items, isEmpty);
      expect(state.collectionName, 'Empty Box');
      expect(state.hasMore, isFalse);
      expect(container.read(provider).hasError, isFalse);
    });

    test('sends no cursor and no limit on the opening request', () async {
      await containerWith('Camera Gear');

      final query = Uri.parse(adapter.requests.single.path).queryParameters;

      expect(query.containsKey('cursor'), isFalse);
      expect(
        query.containsKey('limit'),
        isFalse,
        reason: 'the server owns the default and the cap (AGENTS.md §3)',
      );
    });

    test('COLLECTION_NOT_FOUND is a not-found failure', () async {
      final container = await makeContainer();

      adapter.onSequence(path, [FakeReply.error(404, 'COLLECTION_NOT_FOUND')]);

      await expectLater(
        container.read(provider.future),
        throwsA(isA<ApiFailureNotFound>()),
      );

      final failure = container.read(provider).error;
      expect(failure, isA<ApiFailureNotFound>());
      expect(
        (failure! as ApiFailureNotFound).code,
        'COLLECTION_NOT_FOUND',
        reason: 'retained for diagnosis, never displayed',
      );
    });

    test(
      'has_more without a cursor is unreadable, and cannot be paged',
      () async {
        final container = await makeContainer();

        adapter.onSequence(path, [
          pageReply(
            items: [CollectionSavedItemsFixtures.item(id: 'a')],
            hasMore: true,
          ),
        ]);

        await expectLater(
          container.read(provider.future),
          throwsA(isA<ApiFailureUnreadableResponse>()),
        );

        final before = adapter.countFor(path);
        await container.read(provider.notifier).loadMore();

        expect(
          adapter.countFor(path),
          before,
          reason:
              'a page that cannot be continued must not start another request',
        );
      },
    );
  });

  group('pagination', () {
    /// Page one (a, b), page two (c), page three (d, final).
    Future<ProviderContainer> threePages() async {
      final container = await makeContainer();
      adapter.onSequence(path, [
        pageReply(
          items: [
            CollectionSavedItemsFixtures.item(id: 'a', title: 'First'),
            CollectionSavedItemsFixtures.item(id: 'b', title: 'Second'),
          ],
          nextCursor: 'cursor-2',
          hasMore: true,
        ),
        pageReply(
          items: [CollectionSavedItemsFixtures.item(id: 'c', title: 'Third')],
          nextCursor: 'cursor-3',
          hasMore: true,
        ),
        pageReply(
          items: [CollectionSavedItemsFixtures.item(id: 'd', title: 'Fourth')],
        ),
      ]);

      await container.read(provider.future);
      return container;
    }

    test('appends the next page and advances the cursor', () async {
      final container = await threePages();

      await container.read(provider.notifier).loadMore();

      final state = stateOf(container);
      expect(state.items.map((item) => item.id), ['a', 'b', 'c']);
      expect(state.nextCursor, 'cursor-3');
      expect(state.hasMore, isTrue);
      expect(state.isLoadingMore, isFalse);
    });

    test('sends each cursor back unchanged', () async {
      final container = await threePages();
      final notifier = container.read(provider.notifier);

      await notifier.loadMore();
      await notifier.loadMore();

      expect(sentCursors(), [null, 'cursor-2', 'cursor-3']);
    });

    test(
      'skips an id already on screen instead of duplicating the row',
      () async {
        final container = await makeContainer();

        // An item moved into this collection between two page fetches can appear
        // in both; the conformance of the server is not what this protects.
        adapter.onSequence(path, [
          pageReply(
            items: [CollectionSavedItemsFixtures.item(id: 'a')],
            nextCursor: 'cursor-2',
            hasMore: true,
          ),
          pageReply(
            items: [
              CollectionSavedItemsFixtures.item(id: 'a'),
              CollectionSavedItemsFixtures.item(id: 'b'),
            ],
          ),
        ]);

        await container.read(provider.future);
        await container.read(provider.notifier).loadMore();

        expect(stateOf(container).items.map((item) => item.id), ['a', 'b']);
      },
    );

    test('stops after the final page', () async {
      final container = await threePages();
      final notifier = container.read(provider.notifier);

      await notifier.loadMore();
      await notifier.loadMore();

      expect(stateOf(container).hasMore, isFalse);
      expect(stateOf(container).nextCursor, isNull);

      final requests = adapter.countFor(path);
      await notifier.loadMore();

      expect(adapter.countFor(path), requests);
    });

    test('does not stack requests while a page is in flight', () async {
      final container = await makeContainer();

      adapter.onSequence(path, [
        pageReply(
          items: [CollectionSavedItemsFixtures.item(id: 'a')],
          nextCursor: 'cursor-2',
          hasMore: true,
        ),
        pageReply(items: [CollectionSavedItemsFixtures.item(id: 'b')]),
      ]);

      await container.read(provider.future);
      final notifier = container.read(provider.notifier);

      // Issued back to back, the way repeated scroll notifications arrive. The
      // first sets `isLoadingMore` before it yields, so the second must decline.
      final first = notifier.loadMore();
      final second = notifier.loadMore();
      await Future.wait([first, second]);

      expect(
        adapter.countFor(path),
        2,
        reason: 'one request for page one and one for page two, not three',
      );
      expect(stateOf(container).items.map((item) => item.id), ['a', 'b']);
    });

    test(
      'keeps the loaded rows when a page fails, and marks the page',
      () async {
        final container = await makeContainer();

        adapter.onSequence(path, [
          pageReply(
            items: [CollectionSavedItemsFixtures.item(id: 'a')],
            nextCursor: 'cursor-2',
            hasMore: true,
          ),
          FakeReply(500, errorBody('INTERNAL_SERVER_ERROR')),
        ]);

        await container.read(provider.future);
        await container.read(provider.notifier).loadMore();

        final state = stateOf(container);
        expect(state.items.map((item) => item.id), ['a']);
        expect(state.nextCursor, 'cursor-2');
        expect(state.isLoadingMore, isFalse);
        expect(state.loadMoreFailed, isTrue);
        expect(container.read(provider).hasError, isFalse);
        expect(
          noticeOf(container),
          isNull,
          reason: 'a pagination failure is not a manual refresh',
        );
      },
    );

    test('scrolling does not retry the failed cursor', () async {
      final container = await makeContainer();

      adapter.onSequence(path, [
        pageReply(
          items: [CollectionSavedItemsFixtures.item(id: 'a')],
          nextCursor: 'cursor-2',
          hasMore: true,
        ),
        FakeReply(500, errorBody('INTERNAL_SERVER_ERROR')),
      ]);

      await container.read(provider.future);
      final notifier = container.read(provider.notifier);
      await notifier.loadMore();

      final failedAt = adapter.countFor(path);

      // Three more scroll notifications' worth of calls.
      await notifier.loadMore();
      await notifier.loadMore();
      await notifier.loadMore();

      expect(
        adapter.countFor(path),
        failedAt,
        reason: 'only the footer Retry may resume a failed cursor',
      );
      expect(stateOf(container).loadMoreFailed, isTrue);
    });

    test('Retry uses the cursor that failed and resumes paging', () async {
      final container = await makeContainer();

      adapter.onSequence(path, [
        pageReply(
          items: [CollectionSavedItemsFixtures.item(id: 'a')],
          nextCursor: 'cursor-2',
          hasMore: true,
        ),
        FakeReply(500, errorBody('INTERNAL_SERVER_ERROR')),
        pageReply(items: [CollectionSavedItemsFixtures.item(id: 'b')]),
      ]);

      await container.read(provider.future);
      final notifier = container.read(provider.notifier);

      await notifier.loadMore();
      await notifier.retryLoadMore();

      expect(sentCursors(), [null, 'cursor-2', 'cursor-2']);

      final state = stateOf(container);
      expect(state.items.map((item) => item.id), ['a', 'b']);
      expect(state.loadMoreFailed, isFalse);
      expect(state.hasMore, isFalse);
      expect(state.nextCursor, isNull);
    });

    test('repeated Retry taps do not stack page requests', () async {
      final container = await makeContainer();

      adapter.onSequence(path, [
        pageReply(
          items: [CollectionSavedItemsFixtures.item(id: 'a')],
          nextCursor: 'cursor-2',
          hasMore: true,
        ),
        FakeReply(500, errorBody('INTERNAL_SERVER_ERROR')),
        pageReply(items: [CollectionSavedItemsFixtures.item(id: 'b')]),
      ]);

      await container.read(provider.future);
      final notifier = container.read(provider.notifier);
      await notifier.loadMore();

      // Two taps before either request yields.
      final first = notifier.retryLoadMore();
      final second = notifier.retryLoadMore();
      await Future.wait([first, second]);

      expect(
        adapter.countFor(path),
        3,
        reason: 'page one, the failure and exactly one retry',
      );
      expect(stateOf(container).items.map((item) => item.id), ['a', 'b']);
    });

    test('a repeated cursor fails the page instead of looping', () async {
      final container = await makeContainer();

      adapter.onSequence(path, [
        pageReply(
          items: [CollectionSavedItemsFixtures.item(id: 'a')],
          nextCursor: 'cursor-2',
          hasMore: true,
        ),
        // The server did not advance: it answered with the cursor it was given.
        pageReply(
          items: [CollectionSavedItemsFixtures.item(id: 'b')],
          nextCursor: 'cursor-2',
          hasMore: true,
        ),
      ]);

      await container.read(provider.future);
      final notifier = container.read(provider.notifier);

      await notifier.loadMore();
      await notifier.loadMore();
      await notifier.loadMore();

      expect(
        adapter.countFor(path),
        2,
        reason: 'a cursor already consumed is never sent again automatically',
      );
      expect(stateOf(container).loadMoreFailed, isTrue);
      expect(stateOf(container).items.map((item) => item.id), ['a', 'b']);
    });

    test('a later page with has_more but no cursor fails the page', () async {
      final container = await makeContainer();

      adapter.onSequence(path, [
        pageReply(
          items: [CollectionSavedItemsFixtures.item(id: 'a')],
          nextCursor: 'cursor-2',
          hasMore: true,
        ),
        pageReply(
          items: [CollectionSavedItemsFixtures.item(id: 'b')],
          hasMore: true,
        ),
      ]);

      await container.read(provider.future);
      final notifier = container.read(provider.notifier);

      await notifier.loadMore();

      expect(stateOf(container).items.map((item) => item.id), ['a']);
      expect(stateOf(container).loadMoreFailed, isTrue);

      final requests = adapter.countFor(path);
      await notifier.loadMore();

      expect(
        adapter.countFor(path),
        requests,
        reason: 'an unusable continuation is reported, not requested again',
      );
    });
  });

  group('first-page retry', () {
    test('refetches and replaces the error, resetting pagination', () async {
      final container = await makeContainer();

      adapter.onSequence(path, [
        FakeReply(500, errorBody('INTERNAL_SERVER_ERROR')),
        pageReply(
          items: [CollectionSavedItemsFixtures.item(id: 'a')],
          nextCursor: 'cursor-2',
          hasMore: true,
        ),
      ]);

      await expectLater(
        container.read(provider.future),
        throwsA(isA<ApiFailureServerFault>()),
      );

      await container.read(provider.notifier).retry();

      final state = stateOf(container);
      expect(state.items.map((item) => item.id), ['a']);
      expect(state.nextCursor, 'cursor-2');
      expect(state.loadMoreFailed, isFalse);
      expect(sentCursors(), [null, null]);
    });

    test('repeated taps share one request', () async {
      final container = await makeContainer();

      adapter.onSequence(path, [
        FakeReply(500, errorBody('INTERNAL_SERVER_ERROR')),
        pageReply(items: [CollectionSavedItemsFixtures.item(id: 'a')]),
      ]);

      await expectLater(
        container.read(provider.future),
        throwsA(isA<ApiFailureServerFault>()),
      );

      final notifier = container.read(provider.notifier);
      final first = notifier.retry();
      final second = notifier.retry();
      await Future.wait([first, second]);

      expect(
        adapter.countFor(path),
        2,
        reason: 'the failed first load and exactly one retry',
      );
    });
  });

  group('refresh', () {
    test('replaces the rows and the cursor with the new head', () async {
      final container = await makeContainer();

      adapter.onSequence(path, [
        pageReply(
          items: [CollectionSavedItemsFixtures.item(id: 'a')],
          nextCursor: 'cursor-2',
          hasMore: true,
        ),
        pageReply(
          items: [CollectionSavedItemsFixtures.item(id: 'fresh')],
          collectionName: 'Renamed',
        ),
      ]);

      await container.read(provider.future);
      await container.read(provider.notifier).refresh();

      final state = stateOf(container);
      expect(state.items.map((item) => item.id), ['fresh']);
      expect(state.collectionName, 'Renamed');
      expect(state.nextCursor, isNull);
      expect(state.hasMore, isFalse);
    });

    test('the next page continues from the refreshed cursor', () async {
      final container = await makeContainer();

      adapter.onSequence(path, [
        pageReply(
          items: [CollectionSavedItemsFixtures.item(id: 'a')],
          nextCursor: 'cursor-2',
          hasMore: true,
        ),
        pageReply(
          items: [CollectionSavedItemsFixtures.item(id: 'b')],
          nextCursor: 'cursor-9',
          hasMore: true,
        ),
        pageReply(items: [CollectionSavedItemsFixtures.item(id: 'c')]),
      ]);

      await container.read(provider.future);
      final notifier = container.read(provider.notifier);

      await notifier.refresh();
      await notifier.loadMore();

      expect(sentCursors(), [null, null, 'cursor-9']);
      expect(stateOf(container).items.map((item) => item.id), ['b', 'c']);
    });

    test('a failed refresh keeps the rows and publishes one notice', () async {
      final container = await makeContainer();

      adapter.onSequence(path, [
        pageReply(
          items: [CollectionSavedItemsFixtures.item(id: 'a')],
          nextCursor: 'cursor-2',
          hasMore: true,
        ),
        FakeReply(500, errorBody('INTERNAL_SERVER_ERROR')),
      ]);

      await container.read(provider.future);
      await container.read(provider.notifier).refresh();

      final state = stateOf(container);
      expect(state.items.map((item) => item.id), ['a']);
      expect(state.nextCursor, 'cursor-2');
      expect(state.hasMore, isTrue);
      expect(container.read(provider).hasError, isFalse);

      final notice = noticeOf(container);
      expect(notice, isNotNull);
      expect(notice!.copy, contains("Couldn't refresh"));
    });

    test(
      'a failed refresh with nothing loaded becomes an error state',
      () async {
        final container = await makeContainer();

        adapter.onSequence(path, [
          pageReply(),
          FakeReply(500, errorBody('INTERNAL_SERVER_ERROR')),
        ]);

        await container.read(provider.future);
        await container.read(provider.notifier).refresh();

        expect(container.read(provider).hasError, isTrue);
        expect(container.read(provider).error, isA<ApiFailureServerFault>());
      },
    );

    test('a page in flight cannot append to a refreshed list', () async {
      final container = await makeContainer();

      adapter.onSequenceHolding(path, [
        pageReply(
          items: [CollectionSavedItemsFixtures.item(id: 'a')],
          nextCursor: 'cursor-2',
          hasMore: true,
        ),
        pageReply(items: [CollectionSavedItemsFixtures.item(id: 'stale')]),
        pageReply(items: [CollectionSavedItemsFixtures.item(id: 'fresh')]),
      ], holdAt: 2);

      await container.read(provider.future);

      final notifier = container.read(provider.notifier);
      final stalePage = notifier.loadMore();
      await untilCalled(() => adapter.countFor(path) == 2);

      await notifier.refresh();
      expect(stateOf(container).items.map((item) => item.id), ['fresh']);

      adapter.releaseBlocked();
      await stalePage;

      expect(
        stateOf(container).items.map((item) => item.id),
        ['fresh'],
        reason:
            'a page fetched against the old list must not land in the new one',
      );
    });
  });
}
