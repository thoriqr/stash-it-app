import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_it_app/core/error/api_failure.dart';
import 'package:stash_it_app/features/user_feedback/data/datasources/user_feedback_api.dart';
import 'package:stash_it_app/features/user_feedback/data/models/create_user_feedback_request.dart';
import 'package:stash_it_app/features/user_feedback/data/user_feedback_repository.dart';

import '../../../support/fake_http.dart';

Map<String, dynamic> _createdBody() => {
  'data': {'id': 'feedback-1', 'created_at': '2026-11-20T10:00:00Z'},
  'message': 'feedback created successfully',
};

void main() {
  late FakeHttpAdapter adapter;
  late UserFeedbackRepository repository;

  setUp(() {
    adapter = FakeHttpAdapter();
    final dio = Dio(
      BaseOptions(
        baseUrl: 'https://api.test',
        contentType: Headers.jsonContentType,
      ),
    )..httpClientAdapter = adapter;
    repository = UserFeedbackRepository(api: UserFeedbackApi(dio));
  });

  const request = CreateUserFeedbackRequest(
    type: 'bug',
    message: 'The note preview disappears after refresh.',
  );

  test('POSTs the type and message to /feedback exactly once', () async {
    adapter.onMethod('POST', '/feedback', status: 201, body: _createdBody());

    await repository.submit(request);

    final sent = adapter.lastRequestTo('/feedback')!;
    expect(sent.method, 'POST');
    expect(adapter.countFor('/feedback'), 1, reason: 'one explicit write');
    expect(sent.body, {
      'type': 'bug',
      'message': 'The note preview disappears after refresh.',
    });
    expect(
      sent.jsonField('platform'),
      isNull,
      reason: 'platform belongs to the X-Platform interceptor, not this body',
    );
  });

  test('includes the optional app version and build when supplied', () async {
    adapter.onMethod('POST', '/feedback', status: 201, body: _createdBody());

    await repository.submit(
      const CreateUserFeedbackRequest(
        type: 'idea',
        message: 'A search shortcut would help.',
        appVersion: '1.3.1',
        appBuild: 7,
      ),
    );

    expect(adapter.lastRequestTo('/feedback')!.body, {
      'type': 'idea',
      'message': 'A search shortcut would help.',
      'app_version': '1.3.1',
      'app_build': 7,
    });
  });

  test('accepts the documented 201', () async {
    adapter.onMethod('POST', '/feedback', status: 201, body: _createdBody());

    await expectLater(repository.submit(request), completes);
  });

  test('maps a spent budget and keeps its Retry-After', () async {
    adapter.onMethod(
      'POST',
      '/feedback',
      status: 429,
      body: errorBody('USER_RATE_LIMIT_EXCEEDED'),
      headers: {
        'retry-after': ['120'],
      },
    );

    final failure = await repository
        .submit(request)
        .then<Object?>((_) => null, onError: (Object error) => error);

    expect(failure, isA<ApiFailureRateLimited>());
    expect(
      (failure! as ApiFailureRateLimited).retryAfter,
      const Duration(seconds: 120),
      reason: "the wait is the server's, never a client guess",
    );
  });

  test('does not invent a wait when the 429 has no Retry-After', () async {
    adapter.onMethod(
      'POST',
      '/feedback',
      status: 429,
      body: errorBody('USER_RATE_LIMIT_EXCEEDED'),
    );

    final failure = await repository
        .submit(request)
        .then<Object?>((_) => null, onError: (Object error) => error);

    expect(failure, isA<ApiFailureRateLimited>());
    expect((failure! as ApiFailureRateLimited).retryAfter, isNull);
  });

  test(
    'maps a limiter that failed closed to unavailable without a wait',
    () async {
      adapter.onMethod(
        'POST',
        '/feedback',
        status: 503,
        body: errorBody('USER_RATE_LIMIT_UNAVAILABLE'),
      );

      final failure = await repository
          .submit(request)
          .then<Object?>((_) => null, onError: (Object error) => error);

      expect(failure, isA<ApiFailureServerUnavailable>());
      expect(
        (failure! as ApiFailureServerUnavailable).code,
        'USER_RATE_LIMIT_UNAVAILABLE',
      );
    },
  );

  test(
    'a 201 whose body cannot be read is unreadable, not a success',
    () async {
      adapter.onMethod(
        'POST',
        '/feedback',
        status: 201,
        body: {'message': 'feedback created successfully'},
      );

      await expectLater(
        repository.submit(request),
        throwsA(isA<ApiFailureUnreadableResponse>()),
      );
    },
  );

  test('maps a server error to a known failure', () async {
    adapter.onMethod(
      'POST',
      '/feedback',
      status: 500,
      body: errorBody('INTERNAL_SERVER_ERROR'),
    );

    await expectLater(
      repository.submit(request),
      throwsA(isA<ApiFailureServerFault>()),
    );
  });

  test('maps a request that never arrives to transport', () async {
    adapter.onOffline('/feedback', method: 'POST');

    await expectLater(
      repository.submit(request),
      throwsA(isA<ApiFailureTransport>()),
    );
  });
}
