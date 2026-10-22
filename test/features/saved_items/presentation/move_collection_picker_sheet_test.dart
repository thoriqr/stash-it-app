import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_it_app/app/theme/app_theme.dart';
import 'package:stash_it_app/core/error/api_failure.dart';
import 'package:stash_it_app/features/collections/data/collections_providers.dart';
import 'package:stash_it_app/features/collections/domain/collection_page.dart';
import 'package:stash_it_app/features/collections/domain/collection_summary.dart';
import 'package:stash_it_app/features/saved_items/presentation/widgets/collection_destination_row.dart';
import 'package:stash_it_app/features/saved_items/presentation/widgets/move_collection_picker_sheet.dart';
import 'package:stash_it_app/shared/widgets/app_button.dart';

import '../../../support/fake_collections_repository.dart';

/// The full collection browser: current-context filtering, system collections,
/// cursor load-more, duplicate-row suppression, errors, empty results, and the
/// selection it returns to the move sheet.
void main() {
  const currentId = 'collection-current';

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

  Future<void> pumpHost(
    WidgetTester tester,
    FakeCollectionsRepository repository,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        retry: (_, _) => null,
        overrides: [
          collectionsRepositoryProvider.overrideWithValue(repository),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const _PickerHost(currentCollectionId: currentId),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> openPicker(WidgetTester tester) async {
    await tester.tap(find.text('Open collections'));
    await tester.pumpAndSettle();
  }

  testWidgets('loads one cursor page at a time, suppresses duplicate rows, '
      'keeps system collections, and returns the selected collection', (
    tester,
  ) async {
    final repository = FakeCollectionsRepository(
      results: [
        page(
          [
            collection(id: currentId, name: 'Camera Gear'),
            collection(
              id: 'system-unsorted',
              name: 'Unsorted',
              type: 'system',
              systemKey: 'unsorted',
            ),
            collection(id: 'alpha', name: 'Alpha'),
          ],
          nextCursor: 'page-2',
          hasMore: true,
        ),
        page([
          collection(id: 'alpha', name: 'Alpha'),
          collection(id: 'beta', name: 'Beta'),
        ]),
      ],
    );

    await pumpHost(tester, repository);
    await openPicker(tester);

    expect(find.text('All collections'), findsOneWidget);
    expect(find.byIcon(Icons.close), findsNothing);
    final sheet = tester.widget<BottomSheet>(
      find.byWidgetPredicate((widget) => widget is BottomSheet),
    );
    expect(sheet.showDragHandle, isTrue);
    expect(sheet.enableDrag, isTrue);
    expect(
      Theme.of(
        tester.element(find.byType(MoveCollectionPickerSheet)),
      ).bottomSheetTheme.dragHandleColor,
      AppTokens.light.borderStrong,
    );

    expect(
      find.widgetWithText(CollectionDestinationRow, 'Camera Gear'),
      findsNothing,
      reason: 'the current collection is context, not a destination',
    );
    expect(
      find.widgetWithText(CollectionDestinationRow, 'Unsorted'),
      findsOneWidget,
      reason: 'system collections are selectable',
    );
    expect(
      find.widgetWithText(CollectionDestinationRow, 'Alpha'),
      findsOneWidget,
    );
    expect(find.widgetWithText(CollectionDestinationRow, 'Beta'), findsNothing);
    expect(
      find.widgetWithText(AppButton, 'Load more collections'),
      findsOneWidget,
    );

    await tester.tap(find.widgetWithText(AppButton, 'Load more collections'));
    await tester.pumpAndSettle();

    expect(
      find.widgetWithText(CollectionDestinationRow, 'Alpha'),
      findsOneWidget,
      reason: 'the overlapping Alpha row is not appended twice',
    );
    expect(
      find.widgetWithText(CollectionDestinationRow, 'Beta'),
      findsOneWidget,
    );
    expect(
      find.widgetWithText(AppButton, 'Load more collections'),
      findsNothing,
    );
    expect(repository.sorts, ['name', 'name']);
    expect(repository.limits, [20, 20]);
    expect(repository.cursors, [null, 'page-2']);

    await tester.tap(find.widgetWithText(CollectionDestinationRow, 'Beta'));
    await tester.pumpAndSettle();

    expect(find.byType(MoveCollectionPickerSheet), findsNothing);
    expect(find.text('Selected: Beta'), findsOneWidget);
  });

  testWidgets('a failed next page keeps loaded rows visible and a retry '
      'resumes the same cursor', (tester) async {
    final repository = FakeCollectionsRepository(
      results: [
        page(
          [collection(id: 'alpha', name: 'Alpha')],
          nextCursor: 'page-2',
          hasMore: true,
        ),
        const ApiFailureServerFault(),
        page([collection(id: 'beta', name: 'Beta')]),
      ],
    );

    await pumpHost(tester, repository);
    await openPicker(tester);

    await tester.tap(find.widgetWithText(AppButton, 'Load more collections'));
    await tester.pumpAndSettle();

    expect(find.text("We couldn't load more collections."), findsOneWidget);
    expect(
      find.widgetWithText(CollectionDestinationRow, 'Alpha'),
      findsOneWidget,
    );
    expect(find.widgetWithText(CollectionDestinationRow, 'Beta'), findsNothing);

    await tester.tap(find.widgetWithText(AppButton, 'Retry'));
    await tester.pumpAndSettle();

    expect(find.text("We couldn't load more collections."), findsNothing);
    expect(
      find.widgetWithText(CollectionDestinationRow, 'Beta'),
      findsOneWidget,
    );
    expect(repository.cursors, [null, 'page-2', 'page-2']);
  });

  testWidgets('an initial error shows a retry that reloads the first page', (
    tester,
  ) async {
    final repository = FakeCollectionsRepository(
      results: [
        const ApiFailureServerFault(),
        page([collection(id: 'alpha', name: 'Alpha')]),
      ],
    );

    await pumpHost(tester, repository);
    await openPicker(tester);

    expect(find.text("We couldn't load your collections."), findsOneWidget);
    expect(
      find.widgetWithText(CollectionDestinationRow, 'Alpha'),
      findsNothing,
    );

    await tester.tap(find.widgetWithText(AppButton, 'Retry'));
    await tester.pumpAndSettle();

    expect(find.text("We couldn't load your collections."), findsNothing);
    expect(
      find.widgetWithText(CollectionDestinationRow, 'Alpha'),
      findsOneWidget,
    );
    expect(repository.listCalls, 2);
  });

  testWidgets('an empty result is a successful empty state that the barrier '
      'can still dismiss', (tester) async {
    final repository = FakeCollectionsRepository(results: [page([])]);

    await pumpHost(tester, repository);
    await openPicker(tester);

    expect(find.text('No other collections yet.'), findsOneWidget);
    expect(
      find.widgetWithText(AppButton, 'Load more collections'),
      findsNothing,
    );

    await tester.tapAt(const Offset(8, 8));
    await tester.pumpAndSettle();

    expect(find.byType(MoveCollectionPickerSheet), findsNothing);
    expect(find.text('Open collections'), findsOneWidget);
  });
}

class _PickerHost extends StatefulWidget {
  const _PickerHost({required this.currentCollectionId});

  final String currentCollectionId;

  @override
  State<_PickerHost> createState() => _PickerHostState();
}

class _PickerHostState extends State<_PickerHost> {
  String? _selectedName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TextButton(
            onPressed: () async {
              final selected = await showMoveCollectionPickerSheet(
                context,
                currentCollectionId: widget.currentCollectionId,
              );
              if (!mounted) return;
              setState(() => _selectedName = selected?.name);
            },
            child: const Text('Open collections'),
          ),
          if (_selectedName != null) Text('Selected: $_selectedName'),
        ],
      ),
    );
  }
}
