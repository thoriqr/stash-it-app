import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_it_app/app/feedback/app_feedback.dart';
import 'package:stash_it_app/features/pending_urls/application/pending_url_save_state.dart';
import 'package:stash_it_app/features/pending_urls/presentation/pending_url_save_summary_copy.dart';
import 'package:stash_it_app/l10n/app_localizations.dart';

void main() {
  final english = lookupAppLocalizations(const Locale('en'));
  final indonesian = lookupAppLocalizations(const Locale('id'));

  test('all saved is a success', () {
    final feedback = pendingUrlSaveSummaryFeedback(
      const PendingUrlSaveSummary(total: 3, saved: 3, remaining: 0),
    );

    expect(feedback.tone, FeedbackTone.success);
    expect(feedback.resolve(english), 'Saved all 3 links to your account.');
  });

  test('one saved link is singular', () {
    final feedback = pendingUrlSaveSummaryFeedback(
      const PendingUrlSaveSummary(total: 1, saved: 1, remaining: 0),
    );

    expect(feedback.tone, FeedbackTone.success);
    expect(feedback.resolve(english), 'Saved the link to your account.');
  });

  test('a partial run is a warning with the remaining count', () {
    final feedback = pendingUrlSaveSummaryFeedback(
      const PendingUrlSaveSummary(total: 3, saved: 2, remaining: 1),
    );

    expect(feedback.tone, FeedbackTone.warning);
    expect(feedback.resolve(english), contains('Saved 2 of 3 links.'));
    expect(
      feedback.resolve(english),
      contains('1 link is still on this device.'),
    );
  });

  test('nothing saved is a known failure', () {
    final feedback = pendingUrlSaveSummaryFeedback(
      const PendingUrlSaveSummary(total: 3, saved: 0, remaining: 3),
    );

    expect(feedback.tone, FeedbackTone.danger);
    expect(feedback.resolve(english), contains('No links were saved.'));
    expect(
      feedback.resolve(english),
      contains('3 links are still on this device.'),
    );
  });

  test(
    'an uncertain outcome uses the uncertain tone and never says unsaved',
    () {
      final feedback = pendingUrlSaveSummaryFeedback(
        const PendingUrlSaveSummary(
          total: 2,
          saved: 1,
          uncertain: 1,
          remaining: 1,
        ),
      );

      expect(feedback.tone, FeedbackTone.uncertain);
      expect(feedback.resolve(english), contains("couldn't confirm 1 link"));
      expect(
        feedback.resolve(english),
        contains('1 link is still on this device.'),
      );
      expect(
        feedback.resolve(english),
        contains('Check your Inbox before trying again.'),
      );
      expect(feedback.resolve(english), isNot(contains('wasn\u2019t saved')));
      expect(feedback.resolve(english), isNot(contains("wasn't saved")));
    },
  );

  test('a single uncertain link is described without a count', () {
    final feedback = pendingUrlSaveSummaryFeedback(
      const PendingUrlSaveSummary(total: 1, uncertain: 1, remaining: 1),
    );

    expect(feedback.tone, FeedbackTone.uncertain);
    expect(
      feedback.resolve(english),
      "We couldn't confirm the save. The link is still on this device. "
      'Check your Inbox before trying again.',
    );
  });

  test('a rate-limit stop reports the server wait', () {
    final feedback = pendingUrlSaveSummaryFeedback(
      const PendingUrlSaveSummary(
        total: 2,
        saved: 1,
        remaining: 1,
        stoppedBy: PendingUrlSaveStop.rateLimited,
        retryAfter: Duration(seconds: 42),
      ),
    );

    expect(feedback.tone, FeedbackTone.warning);
    expect(feedback.resolve(english), contains('Try again in 42 seconds.'));
  });

  test('a rate-limit stop without a server wait invents none', () {
    final feedback = pendingUrlSaveSummaryFeedback(
      const PendingUrlSaveSummary(
        total: 2,
        stoppedBy: PendingUrlSaveStop.rateLimited,
        remaining: 2,
      ),
    );

    expect(feedback.tone, FeedbackTone.warning);
    expect(feedback.resolve(english), contains('Try again shortly.'));
    expect(feedback.resolve(english), isNot(contains('seconds')));
  });

  test('an auth stop points at signing in again', () {
    final feedback = pendingUrlSaveSummaryFeedback(
      const PendingUrlSaveSummary(
        total: 2,
        saved: 1,
        remaining: 1,
        stoppedBy: PendingUrlSaveStop.authRequired,
      ),
    );

    expect(feedback.tone, FeedbackTone.warning);
    expect(
      feedback.resolve(english),
      contains('Sign in again to save the rest.'),
    );
  });

  test('a server stop points at a retry', () {
    final feedback = pendingUrlSaveSummaryFeedback(
      const PendingUrlSaveSummary(
        total: 2,
        saved: 1,
        remaining: 1,
        stoppedBy: PendingUrlSaveStop.server,
      ),
    );

    expect(feedback.tone, FeedbackTone.warning);
    expect(feedback.resolve(english), contains('Try again.'));
  });

  test('a local-list failure does not claim the entry was removed', () {
    final feedback = pendingUrlSaveSummaryFeedback(
      const PendingUrlSaveSummary(
        total: 2,
        saved: 1,
        remaining: 2,
        stoppedBy: PendingUrlSaveStop.localList,
      ),
    );

    expect(feedback.tone, FeedbackTone.warning);
    expect(feedback.resolve(english), contains("couldn't update the list"));
    expect(feedback.resolve(english), isNot(contains('Saved all')));
  });

  test('an unknown remaining count is omitted, not invented', () {
    final feedback = pendingUrlSaveSummaryFeedback(
      const PendingUrlSaveSummary(total: 3, saved: 2),
    );

    expect(feedback.tone, FeedbackTone.warning);
    expect(feedback.resolve(english), 'Saved 2 of 3 links.');
    expect(feedback.resolve(english), isNot(contains('still on this device')));
  });

  test('a zero remaining count does not claim the rest are still here', () {
    final partial = pendingUrlSaveSummaryFeedback(
      const PendingUrlSaveSummary(total: 3, saved: 2, remaining: 0),
    );
    expect(partial.resolve(english), 'Saved 2 of 3 links.');
    expect(partial.resolve(english), isNot(contains('still on this device')));

    final none = pendingUrlSaveSummaryFeedback(
      const PendingUrlSaveSummary(total: 2, knownFailed: 2, remaining: 0),
    );
    expect(none.tone, FeedbackTone.danger);
    expect(none.resolve(english), 'No links were saved.');
    expect(none.resolve(english), isNot(contains('still on this device')));
  });

  group('Indonesian copy', () {
    test('all saved is localized with singular and plural forms', () {
      final one = pendingUrlSaveSummaryFeedback(
        const PendingUrlSaveSummary(total: 1, saved: 1, remaining: 0),
      );
      final many = pendingUrlSaveSummaryFeedback(
        const PendingUrlSaveSummary(total: 3, saved: 3, remaining: 0),
      );

      expect(one.resolve(indonesian), 'Tautan tersimpan ke akun Anda.');
      expect(
        many.resolve(indonesian),
        'Semua 3 tautan tersimpan ke akun Anda.',
      );
    });

    test('partial and none-saved copy includes the remaining count', () {
      final partial = pendingUrlSaveSummaryFeedback(
        const PendingUrlSaveSummary(total: 3, saved: 2, remaining: 1),
      );
      final none = pendingUrlSaveSummaryFeedback(
        const PendingUrlSaveSummary(total: 3, remaining: 3),
      );

      expect(
        partial.resolve(indonesian),
        contains('Tersimpan 2 dari 3 tautan.'),
      );
      expect(
        partial.resolve(indonesian),
        contains('1 tautan masih ada di perangkat ini.'),
      );
      expect(
        none.resolve(indonesian),
        'Tidak ada tautan yang tersimpan. 3 tautan masih ada di perangkat ini.',
      );
    });

    test('uncertain copy never says the save failed', () {
      final single = pendingUrlSaveSummaryFeedback(
        const PendingUrlSaveSummary(total: 1, uncertain: 1, remaining: 1),
      );
      final partial = pendingUrlSaveSummaryFeedback(
        const PendingUrlSaveSummary(
          total: 2,
          saved: 1,
          uncertain: 1,
          remaining: 1,
        ),
      );

      expect(
        single.resolve(indonesian),
        'Kami tidak dapat mengonfirmasi penyimpanan. Tautan masih ada di perangkat ini. Periksa Inbox sebelum mencoba lagi.',
      );
      expect(
        partial.resolve(indonesian),
        'Tersimpan 1 dari 2 tautan. Kami tidak dapat mengonfirmasi 1 tautan. 1 tautan masih ada di perangkat ini. Periksa Inbox sebelum mencoba lagi.',
      );
      expect(partial.resolve(indonesian), isNot(contains('tidak tersimpan')));
    });

    test('rate-limit, auth, retry and local-list outcomes are localized', () {
      final rateLimited = pendingUrlSaveSummaryFeedback(
        const PendingUrlSaveSummary(
          total: 2,
          saved: 1,
          remaining: 1,
          stoppedBy: PendingUrlSaveStop.rateLimited,
          retryAfter: Duration(seconds: 42),
        ),
      );
      final auth = pendingUrlSaveSummaryFeedback(
        const PendingUrlSaveSummary(
          total: 2,
          saved: 1,
          remaining: 1,
          stoppedBy: PendingUrlSaveStop.authRequired,
        ),
      );
      final retry = pendingUrlSaveSummaryFeedback(
        const PendingUrlSaveSummary(
          total: 2,
          saved: 1,
          remaining: 1,
          stoppedBy: PendingUrlSaveStop.server,
        ),
      );
      final localList = pendingUrlSaveSummaryFeedback(
        const PendingUrlSaveSummary(
          total: 2,
          saved: 1,
          remaining: 2,
          stoppedBy: PendingUrlSaveStop.localList,
        ),
      );

      expect(
        rateLimited.resolve(indonesian),
        'Tersimpan 1 dari 2 tautan. Anda menyimpan terlalu cepat. Coba lagi dalam 42 detik. 1 tautan masih ada di perangkat ini.',
      );
      expect(
        auth.resolve(indonesian),
        'Tersimpan 1 dari 2 tautan. Masuk lagi untuk menyimpan sisanya. 1 tautan masih ada di perangkat ini.',
      );
      expect(
        retry.resolve(indonesian),
        'Tersimpan 1 dari 2 tautan. Coba lagi. 1 tautan masih ada di perangkat ini.',
      );
      expect(
        localList.resolve(indonesian),
        'Tersimpan 1 tautan, tetapi perangkat ini tidak dapat memperbarui daftar. Periksa daftar sebelum mencoba lagi.',
      );
    });

    test('an unknown remaining count is omitted in Indonesian too', () {
      final feedback = pendingUrlSaveSummaryFeedback(
        const PendingUrlSaveSummary(total: 3, saved: 2),
      );

      expect(feedback.resolve(indonesian), 'Tersimpan 2 dari 3 tautan.');
      expect(feedback.resolve(indonesian), isNot(contains('masih ada')));
    });

    test('singular stopped outcomes use complete localized messages', () {
      final rateLimited = pendingUrlSaveSummaryFeedback(
        const PendingUrlSaveSummary(
          total: 1,
          remaining: 1,
          stoppedBy: PendingUrlSaveStop.rateLimited,
          retryAfter: Duration(seconds: 5),
        ),
      );
      final auth = pendingUrlSaveSummaryFeedback(
        const PendingUrlSaveSummary(
          total: 1,
          remaining: 1,
          stoppedBy: PendingUrlSaveStop.authRequired,
        ),
      );
      final retry = pendingUrlSaveSummaryFeedback(
        const PendingUrlSaveSummary(
          total: 1,
          remaining: 1,
          stoppedBy: PendingUrlSaveStop.server,
        ),
      );

      expect(
        rateLimited.resolve(indonesian),
        'Tautan tidak tersimpan. Anda menyimpan terlalu cepat. Coba lagi dalam 5 detik. 1 tautan masih ada di perangkat ini.',
      );
      expect(
        auth.resolve(indonesian),
        'Tautan tidak tersimpan. Masuk lagi untuk menyimpan sisanya. 1 tautan masih ada di perangkat ini.',
      );
      expect(
        retry.resolve(indonesian),
        'Tautan tidak tersimpan. Coba lagi. 1 tautan masih ada di perangkat ini.',
      );
    });
  });
}
