import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:stash_it_app/app/theme/app_theme.dart';
import 'package:stash_it_app/core/error/api_failure.dart';
import 'package:stash_it_app/features/saved_items/application/collection_saved_items_controller.dart';
import 'package:stash_it_app/features/saved_items/application/collection_saved_items_state.dart';
import 'package:stash_it_app/features/saved_items/data/saved_items_providers.dart';
import 'package:stash_it_app/features/saved_items/domain/collection_saved_items_page.dart';
import 'package:stash_it_app/features/saved_items/domain/saved_item_summary.dart';
import 'package:stash_it_app/features/saved_items/presentation/collection_saved_items_screen.dart';
import 'package:stash_it_app/features/saved_items/presentation/widgets/saved_item_collection_chip.dart';
import 'package:stash_it_app/features/saved_items/presentation/widgets/saved_item_row.dart';
import 'package:stash_it_app/features/saved_items/presentation/widgets/saved_item_skeleton.dart';
import 'package:stash_it_app/shared/widgets/app_button.dart';

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

  Future<ProviderContainer> pumpScreen(
    WidgetTester tester,
    FakeSavedItemsRepository repository, {
    bool settle = true,
  }) async {
    final container = ProviderContainer(
      overrides: [savedItemsRepositoryProvider.overrideWithValue(repository)],
      retry: (_, _) => null,
    );
    addTearDown(container.dispose);

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
}
