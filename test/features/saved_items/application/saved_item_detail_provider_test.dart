import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_it_app/app/network/network_providers.dart';
import 'package:stash_it_app/core/error/api_failure.dart';
import 'package:stash_it_app/core/storage/secure_credential_store.dart';
import 'package:stash_it_app/features/auth/application/session_controller.dart';
import 'package:stash_it_app/features/saved_items/application/saved_item_detail_provider.dart';
import 'package:stash_it_app/features/saved_items/domain/saved_item_enrichment_result.dart';
import 'package:stash_it_app/features/saved_items/domain/saved_item_summary.dart';

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

  group('applying a confirmed re-read', () {
    SavedItemEnrichmentResult result({
      String savedItemId = id,
      EnrichmentStatus status = EnrichmentStatus.completed,
      String? title = 'Re-read title',
      String? description = 'Re-read description.',
      String? imageUrl = 'https://example.com/new.png',
    }) => SavedItemEnrichmentResult(
      savedItemId: savedItemId,
      enrichmentStatus: status,
      title: title,
      description: description,
      imageUrl: imageUrl,
    );

    /// Loads the detail, then keeps it alive while the test patches it.
    Future<ProviderContainer> loaded() async {
      final container = makeContainer();
      adapter.onMethod(
        'GET',
        path,
        body: SavedItemsFixtures.detail(
          id: id,
          title: 'Old title',
          description: 'Old description.',
          imageUrl: 'https://example.com/old.png',
          enrichmentStatus: 'pending',
          collectionId: 'collection-42',
          collectionName: 'Wishlist',
        ),
      );

      final provider = savedItemDetailProvider(id);
      final subscription = container.listen(provider, (_, _) {});
      addTearDown(subscription.close);

      await container.read(provider.future);
      return container;
    }

    test('replaces the four fields without issuing a request', () async {
      final container = await loaded();

      container
          .read(savedItemDetailProvider(id).notifier)
          .applyEnrichment(result());

      final item = container.read(savedItemDetailProvider(id)).value!;
      expect(item.title, 'Re-read title');
      expect(item.description, 'Re-read description.');
      expect(item.imageUrl, 'https://example.com/new.png');
      expect(item.enrichmentStatus, EnrichmentStatus.completed);
      expect(
        adapter.countFor(path),
        1,
        reason: 'the POST already returned the complete post-attempt item',
      );
    });

    test('keeps the identity and collection the write cannot change', () async {
      final container = await loaded();
      final before = container.read(savedItemDetailProvider(id)).value!;

      container
          .read(savedItemDetailProvider(id).notifier)
          .applyEnrichment(result());

      final after = container.read(savedItemDetailProvider(id)).value!;
      expect(after.id, before.id);
      expect(after.url, before.url);
      expect(after.collectionId, 'collection-42');
      expect(
        after.collectionName,
        'Wishlist',
        reason: 'the enrich response carries no collection name to replace it',
      );
      expect(after.savedTimeLabel, before.savedTimeLabel);
    });

    test('an explicit null clears the previous value', () async {
      final container = await loaded();

      container
          .read(savedItemDetailProvider(id).notifier)
          .applyEnrichment(
            result(title: null, description: null, imageUrl: null),
          );

      final item = container.read(savedItemDetailProvider(id)).value!;
      expect(item.title, isNull);
      expect(item.description, isNull);
      expect(item.imageUrl, isNull);
      expect(
        item.hasNoMetadata,
        isTrue,
        reason: 'a completed attempt that found nothing is the empty state',
      );
    });

    test('a failed attempt is applied as recorded', () async {
      final container = await loaded();

      container
          .read(savedItemDetailProvider(id).notifier)
          .applyEnrichment(
            result(
              status: EnrichmentStatus.failed,
              title: 'Kept from the previous read',
              description: null,
              imageUrl: null,
            ),
          );

      final item = container.read(savedItemDetailProvider(id)).value!;
      expect(item.enrichmentStatus, EnrichmentStatus.failed);
      expect(item.title, 'Kept from the previous read');
      expect(item.hasNoMetadata, isFalse);
    });

    test('a result for another item is ignored', () async {
      final container = await loaded();

      container
          .read(savedItemDetailProvider(id).notifier)
          .applyEnrichment(result(savedItemId: 'another-item'));

      final item = container.read(savedItemDetailProvider(id)).value!;
      expect(item.title, 'Old title');
      expect(item.enrichmentStatus, EnrichmentStatus.pending);
    });

    test('a patch before the read completes is a no-op', () async {
      final container = makeContainer();
      adapter.onMethod(
        'GET',
        path,
        body: SavedItemsFixtures.detail(id: id, title: 'From the read'),
      );

      final provider = savedItemDetailProvider(id);
      final subscription = container.listen(provider, (_, _) {});
      addTearDown(subscription.close);

      // The notifier exists and its build is in flight, so there is nothing to
      // patch yet. This must stay silent rather than throwing or fabricating data.
      container.read(provider.notifier).applyEnrichment(result());

      final item = await container.read(provider.future);
      expect(item.title, 'From the read');
      expect(adapter.countFor(path), 1);
    });

    test('a failed read is not replaced by a re-read result', () async {
      final container = makeContainer();
      adapter.onMethod(
        'GET',
        path,
        status: 500,
        body: errorBody('INTERNAL_SERVER_ERROR'),
      );

      final provider = savedItemDetailProvider(id);
      final subscription = container.listen(provider, (_, _) {});
      addTearDown(subscription.close);

      await expectLater(
        container.read(provider.future),
        throwsA(isA<ApiFailureServerFault>()),
      );

      container.read(provider.notifier).applyEnrichment(result());

      final state = container.read(provider);
      expect(
        state,
        isA<AsyncError<SavedItemSummary>>(),
        reason: 'no data was loaded, so there was no row to patch',
      );
      expect(adapter.countFor(path), 1);
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
