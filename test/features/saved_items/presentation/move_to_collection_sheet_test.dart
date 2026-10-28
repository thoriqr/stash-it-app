import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_it_app/app/theme/app_theme.dart';
import 'package:stash_it_app/core/error/api_error_codes.dart';
import 'package:stash_it_app/core/error/api_failure.dart';
import 'package:stash_it_app/features/collections/data/collections_providers.dart';
import 'package:stash_it_app/features/collections/domain/collection_page.dart';
import 'package:stash_it_app/features/collections/domain/collection_summary.dart';
import 'package:stash_it_app/features/saved_items/data/saved_items_providers.dart';
import 'package:stash_it_app/features/saved_items/domain/move_to_collection_intent.dart';
import 'package:stash_it_app/features/saved_items/domain/move_to_collection_result.dart';
import 'package:stash_it_app/features/saved_items/domain/saved_item_page.dart';
import 'package:stash_it_app/features/saved_items/domain/saved_item_summary.dart';
import 'package:stash_it_app/features/saved_items/presentation/widgets/collection_destination_row.dart';
import 'package:stash_it_app/features/saved_items/presentation/widgets/move_to_collection_sheet.dart';
import 'package:stash_it_app/shared/widgets/app_button.dart';

import '../../../support/fake_collections_repository.dart';
import '../../../support/fake_saved_items_repository.dart';

