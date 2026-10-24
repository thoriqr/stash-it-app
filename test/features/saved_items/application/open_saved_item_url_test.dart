import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_it_app/app/feedback/app_feedback.dart';
import 'package:stash_it_app/app/feedback/feedback_controller.dart';
import 'package:stash_it_app/features/saved_items/application/open_saved_item_url.dart';
import 'package:stash_it_app/features/saved_items/application/saved_item_detail_provider.dart';
import 'package:stash_it_app/features/saved_items/application/saved_items_controller.dart';
import 'package:stash_it_app/features/saved_items/data/saved_items_providers.dart';
import 'package:stash_it_app/features/saved_items/domain/saved_item_summary.dart';

import '../../../support/fake_saved_item_url_launcher.dart';
import '../../../support/fake_saved_items_repository.dart';

/// Opening a saved item's original URL: what reaches the platform, what does not,
/// and what the app says about each.
///
/// The launcher is a fake, so no browser opens and no platform channel is touched.
/// What this file establishes is the gate (only absolute `http(s)` URLs with a host
/// are handed over), the two failure notices, the silence of an accepted handoff,
/// and that opening writes nothing anywhere.
void main() {
  SavedItemSummary item({
    String url = 'https://example.com/articles/crdts-explained',
  }) => SavedItemSummary(
    id: 'item-1',
    collectionId: 'collection-1',
    url: url,
    collectionName: 'Camera Gear',
    enrichmentStatus: EnrichmentStatus.completed,
    title: 'Understanding CRDTs',
    description: 'Conflict-free replicated data types converge.',
    imageUrl: 'https://example.com/og.png',
    savedTimeLabel: 'Saved 1 hour ago',
  );

  ({
    ProviderContainer container,
    FakeSavedItemUrlLauncher launcher,
    FakeSavedItemsRepository saved,
  })
  harness({List<Object> results = const [true]}) {
    final launcher = FakeSavedItemUrlLauncher(results: results);
    final saved = FakeSavedItemsRepository(detailResults: [item()]);
    final container = ProviderContainer.test(
      overrides: [
        savedItemUrlLauncherProvider.overrideWithValue(launcher),
        savedItemsRepositoryProvider.overrideWithValue(saved),
      ],
    );
    return (container: container, launcher: launcher, saved: saved);
  }

  AppFeedback? noticeOf(ProviderContainer container) =>
      container.read(feedbackProvider);

  group('an accepted handoff', () {
    test('hands over the exact stored URL', () async {
      final h = harness();

      await h.container.read(openSavedItemUrlProvider).open(item());

      expect(h.launcher.calls, 1);
      expect(
        h.launcher.launched.single.toString(),
        'https://example.com/articles/crdts-explained',
      );
    });

    test('accepts http as well as https', () async {
      for (final url in const [
        'http://example.com/a',
        'https://example.com/a',
      ]) {
        final h = harness();

        await h.container.read(openSavedItemUrlProvider).open(item(url: url));

        expect(h.launcher.launched.single.toString(), url, reason: url);
      }
    });

    test('keeps the path, query and fragment exactly as saved', () async {
      const url = 'https://example.com/a/b?q=1&r=two#section-3';
      final h = harness();

      await h.container.read(openSavedItemUrlProvider).open(item(url: url));

      expect(h.launcher.launched.single.toString(), url);
    });

    test('says nothing: an accepted handoff is not a loaded page', () async {
      final h = harness();

      await h.container.read(openSavedItemUrlProvider).open(item());

      expect(
        noticeOf(h.container),
        isNull,
        reason:
            'the OS took the link; nothing here knows whether the page loads',
      );
    });

    test('a second tap is a second handoff, not a retry', () async {
      // Nothing is queued, deduplicated or retried: the user's tap is the only
      // thing that starts one.
      final h = harness();
      final opener = h.container.read(openSavedItemUrlProvider);

      await opener.open(item());
      await opener.open(item());

      expect(h.launcher.launched, hasLength(2));
      expect(noticeOf(h.container), isNull);
    });
  });

  group('a value this client refuses', () {
    final refused = <String>[
      '',
      '   ',
      'not a url',
      'example.com/articles/one',
      '/articles/one',
      'articles/one',
      '//example.com/articles/one',
      'http://',
      'https://exa mple.com/articles/one',
      'ftp://example.com/file.txt',
      'mailto:someone@example.com',
      'javascript:alert(1)',
      'file:///etc/passwd',
    ];

    for (final url in refused) {
      test('"$url" never reaches the platform', () async {
        final h = harness();

        await h.container.read(openSavedItemUrlProvider).open(item(url: url));

        expect(h.launcher.launched, isEmpty);
        final notice = noticeOf(h.container)!;
        expect(notice.copy, "This link can't be opened.");
        expect(notice.tone, FeedbackTone.danger);
        expect(
          notice.copy.toLowerCase().contains('page'),
          isFalse,
          reason:
              'a value the client will not open says nothing about the page',
        );
      });
    }

    test(
      'a relative value is refused, never completed against a base',
      () async {
        final h = harness();

        await h.container
            .read(openSavedItemUrlProvider)
            .open(item(url: '/articles/one'));

        expect(
          h.launcher.launched,
          isEmpty,
          reason:
              'resolving it would invent a destination the item does not have',
        );
      },
    );
  });

  group('a launch the platform refuses', () {
    test('a false result is reported and not retried', () async {
      final h = harness(results: const [false]);

      await h.container.read(openSavedItemUrlProvider).open(item());

      final notice = noticeOf(h.container)!;
      expect(notice.copy, "We couldn't open this link. Try again.");
      expect(notice.tone, FeedbackTone.danger);
      expect(h.launcher.calls, 1, reason: 'one tap, one attempt');
    });

    test('a thrown platform exception is reported, not raised', () async {
      // Android's implementation throws rather than returning false.
      final h = harness(
        results: [
          PlatformException(code: 'ACTIVITY_NOT_FOUND', message: 'no browser'),
        ],
      );

      await h.container.read(openSavedItemUrlProvider).open(item());

      expect(
        noticeOf(h.container)!.copy,
        "We couldn't open this link. Try again.",
      );
    });

    test('a missing plugin is reported, not raised', () async {
      final h = harness(results: [MissingPluginException('no plugin')]);

      await h.container.read(openSavedItemUrlProvider).open(item());

      expect(
        noticeOf(h.container)!.copy,
        "We couldn't open this link. Try again.",
      );
      expect(noticeOf(h.container)!.tone, FeedbackTone.danger);
    });

    test('a success after a failure adds no notice of its own', () async {
      final h = harness(results: const [false, true]);

      final opener = h.container.read(openSavedItemUrlProvider);
      await opener.open(item());
      expect(noticeOf(h.container), isNotNull);

      await opener.open(item());
      expect(
        noticeOf(h.container)!.copy,
        "We couldn't open this link. Try again.",
        reason: 'an accepted handoff publishes nothing to replace it with',
      );
      expect(h.launcher.calls, 2);
    });
  });

  group('nothing else changes', () {
    test('a failure creates no listing and issues no request', () async {
      final h = harness(results: const [false]);

      await h.container.read(openSavedItemUrlProvider).open(item());

      expect(h.container.exists(savedItemsProvider), isFalse);
      expect(h.container.exists(savedItemDetailProvider('item-1')), isFalse);
      expect(h.saved.listCalls, 0);
      expect(h.saved.detailCalls, 0);
      expect(h.saved.enrichCalls, 0);
      expect(h.saved.collectionCalls, 0);
    });

    test('an accepted handoff touches no saved-item state either', () async {
      final h = harness();

      await h.container.read(openSavedItemUrlProvider).open(item());

      expect(h.container.exists(savedItemsProvider), isFalse);
      expect(h.container.exists(savedItemDetailProvider('item-1')), isFalse);
      expect(h.saved.listCalls, 0);
      expect(h.saved.detailCalls, 0);
    });
  });
}
