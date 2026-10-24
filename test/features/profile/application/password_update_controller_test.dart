import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_it_app/app/feedback/app_feedback.dart';
import 'package:stash_it_app/app/feedback/feedback_controller.dart';
import 'package:stash_it_app/core/error/api_failure.dart';
import 'package:stash_it_app/features/auth/application/auth_state.dart';
import 'package:stash_it_app/features/profile/application/password_update_controller.dart';
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
    'create mode omits the current password and sets the flag only after 200',
    () async {
      final auth = _RecordingAuthState();
      final fake = FakeProfileRepository(
        profile: profileFixture(hasPasswordCredential: false),
      );
      final container = makeContainer(fake, auth: auth);
      await container.read(profileProvider.future);

      final outcome = await container
          .read(passwordUpdateProvider.notifier)
          .submit(
            change: false,
            newPassword: 'a first password',
            currentPassword: 'ignored in create mode',
          );

      expect(outcome, isA<PasswordUpdateSucceeded>());
      expect(fake.passwordSubmissions.single.currentPassword, isNull);
      expect(fake.passwordSubmissions.single.newPassword, 'a first password');
      expect(
        container.read(profileProvider).value!.hasPasswordCredential,
        isTrue,
      );
      expect(container.read(feedbackProvider)?.copy, 'Password created.');
      expect(
        auth.signOutCalls,
        0,
        reason: 'creating a password does not end the caller session',
      );
    },
  );

  test('change mode sends the current password exactly as typed', () async {
    final auth = _RecordingAuthState();
    final fake = FakeProfileRepository();
    final container = makeContainer(fake, auth: auth);
    await container.read(profileProvider.future);

    final outcome = await container
        .read(passwordUpdateProvider.notifier)
        .submit(
          change: true,
          newPassword: 'a new password',
          currentPassword: '  my current password  ',
        );

    expect(outcome, isA<PasswordUpdateSucceeded>());
    expect(
      fake.passwordSubmissions.single.currentPassword,
      '  my current password  ',
    );
    expect(container.read(feedbackProvider)?.copy, 'Password changed.');
    expect(auth.signOutCalls, 0);
  });

  test(
    'CURRENT_PASSWORD_INVALID leaves the credential flag untouched',
    () async {
      final fake =
          FakeProfileRepository(
              profile: profileFixture(hasPasswordCredential: true),
            )
            ..passwordFailure = const ApiFailureCurrentPasswordInvalid(
              code: 'CURRENT_PASSWORD_INVALID',
            );
      final container = makeContainer(fake);
      await container.read(profileProvider.future);

      final outcome = await container
          .read(passwordUpdateProvider.notifier)
          .submit(
            change: true,
            newPassword: 'a new password',
            currentPassword: 'wrong',
          );

      expect(outcome, isA<PasswordUpdateCurrentPasswordInvalid>());
      expect(
        container.read(profileProvider).value!.hasPasswordCredential,
        isTrue,
        reason: 'the flag was already true and nothing confirmed a change',
      );
      expect(container.read(feedbackProvider), isNull);
    },
  );

  test('a failed create never marks the credential optimistically', () async {
    for (final failure in const [
      ApiFailureValidation([]),
      ApiFailurePasswordAlreadyChanged(code: 'PASSWORD_ALREADY_CHANGED'),
      ApiFailurePasswordCredentialAlreadyExists(
        code: 'PASSWORD_CREDENTIAL_ALREADY_EXISTS',
      ),
    ]) {
      final fake = FakeProfileRepository(
        profile: profileFixture(hasPasswordCredential: false),
      )..passwordFailure = failure;
      final container = makeContainer(fake);
      await container.read(profileProvider.future);

      await container
          .read(passwordUpdateProvider.notifier)
          .submit(change: false, newPassword: 'a first password');

      expect(
        container.read(profileProvider).value!.hasPasswordCredential,
        isFalse,
        reason: '$failure must not be treated as success',
      );
    }
  });

  test('PASSWORD_ALREADY_CHANGED is its own outcome', () async {
    final fake = FakeProfileRepository()
      ..passwordFailure = const ApiFailurePasswordAlreadyChanged(
        code: 'PASSWORD_ALREADY_CHANGED',
      );
    final container = makeContainer(fake);
    await container.read(profileProvider.future);

    final outcome = await container
        .read(passwordUpdateProvider.notifier)
        .submit(
          change: true,
          newPassword: 'a new password',
          currentPassword: 'old password',
        );

    expect(outcome, isA<PasswordUpdateAlreadyChanged>());
  });

  test(
    'each credential-state mismatch closes the form and refetches',
    () async {
      final cases = <(ApiFailure, String)>[
        (
          const ApiFailureCurrentPasswordRequired(
            code: 'CURRENT_PASSWORD_REQUIRED',
          ),
          'already has a password',
        ),
        (
          const ApiFailureUnexpectedCurrentPassword(
            code: 'UNEXPECTED_CURRENT_PASSWORD',
          ),
          'has no password yet',
        ),
        (
          const ApiFailurePasswordCredentialAlreadyExists(
            code: 'PASSWORD_CREDENTIAL_ALREADY_EXISTS',
          ),
          'was already created',
        ),
      ];

      for (final (failure, expectedCopy) in cases) {
        final fake = FakeProfileRepository()..passwordFailure = failure;
        final container = makeContainer(fake);
        await container.read(profileProvider.future);

        final outcome = await container
            .read(passwordUpdateProvider.notifier)
            .submit(change: false, newPassword: 'a first password');

        expect(outcome, isA<PasswordUpdateModeConflict>(), reason: '$failure');
        expect(container.read(feedbackProvider)?.tone, FeedbackTone.warning);
        expect(container.read(feedbackProvider)?.copy, contains(expectedCopy));

        await container.read(profileProvider.future);
        expect(fake.getUserCalls, 2, reason: '$failure');
      }
    },
  );

  test('a rate limit is capacity-neutral and never blames attempts', () async {
    final fake = FakeProfileRepository()
      ..passwordFailure = const ApiFailureRateLimited(
        code: 'PASSWORD_WORK_UNAVAILABLE',
        retryAfter: Duration(seconds: 90),
      );
    final container = makeContainer(fake);
    await container.read(profileProvider.future);

    final outcome = await container
        .read(passwordUpdateProvider.notifier)
        .submit(change: false, newPassword: 'a first password');

    expect(outcome, isA<PasswordUpdateRejected>());
    final rejected = outcome as PasswordUpdateRejected;
    expect(rejected.tone, FeedbackTone.warning);
    expect(rejected.message, contains('90 seconds'));
    expect(rejected.message, isNot(contains('Too many attempts')));
    expect(
      rejected.message,
      isNot(contains('too many')),
      reason:
          'a spent budget and exhausted password capacity are different '
          'causes with the same wait',
    );
  });

  test('an ambiguous write is reconciled and never called unchanged', () async {
    for (final failure in const [
      ApiFailureServerFault(),
      ApiFailureTransport(),
      ApiFailureUnreadableResponse(),
    ]) {
      final fake = FakeProfileRepository(
        profile: profileFixture(hasPasswordCredential: false),
      )..passwordFailure = failure;
      final container = makeContainer(fake);
      await container.read(profileProvider.future);

      final outcome = await container
          .read(passwordUpdateProvider.notifier)
          .submit(change: false, newPassword: 'a first password');

      expect(outcome, isA<PasswordUpdateUncertain>(), reason: '$failure');
      final notice = container.read(feedbackProvider);
      expect(notice?.tone, FeedbackTone.uncertain);
      expect(notice?.copy, contains("couldn't confirm"));
      expect(notice?.copy, isNot(contains("wasn't written")));
      expect(notice?.copy, isNot(contains('unchanged')));

      await container.read(profileProvider.future);
      expect(fake.getUserCalls, 2, reason: '$failure');
    }
  });

  test('USER_NOT_FOUND refetches and does not sign the user out', () async {
    final auth = _RecordingAuthState();
    final fake = FakeProfileRepository()
      ..passwordFailure = const ApiFailureUserNotFound(code: 'USER_NOT_FOUND');
    final container = makeContainer(fake, auth: auth);
    await container.read(profileProvider.future);

    final outcome = await container
        .read(passwordUpdateProvider.notifier)
        .submit(change: false, newPassword: 'a first password');

    expect(outcome, isA<PasswordUpdateAccountUnavailable>());
    expect(auth.signOutCalls, 0);

    await container.read(profileProvider.future);
    expect(fake.getUserCalls, 2);
  });

  test('a second submission while one is in flight sends nothing', () async {
    final fake = FakeProfileRepository()..passwordGate = Completer<void>();
    final container = makeContainer(fake);
    await container.read(profileProvider.future);
    final notifier = container.read(passwordUpdateProvider.notifier);

    final first = notifier.submit(
      change: false,
      newPassword: 'a first password',
    );
    final second = await notifier.submit(
      change: false,
      newPassword: 'a second password',
    );

    expect(second, isA<PasswordUpdateIgnored>());
    expect(fake.passwordCalls, 1);

    fake.passwordGate!.complete();
    expect(await first, isA<PasswordUpdateSucceeded>());
  });
}
