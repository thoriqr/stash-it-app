import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_it_app/app/feedback/app_feedback.dart';
import 'package:stash_it_app/app/feedback/feedback_controller.dart';
import 'package:stash_it_app/core/error/api_failure.dart';
import 'package:stash_it_app/core/storage/secure_credential_store.dart';
import 'package:stash_it_app/features/auth/application/session_controller.dart';
import 'package:stash_it_app/features/auth/data/models/auth_tokens.dart';
import 'package:stash_it_app/features/collections/application/collections_controller.dart';
import 'package:stash_it_app/features/collections/data/collections_providers.dart';
import 'package:stash_it_app/features/collections/domain/collection_page.dart';
import 'package:stash_it_app/features/saved_items/application/collection_saved_items_controller.dart';
import 'package:stash_it_app/features/saved_items/application/collection_saved_items_state.dart';
import 'package:stash_it_app/features/saved_items/application/enrich_saved_item_controller.dart';
import 'package:stash_it_app/features/saved_items/application/saved_item_detail_provider.dart';
import 'package:stash_it_app/features/saved_items/application/saved_items_controller.dart';
import 'package:stash_it_app/features/saved_items/application/saved_items_state.dart';
import 'package:stash_it_app/features/saved_items/data/saved_items_providers.dart';
import 'package:stash_it_app/features/saved_items/domain/collection_saved_items_page.dart';
import 'package:stash_it_app/features/saved_items/domain/saved_item_enrichment_result.dart';
import 'package:stash_it_app/features/saved_items/domain/saved_item_page.dart';
import 'package:stash_it_app/features/saved_items/domain/saved_item_summary.dart';

import '../../../support/fake_collections_repository.dart';
import '../../../support/fake_http.dart';
import '../../../support/fake_saved_items_repository.dart';

