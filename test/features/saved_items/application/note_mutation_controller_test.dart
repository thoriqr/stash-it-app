import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_it_app/app/feedback/feedback_controller.dart';
import 'package:stash_it_app/core/error/api_failure.dart';
import 'package:stash_it_app/features/saved_items/application/collection_saved_items_controller.dart';
import 'package:stash_it_app/features/saved_items/application/collection_saved_items_state.dart';
import 'package:stash_it_app/features/saved_items/application/note_mutation_controller.dart';
import 'package:stash_it_app/features/saved_items/application/saved_item_detail_provider.dart';
import 'package:stash_it_app/features/saved_items/application/saved_items_controller.dart';
import 'package:stash_it_app/features/saved_items/application/saved_items_state.dart';
import 'package:stash_it_app/features/saved_items/data/saved_items_providers.dart';
import 'package:stash_it_app/features/saved_items/domain/collection_saved_items_page.dart';
import 'package:stash_it_app/features/saved_items/domain/saved_item_page.dart';
import 'package:stash_it_app/features/saved_items/domain/saved_item_summary.dart';
import 'package:stash_it_app/features/saved_items/domain/saved_time.dart';
import 'package:stash_it_app/l10n/app_localizations.dart';

import '../../../support/fake_saved_items_repository.dart';

