import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:stash_it_app/app/feedback/app_feedback.dart';
import 'package:stash_it_app/app/feedback/feedback_controller.dart';
import 'package:stash_it_app/app/theme/app_theme.dart';
import 'package:stash_it_app/core/error/api_failure.dart';
import 'package:stash_it_app/features/settings/application/package_info_provider.dart';
import 'package:stash_it_app/features/user_feedback/data/datasources/user_feedback_api.dart';
import 'package:stash_it_app/features/user_feedback/data/models/create_user_feedback_request.dart';
import 'package:stash_it_app/features/user_feedback/data/user_feedback_providers.dart';
import 'package:stash_it_app/features/user_feedback/data/user_feedback_repository.dart';
import 'package:stash_it_app/features/user_feedback/presentation/user_feedback_screen.dart';
import 'package:stash_it_app/l10n/app_localizations.dart';

class _FakeUserFeedbackRepository extends UserFeedbackRepository {
  _FakeUserFeedbackRepository(this._onSubmit)
    : super(api: UserFeedbackApi(Dio()));

  final Future<void> Function(CreateUserFeedbackRequest request) _onSubmit;
  final List<CreateUserFeedbackRequest> requests = [];

  @override
  Future<void> submit(CreateUserFeedbackRequest request) {
    requests.add(request);
    return _onSubmit(request);
  }
}

final _installed = PackageInfo(
  appName: 'Stash-it',
  packageName: 'app.stashit',
  version: '1.3.1',
  buildNumber: '7',
);

void main() {
  Future<void> pumpScreen(
    WidgetTester tester,
    _FakeUserFeedbackRepository repository,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userFeedbackRepositoryProvider.overrideWithValue(repository),
          packageInfoProvider.overrideWith((ref) async => _installed),
        ],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.light(),
          home: const UserFeedbackScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> chooseBugAndMessage(
    WidgetTester tester, {
    required String message,
  }) async {
    await tester.tap(find.text('Bug'));
    await tester.pump();
    await tester.enterText(find.byType(TextFormField), message);
    await tester.pump();
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();
  }

  testWidgets('requires a type and a message before calling the API', (
    tester,
  ) async {
    final repository = _FakeUserFeedbackRepository((_) async {});
    await pumpScreen(tester, repository);

    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();

    expect(find.text('Choose a type.'), findsOneWidget);
    expect(find.text('Write your feedback first.'), findsOneWidget);
    expect(repository.requests, isEmpty);
  });

  testWidgets('a 429 keeps the draft, shows the wait, and blocks retry', (
    tester,
  ) async {
    const failure = ApiFailureRateLimited(
      code: 'USER_RATE_LIMIT_EXCEEDED',
      retryAfter: Duration(minutes: 1),
    );
    final repository = _FakeUserFeedbackRepository((_) async {
      throw failure;
    });
    await pumpScreen(tester, repository);

    await chooseBugAndMessage(tester, message: 'The note preview disappears.');

    final field = tester.widget<TextFormField>(find.byType(TextFormField));
    expect(field.controller!.text, 'The note preview disappears.');
    expect(
      find.text("You've reached the feedback limit. Try again in 1 minute."),
      findsOneWidget,
    );
    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.onPressed, isNull);
    expect(repository.requests.single.type, 'bug');

    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  });

  testWidgets('a 503 shows no wait and leaves retry available', (tester) async {
    const failure = ApiFailureServerUnavailable(
      code: 'USER_RATE_LIMIT_UNAVAILABLE',
    );
    final repository = _FakeUserFeedbackRepository((_) async {
      throw failure;
    });
    await pumpScreen(tester, repository);

    await chooseBugAndMessage(tester, message: 'The note preview disappears.');

    expect(
      find.text('Feedback is temporarily unavailable. Try again later.'),
      findsOneWidget,
    );
    expect(find.textContaining('Try again in'), findsNothing);
    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.onPressed, isNotNull);
  });

  testWidgets('a confirmed submission closes the form and announces success', (
    tester,
  ) async {
    final repository = _FakeUserFeedbackRepository((_) async {});
    final container = ProviderContainer(
      overrides: [
        userFeedbackRepositoryProvider.overrideWithValue(repository),
        packageInfoProvider.overrideWith((ref) async => _installed),
      ],
      retry: (_, _) => null,
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.light(),
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (context) => const UserFeedbackScreen(),
                    ),
                  ),
                  child: const Text('Open feedback'),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open feedback'));
    await tester.pumpAndSettle();
    await chooseBugAndMessage(tester, message: 'A useful report');

    expect(find.text('Open feedback'), findsOneWidget);
    final notice = container.read(feedbackProvider)!;
    expect(notice.tone, FeedbackTone.success);
    expect(
      notice.resolve(lookupAppLocalizations(const Locale('en'))),
      'Feedback sent.',
    );
  });
}
