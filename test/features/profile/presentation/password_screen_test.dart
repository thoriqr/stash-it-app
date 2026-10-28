import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_it_app/app/feedback/feedback_controller.dart';
import 'package:stash_it_app/app/theme/app_theme.dart';
import 'package:stash_it_app/core/error/api_failure.dart';
import 'package:stash_it_app/features/profile/application/profile_controller.dart';
import 'package:stash_it_app/features/profile/data/profile_providers.dart';
import 'package:stash_it_app/features/profile/presentation/password_screen.dart';
import 'package:stash_it_app/shared/widgets/app_button.dart';
import 'package:stash_it_app/shared/widgets/app_field.dart';

import '../../../support/fake_profile_repository.dart';

void main() {
  Future<ProviderContainer> pumpPasswordScreen(
    WidgetTester tester,
    FakeProfileRepository repository, {
    bool awaitProfile = true,
    bool settle = true,
  }) async {
    final container = ProviderContainer.test(
      overrides: [profileRepositoryProvider.overrideWithValue(repository)],
    );
    if (awaitProfile) await container.read(profileProvider.future);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.light(),
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const PasswordScreen(),
                    ),
                  ),
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    if (settle) {
      await tester.pumpAndSettle();
    } else {
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
    }
    return container;
  }

  List<TextField> fields(WidgetTester tester) {
    return tester.widgetList<TextField>(find.byType(TextField)).toList();
  }

  Finder fieldFor(String label) => find.widgetWithText(AppField, label);

  testWidgets('create mode shows two fields and omits the session note', (
    tester,
  ) async {
    final repository = FakeProfileRepository(
      profile: profileFixture(hasPasswordCredential: false),
    );
    await pumpPasswordScreen(tester, repository);

    expect(find.text('CREATE PASSWORD'), findsOneWidget);
    expect(find.text('New password'), findsOneWidget);
    expect(find.text('Confirm new password'), findsOneWidget);
    expect(find.text('Current password'), findsNothing);
    expect(find.textContaining('15 minutes'), findsNothing);

    final visible = fields(tester);
    expect(visible, hasLength(2));
    expect(visible[0].autofillHints, [AutofillHints.newPassword]);
    expect(visible[1].autofillHints, isNull);
  });

  testWidgets('change mode shows three fields and no session note', (
    tester,
  ) async {
    final repository = FakeProfileRepository(
      profile: profileFixture(hasPasswordCredential: true),
    );
    await pumpPasswordScreen(tester, repository);

    expect(find.text('CHANGE PASSWORD'), findsOneWidget);
    expect(find.text('Current password'), findsOneWidget);
    expect(find.text('New password'), findsOneWidget);
    expect(find.text('Confirm new password'), findsOneWidget);
    expect(find.textContaining('15 minutes'), findsNothing);

    final visible = fields(tester);
    expect(visible, hasLength(3));
    expect(visible[0].autofillHints, [AutofillHints.password]);
    expect(visible[1].autofillHints, [AutofillHints.newPassword]);
    expect(visible[2].autofillHints, isNull);
    expect(find.byTooltip('Show current password'), findsOneWidget);
  });

  testWidgets('an unavailable profile never defaults to the create form', (
    tester,
  ) async {
    final repository = FakeProfileRepository()
      ..getUserFailure = const ApiFailureTransport();
    await pumpPasswordScreen(tester, repository, awaitProfile: false);

    expect(
      find.text('No connection. We could not load your profile.'),
      findsOneWidget,
    );
    expect(find.widgetWithText(AppButton, 'Retry'), findsOneWidget);
    expect(find.text('New password'), findsNothing);
    expect(find.text('Create password'), findsNothing);
  });

  testWidgets('a loading profile shows no form until the mode is known', (
    tester,
  ) async {
    final repository = FakeProfileRepository()..getUserGate = Completer<void>();
    await pumpPasswordScreen(
      tester,
      repository,
      awaitProfile: false,
      settle: false,
    );

    expect(find.text('Loading profile…'), findsOneWidget);
    expect(find.text('New password'), findsNothing);

    repository.getUserGate!.complete();
    await tester.pumpAndSettle();

    expect(find.text('New password'), findsOneWidget);
    expect(find.text('CHANGE PASSWORD'), findsOneWidget);
  });

  testWidgets('a short new password is caught before the request', (
    tester,
  ) async {
    final repository = FakeProfileRepository(
      profile: profileFixture(hasPasswordCredential: false),
    );
    await pumpPasswordScreen(tester, repository);

    await tester.enterText(fieldFor('New password'), 'short');
    await tester.enterText(fieldFor('Confirm new password'), 'short');
    await tester.tap(find.widgetWithText(AppButton, 'Create password'));
    await tester.pumpAndSettle();

    expect(find.text('Use between 8 and 128 characters.'), findsOneWidget);
    expect(repository.passwordCalls, 0);
    expect(find.byType(PasswordScreen), findsOneWidget);
  });

  testWidgets(
    'a mismatched confirmation is client-only and blocks the request',
    (tester) async {
      final repository = FakeProfileRepository(
        profile: profileFixture(hasPasswordCredential: false),
      );
      await pumpPasswordScreen(tester, repository);

      await tester.enterText(fieldFor('New password'), 'a new password');
      await tester.enterText(
        fieldFor('Confirm new password'),
        'a different one',
      );
      await tester.tap(find.widgetWithText(AppButton, 'Create password'));
      await tester.pumpAndSettle();

      expect(find.text('The passwords do not match.'), findsOneWidget);
      expect(repository.passwordCalls, 0);
    },
  );

  testWidgets('change mode requires a non-empty current password', (
    tester,
  ) async {
    final repository = FakeProfileRepository(
      profile: profileFixture(hasPasswordCredential: true),
    );
    await pumpPasswordScreen(tester, repository);

    await tester.enterText(fieldFor('New password'), 'a new password');
    await tester.enterText(fieldFor('Confirm new password'), 'a new password');
    await tester.tap(find.widgetWithText(AppButton, 'Change password'));
    await tester.pumpAndSettle();

    expect(find.text('Enter your current password.'), findsOneWidget);
    expect(repository.passwordCalls, 0);
  });

  testWidgets('create mode submits without a current-password key', (
    tester,
  ) async {
    final repository = FakeProfileRepository(
      profile: profileFixture(hasPasswordCredential: false),
    );
    final container = await pumpPasswordScreen(tester, repository);

    await tester.enterText(fieldFor('New password'), 'a first password');
    await tester.enterText(
      fieldFor('Confirm new password'),
      'a first password',
    );
    await tester.tap(find.widgetWithText(AppButton, 'Create password'));
    await tester.pumpAndSettle();

    expect(find.byType(PasswordScreen), findsNothing);
    expect(repository.passwordSubmissions.single.currentPassword, isNull);
    expect(container.read(feedbackProvider)?.copy, 'Password created.');
  });

  testWidgets('CURRENT_PASSWORD_INVALID is shown on the current field', (
    tester,
  ) async {
    final repository = FakeProfileRepository()
      ..passwordFailure = const ApiFailureCurrentPasswordInvalid(
        code: 'CURRENT_PASSWORD_INVALID',
      );
    await pumpPasswordScreen(tester, repository);

    await tester.enterText(fieldFor('Current password'), 'wrong password');
    await tester.enterText(fieldFor('New password'), 'a new password');
    await tester.enterText(fieldFor('Confirm new password'), 'a new password');
    await tester.tap(find.widgetWithText(AppButton, 'Change password'));
    await tester.pumpAndSettle();

    expect(find.text('That current password is incorrect.'), findsOneWidget);
    expect(find.byType(PasswordScreen), findsOneWidget);
    expect(fields(tester)[0].controller?.text, 'wrong password');
  });

  testWidgets('PASSWORD_ALREADY_CHANGED clears the stale current password', (
    tester,
  ) async {
    final repository = FakeProfileRepository()
      ..passwordFailure = const ApiFailurePasswordAlreadyChanged(
        code: 'PASSWORD_ALREADY_CHANGED',
      );
    await pumpPasswordScreen(tester, repository);

    await tester.enterText(fieldFor('Current password'), 'old password');
    await tester.enterText(fieldFor('New password'), 'a new password');
    await tester.enterText(fieldFor('Confirm new password'), 'a new password');
    await tester.tap(find.widgetWithText(AppButton, 'Change password'));
    await tester.pumpAndSettle();

    expect(find.byType(PasswordScreen), findsOneWidget);
    expect(fields(tester)[0].controller?.text, isEmpty);
    expect(find.textContaining('changed somewhere else'), findsOneWidget);
  });

  testWidgets('a rate limit keeps the form and uses capacity-neutral copy', (
    tester,
  ) async {
    final repository =
        FakeProfileRepository(
            profile: profileFixture(hasPasswordCredential: false),
          )
          ..passwordFailure = const ApiFailureRateLimited(
            code: 'PASSWORD_WORK_UNAVAILABLE',
            retryAfter: Duration(seconds: 45),
          );
    await pumpPasswordScreen(tester, repository);

    await tester.enterText(fieldFor('New password'), 'a first password');
    await tester.enterText(
      fieldFor('Confirm new password'),
      'a first password',
    );
    await tester.tap(find.widgetWithText(AppButton, 'Create password'));
    await tester.pumpAndSettle();

    expect(find.byType(PasswordScreen), findsOneWidget);
    expect(find.textContaining('45 seconds'), findsOneWidget);
    expect(find.textContaining('Too many attempts'), findsNothing);
    expect(fields(tester)[0].controller?.text, 'a first password');
  });

  testWidgets('a mode conflict closes the screen and explains what changed', (
    tester,
  ) async {
    final repository =
        FakeProfileRepository(
            profile: profileFixture(hasPasswordCredential: false),
          )
          ..passwordFailure = const ApiFailureCurrentPasswordRequired(
            code: 'CURRENT_PASSWORD_REQUIRED',
          );
    final container = await pumpPasswordScreen(tester, repository);

    await tester.enterText(fieldFor('New password'), 'a first password');
    await tester.enterText(
      fieldFor('Confirm new password'),
      'a first password',
    );
    await tester.tap(find.widgetWithText(AppButton, 'Create password'));
    await tester.pumpAndSettle();

    expect(find.byType(PasswordScreen), findsNothing);
    expect(
      container.read(feedbackProvider)?.copy,
      contains('already has a password'),
    );
    await container.read(profileProvider.future);
    expect(repository.getUserCalls, 2);
  });
}
