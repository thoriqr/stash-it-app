import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:stash_it_app/app/feedback/app_feedback.dart';
import 'package:stash_it_app/app/feedback/feedback_controller.dart';
import 'package:stash_it_app/app/theme/app_theme.dart';
import 'package:stash_it_app/core/error/api_failure.dart';
import 'package:stash_it_app/features/collections/application/collections_controller.dart';
import 'package:stash_it_app/features/collections/data/collections_providers.dart';
import 'package:stash_it_app/features/collections/domain/collection_page.dart';
import 'package:stash_it_app/features/collections/domain/collection_summary.dart';
import 'package:stash_it_app/features/saved_items/application/collection_saved_items_controller.dart';
import 'package:stash_it_app/features/saved_items/application/collection_saved_items_state.dart';
import 'package:stash_it_app/features/saved_items/data/saved_items_providers.dart';
import 'package:stash_it_app/features/saved_items/domain/collection_saved_items_page.dart';
import 'package:stash_it_app/features/saved_items/domain/saved_item_summary.dart';
import 'package:stash_it_app/features/saved_items/presentation/collection_saved_items_screen.dart';
import 'package:stash_it_app/features/saved_items/presentation/widgets/collection_destination_row.dart';
import 'package:stash_it_app/features/saved_items/presentation/widgets/saved_item_collection_chip.dart';
import 'package:stash_it_app/features/saved_items/presentation/widgets/saved_item_row.dart';
import 'package:stash_it_app/features/saved_items/presentation/widgets/saved_item_skeleton.dart';
import 'package:stash_it_app/shared/widgets/app_button.dart';

import '../../../support/fake_collections_repository.dart';
import '../../../support/fake_saved_items_repository.dart';

