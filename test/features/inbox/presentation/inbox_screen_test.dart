import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_it_app/features/inbox/presentation/inbox_screen.dart';
import 'package:stash_it_app/features/saved_items/presentation/widgets/saved_item_row.dart';

void main() {
  /// A `ListView` only builds the rows that fit on screen, so the default 800x600
  /// test surface would hide the last mock items.
  void useTallSurface(WidgetTester tester) {
    tester.view.physicalSize = const Size(900, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
  }

  testWidgets('the Inbox renders the mock rows and labels them as mock', (
    tester,
  ) async {
    useTallSurface(tester);

    await tester.pumpWidget(const MaterialApp(home: InboxScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Inbox'), findsWidgets);
    expect(find.byType(SavedItemRow), findsNWidgets(6));

    // The screen must never let mock data read as API data.
    expect(
      find.textContaining('mock data'),
      findsOneWidget,
      reason: 'the notice must state that the listing is fabricated',
    );
  });

  testWidgets('the Inbox shows one enrichment state line per row that needs it', (
    tester,
  ) async {
    useTallSurface(tester);

    await tester.pumpWidget(const MaterialApp(home: InboxScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Reading page…'), findsOneWidget);
    expect(find.text('No details on this page'), findsOneWidget);
    expect(find.text("Couldn't read this page"), findsOneWidget);

    // A successful enrichment with metadata says nothing, so it renders no state.
    expect(find.text('Details read'), findsNothing);

    // Retry is not wired up in the prototype, so no row shows it.
    expect(find.text('Retry'), findsNothing);
  });

  testWidgets('every mock row carries a saved-time label', (tester) async {
    useTallSurface(tester);

    await tester.pumpWidget(const MaterialApp(home: InboxScreen()));
    await tester.pumpAndSettle();

    // Prototype display strings, not timestamps from any field.
    expect(find.text('Saved 12 min ago'), findsOneWidget);
    expect(find.text('Saved yesterday'), findsNWidgets(2));
    expect(find.text('Saved 2 days ago'), findsOneWidget);
  });
}