/// The move sheet: bounded preview, browse path, the two submission paths, the
/// inline name failures, the single in-flight indicator, and a fresh preview
/// each time it opens.
void main() {
  const itemId = 'item-1';
  const currentId = 'collection-current';

  SavedItemSummary item({
    String collectionId = currentId,
    String collectionName = 'Camera Gear',
  }) => SavedItemSummary(
    id: itemId,
    collectionId: collectionId,
    url: 'https://example.com/articles/crdts-explained',
    collectionName: collectionName,
    enrichmentStatus: EnrichmentStatus.completed,
    title: 'Understanding CRDTs',
    description: 'Conflict-free replicated data types converge.',
    savedTimeLabel: 'Saved 1 hour ago',
  );

  CollectionSummary collection({
    required String id,
    required String name,
    String type = 'user',
    String? systemKey,
  }) => CollectionSummary(
    id: id,
    name: name,
    type: type,
    isUnsorted: systemKey == 'unsorted',
    savedItemsCount: 0,
    savedItemsCountOverflow: false,
    createdAt: DateTime.utc(2026, 10, 1),
    updatedAt: DateTime.utc(2026, 10, 1),
  );

  CollectionPage page(
    List<CollectionSummary> items, {
    String? nextCursor,
    bool hasMore = false,
  }) => CollectionPage(items: items, nextCursor: nextCursor, hasMore: hasMore);

  MoveToCollectionResult moved({
    String collectionId = 'collection-wishlist',
    String collectionName = 'Wishlist',
    bool created = false,
  }) => MoveToCollectionResult(
    collectionId: collectionId,
    collectionName: collectionName,
    collectionCreated: created,
    alreadyInCollection: false,
  );

  _Harness makeHarness({
    required List<Object> pages,
    List<Object> moveResults = const [],
    Future<MoveToCollectionResult> Function(
      String,
      String,
      MoveToCollectionIntent,
    )?
    onMove,
  }) {
    final saved = FakeSavedItemsRepository(
      detailResults: [
        item(collectionId: 'collection-wishlist', collectionName: 'Wishlist'),
      ],
      moveResults: moveResults,
      onMove: onMove,
      listPage: const SavedItemPage(
        items: [],
        nextCursor: null,
        hasMore: false,
      ),
    );
    final collections = FakeCollectionsRepository(results: pages);
    return _Harness(saved: saved, collections: collections);
  }

  Future<void> pumpHost(
    WidgetTester tester,
    _Harness harness, {
    SavedItemSummary? hostItem,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        retry: (_, _) => null,
        overrides: [
          savedItemsRepositoryProvider.overrideWithValue(harness.saved),
          collectionsRepositoryProvider.overrideWithValue(harness.collections),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: _PickerHost(item: hostItem ?? item()),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> openPicker(WidgetTester tester) async {
    await tester.tap(find.text('Open picker'));
    await tester.pumpAndSettle();
  }

  Future<void> closePicker(WidgetTester tester) async {
    await tester.tapAt(const Offset(8, 8));
    await tester.pumpAndSettle();
  }

  Future<void> typeName(WidgetTester tester, String value) async {
    await tester.enterText(find.byType(TextFormField), value);
    await tester.pump();
  }

  AppButton primaryButton(WidgetTester tester) {
    return tester.widget<AppButton>(
      find.byWidgetPredicate(
        (widget) =>
            widget is AppButton && widget.variant == AppButtonVariant.primary,
      ),
    );
  }

  testWidgets('shows the returned preview, including system collections, but '
      'never the current collection as a row', (tester) async {
    final harness = makeHarness(
      pages: [
        page([
          collection(id: currentId, name: 'Camera Gear'),
          collection(
            id: 'system-unsorted',
            name: 'Unsorted',
            type: 'system',
            systemKey: 'unsorted',
          ),
          collection(
            id: 'system-github',
            name: 'GitHub',
            type: 'system',
            systemKey: 'github',
          ),
          collection(
            id: 'system-youtube',
            name: 'YouTube',
            type: 'system',
            systemKey: 'youtube',
          ),
          collection(id: 'wishlist-id', name: 'Wishlist'),
        ]),
      ],
    );

    await pumpHost(tester, harness);
    await openPicker(tester);

    expect(find.text('Currently in Camera Gear'), findsOneWidget);
    expect(
      find.text('Camera Gear'),
      findsNothing,
      reason: 'the current collection is context, never a row',
    );
    expect(find.text('Unsorted'), findsOneWidget);
    expect(find.text('GitHub'), findsOneWidget);
    expect(find.text('YouTube'), findsOneWidget);
    expect(find.text('Wishlist'), findsOneWidget);
  });

  testWidgets('shows at most five preview rows and opens the paginated picker '
      'for everything beyond them', (tester) async {
    final six = [
      collection(id: 'alpha-id', name: 'Alpha'),
      collection(id: 'beta-id', name: 'Beta'),
      collection(id: 'gamma-id', name: 'Gamma'),
      collection(id: 'delta-id', name: 'Delta'),
      collection(id: 'epsilon-id', name: 'Epsilon'),
      collection(id: 'zeta-id', name: 'Zeta'),
    ];
    final harness = makeHarness(
      pages: [page(six), page(six)],
      moveResults: [moved(collectionId: 'zeta-id', collectionName: 'Zeta')],
    );

    await pumpHost(tester, harness);
    await openPicker(tester);

    for (final name in ['Alpha', 'Beta', 'Gamma', 'Delta', 'Epsilon']) {
      expect(
        find.widgetWithText(CollectionDestinationRow, name),
        findsOneWidget,
      );
    }
    expect(
      find.widgetWithText(CollectionDestinationRow, 'Zeta'),
      findsNothing,
      reason: 'the sixth preview row belongs behind Browse all collections',
    );

    final browse = find.widgetWithText(AppButton, 'Browse all collections');
    expect(browse, findsOneWidget);
    await tester.ensureVisible(browse);
    await tester.tap(browse);
    await tester.pumpAndSettle();

    expect(find.text('All collections'), findsOneWidget);
    expect(
      find.widgetWithText(CollectionDestinationRow, 'Zeta'),
      findsOneWidget,
    );

    await tester.tap(find.widgetWithText(CollectionDestinationRow, 'Zeta'));
    await tester.pumpAndSettle();

    expect(harness.saved.moveRequests, [
      (
        savedItemId: itemId,
        collectionName: 'Zeta',
        intent: MoveToCollectionIntent.existing,
      ),
    ]);
    expect(find.byType(MoveToCollectionSheet), findsNothing);
    expect(harness.collections.limits, [6, 20]);
    expect(harness.collections.cursors, [null, null]);
  });

  testWidgets('a typed name can match a loaded collection hidden behind the '
      'five visible rows', (tester) async {
    final six = [
      collection(id: 'alpha-id', name: 'Alpha'),
      collection(id: 'beta-id', name: 'Beta'),
      collection(id: 'gamma-id', name: 'Gamma'),
      collection(id: 'delta-id', name: 'Delta'),
      collection(id: 'epsilon-id', name: 'Epsilon'),
      collection(id: 'zeta-id', name: 'Zeta'),
    ];
    final harness = makeHarness(
      pages: [page(six)],
      moveResults: [moved(collectionId: 'zeta-id', collectionName: 'Zeta')],
    );

    await pumpHost(tester, harness);
    await openPicker(tester);
    await typeName(tester, 'Zeta');

    expect(find.widgetWithText(CollectionDestinationRow, 'Zeta'), findsNothing);
    expect(primaryButton(tester).label, 'Move to Zeta');
    expect(
      find.widgetWithText(AppButton, 'Browse all collections'),
      findsOneWidget,
      reason: 'the sixth loaded collection still needs a visible browse path',
    );

    final submit = find.widgetWithText(AppButton, 'Move to Zeta');
    await tester.ensureVisible(submit);
    await tester.tap(submit);
    await tester.pumpAndSettle();

    expect(harness.saved.moveRequests, [
      (
        savedItemId: itemId,
        collectionName: 'Zeta',
        intent: MoveToCollectionIntent.existing,
      ),
    ]);
    expect(find.byType(MoveToCollectionSheet), findsNothing);
  });

  testWidgets('a typed non-match keeps create but offers a browse path to a '
      'collection outside the preview', (tester) async {
    final harness = makeHarness(
      pages: [
        page([
          collection(id: 'alpha-id', name: 'Alpha'),
          collection(id: 'beta-id', name: 'Beta'),
        ]),
        page([
          collection(id: 'alpha-id', name: 'Alpha'),
          collection(id: 'zeta-id', name: 'Zeta'),
        ]),
      ],
      moveResults: [moved(collectionId: 'zeta-id', collectionName: 'Zeta')],
    );

    await pumpHost(tester, harness);
    await openPicker(tester);
    await typeName(tester, 'Zeta');

    expect(primaryButton(tester).label, 'Create Zeta');
    final browse = find.widgetWithText(AppButton, 'Browse all collections');
    expect(browse, findsOneWidget);

    await tester.tap(browse);
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(CollectionDestinationRow, 'Zeta'));
    await tester.pumpAndSettle();

    expect(harness.saved.moveRequests, [
      (
        savedItemId: itemId,
        collectionName: 'Zeta',
        intent: MoveToCollectionIntent.existing,
      ),
    ]);
    expect(find.byType(MoveToCollectionSheet), findsNothing);
  });

  testWidgets('the grab handle replaces close and barrier plus system back '
      'still dismiss the sheet', (tester) async {
    final harness = makeHarness(pages: [page([])]);

    await pumpHost(tester, harness);
    await openPicker(tester);

    expect(find.byIcon(Icons.close), findsNothing);
    final sheet = tester.widget<BottomSheet>(
      find.byWidgetPredicate((widget) => widget is BottomSheet),
    );
    expect(sheet.showDragHandle, isTrue);
    expect(sheet.enableDrag, isTrue);
    expect(
      Theme.of(
        tester.element(find.byType(MoveToCollectionSheet)),
      ).bottomSheetTheme.dragHandleColor,
      AppTokens.light.borderStrong,
    );

    await closePicker(tester);
    expect(find.byType(MoveToCollectionSheet), findsNothing);

    await openPicker(tester);
    expect(find.byType(MoveToCollectionSheet), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(MoveToCollectionSheet), findsNothing);
  });

  testWidgets('a system collection other than the current one is selectable '
      'and submits one PUT with its stored name', (tester) async {
    final harness = makeHarness(
      pages: [
        page([
          collection(
            id: 'system-unsorted',
            name: 'Unsorted',
            type: 'system',
            systemKey: 'unsorted',
          ),
          collection(
            id: 'system-github',
            name: 'GitHub',
            type: 'system',
            systemKey: 'github',
          ),
          collection(
            id: 'system-youtube',
            name: 'YouTube',
            type: 'system',
            systemKey: 'youtube',
          ),
        ]),
      ],
      moveResults: [
        moved(collectionId: 'system-github', collectionName: 'GitHub'),
      ],
    );

    await pumpHost(
      tester,
      harness,
      hostItem: item(
        collectionId: 'system-unsorted',
        collectionName: 'Unsorted',
      ),
    );
    await openPicker(tester);

    expect(find.text('Currently in Unsorted'), findsOneWidget);
    expect(
      find.text('Unsorted'),
      findsNothing,
      reason: 'the current system collection is not a destination row',
    );
    expect(find.text('GitHub'), findsOneWidget);
    expect(find.text('YouTube'), findsOneWidget);

    await tester.tap(find.text('GitHub'));
    await tester.pumpAndSettle();

    expect(harness.saved.moveCalls, 1);
    expect(harness.saved.moveRequests, [
      (
        savedItemId: itemId,
        collectionName: 'GitHub',
        intent: MoveToCollectionIntent.existing,
      ),
    ]);
    expect(find.byType(MoveToCollectionSheet), findsNothing);
  });

  testWidgets('resolves the primary label from the typed name', (tester) async {
    final harness = makeHarness(
      pages: [
        page([
          collection(id: 'wishlist-id', name: 'Wishlist'),
          collection(id: 'current-id', name: 'Camera Gear'),
        ]),
      ],
    );

    await pumpHost(tester, harness);
    await openPicker(tester);

    expect(
      primaryButton(tester).label,
      'Move to a collection',
      reason: 'blank input cannot be submitted',
    );
    expect(primaryButton(tester).onPressed, isNull);

    await typeName(tester, 'wishLIST');
    expect(primaryButton(tester).label, 'Move to Wishlist');
    expect(primaryButton(tester).onPressed, isNotNull);

    await typeName(tester, '  Reading List  ');
    expect(
      primaryButton(tester).label,
      'Create Reading List',
      reason: 'trimmed for display and for the request',
    );
    expect(primaryButton(tester).onPressed, isNotNull);

    await typeName(tester, 'camera gear');
    expect(primaryButton(tester).label, 'Already in Camera Gear');
    expect(primaryButton(tester).onPressed, isNull);
    expect(
      harness.saved.moveCalls,
      0,
      reason: 'typing the current collection name sends no PUT',
    );

    await typeName(tester, '   ');
    expect(primaryButton(tester).label, 'Move to a collection');
    expect(primaryButton(tester).onPressed, isNull);
  });

  testWidgets('a typed name matching a loaded collection moves with existing '
      'intent', (tester) async {
    final harness = makeHarness(
      pages: [
        page([collection(id: 'wishlist-id', name: 'Wishlist')]),
      ],
      moveResults: [moved(collectionName: 'Wishlist')],
    );

    await pumpHost(tester, harness);
    await openPicker(tester);
    await typeName(tester, 'wishLIST');

    await tester.tap(find.widgetWithText(AppButton, 'Move to Wishlist'));
    await tester.pumpAndSettle();

    expect(harness.saved.moveCalls, 1);
    expect(harness.saved.moveRequests, [
      (
        savedItemId: itemId,
        collectionName: 'wishLIST',
        intent: MoveToCollectionIntent.existing,
      ),
    ]);
    expect(find.byType(MoveToCollectionSheet), findsNothing);
  });

  testWidgets('a name over 100 runes is rejected inline before submission', (
    tester,
  ) async {
    final harness = makeHarness(pages: [page([])]);

    await pumpHost(tester, harness);
    await openPicker(tester);
    await typeName(tester, 'a' * 101);

    expect(find.text('Use 100 characters or fewer.'), findsOneWidget);
    expect(primaryButton(tester).onPressed, isNull);
    expect(harness.saved.moveCalls, 0);
  });

  testWidgets('tapping a destination submits its stored name and closes', (
    tester,
  ) async {
    final harness = makeHarness(
      pages: [
        page([collection(id: 'wishlist-id', name: 'Wishlist')]),
      ],
      moveResults: [moved(collectionName: 'Wishlist')],
    );

    await pumpHost(tester, harness);
    await openPicker(tester);

    await tester.tap(find.text('Wishlist'));
    await tester.pumpAndSettle();

    expect(harness.saved.moveCalls, 1);
    expect(harness.saved.moveRequests, [
      (
        savedItemId: itemId,
        collectionName: 'Wishlist',
        intent: MoveToCollectionIntent.existing,
      ),
    ]);
    expect(find.byType(MoveToCollectionSheet), findsNothing);
  });

  testWidgets('creating by name sends the trimmed name and closes', (
    tester,
  ) async {
    final harness = makeHarness(
      pages: [page([])],
      moveResults: [
        moved(collectionId: 'reading-id', collectionName: 'Reading List'),
      ],
    );

    await pumpHost(tester, harness);
    await openPicker(tester);
    await typeName(tester, '  Reading List  ');

    await tester.tap(find.widgetWithText(AppButton, 'Create Reading List'));
    await tester.pumpAndSettle();

    expect(harness.saved.moveCalls, 1);
    expect(harness.saved.moveRequests, [
      (
        savedItemId: itemId,
        collectionName: 'Reading List',
        intent: MoveToCollectionIntent.create,
      ),
    ]);
    expect(find.byType(MoveToCollectionSheet), findsNothing);
  });

  testWidgets('a duplicate create name keeps the sheet and the input open', (
    tester,
  ) async {
    final harness = makeHarness(
      pages: [page([])],
      moveResults: [
        const ApiFailureCollectionNameAlreadyExists(
          code: ApiErrorCode.collectionNameAlreadyExists,
        ),
      ],
    );

    await pumpHost(tester, harness);
    await openPicker(tester);
    await typeName(tester, 'Unsorted');

    await tester.tap(find.widgetWithText(AppButton, 'Create Unsorted'));
    await tester.pumpAndSettle();

    expect(find.byType(MoveToCollectionSheet), findsOneWidget);
    expect(
      find.text(
        'That collection name is already taken. Choose a different name.',
      ),
      findsOneWidget,
    );
    final field = tester.widget<TextFormField>(find.byType(TextFormField));
    expect(field.controller?.text, 'Unsorted');
    expect(harness.saved.moveCalls, 1);
    expect(
      harness.saved.moveRequests.single.intent,
      MoveToCollectionIntent.create,
    );
  });

  testWidgets('a server-rejected name keeps the sheet and the input open', (
    tester,
  ) async {
    final harness = makeHarness(
      pages: [page([])],
      moveResults: [const ApiFailureValidation([])],
    );

    await pumpHost(tester, harness);
    await openPicker(tester);
    await typeName(tester, 'Wishlist');

    await tester.tap(find.widgetWithText(AppButton, 'Create Wishlist'));
    await tester.pumpAndSettle();

    expect(find.byType(MoveToCollectionSheet), findsOneWidget);
    expect(
      find.text('Enter a collection name between 1 and 100 characters.'),
      findsOneWidget,
    );
    final field = tester.widget<TextFormField>(find.byType(TextFormField));
    expect(field.controller?.text, 'Wishlist');
  });

  testWidgets('while busy, all controls are disabled and one indicator shows', (
    tester,
  ) async {
    final completer = Completer<MoveToCollectionResult>();
    final harness = makeHarness(
      pages: [
        page([
          collection(id: 'wishlist-id', name: 'Wishlist'),
          collection(id: 'reading-id', name: 'Reading List'),
        ]),
      ],
      onMove: (_, _, _) => completer.future,
    );

    await pumpHost(tester, harness);
    await openPicker(tester);
    await tester.tap(find.text('Wishlist'));
    await tester.pump();

    expect(harness.saved.moveCalls, 1);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    final submit = primaryButton(tester);
    expect(submit.busy, isTrue);
    expect(submit.onPressed, isNull);

    final field = tester.widget<TextFormField>(find.byType(TextFormField));
    expect(field.enabled, isFalse);

    expect(find.byIcon(Icons.close), findsNothing);
    final sheet = tester.widget<BottomSheet>(
      find.byWidgetPredicate((widget) => widget is BottomSheet),
    );
    expect(sheet.showDragHandle, isTrue);
    expect(sheet.enableDrag, isTrue);

    await tester.binding.handlePopRoute();
    await tester.pump();
    expect(
      find.byType(MoveToCollectionSheet),
      findsOneWidget,
      reason: 'system back cannot dismiss an in-flight move',
    );

    final readingRow = tester.widget<InkWell>(
      find.ancestor(
        of: find.text('Reading List'),
        matching: find.byType(InkWell),
      ),
    );
    expect(readingRow.onTap, isNull);

    await tester.tap(find.text('Reading List'), warnIfMissed: false);
    await tester.pump();
    expect(harness.saved.moveCalls, 1, reason: 'a disabled row sends nothing');

    completer.complete(moved(collectionName: 'Wishlist'));
    await tester.pumpAndSettle();
    expect(find.byType(MoveToCollectionSheet), findsNothing);
  });

  testWidgets('a failed destinations load still allows create-by-name', (
    tester,
  ) async {
    final harness = makeHarness(
      pages: [const ApiFailureServerFault()],
      moveResults: [
        moved(collectionId: 'reading-id', collectionName: 'Reading List'),
      ],
    );

    await pumpHost(tester, harness);
    await openPicker(tester);

    expect(find.text("We couldn't load your collections."), findsOneWidget);
    expect(
      find.text(
        'You can still create a collection by name, or browse all collections.',
      ),
      findsOneWidget,
    );
    expect(find.widgetWithText(AppButton, 'Retry'), findsOneWidget);

    await typeName(tester, 'Reading List');
    await tester.tap(find.widgetWithText(AppButton, 'Create Reading List'));
    await tester.pumpAndSettle();

    expect(harness.saved.moveCalls, 1);
    expect(harness.saved.moveRequests.single.collectionName, 'Reading List');
    expect(
      harness.saved.moveRequests.single.intent,
      MoveToCollectionIntent.create,
    );
    expect(find.byType(MoveToCollectionSheet), findsNothing);
  });

  testWidgets('Retry reloads the destinations inline', (tester) async {
    final harness = makeHarness(
      pages: [
        const ApiFailureServerFault(),
        page([collection(id: 'wishlist-id', name: 'Wishlist')]),
      ],
    );

    await pumpHost(tester, harness);
    await openPicker(tester);
    expect(find.text("We couldn't load your collections."), findsOneWidget);

    await tester.tap(find.widgetWithText(AppButton, 'Retry'));
    await tester.pumpAndSettle();

    expect(find.text("We couldn't load your collections."), findsNothing);
    expect(find.text('Wishlist'), findsOneWidget);
    expect(harness.collections.listCalls, 2);
  });

  testWidgets('reopening the sheet asks for a fresh destination snapshot', (
    tester,
  ) async {
    final harness = makeHarness(
      pages: [
        page([collection(id: 'wishlist-id', name: 'Wishlist')]),
        page([collection(id: 'reading-id', name: 'Reading List')]),
      ],
    );

    await pumpHost(tester, harness);
    await openPicker(tester);
    expect(find.text('Wishlist'), findsOneWidget);
    expect(find.text('Reading List'), findsNothing);
    expect(harness.collections.listCalls, 1);

    await closePicker(tester);
    expect(find.byType(MoveToCollectionSheet), findsNothing);

    await openPicker(tester);

    expect(harness.collections.listCalls, 2);
    expect(find.text('Reading List'), findsOneWidget);
    expect(
      find.text('Wishlist'),
      findsNothing,
      reason:
          'the reopened sheet uses the new server snapshot, not a cached one',
    );
  });
}

class _Harness {
  const _Harness({required this.saved, required this.collections});

  final FakeSavedItemsRepository saved;
  final FakeCollectionsRepository collections;
}

class _PickerHost extends StatelessWidget {
  const _PickerHost({required this.item});

  final SavedItemSummary item;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Builder(
        builder: (context) => TextButton(
          onPressed: () => showMoveToCollectionSheet(context, item: item),
          child: const Text('Open picker'),
        ),
      ),
    );
  }
}
