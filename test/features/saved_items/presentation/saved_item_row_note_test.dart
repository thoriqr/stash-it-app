import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_it_app/app/theme/app_theme.dart';
import 'package:stash_it_app/features/saved_items/domain/saved_item_summary.dart';
import 'package:stash_it_app/features/saved_items/presentation/widgets/saved_item_row.dart';
import 'package:stash_it_app/l10n/app_localizations.dart';

/// The shared row is used by Inbox, a collection's contents, and Search. A note
/// preview therefore has to open its own read-only sheet without also opening
/// the item detail route.
void main() {
  Widget app({String? note, required VoidCallback onRowTap}) {
    return MaterialApp(
      theme: AppTheme.light(),
      locale: const Locale('en'),
      supportedLocales: const [Locale('en')],
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: Scaffold(
        body: SingleChildScrollView(
          child: SavedItemRow(
            item: SavedItemSummary(
              id: 'item-1',
              collectionId: 'collection-1',
              url: 'https://example.com/articles/crdts-explained',
              collectionName: 'Camera Gear',
              enrichmentStatus: EnrichmentStatus.completed,
              title: 'Understanding CRDTs',
              note: note,
              createdAt: DateTime.utc(2026, 10, 2, 10, 30),
            ),
            onTap: onRowTap,
          ),
        ),
      ),
    );
  }

  testWidgets('a note preview opens the note without opening the detail', (
    tester,
  ) async {
    const note = 'First line\nSecond line stays exactly as typed.';
    var rowTapped = false;

    await tester.pumpWidget(app(note: note, onRowTap: () => rowTapped = true));
    await tester.pump();

    expect(find.text('Your note'), findsOneWidget);
    expect(find.text(note), findsOneWidget);

    await tester.ensureVisible(find.text('Your note'));
    await tester.tap(find.text('Your note'));
    await tester.pumpAndSettle();

    expect(rowTapped, isFalse);
    expect(find.byType(SelectableText), findsOneWidget);
    expect(find.text('Your note'), findsNWidgets(2));
    expect(find.text(note), findsNWidgets(2));
  });

  testWidgets('a row without a note has no note preview', (tester) async {
    var rowTapped = false;

    await tester.pumpWidget(app(note: null, onRowTap: () => rowTapped = true));
    await tester.pump();

    expect(find.text('Your note'), findsNothing);

    await tester.tap(find.text('Understanding CRDTs'));
    await tester.pump();

    expect(rowTapped, isTrue);
  });
}
