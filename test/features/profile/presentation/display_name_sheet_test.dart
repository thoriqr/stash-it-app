import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_it_app/app/feedback/feedback_controller.dart';
import 'package:stash_it_app/app/theme/app_theme.dart';
import 'package:stash_it_app/core/error/api_failure.dart';
import 'package:stash_it_app/features/profile/application/profile_controller.dart';
import 'package:stash_it_app/features/profile/data/profile_providers.dart';
import 'package:stash_it_app/features/profile/presentation/widgets/display_name_sheet.dart';
import 'package:stash_it_app/shared/widgets/app_button.dart';

import '../../../support/fake_profile_repository.dart';

void main() {
  Future<ProviderContainer> pumpSheet(
    WidgetTester tester, {
    required FakeProfileRepository repository,
    String initialName = 'Reader',
  }) async {
    final container = ProviderContainer.test(
      overrides: [profileRepositoryProvider.overrideWithValue(repository)],
    );
    await container.read(profileProvider.future);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.light(),
          home: Scaffold(
            body: Builder(
              builder: (context) => Center(
                child: TextButton(
                  onPressed: () =>
                      showDisplayNameSheet(context, initialName: initialName),
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    return container;
  }

  TextFormField field(WidgetTester tester) =>
      tester.widget<TextFormField>(find.byType(TextFormField));

  testWidgets('pre-fills the raw stored name, untrimmed', (tester) async {
    await pumpSheet(
      tester,
      repository: FakeProfileRepository(),
      initialName: '  Ada Lovelace  ',
    );

    expect(find.text('Edit display name'), findsOneWidget);
    expect(field(tester).controller?.text, '  Ada Lovelace  ');
    expect(find.widgetWithText(AppButton, 'Save'), findsOneWidget);
    expect(find.widgetWithText(AppButton, 'Cancel'), findsOneWidget);
  });

  testWidgets('a locally invalid name never reaches the repository', (
    tester,
  ) async {
    final repository = FakeProfileRepository();
    await pumpSheet(tester, repository: repository);

    await tester.enterText(find.byType(TextFormField), 'a');
    await tester.tap(find.widgetWithText(AppButton, 'Save'));
    await tester.pumpAndSettle();

    expect(find.text('Use between 2 and 100 characters.'), findsOneWidget);
    expect(find.text('Edit display name'), findsOneWidget);
    expect(repository.renamedNames, isEmpty);
  });

  testWidgets('a confirmed save closes the sheet with the typed name intact', (
    tester,
  ) async {
    final repository = FakeProfileRepository();
    await pumpSheet(tester, repository: repository);

    await tester.enterText(find.byType(TextFormField), '  Ada Lovelace  ');
    await tester.tap(find.widgetWithText(AppButton, 'Save'));
    await tester.pumpAndSettle();

    expect(find.text('Edit display name'), findsNothing);
    expect(repository.renamedNames, ['  Ada Lovelace  ']);
  });

  testWidgets('a known refusal keeps the sheet and the typed name', (
    tester,
  ) async {
    final repository = FakeProfileRepository()
      ..renameFailure = const ApiFailureRateLimited(
        code: 'USER_RATE_LIMIT_EXCEEDED',
        retryAfter: Duration(seconds: 30),
      );
    await pumpSheet(tester, repository: repository);

    await tester.enterText(find.byType(TextFormField), 'Ada Lovelace');
    await tester.tap(find.widgetWithText(AppButton, 'Save'));
    await tester.pumpAndSettle();

    expect(find.text('Edit display name'), findsOneWidget);
    expect(find.textContaining('30 seconds'), findsOneWidget);
    expect(field(tester).controller?.text, 'Ada Lovelace');
  });

  testWidgets('an ambiguous outcome closes instead of inviting a blind retry', (
    tester,
  ) async {
    final repository = FakeProfileRepository()
      ..renameFailure = const ApiFailureServerFault();
    final container = await pumpSheet(tester, repository: repository);

    await tester.enterText(find.byType(TextFormField), 'Ada Lovelace');
    await tester.tap(find.widgetWithText(AppButton, 'Save'));
    await tester.pumpAndSettle();

    expect(find.text('Edit display name'), findsNothing);
    expect(
      container.read(feedbackProvider)?.copy,
      contains("couldn't confirm"),
    );
    expect(
      container.read(feedbackProvider)?.copy,
      isNot(contains("wasn't changed")),
    );
  });

  testWidgets('USER_NOT_FOUND closes and says the account is unavailable', (
    tester,
  ) async {
    final repository = FakeProfileRepository()
      ..renameFailure = const ApiFailureUserNotFound(code: 'USER_NOT_FOUND');
    final container = await pumpSheet(tester, repository: repository);

    await tester.enterText(find.byType(TextFormField), 'Ada Lovelace');
    await tester.tap(find.widgetWithText(AppButton, 'Save'));
    await tester.pumpAndSettle();

    expect(find.text('Edit display name'), findsNothing);
    expect(
      container.read(feedbackProvider)?.copy,
      'This account is no longer available.',
    );
  });
}
