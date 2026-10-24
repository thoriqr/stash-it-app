import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_it_app/app/feedback/app_feedback.dart';
import 'package:stash_it_app/app/feedback/feedback_controller.dart';
import 'package:stash_it_app/core/error/api_failure.dart';
import 'package:stash_it_app/features/auth/application/auth_state.dart';
import 'package:stash_it_app/features/profile/application/display_name_update_controller.dart';
import 'package:stash_it_app/features/profile/application/profile_controller.dart';
import 'package:stash_it_app/features/profile/data/profile_providers.dart';

import '../../../support/fake_profile_repository.dart';

class _RecordingAuthState extends AuthState {
  int signOutCalls = 0;

  @override
  AuthStatus build() => AuthStatus.signedIn;

  @override
  Future<void> signOut() async {
    signOutCalls++;
  }
}

void main() {
  ProviderContainer makeContainer(
    FakeProfileRepository fake, {
    _RecordingAuthState? auth,
  }) {
    return ProviderContainer.test(
      overrides: [
        profileRepositoryProvider.overrideWithValue(fake),
        if (auth != null) authStateProvider.overrideWith(() => auth),
      ],
      retry: (_, _) => null,
    );
  }

  test(
    'a confirmed rename applies the complete profile the server wrote',
    () async {
      final fake = FakeProfileRepository();
      final container = makeContainer(fake);
      await container.read(profileProvider.future);

      final outcome = await container
          .read(displayNameUpdateProvider.notifier)
          .save('  Ada Lovelace  ');

      expect(outcome, isA<DisplayNameUpdateSucceeded>());
      expect(fake.renamedNames, ['  Ada Lovelace  ']);
      expect(
        container.read(profileProvider).value!.displayName,
        '  Ada Lovelace  ',
      );
      expect(container.read(feedbackProvider)?.tone, FeedbackTone.success);
      expect(container.read(feedbackProvider)?.copy, 'Display name updated.');
    },
  );

  test('VALIDATION_ERROR is a field error rather than a notice', () async {
    final fake = FakeProfileRepository()
      ..renameFailure = const ApiFailureValidation([]);
    final container = makeContainer(fake);
    await container.read(profileProvider.future);

    final outcome = await container
        .read(displayNameUpdateProvider.notifier)
        .save('a');

    expect(outcome, isA<DisplayNameUpdateValidation>());
    expect(container.read(profileProvider).value!.displayName, 'Reader');
    expect(
      container.read(feedbackProvider),
      isNull,
      reason: 'a field error is shown against the field, not app-wide',
    );
  });

  test(
    'a rate limit reports the server wait and keeps the sheet open',
    () async {
      final fake = FakeProfileRepository()
        ..renameFailure = const ApiFailureRateLimited(
          code: 'USER_RATE_LIMIT_EXCEEDED',
          retryAfter: Duration(seconds: 30),
        );
      final container = makeContainer(fake);
      await container.read(profileProvider.future);

      final outcome = await container
          .read(displayNameUpdateProvider.notifier)
          .save('Ada Lovelace');

      expect(outcome, isA<DisplayNameUpdateRejected>());
      final rejected = outcome as DisplayNameUpdateRejected;
      expect(rejected.tone, FeedbackTone.warning);
      expect(rejected.message, contains('30 seconds'));
    },
  );

  test('a server fault is reconciled and described as unconfirmed', () async {
    // The rename handler commits the name before reading identities, so a 500
    // can arrive after the write landed. The client must not say it was not
    // changed, and must ask the server again.
    final fake = FakeProfileRepository()
      ..renameFailure = const ApiFailureServerFault();
    final container = makeContainer(fake);
    await container.read(profileProvider.future);

    final outcome = await container
        .read(displayNameUpdateProvider.notifier)
        .save('Ada Lovelace');

    expect(outcome, isA<DisplayNameUpdateUncertain>());

    final notice = container.read(feedbackProvider);
    expect(notice?.tone, FeedbackTone.uncertain);
    expect(notice?.copy, contains("couldn't confirm"));
    expect(notice?.copy, isNot(contains("wasn't changed")));

    await container.read(profileProvider.future);
    expect(
      fake.getUserCalls,
      2,
      reason: 'the ambiguous outcome must be reconciled by refetching',
    );
  });

  test('transport and unreadable outcomes are equally uncertain', () async {
    for (final failure in const [
      ApiFailureTransport(),
      ApiFailureUnreadableResponse(),
    ]) {
      final fake = FakeProfileRepository()..renameFailure = failure;
      final container = makeContainer(fake);
      await container.read(profileProvider.future);

      final outcome = await container
          .read(displayNameUpdateProvider.notifier)
          .save('Ada Lovelace');

      expect(outcome, isA<DisplayNameUpdateUncertain>(), reason: '$failure');
      expect(container.read(feedbackProvider)?.tone, FeedbackTone.uncertain);

      await container.read(profileProvider.future);
      expect(fake.getUserCalls, 2, reason: '$failure');
    }
  });

  test('USER_NOT_FOUND reconciles without signing the user out', () async {
    final auth = _RecordingAuthState();
    final fake = FakeProfileRepository()
      ..renameFailure = const ApiFailureUserNotFound(code: 'USER_NOT_FOUND');
    final container = makeContainer(fake, auth: auth);
    await container.read(profileProvider.future);

    final outcome = await container
        .read(displayNameUpdateProvider.notifier)
        .save('Ada Lovelace');

    expect(outcome, isA<DisplayNameUpdateAccountUnavailable>());
    expect(
      container.read(feedbackProvider)?.copy,
      'This account is no longer available.',
    );
    expect(auth.signOutCalls, 0);

    await container.read(profileProvider.future);
    expect(fake.getUserCalls, 2);
  });

  test('a second save while one is in flight writes nothing', () async {
    final fake = FakeProfileRepository()..renameGate = Completer<void>();
    final container = makeContainer(fake);
    await container.read(profileProvider.future);
    final notifier = container.read(displayNameUpdateProvider.notifier);

    final first = notifier.save('First');
    final second = await notifier.save('Second');

    expect(second, isA<DisplayNameUpdateIgnored>());
    expect(fake.renamedNames, ['First']);

    fake.renameGate!.complete();
    expect(await first, isA<DisplayNameUpdateSucceeded>());
  });
}