/// The collection detail screen's states, over a repository-supplied listing.
///
/// The screen is pumped on its own — no router — because the only navigation it
/// performs is on a row tap, which the navigation test covers against the real
/// route tree. Everything here is about what the screen renders for a given
/// listing state.
void main() {
  const collectionId = 'collection-1';
  final provider = collectionSavedItemsProvider(collectionId);

  SavedItemSummary item(
    String id, {
    EnrichmentStatus status = EnrichmentStatus.completed,
    String? title,
  }) => SavedItemSummary(
    id: id,
    collectionId: collectionId,
    url: 'https://example.com/articles/$id',
    collectionName: 'Camera Gear',
    enrichmentStatus: status,
    title: title ?? 'Item $id',
    description: 'A saved page description.',
  );

  CollectionSavedItemsPage pageOf({
    List<String> ids = const ['a'],
    String collectionName = 'Camera Gear',
    String? nextCursor,
    bool hasMore = false,
    EnrichmentStatus status = EnrichmentStatus.completed,
  }) => CollectionSavedItemsPage(
    collectionId: collectionId,
    collectionName: collectionName,
    items: [for (final id in ids) item(id, status: status)],
    nextCursor: nextCursor,
    hasMore: hasMore,
  );

  /// A repository whose detail reads are irrelevant here and whose collection
  /// listing is supplied by [collectionResults] or [onListInCollection].
  FakeSavedItemsRepository repository({
    List<Object> collectionResults = const [],
    Future<CollectionSavedItemsPage> Function(String, String?)?
    onListInCollection,
  }) => FakeSavedItemsRepository(
    detailResults: [item('detail')],
    collectionResults: collectionResults,
    onListInCollection: onListInCollection,
  );

  CollectionSummary collection({
    String id = collectionId,
    String name = 'Camera Gear',
    bool isUnsorted = false,
  }) => CollectionSummary(
    id: id,
    name: name,
    type: isUnsorted ? 'system' : 'user',
    isUnsorted: isUnsorted,
    savedItemsCount: 1,
    savedItemsCountOverflow: false,
    createdAt: DateTime.utc(2026, 10, 1),
    updatedAt: DateTime.utc(2026, 10, 1),
  );

  /// Pumps the screen with its repositories supplied by the test.
  ///
  /// [collections] seeds the **already-loaded** Collections list, which is what
  /// the header action reads its identity from. Omitting it leaves that list
  /// uninitialized, exactly as a direct entry into the route would.
  Future<ProviderContainer> pumpScreen(
    WidgetTester tester,
    FakeSavedItemsRepository repository, {
    bool settle = true,
    List<CollectionSummary>? collections,
    FakeCollectionsRepository? collectionsRepository,
  }) async {
    final collectionsUnderTest =
        collectionsRepository ??
        (collections == null
            ? null
            : FakeCollectionsRepository(
                results: [
                  CollectionPage(
                    items: collections,
                    nextCursor: null,
                    hasMore: false,
                  ),
                ],
              ));

    final container = ProviderContainer(
      overrides: [
        savedItemsRepositoryProvider.overrideWithValue(repository),
        if (collectionsUnderTest != null)
          collectionsRepositoryProvider.overrideWithValue(collectionsUnderTest),
      ],
      retry: (_, _) => null,
    );
    addTearDown(container.dispose);

    if (collectionsUnderTest != null) {
      container.listen(collectionsProvider, (_, _) {});
      await container.read(collectionsProvider.future);
    }

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          home: const CollectionSavedItemsScreen(collectionId: collectionId),
        ),
      ),
    );

    if (settle) await tester.pumpAndSettle();
    return container;
  }

  CollectionSavedItemsState stateOf(ProviderContainer container) =>
      switch (container.read(provider)) {
        AsyncData(:final value) => value,
        final other => throw StateError('expected data, got $other'),
      };

  testWidgets('renders the collection name from the response', (tester) async {
    await pumpScreen(
      tester,
      repository(
        collectionResults: [
          pageOf(collectionName: 'Server-side name', ids: ['a', 'b']),
        ],
      ),
    );

    // The header is the API's `data.collection.name`; the screen receives no
    // name from the route at all.
    expect(find.text('Server-side name'), findsOneWidget);
    expect(find.widgetWithText(AppBar, 'COLLECTION'), findsOneWidget);
    expect(find.byType(SavedItemRow), findsNWidgets(2));
  });

  testWidgets('the first load shows the skeleton and a name placeholder', (
    tester,
  ) async {
    final completer = Completer<CollectionSavedItemsPage>();

    await pumpScreen(
      tester,
      repository(onListInCollection: (_, _) => completer.future),
      settle: false,
    );
    await tester.pump();

    // The established loading presentation, not a spinner.
    expect(find.byType(SavedItemSkeletonList), findsOneWidget);
    expect(find.byType(SavedItemSkeleton), findsWidgets);
    // Matched by predicate rather than by type: `Skeletonizer` is a factory
    // whose runtime widget is private, so `find.byType` finds nothing.
    expect(
      find.byWidgetPredicate((widget) => widget is Skeletonizer),
      findsWidgets,
    );
    expect(find.byType(CircularProgressIndicator), findsNothing);

    // The header has a placeholder of its own while the name is unknown, and it
    // is excluded from semantics so no invented name is announced.
    expect(find.text('Collection name'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(ExcludeSemantics),
        matching: find.text('Collection name'),
      ),
      findsOneWidget,
    );

    completer.complete(pageOf(collectionName: 'Wishlist'));
    await tester.pumpAndSettle();

    expect(find.text('Wishlist'), findsOneWidget);
    expect(find.byType(SavedItemSkeletonList), findsNothing);
  });

  testWidgets('an empty collection is a neutral state with no Retry', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      repository(collectionResults: [pageOf(ids: const [])]),
    );

    expect(find.text('Nothing saved here yet'), findsOneWidget);
    expect(find.text('Retry'), findsNothing);
    expect(find.byType(AppButton), findsNothing);
    expect(find.text('Camera Gear'), findsOneWidget);
  });

  testWidgets('a missing collection says so and offers a way back, no Retry', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      repository(
        collectionResults: [
          const ApiFailureNotFound(code: 'COLLECTION_NOT_FOUND'),
        ],
      ),
    );

    expect(find.text('This collection is no longer available'), findsOneWidget);
    expect(
      find.text(
        'It may have been deleted, or it may belong to another account.',
      ),
      findsOneWidget,
    );
    expect(find.text('Retry'), findsNothing);
    expect(
      find.widgetWithText(AppButton, 'Back to Collections'),
      findsOneWidget,
    );
  });

  testWidgets('a recoverable failure offers a Retry that refetches', (
    tester,
  ) async {
    final repositoryUnderTest = repository(
      collectionResults: [
        const ApiFailureTransport(),
        pageOf(ids: ['a']),
      ],
    );

    await pumpScreen(tester, repositoryUnderTest);

    expect(
      find.text(
        'No connection to the server. We could not load this collection.',
      ),
      findsOneWidget,
    );

    await tester.tap(find.widgetWithText(AppButton, 'Retry'));
    await tester.pumpAndSettle();

    expect(find.byType(SavedItemRow), findsOneWidget);
    expect(find.text('Retry'), findsNothing);
    expect(repositoryUnderTest.collectionCalls, 2);
    expect(repositoryUnderTest.collectionCursors, [null, null]);
  });

  testWidgets('rows hide the collection chip and the enrichment Retry', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      repository(
        collectionResults: [
          pageOf(ids: ['a'], status: EnrichmentStatus.failed),
        ],
      ),
    );

    expect(find.byType(SavedItemCollectionChip), findsNothing);

    final row = tester.widget<SavedItemRow>(find.byType(SavedItemRow));
    expect(row.showCollectionChip, isFalse);
    expect(
      row.onRetry,
      isNull,
      reason: 'enrichment is acted on in the saved-item detail',
    );
    expect(row.onTap, isNotNull);
    expect(find.text('Retry'), findsNothing);
  });

  testWidgets('a failed page keeps the rows and offers a footer Retry', (
    tester,
  ) async {
    final repositoryUnderTest = repository(
      collectionResults: [
        pageOf(ids: ['a'], nextCursor: 'cursor-2', hasMore: true),
        const ApiFailureServerFault(),
        pageOf(ids: ['a', 'b']),
      ],
    );
    final container = await pumpScreen(tester, repositoryUnderTest);

    await container.read(provider.notifier).loadMore();
    await tester.pumpAndSettle();

    expect(find.byType(SavedItemRow), findsOneWidget);
    expect(find.text("Couldn't load more items."), findsOneWidget);
    expect(stateOf(container).loadMoreFailed, isTrue);

    await tester.tap(find.widgetWithText(AppButton, 'Retry'));
    await tester.pumpAndSettle();

    expect(find.byType(SavedItemRow), findsNWidgets(2));
    expect(find.text("Couldn't load more items."), findsNothing);
    expect(stateOf(container).items.map((i) => i.id), ['a', 'b']);
    expect(repositoryUnderTest.collectionCursors, [
      null,
      'cursor-2',
      'cursor-2',
    ], reason: 'the retry used the cursor that failed');
    expect(stateOf(container).loadMoreFailed, isFalse);
  });

  testWidgets('scrolling near the end loads the next page automatically', (
    tester,
  ) async {
    final repositoryUnderTest = repository(
      collectionResults: [
        pageOf(
          ids: [for (var i = 0; i < 20; i++) 'item-$i'],
          nextCursor: 'cursor-2',
          hasMore: true,
        ),
        pageOf(ids: ['last']),
      ],
    );
    final container = await pumpScreen(tester, repositoryUnderTest);

    await tester.drag(find.byType(ListView), const Offset(0, -1500));
    await tester.pumpAndSettle();

    expect(
      repositoryUnderTest.collectionCalls,
      2,
      reason: 'reaching the threshold requests the next page once',
    );
    expect(stateOf(container).items, hasLength(21));
    expect(stateOf(container).hasMore, isFalse);
  });

  group('the delete action', () {
    Future<void> openMenu(WidgetTester tester) async {
      await tester.tap(find.byTooltip('Collection actions'));
      await tester.pumpAndSettle();
    }

    Future<void> openSheet(WidgetTester tester) async {
      await openMenu(tester);
      await tester.tap(find.text('Delete collection'));
      await tester.pumpAndSettle();
    }

    testWidgets('is offered for a known collection that is not Unsorted', (
      tester,
    ) async {
      await pumpScreen(
        tester,
        repository(
          collectionResults: [
            pageOf(ids: ['a']),
          ],
        ),
        collections: [collection()],
      );

      expect(find.byTooltip('Collection actions'), findsOneWidget);
    });

    testWidgets('is absent when the collection is Unsorted', (tester) async {
      await pumpScreen(
        tester,
        repository(
          collectionResults: [
            pageOf(ids: ['a']),
          ],
        ),
        collections: [collection(isUnsorted: true)],
      );

      expect(
        find.byTooltip('Collection actions'),
        findsNothing,
        reason: 'Unsorted is resolved by system_key, never by its name (D2)',
      );
    });

    testWidgets('is absent when the identity has not been loaded', (
      tester,
    ) async {
      // A direct entry into the route: the Collections list was never read, so
      // there is no reliable identity to decide from. Guessing from the header
      // name would be a second copy of a server rule.
      await pumpScreen(
        tester,
        repository(
          collectionResults: [
            pageOf(ids: ['a']),
          ],
        ),
      );

      expect(find.byTooltip('Collection actions'), findsNothing);
    });

    testWidgets('is absent while the contents are still loading', (
      tester,
    ) async {
      final completer = Completer<CollectionSavedItemsPage>();

      await pumpScreen(
        tester,
        repository(onListInCollection: (_, _) => completer.future),
        settle: false,
        collections: [collection()],
      );
      await tester.pump();

      expect(find.byTooltip('Collection actions'), findsNothing);

      completer.complete(pageOf(ids: ['a']));
      await tester.pumpAndSettle();

      expect(find.byTooltip('Collection actions'), findsOneWidget);
    });

    testWidgets('is absent when the collection could not be read', (
      tester,
    ) async {
      await pumpScreen(
        tester,
        repository(
          collectionResults: [
            const ApiFailureNotFound(code: 'COLLECTION_NOT_FOUND'),
          ],
        ),
        collections: [collection()],
      );

      expect(find.byTooltip('Collection actions'), findsNothing);
    });

    testWidgets('is absent when the first read failed for any other reason', (
      tester,
    ) async {
      // A retryable failure is not a settled listing: the screen cannot know
      // whether the collection is empty, so it must not offer a decision taken
      // from an uninitialised list.
      await pumpScreen(
        tester,
        repository(collectionResults: [const ApiFailureTransport()]),
        collections: [collection()],
      );

      expect(find.byTooltip('Collection actions'), findsNothing);
    });

    testWidgets('an empty collection asks once, with no Move option', (
      tester,
    ) async {
      final collectionsRepository = FakeCollectionsRepository(
        results: [
          CollectionPage(
            items: [collection()],
            nextCursor: null,
            hasMore: false,
          ),
        ],
      );
      await pumpScreen(
        tester,
        repository(collectionResults: [pageOf(ids: const [])]),
        collectionsRepository: collectionsRepository,
      );

      await openSheet(tester);

      expect(find.text('Delete Camera Gear?'), findsOneWidget);
      expect(
        find.text(
          'This collection is empty. There are no items to keep or discard. '
          'This cannot be undone.',
        ),
        findsOneWidget,
      );
      expect(find.text('Move items to another collection'), findsNothing);
      expect(find.text('Delete'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('Delete Camera Gear?'), findsNothing);
      expect(collectionsRepository.deleteCalls, 0);
    });

    testWidgets('a non-empty collection states its total and three actions', (
      tester,
    ) async {
      await pumpScreen(
        tester,
        repository(
          collectionResults: [
            pageOf(ids: ['a', 'b']),
          ],
        ),
        collections: [collection()],
      );

      await openSheet(tester);

      expect(find.text('Delete Camera Gear?'), findsOneWidget);
      expect(
        find.text(
          'This collection has 2 saved items. Choose what happens to them.',
        ),
        findsOneWidget,
      );
      expect(find.text('Move items to another collection'), findsOneWidget);
      expect(find.text('Delete collection and items'), findsOneWidget);
      expect(find.text('Keep collection'), findsOneWidget);
      expect(
        find.textContaining('cannot be undone'),
        findsOneWidget,
        reason: 'irreversibility is stated on the one sheet',
      );

      await tester.tap(find.text('Keep collection'));
      await tester.pumpAndSettle();

      expect(find.text('Delete Camera Gear?'), findsNothing);
    });

    testWidgets('a partial page never presents its rows as the total', (
      tester,
    ) async {
      await pumpScreen(
        tester,
        repository(
          collectionResults: [
            pageOf(ids: ['a'], nextCursor: 'cursor-2', hasMore: true),
          ],
        ),
        collections: [collection()],
      );

      await openSheet(tester);

      expect(
        find.text(
          'This collection has saved items. Choose what happens to them.',
        ),
        findsOneWidget,
      );
      expect(find.textContaining('1 saved item'), findsNothing);
    });

    testWidgets('Move opens the existing picker with bulk-move copy', (
      tester,
    ) async {
      final collectionsRepository = FakeCollectionsRepository(
        results: [
          CollectionPage(
            items: [
              collection(),
              collection(id: 'collection-2', name: 'Reading list'),
            ],
            nextCursor: null,
            hasMore: false,
          ),
        ],
      );
      await pumpScreen(
        tester,
        repository(
          collectionResults: [
            pageOf(ids: ['a', 'b']),
          ],
        ),
        collectionsRepository: collectionsRepository,
      );

      await openSheet(tester);
      await tester.tap(find.text('Move items to another collection'));
      await tester.pumpAndSettle();

      expect(find.text('All collections'), findsOneWidget);
      expect(
        find.text(
          'Choose where these items should go. Camera Gear will be deleted.',
        ),
        findsOneWidget,
      );
      expect(
        find.widgetWithText(CollectionDestinationRow, 'Camera Gear'),
        findsNothing,
        reason: 'the collection being deleted is context, not a destination',
      );
      expect(
        find.widgetWithText(CollectionDestinationRow, 'Reading list'),
        findsOneWidget,
      );

      // Dismissing the picker sends nothing and returns to the same decision.
      await tester.tapAt(const Offset(20, 20));
      await tester.pumpAndSettle();

      expect(collectionsRepository.moveCalls, 0);
      expect(collectionsRepository.deleteCalls, 0);
      expect(find.text('Delete Camera Gear?'), findsOneWidget);
    });

    testWidgets('a chosen destination is sent once, and a missing one keeps '
        'the sheet open', (tester) async {
      final page = CollectionPage(
        items: [
          collection(),
          collection(id: 'collection-2', name: 'Reading list'),
        ],
        nextCursor: null,
        hasMore: false,
      );
      final collectionsRepository = FakeCollectionsRepository(
        results: [page],
        moveResults: [
          const ApiFailureCollectionDeleteTargetNotFound(
            code: 'COLLECTION_DELETE_TARGET_NOT_FOUND',
          ),
        ],
      );
      final container = await pumpScreen(
        tester,
        repository(
          collectionResults: [
            pageOf(ids: ['a']),
          ],
        ),
        collectionsRepository: collectionsRepository,
      );

      await openSheet(tester);
      await tester.tap(find.text('Move items to another collection'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Reading list'));
      await tester.pumpAndSettle();

      expect(collectionsRepository.moves, [
        (sourceId: collectionId, targetId: 'collection-2'),
      ]);
      expect(collectionsRepository.deleteCalls, 0);

      // Known not deleted, source intact: the sheet stays for another choice
      // and no third confirmation was introduced.
      expect(find.text('Delete Camera Gear?'), findsOneWidget);
      expect(find.text('Move items to another collection'), findsOneWidget);
      expect(
        container.read(feedbackProvider)?.copy,
        contains('Choose another destination'),
      );
    });

    testWidgets('an ambiguous delete keeps the sheet and stops saying Keep', (
      tester,
    ) async {
      final collectionsRepository = FakeCollectionsRepository(
        results: [
          CollectionPage(
            items: [collection()],
            nextCursor: null,
            hasMore: false,
          ),
        ],
        deleteResults: [const ApiFailureTransport()],
      );
      final container = await pumpScreen(
        tester,
        repository(
          collectionResults: [
            pageOf(ids: ['a']),
          ],
        ),
        collectionsRepository: collectionsRepository,
      );

      await openSheet(tester);
      await tester.tap(find.text('Delete collection and items'));
      await tester.pumpAndSettle();

      expect(collectionsRepository.deleteCalls, 1);
      expect(collectionsRepository.deleteIds, [collectionId]);
      expect(find.text('Delete Camera Gear?'), findsOneWidget);
      expect(
        find.text('Keep collection'),
        findsNothing,
        reason: 'the client cannot claim the collection was kept',
      );
      expect(find.text('Close'), findsOneWidget);
      expect(container.read(feedbackProvider)?.tone, FeedbackTone.uncertain);
    });
  });
}