/// The re-read mutation: one POST per explicit action, the caches it patches in
/// place, and the copy every outcome produces.
///
/// The controller is exercised against a fake repository rather than the wire:
/// what matters here is what the client does with an answer, which the repository
/// test already pins to the payload. No provider is read unless a test seeds it,
/// so the "does this create a listing?" assertions are real.
void main() {
  const itemId = 'item-1';
  const collectionId = 'collection-1';

  SavedItemSummary summary({
    String id = itemId,
    String collectionId = collectionId,
    String? title = 'Understanding CRDTs',
    String? description = 'Conflict-free replicated data types converge.',
    String? imageUrl = 'https://example.com/og.png',
    EnrichmentStatus status = EnrichmentStatus.completed,
  }) => SavedItemSummary(
    id: id,
    collectionId: collectionId,
    url: 'https://example.com/articles/crdts-explained',
    collectionName: 'Camera Gear',
    enrichmentStatus: status,
    title: title,
    description: description,
    imageUrl: imageUrl,
    savedTimeLabel: 'Saved 2 hr ago',
  );

  SavedItemEnrichmentResult enriched({
    String savedItemId = itemId,
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

  CollectionSavedItemsPage collectionPage({
    List<SavedItemSummary>? items,
    String? nextCursor,
    bool hasMore = false,
  }) => CollectionSavedItemsPage(
    collectionId: collectionId,
    collectionName: 'Camera Gear',
    items: items ?? [summary()],
    nextCursor: nextCursor,
    hasMore: hasMore,
  );

  _Harness makeHarness({
    SavedItemPage? listPage,
    Future<SavedItemPage> Function(String? cursor)? onList,
    List<Object>? detailResults,
    List<Object> enrichResults = const [],
    Future<SavedItemEnrichmentResult> Function(String id)? onEnrich,
    List<Object>? collectionResults,
    Future<CollectionSavedItemsPage> Function(String, String?)?
    onListInCollection,
    bool signedIn = false,
  }) {
    final saved = FakeSavedItemsRepository(
      listPage:
          listPage ??
          SavedItemPage(items: [summary()], nextCursor: null, hasMore: false),
      onList: onList,
      detailResults: detailResults ?? [summary()],
      enrichResults: enrichResults,
      onEnrich: onEnrich,
      collectionResults: collectionResults ?? [collectionPage()],
      onListInCollection: onListInCollection,
    );
    final collections = FakeCollectionsRepository(
      results: const [
        CollectionPage(items: [], nextCursor: null, hasMore: false),
      ],
    );
    final container = ProviderContainer(
      overrides: [
        savedItemsRepositoryProvider.overrideWithValue(saved),
        collectionsRepositoryProvider.overrideWithValue(collections),
        credentialStoreProvider.overrideWithValue(
          SecureCredentialStore(InMemorySecureStorage()),
        ),
        restoredTokensProvider.overrideWithValue(
          signedIn
              ? const AuthTokens(accessToken: 'access', refreshToken: 'refresh')
              : null,
        ),
      ],
      retry: (_, _) => null,
    );
    return _Harness(
      container: container,
      saved: saved,
      collections: collections,
    );
  }

  AppFeedback? noticeOf(ProviderContainer container) =>
      container.read(feedbackProvider);

  SavedItemsState inboxOf(ProviderContainer container) =>
      switch (container.read(savedItemsProvider)) {
        AsyncData(:final value) => value,
        final other => throw StateError('expected data, got $other'),
      };

  CollectionSavedItemsState contentsOf(
    ProviderContainer container, {
    String id = collectionId,
  }) => switch (container.read(collectionSavedItemsProvider(id))) {
    AsyncData(:final value) => value,
    final other => throw StateError('expected data, got $other'),
  };

  /// Seeds the Inbox and keeps it alive for the rest of the test.
  Future<void> loadInbox(_Harness harness) async {
    harness.container.listen(savedItemsProvider, (_, _) {});
    await harness.container.read(savedItemsProvider.future);
  }

  /// Seeds one detail and keeps it alive, because it is auto-dispose.
  Future<void> loadDetail(_Harness harness, {String id = itemId}) async {
    harness.container.listen(savedItemDetailProvider(id), (_, _) {});
    await harness.container.read(savedItemDetailProvider(id).future);
  }

  /// Seeds one collection's contents and keeps them alive.
  Future<void> loadCollection(
    _Harness harness, {
    String id = collectionId,
  }) async {
    harness.container.listen(collectionSavedItemsProvider(id), (_, _) {});
    await harness.container.read(collectionSavedItemsProvider(id).future);
  }

  group('the request', () {
    test('one action sends one POST for the item', () async {
      final harness = makeHarness(enrichResults: [enriched()]);
      addTearDown(harness.container.dispose);

      await harness.container
          .read(enrichSavedItemProvider.notifier)
          .enrich(summary());

      expect(harness.saved.enrichCalls, 1);
      expect(harness.saved.enrichIds, [itemId]);
      expect(
        harness.saved.listCalls,
        0,
        reason: 'the answer is applied, never fetched again',
      );
    });

    test('a second tap while the first is in flight sends nothing', () async {
      final gate = Completer<SavedItemEnrichmentResult>();
      final harness = makeHarness(onEnrich: (_) => gate.future);
      addTearDown(harness.container.dispose);

      final controller = harness.container.read(
        enrichSavedItemProvider.notifier,
      );
      final first = controller.enrich(summary());
      final second = controller.enrich(summary());

      expect(
        harness.saved.enrichCalls,
        1,
        reason: 'the guard is set before the first await',
      );

      gate.complete(enriched());
      await Future.wait([first, second]);

      expect(harness.saved.enrichCalls, 1);
      expect(noticeOf(harness.container)?.copy, 'Page re-read.');
    });

    test('the in-flight flag is true only while the request is open', () async {
      final gate = Completer<SavedItemEnrichmentResult>();
      final harness = makeHarness(onEnrich: (_) => gate.future);
      addTearDown(harness.container.dispose);

      final container = harness.container;
      expect(container.read(enrichSavedItemProvider), isFalse);

      final pending = container
          .read(enrichSavedItemProvider.notifier)
          .enrich(summary());
      expect(container.read(enrichSavedItemProvider), isTrue);

      gate.complete(enriched());
      await pending;

      expect(container.read(enrichSavedItemProvider), isFalse);
    });

    test('the in-flight flag is cleared when the request fails', () async {
      final harness = makeHarness(
        enrichResults: [const ApiFailureServerFault()],
      );
      addTearDown(harness.container.dispose);

      await harness.container
          .read(enrichSavedItemProvider.notifier)
          .enrich(summary());

      expect(harness.container.read(enrichSavedItemProvider), isFalse);
    });

    test('it does not create a listing that was never loaded', () async {
      final harness = makeHarness(enrichResults: [enriched()]);
      addTearDown(harness.container.dispose);

      await harness.container
          .read(enrichSavedItemProvider.notifier)
          .enrich(summary());

      expect(
        harness.container.exists(savedItemDetailProvider(itemId)),
        isFalse,
        reason: 'a detail that was never opened must not be started here',
      );
      expect(
        harness.container.exists(savedItemsProvider),
        isFalse,
        reason: 'reading a listing would fetch it as a side effect',
      );
      expect(
        harness.container.exists(collectionSavedItemsProvider(collectionId)),
        isFalse,
      );
      expect(harness.saved.listCalls, 0);
      expect(harness.saved.collectionCalls, 0);
      expect(harness.saved.detailCalls, 0);
    });
  });

  group('applying a confirmed re-read', () {
    test('patches the open detail without re-reading it', () async {
      final harness = makeHarness(enrichResults: [enriched()]);
      addTearDown(harness.container.dispose);
      await loadDetail(harness);

      await harness.container
          .read(enrichSavedItemProvider.notifier)
          .enrich(summary());

      final detail = harness.container
          .read(savedItemDetailProvider(itemId))
          .value!;
      expect(detail.title, 'Re-read title');
      expect(detail.description, 'Re-read description.');
      expect(detail.imageUrl, 'https://example.com/new.png');
      expect(detail.collectionName, 'Camera Gear');
      expect(
        harness.saved.detailCalls,
        1,
        reason: 'the POST already returned the complete item',
      );
    });

    test('patches the loaded Inbox row in place', () async {
      final harness = makeHarness(enrichResults: [enriched()]);
      addTearDown(harness.container.dispose);
      await loadInbox(harness);

      await harness.container
          .read(enrichSavedItemProvider.notifier)
          .enrich(summary());

      final item = inboxOf(harness.container).items.single;
      expect(item.title, 'Re-read title');
      expect(item.description, 'Re-read description.');
      expect(item.imageUrl, 'https://example.com/new.png');
      expect(
        item.collectionName,
        'Camera Gear',
        reason: 'enrichment changes no membership',
      );
      expect(
        harness.saved.listCalls,
        1,
        reason: 'a reload would discard pages and reset the cursor',
      );
    });

    test('patches the loaded collection contents in place', () async {
      final harness = makeHarness(enrichResults: [enriched()]);
      addTearDown(harness.container.dispose);
      await loadCollection(harness);

      await harness.container
          .read(enrichSavedItemProvider.notifier)
          .enrich(summary());

      final contents = contentsOf(harness.container);
      expect(contents.items.single.title, 'Re-read title');
      expect(
        contents.collectionName,
        'Camera Gear',
        reason: 'the enrich response carries no collection name',
      );
      expect(harness.saved.collectionCalls, 1);
    });

    test('patches all three caches from one response', () async {
      final harness = makeHarness(enrichResults: [enriched()]);
      addTearDown(harness.container.dispose);
      await loadDetail(harness);
      await loadInbox(harness);
      await loadCollection(harness);

      await harness.container
          .read(enrichSavedItemProvider.notifier)
          .enrich(summary());

      expect(
        harness.container.read(savedItemDetailProvider(itemId)).value!.title,
        'Re-read title',
      );
      expect(inboxOf(harness.container).items.single.title, 'Re-read title');
      expect(contentsOf(harness.container).items.single.title, 'Re-read title');
      expect(harness.saved.detailCalls, 1);
      expect(harness.saved.listCalls, 1);
      expect(harness.saved.collectionCalls, 1);
    });

    test('the Inbox keeps its order and every other row untouched', () async {
      final harness = makeHarness(
        onList: (_) async => SavedItemPage(
          items: [
            summary(id: 'first', title: 'First'),
            summary(id: itemId, title: 'Second'),
            summary(id: 'third', title: 'Third'),
          ],
          nextCursor: null,
          hasMore: false,
        ),
        enrichResults: [enriched()],
      );
      addTearDown(harness.container.dispose);
      await loadInbox(harness);

      await harness.container
          .read(enrichSavedItemProvider.notifier)
          .enrich(summary());

      final items = inboxOf(harness.container).items;
      expect(items.map((item) => item.id), ['first', itemId, 'third']);
      expect(items.map((item) => item.title), [
        'First',
        'Re-read title',
        'Third',
      ]);
    });

    test('the Inbox keeps its cursor, hasMore and loaded pages', () async {
      final harness = makeHarness(
        onList: (cursor) async => cursor == null
            ? SavedItemPage(
                items: [summary(id: 'first')],
                nextCursor: 'cursor-1',
                hasMore: true,
              )
            : SavedItemPage(
                items: [summary(id: itemId)],
                nextCursor: 'cursor-2',
                hasMore: true,
              ),
        enrichResults: [enriched()],
      );
      addTearDown(harness.container.dispose);
      await loadInbox(harness);
      await harness.container.read(savedItemsProvider.notifier).loadMore();

      final before = inboxOf(harness.container);
      expect(before.items, hasLength(2));
      expect(before.nextCursor, 'cursor-2');

      await harness.container
          .read(enrichSavedItemProvider.notifier)
          .enrich(summary());

      final after = inboxOf(harness.container);
      expect(after.items, hasLength(2));
      expect(after.nextCursor, 'cursor-2');
      expect(after.hasMore, isTrue);
      expect(after.isLoadingMore, isFalse);
      expect(after.items.last.title, 'Re-read title');
      expect(harness.saved.listCalls, 2);
    });

    test('an open load-more keeps running while the row is patched', () async {
      final pageGate = Completer<SavedItemPage>();
      final harness = makeHarness(
        onList: (cursor) async => cursor == null
            ? SavedItemPage(
                items: [summary()],
                nextCursor: 'cursor-1',
                hasMore: true,
              )
            : pageGate.future,
        enrichResults: [enriched()],
      );
      addTearDown(harness.container.dispose);
      await loadInbox(harness);

      final loadMore = harness.container
          .read(savedItemsProvider.notifier)
          .loadMore();
      expect(inboxOf(harness.container).isLoadingMore, isTrue);

      await harness.container
          .read(enrichSavedItemProvider.notifier)
          .enrich(summary());

      final during = inboxOf(harness.container);
      expect(
        during.isLoadingMore,
        isTrue,
        reason: 'a re-read neither cancels nor completes a page request',
      );
      expect(during.items.single.title, 'Re-read title');

      pageGate.complete(
        SavedItemPage(
          items: [summary(id: 'page-two')],
          nextCursor: null,
          hasMore: false,
        ),
      );
      await loadMore;

      final after = inboxOf(harness.container);
      expect(after.items.map((item) => item.id), [itemId, 'page-two']);
      expect(after.items.first.title, 'Re-read title');
      expect(after.hasMore, isFalse);
    });

    test('a tombstoned row is not resurrected in the Inbox', () async {
      final harness = makeHarness(enrichResults: [enriched()]);
      addTearDown(harness.container.dispose);
      await loadInbox(harness);

      harness.container.read(savedItemsProvider.notifier).removeItem(itemId);
      expect(inboxOf(harness.container).items, isEmpty);

      await harness.container
          .read(enrichSavedItemProvider.notifier)
          .enrich(summary());

      expect(
        inboxOf(harness.container).items,
        isEmpty,
        reason: 'enrichment changes no membership, least of all a delete',
      );
    });

    test('the collection keeps loadMoreFailed and its cursor', () async {
      final harness = makeHarness(
        collectionResults: [
          collectionPage(nextCursor: 'cursor-1', hasMore: true),
          const ApiFailureServerFault(),
        ],
        enrichResults: [enriched()],
      );
      addTearDown(harness.container.dispose);
      await loadCollection(harness);
      await harness.container
          .read(collectionSavedItemsProvider(collectionId).notifier)
          .loadMore();

      final before = contentsOf(harness.container);
      expect(before.loadMoreFailed, isTrue);
      expect(before.nextCursor, 'cursor-1');

      await harness.container
          .read(enrichSavedItemProvider.notifier)
          .enrich(summary());

      final after = contentsOf(harness.container);
      expect(
        after.loadMoreFailed,
        isTrue,
        reason: 'a re-read must not pretend the failed cursor is healthy',
      );
      expect(after.nextCursor, 'cursor-1');
      expect(after.hasMore, isTrue);
      expect(after.items.single.title, 'Re-read title');
      expect(after.collectionName, 'Camera Gear');
    });

    test('a tombstoned row is not resurrected in a collection', () async {
      final harness = makeHarness(enrichResults: [enriched()]);
      addTearDown(harness.container.dispose);
      await loadCollection(harness);

      harness.container
          .read(collectionSavedItemsProvider(collectionId).notifier)
          .removeItem(itemId);
      expect(contentsOf(harness.container).items, isEmpty);

      await harness.container
          .read(enrichSavedItemProvider.notifier)
          .enrich(summary());

      expect(contentsOf(harness.container).items, isEmpty);
    });

    test('an item missing from every cache changes nothing', () async {
      final harness = makeHarness(
        enrichResults: [enriched(savedItemId: 'not-loaded')],
      );
      addTearDown(harness.container.dispose);
      await loadInbox(harness);

      await harness.container
          .read(enrichSavedItemProvider.notifier)
          .enrich(summary());

      expect(
        inboxOf(harness.container).items.single.title,
        'Understanding CRDTs',
      );
      expect(noticeOf(harness.container)?.copy, 'Page re-read.');
    });

    test('the collections list is not invalidated', () async {
      final harness = makeHarness(enrichResults: [enriched()]);
      addTearDown(harness.container.dispose);
      harness.container.listen(collectionsProvider, (_, _) {});
      await harness.container.read(collectionsProvider.future);
      expect(harness.collections.listCalls, 1);

      await harness.container
          .read(enrichSavedItemProvider.notifier)
          .enrich(summary());
      await Future<void>.delayed(Duration.zero);

      expect(
        harness.collections.listCalls,
        1,
        reason: 'counts and membership cannot change, so nothing is refetched',
      );
    });
  });

  group('outcome feedback', () {
    test('a completed re-read with metadata is a plain success', () async {
      final harness = makeHarness(enrichResults: [enriched()]);
      addTearDown(harness.container.dispose);

      await harness.container
          .read(enrichSavedItemProvider.notifier)
          .enrich(summary());

      final notice = noticeOf(harness.container)!;
      expect(notice.copy, 'Page re-read.');
      expect(notice.tone, FeedbackTone.success);
    });

    test('a completed re-read with nothing found says so', () async {
      final harness = makeHarness(
        enrichResults: [
          enriched(title: null, description: null, imageUrl: null),
        ],
      );
      addTearDown(harness.container.dispose);

      await harness.container
          .read(enrichSavedItemProvider.notifier)
          .enrich(summary());

      final notice = noticeOf(harness.container)!;
      expect(notice.copy, 'Page re-read. This page shows no details.');
      expect(notice.tone, FeedbackTone.success);
    });

    test('a failed extraction is a known failure', () async {
      final harness = makeHarness(
        enrichResults: [enriched(status: EnrichmentStatus.failed)],
      );
      addTearDown(harness.container.dispose);

      await harness.container
          .read(enrichSavedItemProvider.notifier)
          .enrich(summary());

      final notice = noticeOf(harness.container)!;
      expect(notice.copy, "Couldn't read this page.");
      expect(notice.tone, FeedbackTone.danger);
    });

    test('a pending status claims nothing', () async {
      final harness = makeHarness(
        enrichResults: [enriched(status: EnrichmentStatus.pending)],
      );
      addTearDown(harness.container.dispose);

      await harness.container
          .read(enrichSavedItemProvider.notifier)
          .enrich(summary());

      final notice = noticeOf(harness.container)!;
      expect(notice.copy, "We couldn't confirm the re-read. Try again.");
      expect(notice.tone, FeedbackTone.uncertain);
    });
  });

  group('known failures', () {
    test('a rate limit reports the server\'s own wait', () async {
      final harness = makeHarness(
        enrichResults: [
          const ApiFailureRateLimited(
            code: 'USER_RATE_LIMIT_EXCEEDED',
            retryAfter: Duration(seconds: 120),
          ),
        ],
      );
      addTearDown(harness.container.dispose);

      await harness.container
          .read(enrichSavedItemProvider.notifier)
          .enrich(summary());

      final notice = noticeOf(harness.container)!;
      expect(
        notice.copy,
        "You've re-read too many pages. Try again in 2 minutes.",
      );
      expect(notice.tone, FeedbackTone.warning);
    });

    test('a rate limit with no interval invents none', () async {
      final harness = makeHarness(
        enrichResults: [
          const ApiFailureRateLimited(code: 'USER_RATE_LIMIT_EXCEEDED'),
        ],
      );
      addTearDown(harness.container.dispose);

      await harness.container
          .read(enrichSavedItemProvider.notifier)
          .enrich(summary());

      expect(
        noticeOf(harness.container)!.copy,
        "You've re-read too many pages. Try again shortly.",
      );
    });

    test('an unavailable limiter has no countdown', () async {
      final harness = makeHarness(
        enrichResults: [
          const ApiFailureServerUnavailable(
            code: 'USER_RATE_LIMIT_UNAVAILABLE',
          ),
        ],
      );
      addTearDown(harness.container.dispose);

      await harness.container
          .read(enrichSavedItemProvider.notifier)
          .enrich(summary());

      final notice = noticeOf(harness.container)!;
      expect(
        notice.copy,
        'Re-reading is temporarily unavailable. Try again shortly.',
      );
      expect(notice.tone, FeedbackTone.warning);
    });

    test('a 500 is a known failure, not an uncertain one', () async {
      final harness = makeHarness(
        enrichResults: [const ApiFailureServerFault()],
      );
      addTearDown(harness.container.dispose);

      await harness.container
          .read(enrichSavedItemProvider.notifier)
          .enrich(summary());

      final notice = noticeOf(harness.container)!;
      expect(
        notice.copy,
        "Something went wrong re-reading this page. Try again.",
      );
      expect(notice.tone, FeedbackTone.danger);
    });

    test('a validation failure asks for nothing the user can supply', () async {
      final harness = makeHarness(
        enrichResults: [const ApiFailureValidation([])],
      );
      addTearDown(harness.container.dispose);

      await harness.container
          .read(enrichSavedItemProvider.notifier)
          .enrich(summary());

      final notice = noticeOf(harness.container)!;
      expect(notice.copy, "We couldn't re-read this page. Try again.");
      expect(notice.tone, FeedbackTone.danger);
    });

    test('a malformed request is handled like validation', () async {
      final harness = makeHarness(
        enrichResults: [const ApiFailureMalformedRequest()],
      );
      addTearDown(harness.container.dispose);

      await harness.container
          .read(enrichSavedItemProvider.notifier)
          .enrich(summary());

      expect(
        noticeOf(harness.container)!.copy,
        "We couldn't re-read this page. Try again.",
      );
    });

    test('an unrelated collection code has defensive copy', () async {
      final harness = makeHarness(
        enrichResults: [
          const ApiFailureCollectionNotEmpty(code: 'COLLECTION_NOT_EMPTY'),
        ],
      );
      addTearDown(harness.container.dispose);

      await harness.container
          .read(enrichSavedItemProvider.notifier)
          .enrich(summary());

      expect(
        noticeOf(harness.container)!.copy,
        "We couldn't re-read this page. Try again.",
      );
    });
  });

  group('not-found', () {
    test('says the item is gone and invalidates the detail', () async {
      final harness = makeHarness(
        detailResults: [
          summary(),
          const ApiFailureNotFound(code: 'SAVED_ITEM_NOT_FOUND'),
        ],
        enrichResults: [const ApiFailureNotFound(code: 'SAVED_ITEM_NOT_FOUND')],
      );
      addTearDown(harness.container.dispose);
      await loadDetail(harness);

      await harness.container
          .read(enrichSavedItemProvider.notifier)
          .enrich(summary());

      final notice = noticeOf(harness.container)!;
      expect(notice.copy, 'This item is no longer available.');
      expect(notice.tone, FeedbackTone.danger);

      await untilCalled(() => harness.saved.detailCalls == 2);
      expect(
        harness.container.read(savedItemDetailProvider(itemId)),
        isA<AsyncError<SavedItemSummary>>(),
        reason: 'the existing unavailable state takes over',
      );
    });

    test('the copy names no cause and no other user', () async {
      final harness = makeHarness(
        enrichResults: [const ApiFailureNotFound(code: 'SAVED_ITEM_NOT_FOUND')],
      );
      addTearDown(harness.container.dispose);

      await harness.container
          .read(enrichSavedItemProvider.notifier)
          .enrich(summary());

      final copy = noticeOf(harness.container)!.copy.toLowerCase();
      expect(copy.contains('deleted'), isFalse);
      expect(copy.contains('another'), isFalse);
      expect(copy.contains('account'), isFalse);
    });
  });

  group('uncertain outcomes', () {
    test('a transport failure never claims the page was not re-read', () async {
      final harness = makeHarness(enrichResults: [const ApiFailureTransport()]);
      addTearDown(harness.container.dispose);

      await harness.container
          .read(enrichSavedItemProvider.notifier)
          .enrich(summary());

      final notice = noticeOf(harness.container)!;
      expect(notice.copy, "We couldn't confirm the re-read. Try again.");
      expect(notice.tone, FeedbackTone.uncertain);
    });

    test('an unreadable 200 is uncertain as well', () async {
      final harness = makeHarness(
        enrichResults: [const ApiFailureUnreadableResponse()],
      );
      addTearDown(harness.container.dispose);

      await harness.container
          .read(enrichSavedItemProvider.notifier)
          .enrich(summary());

      expect(
        noticeOf(harness.container)!.copy,
        "We couldn't confirm the re-read. Try again.",
      );
      expect(noticeOf(harness.container)!.tone, FeedbackTone.uncertain);
    });

    test('an unconfirmed attempt touches no cached metadata', () async {
      final harness = makeHarness(enrichResults: [const ApiFailureTransport()]);
      addTearDown(harness.container.dispose);
      await loadDetail(harness);
      await loadInbox(harness);
      await loadCollection(harness);

      await harness.container
          .read(enrichSavedItemProvider.notifier)
          .enrich(summary());

      expect(
        harness.container.read(savedItemDetailProvider(itemId)).value!.title,
        'Understanding CRDTs',
      );
      expect(
        inboxOf(harness.container).items.single.title,
        'Understanding CRDTs',
      );
      expect(
        contentsOf(harness.container).items.single.title,
        'Understanding CRDTs',
      );
      expect(
        harness.saved.detailCalls,
        1,
        reason: 'no reconciliation GET after an unconfirmed attempt',
      );
    });

    test('a 500 leaves every cached row untouched', () async {
      final harness = makeHarness(
        enrichResults: [const ApiFailureServerFault()],
      );
      addTearDown(harness.container.dispose);
      await loadInbox(harness);

      await harness.container
          .read(enrichSavedItemProvider.notifier)
          .enrich(summary());

      expect(
        inboxOf(harness.container).items.single.title,
        'Understanding CRDTs',
      );
      expect(
        inboxOf(harness.container).items.single.enrichmentStatus,
        EnrichmentStatus.completed,
      );
    });
  });

  group('session failures', () {
    test('an auth refusal explains itself when the session is held', () async {
      final harness = makeHarness(
        enrichResults: [
          const ApiFailureAuthRequired(code: 'INVALID_ACCESS_TOKEN'),
        ],
        signedIn: true,
      );
      addTearDown(harness.container.dispose);

      await harness.container
          .read(enrichSavedItemProvider.notifier)
          .enrich(summary());

      final notice = noticeOf(harness.container)!;
      expect(notice.copy, 'Sign in again to re-read this page.');
      expect(notice.tone, FeedbackTone.danger);
    });

    test('an auth refusal is silent once the session has ended', () async {
      final harness = makeHarness(
        enrichResults: [
          const ApiFailureAuthRequired(code: 'INVALID_ACCESS_TOKEN'),
        ],
      );
      addTearDown(harness.container.dispose);

      await harness.container
          .read(enrichSavedItemProvider.notifier)
          .enrich(summary());

      expect(
        noticeOf(harness.container),
        isNull,
        reason: 'the router and sign-in screen explain the expiry once',
      );
    });

    test('a terminal session code publishes nothing', () async {
      final harness = makeHarness(
        enrichResults: [const ApiFailureSessionEnded(code: 'SESSION_REVOKED')],
      );
      addTearDown(harness.container.dispose);

      await harness.container
          .read(enrichSavedItemProvider.notifier)
          .enrich(summary());

      expect(noticeOf(harness.container), isNull);
    });

    test('an uncertain refresh says the page was not re-read', () async {
      final harness = makeHarness(
        enrichResults: [
          const ApiFailureRefreshUncertain(cause: ApiFailureServerFault()),
        ],
        signedIn: true,
      );
      addTearDown(harness.container.dispose);

      await harness.container
          .read(enrichSavedItemProvider.notifier)
          .enrich(summary());

      final notice = noticeOf(harness.container)!;
      expect(
        notice.copy,
        "We couldn't renew your session, so the page wasn't re-read. "
        'Try again.',
      );
      expect(notice.tone, FeedbackTone.warning);
    });

    test('a credential-storage failure says the device could not', () async {
      final harness = makeHarness(
        enrichResults: [const ApiFailureCredentialStorage(cause: 'keystore')],
        signedIn: true,
      );
      addTearDown(harness.container.dispose);

      await harness.container
          .read(enrichSavedItemProvider.notifier)
          .enrich(summary());

      final notice = noticeOf(harness.container)!;
      expect(
        notice.copy,
        "This device couldn't refresh your session, so the page wasn't "
        're-read. Try again.',
      );
      expect(notice.tone, FeedbackTone.warning);
    });
  });
}

class _Harness {
  const _Harness({
    required this.container,
    required this.saved,
    required this.collections,
  });

  final ProviderContainer container;
  final FakeSavedItemsRepository saved;
  final FakeCollectionsRepository collections;
}
