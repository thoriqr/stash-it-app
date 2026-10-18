import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_it_app/app/network/network_providers.dart';
import 'package:stash_it_app/core/storage/secure_credential_store.dart';
import 'package:stash_it_app/features/auth/data/models/auth_tokens.dart';
import 'package:stash_it_app/features/auth/application/session_controller.dart';
import 'package:stash_it_app/features/saved_items/application/saved_items_controller.dart';
import 'package:stash_it_app/features/saved_items/application/saved_items_state.dart';

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

      scriptPages([
        SavedItemsFixtures.page(items: [SavedItemsFixtures.item(id: 'a')]),
      ]);
      await container.read(savedItemsProvider.notifier).retry();
      await container.read(savedItemsProvider.future);

      expect(stateOf(container).items.map((i) => i.id), ['a']);
    });
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
