import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_it_app/app/feedback/app_feedback.dart';
import 'package:stash_it_app/app/feedback/feedback_controller.dart';
import 'package:stash_it_app/core/error/api_error_codes.dart';
import 'package:stash_it_app/core/error/api_failure.dart';
import 'package:stash_it_app/core/storage/secure_credential_store.dart';
import 'package:stash_it_app/features/auth/application/session_controller.dart';
import 'package:stash_it_app/features/collections/application/collections_controller.dart';
import 'package:stash_it_app/features/collections/data/collections_providers.dart';
import 'package:stash_it_app/features/collections/domain/collection_name.dart';
import 'package:stash_it_app/features/collections/domain/collection_page.dart';
import 'package:stash_it_app/features/saved_items/application/move_to_collection_controller.dart';
import 'package:stash_it_app/features/saved_items/application/saved_item_detail_provider.dart';
import 'package:stash_it_app/features/saved_items/application/saved_items_controller.dart';
import 'package:stash_it_app/features/saved_items/application/saved_items_state.dart';
import 'package:stash_it_app/features/saved_items/data/saved_items_providers.dart';
import 'package:stash_it_app/features/saved_items/domain/move_to_collection_intent.dart';
import 'package:stash_it_app/features/saved_items/domain/move_to_collection_result.dart';
import 'package:stash_it_app/features/saved_items/domain/saved_item_page.dart';
import 'package:stash_it_app/features/saved_items/domain/saved_item_summary.dart';

import '../../../support/fake_collections_repository.dart';
import '../../../support/fake_http.dart';
import '../../../support/fake_saved_items_repository.dart';

