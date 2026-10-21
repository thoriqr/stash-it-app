import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_it_app/app/network/network_providers.dart';
import 'package:stash_it_app/core/error/api_failure.dart';
import 'package:stash_it_app/core/storage/secure_credential_store.dart';
import 'package:stash_it_app/features/auth/application/session_controller.dart';
import 'package:stash_it_app/features/saved_items/application/saved_item_detail_provider.dart';

import '../../../support/fake_http.dart';
import '../../../support/saved_items_fixtures.dart';

/// The detail provider against the real graph — repository, Retrofit, `appDio`.
///
/// No socket is opened: every request goes through a scripted transport. What
/// this file establishes is that opening a detail reads the item once, that a
/// failure is surfaced as the typed `ApiFailure`, and that the provider does not
/// retry itself.
void main() {
  const id = '01a0f359-093b-737a-963a-80f7ca6768ed';
  const path = '/saved-items/$id';

  /// Past the 200 ms and 600 ms retries Riverpod's default policy would run.
  const retryWindow = Duration(milliseconds: 1200);

  late FakeHttpAdapter adapter;

  setUp(() {
    adapter = FakeHttpAdapter();
  });

  /// A container over the real network graph.
  ///
  /// [defaultRetry] is false for the ordinary cases, where a retry would only
  /// slow a failure test and corrupt the request count. The one test that is
  /// *about* the policy uses Riverpod's real defaults, so suppression there
  /// would mask the defect the override prevents.
  ProviderContainer makeContainer({bool defaultRetry = false}) {
    final container = ProviderContainer(
      overrides: [
        credentialStoreProvider.overrideWithValue(
          SecureCredentialStore(InMemorySecureStorage()),
        ),
        restoredTokensProvider.overrideWithValue(null),
      ],
      retry: defaultRetry ? null : (_, _) => null,
    );
    addTearDown(container.dispose);

    container.read(appDioProvider).httpClientAdapter = adapter;
    container.read(refreshDioProvider).httpClientAdapter = adapter;
    return container;
  }

  group('a successful read', () {
    test('fetches the item once and maps the sibling collection', () async {
      final container = makeContainer();
      adapter.onMethod(
        'GET',
        path,
        body: SavedItemsFixtures.detail(
          id: id,
          title: 'One item',
          collectionName: 'Wishlist',
        ),
      );

      final item = await container.read(savedItemDetailProvider(id).future);

      expect(item.id, id);
      expect(item.title, 'One item');
      expect(item.collectionName, 'Wishlist');
      expect(adapter.countFor(path), 1);

      final request = adapter.requests.single;
      expect(request.method, 'GET');
      expect(
        request.path.contains('/enrich'),
        isFalse,
        reason: 'opening the detail never enriches',
      );
    });

    test('is keyed by id, so two items are two reads', () async {
      final container = makeContainer();
      adapter.onMethod(
        'GET',
        '/saved-items/first',
        body: SavedItemsFixtures.detail(id: 'first'),
      );
      adapter.onMethod(
        'GET',
        '/saved-items/second',
        body: SavedItemsFixtures.detail(id: 'second'),
      );

      final first = await container.read(
        savedItemDetailProvider('first').future,
      );
      final second = await container.read(
        savedItemDetailProvider('second').future,
      );

      expect(first.id, 'first');
      expect(second.id, 'second');
      expect(adapter.countFor('/saved-items/first'), 1);
      expect(adapter.countFor('/saved-items/second'), 1);
    });
  });

  group('failures', () {
    test('surfaces the verified not-found variant', () async {
      final container = makeContainer();
      adapter.onMethod(
        'GET',
        path,
        status: 404,
        body: errorBody('RESOURCE_NOT_FOUND'),
      );

      await expectLater(
        container.read(savedItemDetailProvider(id).future),
        throwsA(isA<ApiFailureNotFound>()),
      );
    });

    test('an unreadable 404 stays unreadable', () async {
      final container = makeContainer();
      adapter.onMethod(
        'GET',
        path,
        status: 404,
        body: '<html><body>Not found</body></html>',
      );

      await expectLater(
        container.read(savedItemDetailProvider(id).future),
        throwsA(isA<ApiFailureUnreadableResponse>()),
      );
    });
  });

  group('manual retry', () {
    test('invalidating produces exactly one new GET', () async {
      final container = makeContainer();
      adapter.onSequence(path, [
        FakeReply.error(500, 'INTERNAL_SERVER_ERROR'),
        FakeReply(200, SavedItemsFixtures.detail(id: id)),
      ]);

      final provider = savedItemDetailProvider(id);
      final subscription = container.listen(provider, (_, _) {});
      addTearDown(subscription.close);

      await expectLater(
        container.read(provider.future),
        throwsA(isA<ApiFailureServerFault>()),
      );
      expect(adapter.countFor(path), 1);

      container.invalidate(provider);

      final item = await container.read(provider.future);
      expect(item.id, id);
      expect(
        adapter.countFor(path),
        2,
        reason: 'the retry is one fresh read, not a loop',
      );
      expect(
        container.read(provider),
        isA<AsyncData<Object?>>(),
        reason: 'the recovered item replaces the error',
      );
    });
  });

  group('no automatic retry', () {
    test('the no-retry policy is attached to the provider', () {
      expect(
        savedItemDetailProvider(id).retry,
        isNotNull,
        reason: 'the provider must carry its own policy, not the default',
      );
    });

    test('a failed read is not retried automatically', () async {
      // Riverpod's real default policy, deliberately not overridden. Without the
      // provider's own `retry: _neverRetry`, it would rebuild this provider at
      // 200 ms and 600 ms, and every rebuild is another GET.
      final container = makeContainer(defaultRetry: true);
      adapter.onMethod(
        'GET',
        path,
        status: 500,
        body: errorBody('INTERNAL_SERVER_ERROR'),
      );

      final provider = savedItemDetailProvider(id);
      // A listener is load-bearing: `invalidateSelf` only schedules a rebuild
      // while the element is active, and an unlistened auto-dispose provider is
      // inert. The screen supplies this listener in the real app by watching it.
      final subscription = container.listen(provider, (_, _) {});
      addTearDown(subscription.close);

      container.read(provider);
      await Future<void>.delayed(retryWindow);

      expect(
        adapter.countFor(path),
        1,
        reason:
            'one GET. A retry would present the refresh token again and could '
            'revoke the session the client had preserved.',
      );

      final state = container.read(provider);
      expect(state, isA<AsyncError>());
      expect(
        state.isLoading,
        isFalse,
        reason: 'a pending retry would leave the screen on the skeleton',
      );
      expect(state.error, isA<ApiFailureServerFault>());
    });
  });
}
