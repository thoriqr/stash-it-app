import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_it_app/features/saved_items/domain/saved_item_summary.dart';
import 'package:stash_it_app/features/saved_items/presentation/widgets/saved_item_row.dart';

/// Wraps [SavedItemRow] in the minimum Material host it needs.
Widget host(
  SavedItemSummary item, {
  VoidCallback? onRetry,
  double width = 360,
}) {
  return MaterialApp(
    home: Scaffold(
      body: SizedBox(
        width: width,
        child: SavedItemRow(item: item, onRetry: onRetry),
      ),
    ),
  );
}

SavedItemSummary itemWith({
  String? title,
  String? description,
  bool hasPreviewImage = false,
  EnrichmentStatus status = EnrichmentStatus.completed,
  String collection = 'Unsorted',
  String? savedTimeLabel,
  String url = 'https://example.com/articles/crdts-explained',
}) {
  return SavedItemSummary(
    id: 'test',
    url: url,
    collectionName: collection,
    enrichmentStatus: status,
    title: title,
    description: description,
    hasPreviewImage: hasPreviewImage,
    savedTimeLabel: savedTimeLabel,
  );
}

void main() {
  group('SavedItemRow', () {
    testWidgets('shows the title, a compact source, and the collection', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(itemWith(title: 'Understanding CRDTs', collection: 'Camera Gear')),
      );

      expect(find.text('Understanding CRDTs'), findsOneWidget);
      // Scheme and www. are dropped; the path stays.
      expect(find.text('example.com/articles/crdts-explained'), findsOneWidget);
      expect(find.text('Camera Gear'), findsOneWidget);
    });

    testWidgets('falls back to the URL when the page supplied no title', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          itemWith(
            url: 'https://archive.example.net/specs/build-notes',
            collection: 'Reading List',
          ),
        ),
      );

      expect(
        find.text('https://archive.example.net/specs/build-notes'),
        findsOneWidget,
      );
      expect(
        find.text('archive.example.net'),
        findsOneWidget,
        reason: 'the host alone, so the URL is not printed twice down the row',
      );
      // The fallback must not read as a fault: no error or warning copy appears.
      expect(find.textContaining('error'), findsNothing);
      expect(find.textContaining('No title'), findsNothing);
    });

    testWidgets('a successful enrichment with metadata stays silent', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          itemWith(
            title: 'Understanding CRDTs',
            description:
                'Conflict-free replicated data types let replicas '
                'converge without a central coordinator.',
          ),
        ),
      );

      // Success needs no announcement.
      expect(find.text('Reading page…'), findsNothing);
      expect(find.textContaining('details'), findsNothing);
      expect(find.text('Retry'), findsNothing);
    });

    testWidgets(
      'completed with no metadata is stated, never styled as a problem',
      (tester) async {
        await tester.pumpWidget(host(itemWith()));

        expect(find.text('No details on this page'), findsOneWidget);
        expect(find.text('Retry'), findsNothing);
        expect(find.textContaining('Couldn'), findsNothing);
      },
    );

    testWidgets('pending and failed each offer retry', (tester) async {
      var pendingRetries = 0;
      await tester.pumpWidget(
        host(
          itemWith(status: EnrichmentStatus.pending),
          onRetry: () => pendingRetries++,
        ),
      );

      expect(find.text('Reading page…'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);

      await tester.tap(find.text('Retry'));
      expect(pendingRetries, 1);

      await tester.pumpWidget(
        host(
          itemWith(status: EnrichmentStatus.failed),
          onRetry: () => pendingRetries++,
        ),
      );

      expect(find.text("Couldn't read this page"), findsOneWidget);
      await tester.tap(find.text('Retry'));
      expect(pendingRetries, 2);
    });

    testWidgets('a thumbnail only appears when the item has a preview image', (
      tester,
    ) async {
      await tester.pumpWidget(host(itemWith(hasPreviewImage: true)));
      expect(find.byIcon(Icons.image_outlined), findsOneWidget);

      await tester.pumpWidget(host(itemWith()));
      expect(find.byIcon(Icons.image_outlined), findsNothing);
    });

    testWidgets('long titles and sources truncate instead of overflowing', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          itemWith(
            title:
                'Designing a rate limiter that fails closed, and what it '
                'costs you the first time the counter store is unreachable in '
                'production during an incident',
            url:
                'https://engineering.example.dev/posts/'
                'a-very-long-path-segment-that-keeps-going-and-going',
            hasPreviewImage: true,
          ),
          width: 320,
        ),
      );

      expect(tester.takeException(), isNull);

      final title = tester.widget<Text>(
        find.textContaining('Designing a rate limiter'),
      );
      expect(title.maxLines, 2);
      expect(title.overflow, TextOverflow.ellipsis);

      final source = tester.widget<Text>(
        find.textContaining('engineering.example.dev'),
      );
      expect(source.maxLines, 1);
      expect(source.overflow, TextOverflow.ellipsis);
    });

    testWidgets('an unparseable URL still renders without throwing', (
      tester,
    ) async {
      await tester.pumpWidget(host(itemWith(url: 'not a url at all')));

      expect(tester.takeException(), isNull);
      expect(find.text('not a url at all'), findsWidgets);
    });

    testWidgets('a saved-time label is shown only when one is supplied', (
      tester,
    ) async {
      await tester.pumpWidget(host(itemWith()));

      expect(find.textContaining('Saved'), findsNothing);

      await tester.pumpWidget(
        host(
          itemWith(
            title: 'Notes on reading',
            savedTimeLabel: 'Saved 12 min ago',
          ),
        ),
      );

      expect(find.text('Saved 12 min ago'), findsOneWidget);
      // The source keeps the left edge; the label is the trailing element.
      expect(find.text('example.com/articles/crdts-explained'), findsOneWidget);
    });

    testWidgets('a long source and a saved-time label do not overflow', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          itemWith(
            title: 'Full-Text Search in Postgres, part three',
            url:
                'https://engineering.example.dev/posts/'
                'a-very-long-path-segment-that-keeps-going-and-going',
            savedTimeLabel: 'Saved 2 days ago',
            hasPreviewImage: true,
          ),
          width: 320,
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('Saved 2 days ago'), findsOneWidget);
    });
  });
}