/// The move mutation: one PUT per explicit action, the three confirmation
/// messages, and the reconciliation that follows a confirmed or unestablished
/// write.
void main() {
  const itemId = 'item-1';
  const oldCollectionId = 'collection-old';
  const oldCollectionName = 'Camera Gear';

  SavedItemSummary summary({
    String id = itemId,
    String collectionId = oldCollectionId,
    String collectionName = oldCollectionName,
    String? title = 'Understanding CRDTs',
  }) => SavedItemSummary(
    id: id,
    collectionId: collectionId,
    url: 'https://example.com/articles/crdts-explained',
    collectionName: collectionName,
    enrichmentStatus: EnrichmentStatus.completed,
    title: title,
    description: 'Conflict-free replicated data types converge.',
    hasPreviewImage: true,
    savedTimeLabel: 'Saved 2 hr ago',
  );

  MoveToCollectionResult movedResult({
    String collectionId = 'collection-new',
    String collectionName = 'Wishlist',
    bool collectionCreated = false,
    bool alreadyInCollection = false,
  }) => MoveToCollectionResult(
    collectionId: collectionId,
    collectionName: collectionName,
    collectionCreated: collectionCreated,
    alreadyInCollection: alreadyInCollection,
  );

  _Harness makeHarness({
    SavedItemPage? listPage,
    List<Object>? detailResults,
    List<Object> moveResults = const [],
    List<Object>? collectionResults,
    Future<MoveToCollectionResult> Function(
      String,
      String,
      MoveToCollectionIntent,
    )?
    onMove,
  }) {
    final saved = FakeSavedItemsRepository(
      listPage:
          listPage ??
          SavedItemPage(items: [summary()], nextCursor: null, hasMore: false),
      detailResults: detailResults ?? [summary()],
      moveResults: moveResults,
      onMove: onMove,
    );
    final collections = FakeCollectionsRepository(
      results:
          collectionResults ??
          const [CollectionPage(items: [], nextCursor: null, hasMore: false)],
    );
    final container = ProviderContainer(
      overrides: [
        savedItemsRepositoryProvider.overrideWithValue(saved),
        collectionsRepositoryProvider.overrideWithValue(collections),
        credentialStoreProvider.overrideWithValue(
          SecureCredentialStore(InMemorySecureStorage()),
        ),
        restoredTokensProvider.overrideWithValue(null),
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

  Future<void> keepCollectionsAlive(_Harness harness) async {
    harness.container.listen(collectionsProvider, (_, _) {});
    await harness.container.read(collectionsProvider.future);
  }

  group('a confirmed move', () {
    test(
      'trims the name, forwards the intent, and publishes the copy',
      () async {
        final harness = makeHarness(
          detailResults: [
            summary(collectionId: 'collection-new', collectionName: 'Wishlist'),
          ],
          moveResults: [movedResult()],
        );
        addTearDown(harness.container.dispose);
        await harness.container.read(savedItemsProvider.future);
        await keepCollectionsAlive(harness);

        final outcome = await harness.container
            .read(moveToCollectionProvider.notifier)
            .submit(
              savedItemId: itemId,
              collectionName: '  Wishlist  ',
              intent: MoveToCollectionIntent.existing,
            );

        expect(outcome, isA<MoveToCollectionSucceeded>());
        expect(harness.saved.moveCalls, 1);
        expect(harness.saved.moveRequests, [
          (
            savedItemId: itemId,
            collectionName: 'Wishlist',
            intent: MoveToCollectionIntent.existing,
          ),
        ]);
        expect(
          noticeOf(harness.container)?.copy,
          'Moved to Wishlist.',
          reason: 'the stored name from the response, not the typed casing',
        );
        expect(noticeOf(harness.container)?.tone, FeedbackTone.success);
        expect(
          harness.saved.listCalls,
          1,
          reason: 'the Inbox row is updated in place, never refetched',
        );

        await untilCalled(() => harness.saved.detailCalls == 1);
        await untilCalled(
          () =>
              inboxOf(harness.container).items.single.collectionName ==
              'Wishlist',
        );
        expect(
          inboxOf(harness.container).items.single.collectionId,
          'collection-new',
        );
        expect(
          inboxOf(harness.container).items.single.title,
          'Understanding CRDTs',
          reason: 'a move does not rewrite the rest of the row',
        );
        await untilCalled(() => harness.collections.listCalls == 2);
      },
    );

    test('reports a created collection with the stored name', () async {
      final harness = makeHarness(
        detailResults: [
          summary(
            collectionId: 'collection-new',
            collectionName: 'Reading List',
          ),
        ],
        moveResults: [
          movedResult(
            collectionId: 'collection-new',
            collectionName: 'Reading List',
            collectionCreated: true,
          ),
        ],
      );
      addTearDown(harness.container.dispose);

      final outcome = await harness.container
          .read(moveToCollectionProvider.notifier)
          .submit(
            savedItemId: itemId,
            collectionName: 'reading list',
            intent: MoveToCollectionIntent.create,
          );

      expect(outcome, isA<MoveToCollectionSucceeded>());
      expect(
        harness.saved.moveRequests.single.intent,
        MoveToCollectionIntent.create,
      );
      expect(
        noticeOf(harness.container)?.copy,
        'Created Reading List and moved the item.',
      );
      await untilCalled(() => harness.saved.detailCalls == 1);
    });

    test(
      'falls back to the PUT collection when the detail read fails',
      () async {
        final harness = makeHarness(
          detailResults: [const ApiFailureServerFault()],
          moveResults: [
            movedResult(
              collectionId: 'collection-new',
              collectionName: 'Wishlist',
            ),
          ],
        );
        addTearDown(harness.container.dispose);
        await harness.container.read(savedItemsProvider.future);

        await harness.container
            .read(moveToCollectionProvider.notifier)
            .submit(
              savedItemId: itemId,
              collectionName: 'Wishlist',
              intent: MoveToCollectionIntent.existing,
            );

        await untilCalled(() => harness.saved.detailCalls == 1);
        await untilCalled(
          () =>
              inboxOf(harness.container).items.single.collectionName ==
              'Wishlist',
        );
        expect(
          inboxOf(harness.container).items.single.collectionId,
          'collection-new',
          reason: 'the PUT response is authoritative for the collection',
        );
        expect(
          inboxOf(harness.container).items.single.title,
          'Understanding CRDTs',
          reason: 'the fallback must not blank fields the write never returned',
        );
      },
    );

    test(
      'already_in_collection publishes Already in and does not reconcile',
      () async {
        final harness = makeHarness(
          moveResults: [
            movedResult(alreadyInCollection: true, collectionName: 'Wishlist'),
          ],
        );
        addTearDown(harness.container.dispose);
        await harness.container.read(savedItemsProvider.future);
        await keepCollectionsAlive(harness);

        final outcome = await harness.container
            .read(moveToCollectionProvider.notifier)
            .submit(
              savedItemId: itemId,
              collectionName: 'wishlist',
              intent: MoveToCollectionIntent.existing,
            );

        expect(outcome, isA<MoveToCollectionSucceeded>());
        expect(noticeOf(harness.container)?.copy, 'Already in Wishlist.');
        expect(noticeOf(harness.container)?.tone, FeedbackTone.success);
        expect(
          harness.saved.detailCalls,
          0,
          reason: 'a no-op has nothing to re-read',
        );
        expect(
          harness.collections.listCalls,
          1,
          reason: 'a no-op changes no collection count',
        );
        expect(
          inboxOf(harness.container).items.single.collectionName,
          oldCollectionName,
          reason: 'the item never moved',
        );
      },
    );

    test(
      'a contradictory already_in_collection pair is not called a create',
      () async {
        final harness = makeHarness(
          moveResults: [
            movedResult(
              alreadyInCollection: true,
              collectionCreated: true,
              collectionName: 'Wishlist',
            ),
          ],
        );
        addTearDown(harness.container.dispose);

        await harness.container
            .read(moveToCollectionProvider.notifier)
            .submit(
              savedItemId: itemId,
              collectionName: 'Wishlist',
              intent: MoveToCollectionIntent.existing,
            );

        expect(noticeOf(harness.container)?.copy, 'Already in Wishlist.');
        expect(harness.saved.detailCalls, 0);
      },
    );
  });

  group('one explicit action', () {
    test(
      'sets the in-flight state synchronously and ignores a second tap',
      () async {
        final completer = Completer<MoveToCollectionResult>();
        final harness = makeHarness(
          listPage: const SavedItemPage(
            items: [],
            nextCursor: null,
            hasMore: false,
          ),
          onMove: (_, _, _) => completer.future,
        );
        addTearDown(harness.container.dispose);

        final notifier = harness.container.read(
          moveToCollectionProvider.notifier,
        );
        final first = notifier.submit(
          savedItemId: itemId,
          collectionName: 'Wishlist',
          intent: MoveToCollectionIntent.existing,
        );

        expect(harness.container.read(moveToCollectionProvider), isTrue);
        final second = await notifier.submit(
          savedItemId: itemId,
          collectionName: 'Other',
          intent: MoveToCollectionIntent.create,
        );

        expect(second, isA<MoveToCollectionIgnored>());
        expect(harness.saved.moveCalls, 1);

        completer.complete(movedResult());
        expect(await first, isA<MoveToCollectionSucceeded>());
        expect(harness.container.read(moveToCollectionProvider), isFalse);
        expect(harness.saved.moveCalls, 1);
      },
    );

    test('a blank name never becomes a request', () async {
      final harness = makeHarness();
      addTearDown(harness.container.dispose);

      final outcome = await harness.container
          .read(moveToCollectionProvider.notifier)
          .submit(
            savedItemId: itemId,
            collectionName: '   ',
            intent: MoveToCollectionIntent.create,
          );

      expect(outcome, isA<MoveToCollectionNameInvalid>());
      expect(
        (outcome as MoveToCollectionNameInvalid).problem,
        CollectionNameProblem.blank,
      );
      expect(harness.saved.moveCalls, 0);
      expect(noticeOf(harness.container), isNull);
    });

    test('a name over 100 runes never becomes a request', () async {
      final harness = makeHarness();
      addTearDown(harness.container.dispose);

      final outcome = await harness.container
          .read(moveToCollectionProvider.notifier)
          .submit(
            savedItemId: itemId,
            collectionName: 'a' * 101,
            intent: MoveToCollectionIntent.create,
          );

      expect(outcome, isA<MoveToCollectionNameInvalid>());
      expect(
        (outcome as MoveToCollectionNameInvalid).problem,
        CollectionNameProblem.tooLong,
      );
      expect(harness.saved.moveCalls, 0);
    });
  });

  group('correctable name failures stay in the sheet', () {
    test(
      'INVALID_COLLECTION_NAME is a validation outcome with no notice',
      () async {
        final harness = makeHarness(
          moveResults: [const ApiFailureValidation([])],
        );
        addTearDown(harness.container.dispose);

        final outcome = await harness.container
            .read(moveToCollectionProvider.notifier)
            .submit(
              savedItemId: itemId,
              collectionName: 'Wishlist',
              intent: MoveToCollectionIntent.create,
            );

        expect(outcome, isA<MoveToCollectionNameInvalid>());
        expect((outcome as MoveToCollectionNameInvalid).problem, isNull);
        expect(noticeOf(harness.container), isNull);
        expect(harness.saved.detailCalls, 0);
      },
    );

    test('COLLECTION_NAME_ALREADY_EXISTS keeps the create flow open', () async {
      final harness = makeHarness(
        moveResults: [
          const ApiFailureCollectionNameAlreadyExists(
            code: ApiErrorCode.collectionNameAlreadyExists,
          ),
        ],
      );
      addTearDown(harness.container.dispose);

      final outcome = await harness.container
          .read(moveToCollectionProvider.notifier)
          .submit(
            savedItemId: itemId,
            collectionName: 'Unsorted',
            intent: MoveToCollectionIntent.create,
          );

      expect(outcome, isA<MoveToCollectionNameAlreadyExists>());
      expect(
        noticeOf(harness.container),
        isNull,
        reason: 'the duplicate is shown inline beside the preserved name',
      );
      expect(
        harness.saved.detailCalls,
        0,
        reason: 'a known-not-moved refusal has nothing to reconcile',
      );
    });
  });

  group('unexpected request failures', () {
    test(
      'INVALID_COLLECTION_INTENT is a malformed request, not a duplicate name',
      () async {
        final harness = makeHarness(
          moveResults: [const ApiFailureMalformedRequest()],
        );
        addTearDown(harness.container.dispose);

        final outcome = await harness.container
            .read(moveToCollectionProvider.notifier)
            .submit(
              savedItemId: itemId,
              collectionName: 'Wishlist',
              intent: MoveToCollectionIntent.create,
            );

        expect(outcome, isA<MoveToCollectionFailed>());
        expect(
          noticeOf(harness.container)?.copy,
          'Something went wrong sending that name. Try again.',
        );
        expect(noticeOf(harness.container)?.tone, FeedbackTone.danger);
        expect(harness.saved.detailCalls, 0);
      },
    );
  });

  group('SAVED_ITEM_NOT_FOUND', () {
    test('closes the item, invalidates detail to C3, and says so', () async {
      final harness = makeHarness(
        detailResults: [
          summary(),
          const ApiFailureNotFound(code: ApiErrorCode.savedItemNotFound),
        ],
        moveResults: [
          const ApiFailureNotFound(code: ApiErrorCode.savedItemNotFound),
        ],
      );
      addTearDown(harness.container.dispose);

      final detailSubscription = harness.container.listen(
        savedItemDetailProvider(itemId),
        (_, _) {},
      );
      addTearDown(detailSubscription.close);
      await harness.container.read(savedItemDetailProvider(itemId).future);
      expect(harness.saved.detailCalls, 1);

      final outcome = await harness.container
          .read(moveToCollectionProvider.notifier)
          .submit(
            savedItemId: itemId,
            collectionName: 'Wishlist',
            intent: MoveToCollectionIntent.existing,
          );

      expect(outcome, isA<MoveToCollectionItemNotFound>());
      expect(
        noticeOf(harness.container)?.copy,
        'This item is no longer available.',
      );
      expect(noticeOf(harness.container)?.tone, FeedbackTone.danger);

      await untilCalled(
        () => harness.container.read(savedItemDetailProvider(itemId)).hasError,
      );
      expect(
        harness.container.read(savedItemDetailProvider(itemId)).error,
        isA<ApiFailureNotFound>(),
      );
    });
  });

  group('an unestablished write', () {
    final failures = <ApiFailure>[
      const ApiFailureTransport(),
      const ApiFailureUnreadableResponse(),
      const ApiFailureServerFault(),
      const ApiFailureServerUnavailable(code: 'IP_RATE_LIMIT_UNAVAILABLE'),
    ];

    for (final failure in failures) {
      test('${failure.runtimeType} is neutral and re-reads the item', () async {
        final harness = makeHarness(
          detailResults: [
            summary(collectionId: 'collection-new', collectionName: 'Wishlist'),
          ],
          moveResults: [failure],
        );
        addTearDown(harness.container.dispose);
        await harness.container.read(savedItemsProvider.future);
        await keepCollectionsAlive(harness);

        final outcome = await harness.container
            .read(moveToCollectionProvider.notifier)
            .submit(
              savedItemId: itemId,
              collectionName: 'Wishlist',
              intent: MoveToCollectionIntent.existing,
            );

        expect(outcome, isA<MoveToCollectionUnconfirmed>());
        expect(
          noticeOf(harness.container)?.copy,
          "We couldn't confirm the move. Check the item's collection.",
        );
        expect(noticeOf(harness.container)?.tone, FeedbackTone.uncertain);
        expect(
          harness.saved.moveCalls,
          1,
          reason: 'an unestablished outcome is never replayed automatically',
        );

        await untilCalled(() => harness.saved.detailCalls == 1);
        await untilCalled(
          () =>
              inboxOf(harness.container).items.single.collectionName ==
              'Wishlist',
        );
        expect(
          harness.collections.listCalls,
          1,
          reason: 'an unconfirmed move must not assert a new collection count',
        );
      });
    }
  });

  group('known not-moved failures', () {
    test('a rate limit publishes a known refusal and never re-reads', () async {
      final harness = makeHarness(
        moveResults: [
          const ApiFailureRateLimited(
            code: 'USER_RATE_LIMIT_EXCEEDED',
            retryAfter: Duration(seconds: 30),
          ),
        ],
      );
      addTearDown(harness.container.dispose);
      await harness.container.read(savedItemsProvider.future);

      final outcome = await harness.container
          .read(moveToCollectionProvider.notifier)
          .submit(
            savedItemId: itemId,
            collectionName: 'Wishlist',
            intent: MoveToCollectionIntent.existing,
          );

      expect(outcome, isA<MoveToCollectionFailed>());
      expect(noticeOf(harness.container)?.copy, contains('30 seconds'));
      expect(noticeOf(harness.container)?.tone, FeedbackTone.warning);
      expect(harness.saved.detailCalls, 0);
      expect(
        inboxOf(harness.container).items.single.collectionName,
        oldCollectionName,
      );
    });

    test(
      'an auth refusal publishes nothing when the session already ended',
      () async {
        final harness = makeHarness(
          moveResults: [const ApiFailureAuthRequired()],
        );
        addTearDown(harness.container.dispose);

        final outcome = await harness.container
            .read(moveToCollectionProvider.notifier)
            .submit(
              savedItemId: itemId,
              collectionName: 'Wishlist',
              intent: MoveToCollectionIntent.existing,
            );

        expect(outcome, isA<MoveToCollectionFailed>());
        expect(
          noticeOf(harness.container),
          isNull,
          reason: 'the router and sign-in screen own the expiry explanation',
        );
        expect(harness.saved.detailCalls, 0);
      },
    );
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