/// One note save or clear, the state it patches, and the notice it publishes.
///
/// The controller is exercised against a fake repository. The wire shape is
/// covered by the repository tests; these pin what the client does with the
/// answer, including the no-refetch path.
void main() {
  final english = lookupAppLocalizations(const Locale('en'));
  const itemId = 'item-1';
  const collectionId = 'collection-1';

  SavedItemSummary summary({String? note = 'Existing note'}) =>
      SavedItemSummary(
        id: itemId,
        collectionId: collectionId,
        url: 'https://example.com/articles/1',
        collectionName: 'Camera Gear',
        enrichmentStatus: EnrichmentStatus.completed,
        title: 'Understanding CRDTs',
        note: note,
        priceAmount: '129.99',
        priceCurrency: 'USD',
        savedTime: const SavedTime.hours(2),
      );

  _Harness makeHarness({
    SavedItemSummary? item,
    List<Object?> updateNoteResults = const [],
    Future<String?> Function(String id, String note)? onUpdateNote,
    List<Object?> deleteNoteResults = const [],
    Future<void> Function(String id)? onDeleteNote,
  }) {
    final initial = item ?? summary();
    final saved = FakeSavedItemsRepository(
      listPage: SavedItemPage(
        items: [initial],
        nextCursor: null,
        hasMore: false,
      ),
      detailResults: [initial],
      collectionResults: [
        CollectionSavedItemsPage(
          collectionId: collectionId,
          collectionName: initial.collectionName,
          items: [initial],
          nextCursor: null,
          hasMore: false,
        ),
      ],
      updateNoteResults: updateNoteResults,
      onUpdateNote: onUpdateNote,
      deleteNoteResults: deleteNoteResults,
      onDeleteNote: onDeleteNote,
    );

    final container = ProviderContainer(
      overrides: [savedItemsRepositoryProvider.overrideWithValue(saved)],
      retry: (_, _) => null,
    );

    return _Harness(container: container, saved: saved);
  }

  String? noticeOf(ProviderContainer container) =>
      container.read(feedbackProvider)?.resolve(english);

  Future<void> loadInbox(_Harness harness) async {
    harness.container.listen(savedItemsProvider, (_, _) {});
    await harness.container.read(savedItemsProvider.future);
  }

  Future<void> loadDetail(_Harness harness) async {
    harness.container.listen(savedItemDetailProvider(itemId), (_, _) {});
    await harness.container.read(savedItemDetailProvider(itemId).future);
  }

  Future<void> loadCollection(_Harness harness) async {
    harness.container.listen(
      collectionSavedItemsProvider(collectionId),
      (_, _) {},
    );
    await harness.container.read(
      collectionSavedItemsProvider(collectionId).future,
    );
  }

  Future<void> loadAll(_Harness harness) async {
    await loadInbox(harness);
    await loadDetail(harness);
    await loadCollection(harness);
  }

  SavedItemsState inboxOf(ProviderContainer container) =>
      switch (container.read(savedItemsProvider)) {
        AsyncData(:final value) => value,
        final other => throw StateError('expected data, got $other'),
      };

  CollectionSavedItemsState contentsOf(ProviderContainer container) =>
      switch (container.read(collectionSavedItemsProvider(collectionId))) {
        AsyncData(:final value) => value,
        final other => throw StateError('expected data, got $other'),
      };

  SavedItemSummary detailOf(ProviderContainer container) =>
      container.read(savedItemDetailProvider(itemId)).value!;

  group('saving', () {
    test('sends the exact text and patches every loaded copy', () async {
      final harness = makeHarness(updateNoteResults: ['Stored note']);
      addTearDown(harness.container.dispose);
      await loadAll(harness);

      const text = 'Line one\nLine two stays exactly as typed.  ';
      final outcome = await harness.container
          .read(noteMutationProvider.notifier)
          .save(summary(note: null), text);

      expect(outcome, isA<NoteSaved>());
      expect((outcome as NoteSaved).note, 'Stored note');
      expect(harness.saved.noteUpdates, [(savedItemId: itemId, note: text)]);
      expect(detailOf(harness.container).note, 'Stored note');
      expect(inboxOf(harness.container).items.single.note, 'Stored note');
      expect(contentsOf(harness.container).items.single.note, 'Stored note');
      expect(noticeOf(harness.container), 'Note saved.');

      expect(harness.saved.detailCalls, 1, reason: 'no follow-up detail read');
      expect(harness.saved.listCalls, 1, reason: 'no Inbox refetch');
      expect(harness.saved.collectionCalls, 1, reason: 'no collection refetch');
    });

    test('uses the submitted text when the reply omits the note', () async {
      final harness = makeHarness(updateNoteResults: [null]);
      addTearDown(harness.container.dispose);
      await loadDetail(harness);

      const text = 'Submitted note';
      final outcome = await harness.container
          .read(noteMutationProvider.notifier)
          .save(summary(), text);

      expect(outcome, isA<NoteSaved>());
      expect((outcome as NoteSaved).note, text);
      expect(detailOf(harness.container).note, text);
    });

    test('a second save while one is in flight is ignored', () async {
      final gate = Completer<String?>();
      final harness = makeHarness(onUpdateNote: (_, _) => gate.future);
      addTearDown(harness.container.dispose);

      final controller = harness.container.read(noteMutationProvider.notifier);
      final first = controller.save(summary(), 'First');
      final second = controller.save(summary(), 'Second');

      expect(harness.saved.updateNoteCalls, 1);
      expect(await second, isA<NoteIgnored>());

      gate.complete('Stored');
      await first;

      expect(harness.saved.updateNoteCalls, 1);
      expect(harness.saved.noteUpdates.single.note, 'First');
    });

    test(
      'validation is a known rejection that keeps the editor open',
      () async {
        final harness = makeHarness(
          updateNoteResults: [const ApiFailureValidation([])],
        );
        addTearDown(harness.container.dispose);
        await loadDetail(harness);

        final outcome = await harness.container
            .read(noteMutationProvider.notifier)
            .save(summary(), 'Bad note');

        expect(outcome, isA<NoteRejected>());
        expect(outcome.closesEditor, isFalse);
        expect(detailOf(harness.container).note, 'Existing note');
        expect(
          noticeOf(harness.container),
          "That note can't be saved. Check the text and try again.",
        );
      },
    );

    test('transport leaves the outcome unconfirmed', () async {
      final harness = makeHarness(
        updateNoteResults: [const ApiFailureTransport()],
      );
      addTearDown(harness.container.dispose);
      await loadDetail(harness);

      final outcome = await harness.container
          .read(noteMutationProvider.notifier)
          .save(summary(), 'A note');

      expect(outcome, isA<NoteUnconfirmed>());
      expect(outcome.closesEditor, isFalse);
      expect(detailOf(harness.container).note, 'Existing note');
      expect(
        noticeOf(harness.container),
        "We couldn't confirm whether your note was saved. "
        'Check the note before trying again.',
      );
    });

    test('a rate limit uses the server wait', () async {
      final harness = makeHarness(
        updateNoteResults: [
          const ApiFailureRateLimited(
            code: 'USER_RATE_LIMIT_EXCEEDED',
            retryAfter: Duration(seconds: 5),
          ),
        ],
      );
      addTearDown(harness.container.dispose);

      await harness.container
          .read(noteMutationProvider.notifier)
          .save(summary(), 'A note');

      expect(
        noticeOf(harness.container),
        "You're changing notes too quickly. Try again in 5 seconds.",
      );
    });

    test('a missing item reports unavailable and closes the editor', () async {
      final harness = makeHarness(
        updateNoteResults: [
          const ApiFailureNotFound(code: 'RESOURCE_NOT_FOUND'),
        ],
      );
      addTearDown(harness.container.dispose);

      final outcome = await harness.container
          .read(noteMutationProvider.notifier)
          .save(summary(), 'A note');

      expect(outcome, isA<NoteNotFound>());
      expect(outcome.closesEditor, isTrue);
      expect(noticeOf(harness.container), 'This item is no longer available.');
    });

    test('a mutation does not start an unloaded provider', () async {
      final harness = makeHarness(updateNoteResults: ['Stored']);
      addTearDown(harness.container.dispose);

      await harness.container
          .read(noteMutationProvider.notifier)
          .save(summary(), 'A note');

      expect(
        harness.container.exists(savedItemDetailProvider(itemId)),
        isFalse,
      );
      expect(harness.container.exists(savedItemsProvider), isFalse);
      expect(
        harness.container.exists(collectionSavedItemsProvider(collectionId)),
        isFalse,
      );
      expect(harness.saved.detailCalls, 0);
      expect(harness.saved.listCalls, 0);
      expect(harness.saved.collectionCalls, 0);
    });
  });

  group('deleting', () {
    test('clears every loaded copy and publishes success', () async {
      final harness = makeHarness(deleteNoteResults: [null]);
      addTearDown(harness.container.dispose);
      await loadAll(harness);

      final outcome = await harness.container
          .read(noteMutationProvider.notifier)
          .delete(summary());

      expect(outcome, isA<NoteDeleted>());
      expect(outcome.closesEditor, isTrue);
      expect(harness.saved.noteDeleteIds, [itemId]);
      expect(detailOf(harness.container).note, isNull);
      expect(inboxOf(harness.container).items.single.note, isNull);
      expect(contentsOf(harness.container).items.single.note, isNull);
      expect(noticeOf(harness.container), 'Note deleted.');

      expect(harness.saved.detailCalls, 1, reason: 'no follow-up detail read');
      expect(harness.saved.listCalls, 1, reason: 'no Inbox refetch');
      expect(harness.saved.collectionCalls, 1, reason: 'no collection refetch');
    });

    test('a clear failure keeps the note and the editor', () async {
      final harness = makeHarness(
        deleteNoteResults: [const ApiFailureServerUnavailable(code: 'X')],
      );
      addTearDown(harness.container.dispose);
      await loadDetail(harness);

      final outcome = await harness.container
          .read(noteMutationProvider.notifier)
          .delete(summary());

      expect(outcome, isA<NoteRejected>());
      expect(outcome.closesEditor, isFalse);
      expect(detailOf(harness.container).note, 'Existing note');
      expect(
        noticeOf(harness.container),
        'Note changes are temporarily unavailable. Try again shortly.',
      );
    });
  });
}

class _Harness {
  const _Harness({required this.container, required this.saved});

  final ProviderContainer container;
  final FakeSavedItemsRepository saved;
}
