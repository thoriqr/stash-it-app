import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_it_app/app/feedback/app_feedback.dart';
import 'package:stash_it_app/app/feedback/feedback_controller.dart';

/// The app's one feedback channel.
///
/// The channel holds whatever is currently showing and nothing else — no timer
/// (that is the presenter's, `feedback_host.dart`), no queue and no feature
/// concept. What matters here is the *change* semantics a presenter listens to:
/// what counts as a new notice and what counts as no change.
void main() {
  late ProviderContainer container;

  /// Every value the channel has published, in order.
  ///
  /// `fireImmediately` is left off, so this records changes rather than the
  /// initial null — which is the whole point: the presenter must not be handed
  /// the same state twice.
  late List<AppFeedback?> published;

  setUp(() {
    container = ProviderContainer();
    addTearDown(container.dispose);

    published = [];
    container.listen<AppFeedback?>(feedbackProvider, (previous, next) {
      published.add(next);
    });
  });

  Feedback channel() => container.read(feedbackProvider.notifier);

  /// A notice with [copy], as a *call site* would build it: a fresh value each
  /// time, rather than a reused constant.
  AppFeedback notice(String copy) =>
      AppFeedback(tone: FeedbackTone.danger, copy: copy);

  group('no feature concept', () {
    test('the channel starts showing nothing', () {
      expect(container.read(feedbackProvider), isNull);
      expect(published, isEmpty);
    });

    test('a caller supplies both the tone and the copy', () {
      // The channel cannot invent either: there is no mapping from an error to a
      // sentence here, and no default tone. That is what keeps it reusable by a
      // feature it has never heard of.
      const feedback = AppFeedback(
        tone: FeedbackTone.warning,
        copy: 'Too many saves. Try again shortly.',
      );
      channel().show(feedback);

      expect(container.read(feedbackProvider), same(feedback));
      expect(container.read(feedbackProvider)!.copy, isNotEmpty);
    });
  });

  group('publishing and dismissing', () {
    test('publishing shows the notice', () {
      channel().show(notice('That link was not saved.'));

      expect(
        container.read(feedbackProvider)?.copy,
        'That link was not saved.',
      );
      expect(published, hasLength(1));
    });

    test('dismissing clears it, and dismissing nothing is not an error', () {
      channel().dismiss();
      expect(container.read(feedbackProvider), isNull);
      expect(
        published,
        isEmpty,
        reason: 'nothing to nothing is not a change a presenter should see',
      );

      channel().show(notice('Saved.'));
      channel().dismiss();

      expect(container.read(feedbackProvider), isNull);
      expect(published.last, isNull);
    });
  });

  group('repeated and replaced notices', () {
    test('the same copy published twice is two notifications', () {
      // Saving two links that both fail the same way is two separate answers to
      // two separate actions, and the second is not "already showing". This only
      // holds because `AppFeedback` deliberately has no value equality: two
      // instances with identical fields are not `==`.
      channel().show(notice('We could not confirm the save.'));
      channel().show(notice('We could not confirm the save.'));

      expect(
        published,
        hasLength(2),
        reason: 'identical copy is a new notice, not a suppressed duplicate',
      );
      expect(published.first, isNot(same(published.last)));
    });

    test('the identical instance twice is no change', () {
      // The other half of the same rule: if nothing about the notice changed,
      // there is nothing to re-present. A presenter that replayed this would
      // restart its animation for a state it is already showing.
      final same = notice('Saved.');
      channel().show(same);
      channel().show(same);

      expect(published, hasLength(1));
    });

    test('a second notice replaces the first rather than queueing', () {
      channel().show(notice('First.'));
      channel().show(notice('Second.'));

      expect(container.read(feedbackProvider)?.copy, 'Second.');
      expect(
        published.map((feedback) => feedback?.copy).toList(),
        ['First.', 'Second.'],
        reason:
            'each publish is its own change, so the presenter animates the '
            'replacement instead of stacking notices',
      );
    });

    test('showing again after a dismissal works', () {
      channel().show(notice('Saved.'));
      channel().dismiss();
      channel().show(notice('Saved.'));

      expect(container.read(feedbackProvider)?.copy, 'Saved.');
      expect(published, hasLength(3));
    });
  });

  group('the value carries no backend prose', () {
    test('there is nowhere for a server message to be stored', () {
      // [D22] This is a structural guarantee, not a convention: `AppFeedback`
      // has two fields and neither is a code or a server string. The taxonomy in
      // `core/error` carries none either, so a backend message has no path to
      // the screen.
      const feedback = AppFeedback(tone: FeedbackTone.success, copy: 'Saved.');

      expect(feedback.toString(), isNot(contains('message')));
      expect(feedback.copy, 'Saved.');
    });
  });
}
