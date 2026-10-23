import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_it_app/app/theme/app_theme.dart';
import 'package:stash_it_app/features/saved_items/domain/saved_item_summary.dart';
import 'package:stash_it_app/features/saved_items/presentation/widgets/saved_item_preview.dart';
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
  String? imageUrl,
  EnrichmentStatus status = EnrichmentStatus.completed,
  String collection = 'Unsorted',
  String? savedTimeLabel,
  String url = 'https://example.com/articles/crdts-explained',
}) {
  return SavedItemSummary(
    id: 'test',
    collectionId: 'collection-test',
    url: url,
    collectionName: collection,
    enrichmentStatus: status,
    title: title,
    description: description,
    imageUrl: imageUrl,
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

    testWidgets('the row hands the URL and enrichment state to the shared '
        'preview', (tester) async {
      // The row decides layout, not image state. Both values travel untouched,
      // so every screen built on this row renders the same matrix through the
      // one widget that owns it.
      await tester.pumpWidget(
        host(
          itemWith(
            imageUrl: 'https://example.com/og.png',
            status: EnrichmentStatus.failed,
          ),
        ),
      );

      final preview = tester.widget<SavedItemPreview>(
        find.byType(SavedItemPreview),
      );
      expect(preview.imageUrl, 'https://example.com/og.png');
      expect(preview.enrichmentStatus, EnrichmentStatus.failed);
    });

    testWidgets('a pending thumbnail reserves the space without fetching it', (
      tester,
    ) async {
      // Pending takes precedence over the URL. An anomalous URL on a pending
      // item must not become a request issued from inside a list.
      await tester.pumpWidget(
        host(
          itemWith(
            imageUrl: 'https://example.com/og.png',
            status: EnrichmentStatus.pending,
          ),
        ),
      );

      expect(
        find.byKey(SavedItemPreview.pendingPlaceholderKey),
        findsOneWidget,
      );
      expect(find.byType(Image), findsNothing);
    });

    testWidgets('no reported image leaves the neutral well, not a failure', (
      tester,
    ) async {
      // A missing preview is routine: no error, no retry, and the slot keeps its
      // size so a list of mixed items does not reflow.
      await tester.pumpWidget(host(itemWith(imageUrl: null)));

      expect(
        find.byKey(SavedItemPreview.unavailablePlaceholderKey),
        findsOneWidget,
      );
      expect(find.text('Retry'), findsNothing);
    });

    testWidgets('the preview slot keeps its size in every placeholder state', (
      tester,
    ) async {
      final rowHeights = <double>[];

      for (final status in EnrichmentStatus.values) {
        // No URL: each state is measured on its placeholder, so no case in this
        // test reaches the network.
        await tester.pumpWidget(host(itemWith(imageUrl: null, status: status)));

        final slot = tester.getSize(find.byType(SavedItemPreview));
        expect(slot.width, AppMetrics.slotThumbSize);
        expect(slot.height, AppMetrics.slotThumbSize);

        rowHeights.add(tester.getSize(find.byType(SavedItemRow)).height);
      }

      expect(
        rowHeights.toSet(),
        hasLength(1),
        reason: 'placeholder state never changes the height of a row',
      );
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
          ),
          width: 320,
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('Saved 2 days ago'), findsOneWidget);
    });
  });
}
