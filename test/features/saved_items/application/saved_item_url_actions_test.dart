import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_it_app/app/feedback/feedback_controller.dart';
import 'package:stash_it_app/features/saved_items/application/saved_item_url_actions.dart';
import 'package:stash_it_app/l10n/app_localizations.dart';

/// Copy and share, separated from the platform channels.
///
/// These pin the complete-URL rule, the ordinary-cancellation rule, and the
/// clipboard fallback when the native sheet cannot be opened.
void main() {
  final english = lookupAppLocalizations(const Locale('en'));
  const url = 'https://example.com/articles/1?source=detail';

  ProviderContainer containerWith({
    required SavedItemClipboard clipboard,
    required SavedItemShareLauncher share,
  }) {
    final container = ProviderContainer(
      overrides: [
        savedItemClipboardProvider.overrideWithValue(clipboard),
        savedItemShareLauncherProvider.overrideWithValue(share),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  String? noticeOf(ProviderContainer container) =>
      container.read(feedbackProvider)?.resolve(english);

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
  });

  group('copy', () {
    test('writes the complete URL and publishes success', () async {
      final clipboard = _FakeClipboard();
      final container = containerWith(
        clipboard: clipboard,
        share: _FakeShare(SavedItemShareOutcome.failed),
      );

      await container.read(savedItemUrlActionsProvider).copy(url);

      expect(clipboard.writes, [url]);
      expect(noticeOf(container), 'URL copied');
    });

    test('publishes failure when the clipboard refuses', () async {
      final clipboard = _FakeClipboard(written: false);
      final container = containerWith(
        clipboard: clipboard,
        share: _FakeShare(SavedItemShareOutcome.failed),
      );

      await container.read(savedItemUrlActionsProvider).copy(url);

      expect(clipboard.writes, [url]);
      expect(noticeOf(container), "Couldn't copy the URL. Try again.");
    });

    test('an empty URL is not written', () async {
      final clipboard = _FakeClipboard();
      final container = containerWith(
        clipboard: clipboard,
        share: _FakeShare(SavedItemShareOutcome.failed),
      );

      await container.read(savedItemUrlActionsProvider).copy('   ');

      expect(clipboard.writes, isEmpty);
      expect(noticeOf(container), "Couldn't copy the URL. Try again.");
    });
  });

  group('share', () {
    test('a successful share is silent and does not copy', () async {
      final clipboard = _FakeClipboard();
      final share = _FakeShare(SavedItemShareOutcome.shared);
      final container = containerWith(clipboard: clipboard, share: share);

      await container.read(savedItemUrlActionsProvider).share(url);

      expect(share.shared, [url]);
      expect(clipboard.writes, isEmpty);
      expect(noticeOf(container), isNull);
    });

    test('a dismissed sheet is cancellation, not a failure', () async {
      final clipboard = _FakeClipboard();
      final share = _FakeShare(SavedItemShareOutcome.dismissed);
      final container = containerWith(clipboard: clipboard, share: share);

      await container.read(savedItemUrlActionsProvider).share(url);

      expect(share.shared, [url]);
      expect(clipboard.writes, isEmpty);
      expect(noticeOf(container), isNull);
    });

    test('a failed sheet falls back to copying the same URL', () async {
      final clipboard = _FakeClipboard();
      final share = _FakeShare(SavedItemShareOutcome.failed);
      final container = containerWith(clipboard: clipboard, share: share);

      await container.read(savedItemUrlActionsProvider).share(url);

      expect(share.shared, [url]);
      expect(clipboard.writes, [url]);
      expect(noticeOf(container), 'URL copied');
    });

    test('a failed sheet and failed copy reports the copy failure', () async {
      final clipboard = _FakeClipboard(written: false);
      final share = _FakeShare(SavedItemShareOutcome.failed);
      final container = containerWith(clipboard: clipboard, share: share);

      await container.read(savedItemUrlActionsProvider).share(url);

      expect(clipboard.writes, [url]);
      expect(noticeOf(container), "Couldn't copy the URL. Try again.");
    });
  });

  group('platform behavior', () {
    test('Android exposes share', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      expect(showsSavedItemShareAction, isTrue);
    });

    test('Windows and macOS expose copy only', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.windows;
      expect(showsSavedItemShareAction, isFalse);

      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
      expect(showsSavedItemShareAction, isFalse);
    });
  });
}

class _FakeClipboard extends SavedItemClipboard {
  _FakeClipboard({this.written = true});

  final bool written;
  final List<String> writes = [];

  @override
  Future<bool> write(String text) async {
    writes.add(text);
    return written;
  }
}

class _FakeShare extends SavedItemShareLauncher {
  _FakeShare(this.outcome);

  final SavedItemShareOutcome outcome;
  final List<String> shared = [];

  @override
  Future<SavedItemShareOutcome> share(String text) async {
    shared.add(text);
    return outcome;
  }
}
