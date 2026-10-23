import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:stash_it_app/app/feedback/app_feedback.dart';
import 'package:stash_it_app/app/feedback/feedback_controller.dart';
import 'package:stash_it_app/app/theme/app_theme.dart';
import 'package:stash_it_app/core/error/api_failure.dart';
import 'package:stash_it_app/features/collections/data/collections_providers.dart';
import 'package:stash_it_app/features/collections/domain/collection_page.dart';
import 'package:stash_it_app/features/collections/domain/collection_summary.dart';
import 'package:stash_it_app/features/saved_items/application/saved_item_detail_provider.dart';
import 'package:stash_it_app/features/saved_items/data/saved_items_providers.dart';
import 'package:stash_it_app/features/saved_items/domain/saved_item_enrichment_result.dart';
import 'package:stash_it_app/features/saved_items/domain/saved_item_summary.dart';
import 'package:stash_it_app/features/saved_items/presentation/saved_item_detail_screen.dart';
import 'package:stash_it_app/features/saved_items/presentation/widgets/saved_item_preview.dart';
import 'package:stash_it_app/shared/widgets/app_button.dart';

import '../../../support/fake_collections_repository.dart';
import '../../../support/fake_saved_items_repository.dart';

/// The detail screen's content states, its loading and error states, and the one
/// explicit write it offers.
///
/// The screen reads the provider, which reads the repository. Overriding the
/// repository (rather than the provider) exercises the real screen → provider
/// wiring while keeping every outcome deterministic. No socket is opened.
void main() {
  const id = 'item-1';

  SavedItemSummary itemWith({
    String? title = 'Understanding CRDTs',
    String? description = 'Conflict-free replicated data types converge.',
    String? imageUrl,
    EnrichmentStatus status = EnrichmentStatus.completed,
    String collection = 'Camera Gear',
    String url = 'https://example.com/articles/crdts-explained',
  }) => SavedItemSummary(
    id: id,
    collectionId: 'collection-1',
    url: url,
    collectionName: collection,
    enrichmentStatus: status,
    title: title,
    description: description,
    imageUrl: imageUrl,
    savedTimeLabel: 'Saved 1 hour ago',
  );

  CollectionSummary collection({
    String id = 'wishlist-id',
    String name = 'Wishlist',
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

  /// Pumps the screen with one scripted outcome per call to `getById`.
  ///
  /// Settles because every outcome other than [Completer.future] completes
  /// immediately; the loading case is pumped separately so the skeleton's
  /// animation is not mistaken for a failure to settle.
  Future<FakeSavedItemsRepository> pumpScreen(
    WidgetTester tester, {
    required List<Object> results,
    List<Object> enrichResults = const [],
    Future<SavedItemEnrichmentResult> Function(String id)? onEnrich,
    FakeCollectionsRepository? collections,
  }) async {
    final repository = FakeSavedItemsRepository(
      detailResults: results,
      enrichResults: enrichResults,
      onEnrich: onEnrich,
    );
    final collectionsRepository =
        collections ??
        FakeCollectionsRepository(
          results: const [
            CollectionPage(items: [], nextCursor: null, hasMore: false),
          ],
        );

    await tester.pumpWidget(
      ProviderScope(
        // Riverpod 3 retries failed providers by default, which would turn an
        // error case into a slow, repeated request in this widget test.
        retry: (_, _) => null,
        overrides: [
          savedItemsRepositoryProvider.overrideWithValue(repository),
          collectionsRepositoryProvider.overrideWithValue(
            collectionsRepository,
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const SavedItemDetailScreen(itemId: id),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return repository;
  }

  group('C1 — metadata available', () {
    testWidgets(
      'renders title, source, collection, description and the control',
      (tester) async {
        final repository = await pumpScreen(tester, results: [itemWith()]);

        expect(find.widgetWithText(AppBar, 'ITEM'), findsOneWidget);
        expect(find.text('Understanding CRDTs'), findsOneWidget);
        expect(
          find.text('example.com/articles/crdts-explained'),
          findsOneWidget,
        );
        expect(find.text('Camera Gear'), findsOneWidget);
        expect(
          find.text('Conflict-free replicated data types converge.'),
          findsOneWidget,
        );

        // The enrichment action is available, not inert.
        expect(find.text('ENRICHMENT'), findsOneWidget);
        final reRead = tester.widget<AppButton>(
          find.widgetWithText(AppButton, 'Re-read page'),
        );
        expect(reRead.onPressed, isNotNull);
        expect(reRead.busy, isFalse);
        expect(find.text('Not available in this version.'), findsNothing);

        // No raw enum value and no backend message.
        expect(find.text('completed'), findsNothing);
        expect(find.text('saved item retrieved successfully'), findsNothing);

        expect(repository.detailCalls, 1);
      },
    );

    testWidgets('the wide preview shows the neutral well when none was '
        'reported', (tester) async {
      await pumpScreen(tester, results: [itemWith()]);

      final preview = tester.widget<SavedItemPreview>(
        find.byType(SavedItemPreview),
      );
      expect(preview.width, double.infinity);
      expect(preview.height, 110);
      expect(
        find.byKey(SavedItemPreview.unavailablePlaceholderKey),
        findsOneWidget,
        reason: 'a missing image is routine, not an error',
      );
      expect(find.byType(Image), findsNothing);
    });

    testWidgets('renders the full description without truncating it', (
      tester,
    ) async {
      const long =
          'A first paragraph long enough to need wrapping on a phone screen, '
          'with a second sentence so the line count is not accidental.\n\n'
          'A second paragraph that a two-line clamp would have silently '
          'discarded before the reader ever saw it.';

      await pumpScreen(tester, results: [itemWith(description: long)]);

      final text = tester.widget<Text>(find.text(long));
      expect(text.maxLines, isNull);
      expect(text.overflow, isNull);
    });

    testWidgets(
      'offers Move to a collection and delete, but no open-original',
      (tester) async {
        await pumpScreen(tester, results: [itemWith()]);

        expect(find.text('ACTIONS'), findsOneWidget);
        final move = tester.widget<AppButton>(
          find.widgetWithText(AppButton, 'Move to a collection'),
        );
        expect(move.onPressed, isNotNull);
        expect(move.variant, AppButtonVariant.secondary);

        final delete = tester.widget<AppButton>(
          find.widgetWithText(AppButton, 'Delete this item'),
        );
        expect(delete.onPressed, isNotNull);
        expect(delete.variant, AppButtonVariant.danger);

        expect(find.text('Open original page'), findsNothing);
      },
    );

    testWidgets('opens the picker with the current collection as context', (
      tester,
    ) async {
      await pumpScreen(
        tester,
        results: [itemWith(collection: 'Camera Gear')],
        collections: FakeCollectionsRepository(
          results: [
            CollectionPage(
              items: [collection(id: 'wishlist-id', name: 'Wishlist')],
              nextCursor: null,
              hasMore: false,
            ),
          ],
        ),
      );

      await tester.tap(find.text('Move to a collection'));
      await tester.pumpAndSettle();

      expect(find.text('Currently in Camera Gear'), findsOneWidget);
      expect(find.text('YOUR COLLECTIONS'), findsOneWidget);
      expect(find.text('Wishlist'), findsOneWidget);
      expect(
        find.text('Camera Gear'),
        findsOneWidget,
        reason: 'the current collection is context, not a destination row',
      );
    });

    for (final empty in <String?>[null, '', '   ']) {
      testWidgets('does not render an empty description (${empty ?? 'null'})', (
        tester,
      ) async {
        await pumpScreen(tester, results: [itemWith(description: empty)]);

        expect(
          find.text('Conflict-free replicated data types converge.'),
          findsNothing,
        );
        expect(find.text('Understanding CRDTs'), findsOneWidget);
      });
    }
  });

  group('re-read page', () {
    /// The button carrying a label, found by its widget field rather than by
    /// text: the label is not in the tree while the button is busy.
    AppButton buttonLabelled(WidgetTester tester, String label) => tester
        .widgetList<AppButton>(find.byType(AppButton))
        .firstWhere((button) => button.label == label);

    ProviderContainer containerOf(WidgetTester tester) =>
        ProviderScope.containerOf(
          tester.element(find.byType(SavedItemDetailScreen)),
          listen: false,
        );

    SavedItemEnrichmentResult completed({String? title = 'Re-read title'}) =>
        SavedItemEnrichmentResult(
          savedItemId: id,
          enrichmentStatus: EnrichmentStatus.completed,
          title: title,
          description: 'Re-read description.',
          imageUrl: 'https://example.com/new.png',
        );

    for (final status in EnrichmentStatus.values) {
      testWidgets('is enabled for a ${status.name} item', (tester) async {
        await pumpScreen(
          tester,
          results: [
            itemWith(
              title: status == EnrichmentStatus.completed
                  ? 'Understanding CRDTs'
                  : null,
              description: null,
              status: status,
            ),
          ],
        );

        final button = buttonLabelled(tester, 'Re-read page');
        expect(button.onPressed, isNotNull);
        expect(button.busy, isFalse);
        expect(find.text('Reading the page…'), findsNothing);
        expect(find.text('Not available in this version.'), findsNothing);
        expect(containerOf(tester).read(feedbackProvider), isNull);
      });
    }

    testWidgets('issues one POST and no second GET', (tester) async {
      final repository = await pumpScreen(
        tester,
        results: [itemWith(status: EnrichmentStatus.failed)],
        enrichResults: [completed()],
      );

      await tester.tap(find.text('Re-read page'));
      await tester.pumpAndSettle();

      expect(repository.enrichCalls, 1);
      expect(repository.enrichIds, [id]);
      expect(
        repository.detailCalls,
        1,
        reason: 'the POST already returned the complete item',
      );
      expect(find.text('Re-read title'), findsOneWidget);
      expect(find.text('Re-read description.'), findsOneWidget);
    });

    testWidgets(
      'shows progress, keeps the item visible and blocks the other writes',
      (tester) async {
        final gate = Completer<SavedItemEnrichmentResult>();
        final repository = await pumpScreen(
          tester,
          results: [
            itemWith(
              title: null,
              description: null,
              status: EnrichmentStatus.pending,
            ),
          ],
          onEnrich: (_) => gate.future,
        );

        await tester.tap(find.text('Re-read page'));
        await tester.pump();

        expect(repository.enrichCalls, 1);
        expect(buttonLabelled(tester, 'Re-read page').busy, isTrue);
        expect(find.text('Reading the page…'), findsOneWidget);
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        // The item stays on screen, and the server's pending status is not
        // replaced by a guess while the attempt runs.
        expect(find.text('Reading page…'), findsOneWidget);
        expect(find.text('No details on this page'), findsNothing);
        expect(
          find.byKey(SavedItemPreview.pendingPlaceholderKey),
          findsOneWidget,
        );

        expect(
          tester
              .widget<AppButton>(
                find.widgetWithText(AppButton, 'Move to a collection'),
              )
              .onPressed,
          isNull,
          reason: 'a second item-level write is not started mid-re-read',
        );
        expect(
          tester
              .widget<AppButton>(
                find.widgetWithText(AppButton, 'Delete this item'),
              )
              .onPressed,
          isNull,
        );

        gate.complete(completed());
        await tester.pumpAndSettle();

        expect(find.text('Reading the page…'), findsNothing);
        expect(buttonLabelled(tester, 'Re-read page').busy, isFalse);
        expect(buttonLabelled(tester, 'Re-read page').onPressed, isNotNull);
        expect(
          tester
              .widget<AppButton>(
                find.widgetWithText(AppButton, 'Move to a collection'),
              )
              .onPressed,
          isNotNull,
        );
        expect(find.text('Re-read title'), findsOneWidget);
        expect(repository.detailCalls, 1);
      },
    );

    testWidgets('a completed re-read publishes one success notice', (
      tester,
    ) async {
      await pumpScreen(
        tester,
        results: [itemWith()],
        enrichResults: [completed()],
      );

      await tester.tap(find.text('Re-read page'));
      await tester.pumpAndSettle();

      final notice = containerOf(tester).read(feedbackProvider)!;
      expect(notice.copy, 'Page re-read.');
      expect(notice.tone, FeedbackTone.success);
    });

    testWidgets('a failed extraction keeps the item and publishes a failure', (
      tester,
    ) async {
      await pumpScreen(
        tester,
        results: [itemWith(title: 'Old title', description: null)],
        enrichResults: [
          SavedItemEnrichmentResult(
            savedItemId: id,
            enrichmentStatus: EnrichmentStatus.failed,
            title: 'Old title',
          ),
        ],
      );

      await tester.tap(find.text('Re-read page'));
      await tester.pumpAndSettle();

      final notice = containerOf(tester).read(feedbackProvider)!;
      expect(notice.copy, "Couldn't read this page.");
      expect(notice.tone, FeedbackTone.danger);
      expect(
        find.text('Old title'),
        findsOneWidget,
        reason: 'a failed attempt preserves the metadata already stored',
      );
      expect(find.text("Couldn't read this page"), findsOneWidget);
    });
  });

  group('C2 — pending', () {
    testWidgets('keeps the item visible and does not imply a new request', (
      tester,
    ) async {
      final item = itemWith(
        title: null,
        description: null,
        status: EnrichmentStatus.pending,
      );
      final repository = await pumpScreen(tester, results: [item]);

      // The fallback chain renders the URL; a missing title is not an error.
      expect(find.text(item.url), findsOneWidget);
      expect(find.text('Reading page…'), findsOneWidget);
      expect(
        find.byKey(SavedItemPreview.pendingPlaceholderKey),
        findsOneWidget,
        reason: 'the wide band reports the same pending state as a row',
      );
      expect(find.text('Re-read page'), findsOneWidget);
      expect(
        tester
            .widget<AppButton>(find.widgetWithText(AppButton, 'Re-read page'))
            .onPressed,
        isNotNull,
        reason: 'a pending item is exactly what a re-read is for',
      );
      expect(
        find.text('Move to a collection'),
        findsOneWidget,
        reason: 'enrichment state does not remove the move action',
      );
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(repository.detailCalls, 1);
    });
  });

  group('C2 — failed', () {
    testWidgets('keeps available metadata and shows the failed status', (
      tester,
    ) async {
      await pumpScreen(
        tester,
        results: [itemWith(description: null, status: EnrichmentStatus.failed)],
      );

      expect(find.text('Understanding CRDTs'), findsOneWidget);
      expect(find.text("Couldn't read this page"), findsOneWidget);
      expect(find.text('No details on this page'), findsNothing);
      expect(
        find.text('Move to a collection'),
        findsOneWidget,
        reason: 'failure is an enrichment state, not a missing item',
      );
      // Failure is a status, not a blocking operation.
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });

  group('completed without metadata', () {
    testWidgets('is normal content, not an error', (tester) async {
      final item = itemWith(title: null, description: null);
      await pumpScreen(tester, results: [item]);

      expect(find.text(item.url), findsOneWidget);
      expect(find.text('No details on this page'), findsOneWidget);
      expect(find.text("Couldn't read this page"), findsNothing);
      expect(find.text('Reading page…'), findsNothing);
      expect(find.text('We could not load this item'), findsNothing);
      expect(find.byIcon(Icons.error_outline), findsNothing);
    });
  });

  group('loading', () {
    testWidgets('shows the real layout under the skeleton', (tester) async {
      final never = Completer<SavedItemSummary>();

      await tester.pumpWidget(
        ProviderScope(
          retry: (_, _) => null,
          overrides: [
            savedItemDetailProvider.overrideWithBuild(
              (ref, notifier) => never.future,
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.light(),
            home: const SavedItemDetailScreen(itemId: id),
          ),
        ),
      );
      await tester.pump();

      // `Skeletonizer` is an abstract factory whose runtime widget is private.
      // A predicate matches the implementation, unlike `find.byType`.
      final skeleton = find.byWidgetPredicate(
        (widget) => widget is Skeletonizer,
      );
      expect(skeleton, findsOneWidget);
      expect(find.widgetWithText(AppBar, 'ITEM'), findsOneWidget);
      expect(find.text('Move to a collection'), findsNothing);
      expect(find.text('ACTIONS'), findsNothing);
      // The placeholder item carries no URL, so the skeleton never creates a
      // network image request.
      expect(find.byType(Image), findsNothing);
      // The screen does not fall back to a bare centred spinner.
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });

  group('C3 — not found', () {
    testWidgets('renders the neutral copy and offers no Retry', (tester) async {
      await pumpScreen(
        tester,
        results: [const ApiFailureNotFound(code: 'RESOURCE_NOT_FOUND')],
      );

      expect(find.text('This item is no longer available'), findsOneWidget);
      expect(
        find.text(
          'It may have been deleted, or it may belong to another account.',
        ),
        findsOneWidget,
      );
      expect(find.text('Back to Inbox'), findsOneWidget);

      expect(find.text('Retry'), findsNothing);
      expect(find.text('We could not load this item'), findsNothing);
      expect(
        find.text('ENRICHMENT'),
        findsNothing,
        reason: 'there is no item to enrich',
      );
      expect(
        find.text('Move to a collection'),
        findsNothing,
        reason: 'there is no loaded item to move',
      );
      expect(find.text('ACTIONS'), findsNothing);
    });
  });

  group('generic read errors', () {
    final cases = <(String, Object, String)>[
      (
        'transport',
        const ApiFailureTransport(),
        "No connection to the server. We couldn't load this item.",
      ),
      (
        'server fault',
        const ApiFailureServerFault(),
        'We could not reach the server. Try again shortly.',
      ),
      (
        'auth required',
        const ApiFailureAuthRequired(),
        'Sign in again to see this item.',
      ),
      (
        'session ended',
        const ApiFailureSessionEnded(code: 'SESSION_REVOKED'),
        'Your session has ended. Sign in again to see this item.',
      ),
      (
        'unreadable response',
        const ApiFailureUnreadableResponse(),
        "We couldn't read the server's reply. Try again.",
      ),
    ];

    for (final (name, failure, copy) in cases) {
      testWidgets('$name is distinct from not-found and can be retried', (
        tester,
      ) async {
        await pumpScreen(tester, results: [failure]);

        expect(find.text('We could not load this item'), findsOneWidget);
        expect(find.text(copy), findsOneWidget);
        expect(find.text('Retry'), findsOneWidget);

        expect(find.text('This item is no longer available'), findsNothing);
        expect(find.text('Back to Inbox'), findsNothing);
        expect(find.text('Move to a collection'), findsNothing);
        expect(find.text('ACTIONS'), findsNothing);
      });
    }

    testWidgets('Retry issues exactly one fresh GET and recovers', (
      tester,
    ) async {
      final repository = await pumpScreen(
        tester,
        results: [
          const ApiFailureServerFault(),
          itemWith(title: 'After retry'),
        ],
      );

      await tester.tap(find.text('Retry'));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('After retry'), findsOneWidget);
      expect(repository.detailCalls, 2);
      expect(find.text('We could not load this item'), findsNothing);
    });

    testWidgets('an unreadable 404 is not shown as not-found', (tester) async {
      // The repository maps only RESOURCE_NOT_FOUND to ApiFailureNotFound; an
      // unreadable 404 arrives as this variant and keeps its Retry.
      await pumpScreen(tester, results: [const ApiFailureUnreadableResponse()]);

      expect(find.text('Retry'), findsOneWidget);
      expect(find.text('This item is no longer available'), findsNothing);
    });
  });
}
