import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:stash_it_app/app/feedback/app_feedback.dart';
import 'package:stash_it_app/app/feedback/feedback_controller.dart';
import 'package:stash_it_app/core/error/api_failure.dart';
import 'package:stash_it_app/features/settings/application/package_info_provider.dart';
import 'package:stash_it_app/features/user_feedback/application/user_feedback_controller.dart';
import 'package:stash_it_app/features/user_feedback/application/user_feedback_submission_state.dart';
import 'package:stash_it_app/features/user_feedback/data/datasources/user_feedback_api.dart';
import 'package:stash_it_app/features/user_feedback/data/models/create_user_feedback_request.dart';
import 'package:stash_it_app/features/user_feedback/data/user_feedback_providers.dart';
import 'package:stash_it_app/features/user_feedback/data/user_feedback_repository.dart';
import 'package:stash_it_app/features/user_feedback/domain/user_feedback_type.dart';
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
  final english = lookupAppLocalizations(const Locale('en'));

  ProviderContainer makeContainer(
    _FakeUserFeedbackRepository repository, {
    Future<PackageInfo> Function()? packageInfo,
  }) {
    final container = ProviderContainer(
      overrides: [
        userFeedbackRepositoryProvider.overrideWithValue(repository),
        packageInfoProvider.overrideWith(
          (ref) => packageInfo?.call() ?? Future.value(_installed),
        ),
      ],
      retry: (_, _) => null,
    );
    addTearDown(container.dispose);
    return container;
  }

  test(
    'submits the selected type, trimmed message, and installed build',
    () async {
      final repository = _FakeUserFeedbackRepository((_) async {});
      final container = makeContainer(repository);

      final result = await container
          .read(userFeedbackControllerProvider.notifier)
          .submit(
            type: UserFeedbackType.bug,
            message: '  The note preview disappears.  ',
          );

      expect(result, isA<UserFeedbackSubmitted>());
      final request = repository.requests.single;
      expect(request.type, 'bug');
      expect(request.message, 'The note preview disappears.');
      expect(request.appVersion, '1.3.1');
      expect(request.appBuild, 7);
      expect(container.read(userFeedbackControllerProvider), isFalse);

      final notice = container.read(feedbackProvider)!;
      expect(notice.tone, FeedbackTone.success);
      expect(notice.resolve(english), 'Feedback sent.');
    },
  );

  test('omits app metadata when the platform lookup fails', () async {
    final repository = _FakeUserFeedbackRepository((_) async {});
    final container = makeContainer(
      repository,
      packageInfo: () => Future<PackageInfo>.error(StateError('no channel')),
    );

    final result = await container
        .read(userFeedbackControllerProvider.notifier)
        .submit(type: UserFeedbackType.idea, message: 'A search shortcut');

    expect(result, isA<UserFeedbackSubmitted>());
    final request = repository.requests.single;
    expect(request.appVersion, isNull);
    expect(request.appBuild, isNull);
  });

  test(
    'returns the typed refusal and keeps the success notice absent',
    () async {
      const failure = ApiFailureRateLimited(
        code: 'USER_RATE_LIMIT_EXCEEDED',
        retryAfter: Duration(minutes: 1),
      );
      final repository = _FakeUserFeedbackRepository((_) async {
        throw failure;
      });
      final container = makeContainer(repository);

      final result = await container
          .read(userFeedbackControllerProvider.notifier)
          .submit(type: UserFeedbackType.other, message: 'Something else');

      expect(result, isA<UserFeedbackSubmitFailed>());
      expect((result as UserFeedbackSubmitFailed).failure, same(failure));
      expect(container.read(feedbackProvider), isNull);
      expect(container.read(userFeedbackControllerProvider), isFalse);
    },
  );

  test('a second tap while the first is in flight is ignored', () async {
    final gate = Completer<void>();
    final repository = _FakeUserFeedbackRepository((_) => gate.future);
    final container = makeContainer(repository);

    final first = container
        .read(userFeedbackControllerProvider.notifier)
        .submit(type: UserFeedbackType.bug, message: 'First');
    final second = await container
        .read(userFeedbackControllerProvider.notifier)
        .submit(type: UserFeedbackType.bug, message: 'Second');

    expect(second, isA<UserFeedbackSubmitIgnored>());
    expect(container.read(userFeedbackControllerProvider), isTrue);

    gate.complete();
    expect(await first, isA<UserFeedbackSubmitted>());
    expect(repository.requests, hasLength(1));
    expect(repository.requests.single.message, 'First');
  });
}
