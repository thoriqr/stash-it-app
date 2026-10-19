import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_it_app/app/feedback/app_feedback.dart';
import 'package:stash_it_app/app/feedback/feedback_controller.dart';
import 'package:stash_it_app/app/network/network_providers.dart';
import 'package:stash_it_app/core/error/api_failure.dart';
import 'package:stash_it_app/core/storage/secure_credential_store.dart';
import 'package:stash_it_app/features/auth/application/auth_state.dart';
import 'package:stash_it_app/features/auth/application/session_controller.dart';
import 'package:stash_it_app/features/auth/data/models/auth_tokens.dart';
import 'package:stash_it_app/features/saved_items/application/save_url_controller.dart';
import 'package:stash_it_app/features/saved_items/application/saved_items_controller.dart';

import '../../../support/fake_http.dart';
import '../../../support/saved_items_fixtures.dart';

/// The Save URL mutation: one POST per explicit action, and the notice each
/// outcome earns.
///
/// The copy table is checked as a pure function — every variant, every piece of
/// copy — and then the paths that need the **real** pipeline (interceptor,
/// session controller, credential store) are driven end to end against a scripted
/// transport. No socket is opened.
void main() {
  late FakeHttpAdapter adapter;

  const session = AuthTokens(
    accessToken: 'access-1',
    refreshToken: 'refresh-1',
  );

  /// A container with a scripted transport and no automatic provider retry.
  ///
  /// [withSession] seeds the **credential store**, not only
  /// `restoredTokensProvider`, because that is where the interceptor reads the
  /// bearer from and where `SessionController` reads the refresh token from: a
  /// renewal test with an empty store would take the "nothing to renew with"
  /// branch instead of the one under test.
  ///
  /// `retry: (_, _) => null` — Riverpod 3 retries a failed provider up to ten
  /// times with backoff, which would corrupt the request counts asserted here.
  Future<ProviderContainer> makeContainer({bool withSession = false}) async {
    final store = InMemorySecureStorage();
    if (withSession) await SecureCredentialStore(store).write(session);

    final made = ProviderContainer(
      overrides: [
        credentialStoreProvider.overrideWithValue(SecureCredentialStore(store)),
        restoredTokensProvider.overrideWithValue(withSession ? session : null),
      ],
      retry: (_, _) => null,
    );
    made.read(appDioProvider).httpClientAdapter = adapter;
    made.read(refreshDioProvider).httpClientAdapter = adapter;
    return made;
  }

  /// POSTs to the save route itself.
  ///
  /// Not "every POST on the adapter": a renewal is also a POST, and a test about
  /// the save must not count it. Where the renewal matters it is asserted
  /// separately, by path.
  int savePosts() => adapter.requests
      .where(
        (request) =>
            request.method == 'POST' && request.path.contains('/saved-items'),
      )
      .length;

  Future<bool> submit(ProviderContainer container, String url) =>
      container.read(saveUrlProvider.notifier).submit(url);

  AppFeedback? noticeOf(ProviderContainer container) =>
      container.read(feedbackProvider);

  List<String> itemIds(ProviderContainer container) =>
      switch (container.read(savedItemsProvider)) {
        AsyncData(:final value) => value.items.map((item) => item.id).toList(),
        final other => throw StateError('expected data, got $other'),
      };

  /// Scripts the POST as a confirmed create.
  void scriptCreated({String url = 'https://example.com/new'}) {
    adapter.onMethod(
      'POST',
      '/saved-items',
      status: 201,
      body: SavedItemsFixtures.created(url: url),
    );
  }

  /// Scripts the listing the head refresh will read.
  void scriptListing(List<Map<String, dynamic>> items) {
    adapter.onMethod(
      'GET',
      '/saved-items',
      body: SavedItemsFixtures.page(items: items),
    );
  }

  setUp(() => adapter = FakeHttpAdapter());

  group('the copy table', () {
    // Every row, spelled out. These strings are product copy: a failure here is
    // the point, and it should be a deliberate edit rather than a diff nobody
    // reads.
    for (final (name, failure, tone, copy)
        in <(String, ApiFailure, FeedbackTone, String)>[
          (
            'a URL the server refuses to use',
            const ApiFailureValidation([]),
            FeedbackTone.danger,
            "That doesn't look like a valid link. Check the URL and try again.",
          ),
          (
            'a body this client should never have sent',
            const ApiFailureMalformedRequest(),
            FeedbackTone.danger,
            'Something went wrong sending that link. Try again.',
          ),
          (
            "a spent budget, with the server's retry-after",
            const ApiFailureRateLimited(
              code: 'USER_RATE_LIMIT_EXCEEDED',
              retryAfter: Duration(seconds: 120),
            ),
            FeedbackTone.warning,
            "You're saving too quickly. Try again in 2 minutes.",
          ),
          (
            'a limiter that could not evaluate the budget',
            const ApiFailureServerUnavailable(
              code: 'USER_RATE_LIMIT_UNAVAILABLE',
            ),
            FeedbackTone.danger,
            "We couldn't save this link just now. Try again shortly.",
          ),
          (
            'an insert that failed',
            const ApiFailureServerFault(),
            FeedbackTone.danger,
            "We couldn't save this link just now. Try again shortly.",
          ),
          (
            'a reply whose body could not be read',
            const ApiFailureUnreadableResponse(),
            FeedbackTone.uncertain,
            "We couldn't read the server's reply, so we can't confirm the save. "
                'Check your Inbox before trying again.',
          ),
          (
            'a request that never arrived',
            const ApiFailureTransport(),
            FeedbackTone.uncertain,
            "We couldn't confirm this save. It may or may not have gone through "
                '— check your Inbox before trying again.',
          ),
          (
            'a renewal that failed without an answer',
            const ApiFailureRefreshUncertain(cause: ApiFailureTransport()),
            FeedbackTone.warning,
            "We couldn't renew your session, so that link wasn't saved. "
                'Try again.',
          ),
          (
            'a device whose credential store is unreachable',
            const ApiFailureCredentialStorage(cause: 'keystore'),
            FeedbackTone.warning,
            "This device couldn't refresh your session, so that link wasn't "
                'saved. Try again.',
          ),
          (
            'a refused token while the session is still held',
            const ApiFailureAuthRequired(code: 'INVALID_ACCESS_TOKEN'),
            FeedbackTone.danger,
            'Sign in again to save this link.',
          ),
        ]) {
      test('$name gets its own tone and copy', () {
        final feedback = saveFeedbackFor(failure, sessionEnded: false);

        expect(feedback, isNotNull);
        expect(feedback!.tone, tone);
        expect(feedback.copy, copy);
      });
    }

    test('no countdown is invented when the server sent none', () {
      final feedback = saveFeedbackFor(
        const ApiFailureRateLimited(code: 'USER_RATE_LIMIT_EXCEEDED'),
        sessionEnded: false,
      )!;

      // Â§6.5: a 429 shows the countdown the server sent, and nothing shows a
      // fabricated one. A missing header is not a licence to guess.
      expect(feedback.copy, "You're saving too quickly. Try again shortly.");
      expect(
        feedback.copy,
        isNot(matches(RegExp(r'\d'))),
        reason: 'a countdown needs a number, and there is no number to give',
      );
    });

    test('the countdown is the coarsest unit that does not understate it', () {
      // `Retry-After` is the limiter's remaining TTL rounded up to whole seconds.
      // Rounding again must never promise a retry that is still refused, which is
      // why 59 s is seconds and 3599 s is already an hour.
      for (final (wait, phrase) in <(Duration, String)>[
        (const Duration(seconds: 1), 'a second'),
        (const Duration(seconds: 59), '59 seconds'),
        (const Duration(seconds: 60), '1 minute'),
        (const Duration(seconds: 90), '2 minutes'),
        (const Duration(seconds: 600), '10 minutes'),
        (const Duration(seconds: 3540), '59 minutes'),
        (const Duration(seconds: 3599), '1 hour'),
        (const Duration(seconds: 7200), '2 hours'),
      ]) {
        final feedback = saveFeedbackFor(
          ApiFailureRateLimited(
            code: 'USER_RATE_LIMIT_EXCEEDED',
            retryAfter: wait,
          ),
          sessionEnded: false,
        )!;

        expect(
          feedback.copy,
          "You're saving too quickly. Try again in $phrase.",
          reason: 'for ${wait.inSeconds}s',
        );
      }
    });

    test('the uncertain rows never claim the item was not saved', () {
      // [D15]/[D16]: an unestablished outcome must not be described as
      // definitely unsaved, in either direction. This is what the tone and the
      // copy have to protect together.
      for (final failure in <ApiFailure>[
        const ApiFailureTransport(),
        const ApiFailureUnreadableResponse(),
      ]) {
        final feedback = saveFeedbackFor(failure, sessionEnded: false)!;
        final copy = feedback.copy.toLowerCase();

        expect(feedback.tone, FeedbackTone.uncertain);
        expect(copy, isNot(contains("wasn't saved")));
        expect(copy, isNot(contains('not saved')));
        expect(
          copy,
          contains('check your inbox before trying again'),
          reason:
              'the advice for an unknown outcome is manual, never automatic',
        );
      }
    });

    test('a failure about a held session is reported as a held session', () {
      // The renewal failed, so the POST was never replayed — but the session did
      // **not** end. Telling the user to sign in would be a different, wrong
      // story. Only `ApiFailureAuthRequired` may ask for a sign-in.
      for (final failure in <ApiFailure>[
        const ApiFailureRefreshUncertain(cause: ApiFailureTransport()),
        const ApiFailureCredentialStorage(cause: 'keystore'),
      ]) {
        final feedback = saveFeedbackFor(failure, sessionEnded: false)!;

        expect(feedback.copy, contains("wasn't saved"));
        expect(
          feedback.copy.toLowerCase(),
          isNot(contains('sign in')),
          reason: 'the session is still held; only the renewal failed',
        );
      }
    });

    test('the session layer keeps its own expiry for itself', () {
      // Sign-in's one-time notice owns the ended session: `saveFeedbackFor`
      // returns nothing at all, rather than a second announcement of one event.
      expect(
        saveFeedbackFor(
          const ApiFailureAuthRequired(code: 'ACCESS_TOKEN_EXPIRED'),
          sessionEnded: true,
        ),
        isNull,
      );
      expect(
        saveFeedbackFor(
          const ApiFailureSessionEnded(code: 'SESSION_REVOKED'),
          sessionEnded: false,
        ),
        isNull,
      );
      expect(
        saveFeedbackFor(
          const ApiFailureSessionEnded(code: 'SESSION_REVOKED'),
          sessionEnded: true,
        ),
        isNull,
      );
    });
  });

  group('a submission', () {
    test('sends exactly one POST and reports the confirmed create', () async {
      final container = await makeContainer();
      addTearDown(container.dispose);

      scriptCreated(url: 'https://example.com/new');
      scriptListing([SavedItemsFixtures.item(id: 'new')]);

      expect(await submit(container, 'https://example.com/new'), isTrue);

      expect(savePosts(), 1, reason: 'one tap, one write — never more');
      expect(adapter.lastRequestTo('/saved-items')!.method, 'POST');
      expect(
        adapter.requests
            .firstWhere((request) => request.method == 'POST')
            .jsonField('url'),
        'https://example.com/new',
      );

      final notice = noticeOf(container)!;
      expect(notice.tone, FeedbackTone.success);
      expect(
        notice.copy,
        'Saved.',
        reason: '[D26] it confirms the create and nothing beyond it',
      );
    });

    test('trims the value before sending it', () async {
      final container = await makeContainer();
      addTearDown(container.dispose);

      scriptCreated(url: 'https://example.com/new');
      scriptListing([SavedItemsFixtures.item(id: 'new')]);

      await submit(container, '  https://example.com/new\n');

      expect(
        adapter.requests
            .firstWhere((request) => request.method == 'POST')
            .jsonField('url'),
        'https://example.com/new',
      );
    });

    test('nothing to send is not a request', () async {
      final container = await makeContainer();
      addTearDown(container.dispose);

      expect(await submit(container, '   '), isFalse);

      expect(adapter.countFor('/saved-items'), 0);
      expect(
        noticeOf(container),
        isNull,
        reason: 'an empty field is not an outcome worth announcing',
      );
    });

    test(
      'a second submission while the first is in flight is declined',
      () async {
        final container = await makeContainer();
        addTearDown(container.dispose);

        scriptListing([SavedItemsFixtures.emptyPage()]);
        adapter.onBlocking(
          '/saved-items',
          FakeReply(201, SavedItemsFixtures.created()),
        );

        final first = submit(container, 'https://example.com/new');
        await untilCalled(() => savePosts() == 1);

        expect(
          await submit(container, 'https://example.com/new'),
          isFalse,
          reason: 'it is declined, so the value is not cleared either',
        );
        expect(
          savePosts(),
          1,
          reason: 'no second insert: duplicates are allowed',
        );

        adapter.releaseBlocked();
        expect(await first, isTrue);
        expect(savePosts(), 1);
      },
    );

    test(
      'a refusal returns false, so the value stays put to be corrected',
      () async {
        final container = await makeContainer();
        addTearDown(container.dispose);

        adapter.onMethod(
          'POST',
          '/saved-items',
          status: 400,
          body: errorBody('INVALID_URL'),
        );

        // Locally valid, so the gate lets it through: this is the server's
        // refusal, and it must still round-trip and read as one.
        expect(await submit(container, 'https://example.com/broken'), isFalse);

        expect(
          savePosts(),
          1,
          reason: 'the local gate is a shape check, not the contract',
        );

        final notice = noticeOf(container)!;
        expect(notice.tone, FeedbackTone.danger);
        expect(notice.copy, contains('Check the URL'));
      },
    );

    test('a value that cannot be a URL never reaches the transport', () async {
      final container = await makeContainer();
      addTearDown(container.dispose);

      expect(await submit(container, 'example'), isFalse);

      expect(
        adapter.requests,
        isEmpty,
        reason: 'no POST — and no head refresh either: nothing was saved',
      );
      expect(
        container.read(saveUrlProvider),
        isFalse,
        reason: 'nothing was in flight, so nothing needs to settle',
      );

      final notice = noticeOf(container)!;
      expect(notice.tone, FeedbackTone.danger);
      expect(
        notice.copy,
        "That doesn't look like a valid link. Enter a full http:// or https:// "
        'address.',
      );
      expect(
        notice.copy,
        isNot(contains('server')),
        reason: 'nothing was sent, so nothing can have been rejected',
      );
    });

    test('a corrected value goes through after a local refusal', () async {
      final container = await makeContainer();
      addTearDown(container.dispose);

      scriptCreated();
      scriptListing([SavedItemsFixtures.item(id: 'new')]);

      expect(await submit(container, 'example.com'), isFalse);
      expect(adapter.requests, isEmpty);

      expect(await submit(container, 'https://example.com/new'), isTrue);
      expect(savePosts(), 1);
      expect(noticeOf(container)!.copy, 'Saved.');
    });

    test('a spent budget reports the wait the server sent', () async {
      final container = await makeContainer();
      addTearDown(container.dispose);

      adapter.onMethod(
        'POST',
        '/saved-items',
        status: 429,
        body: errorBody('USER_RATE_LIMIT_EXCEEDED'),
        headers: {
          'retry-after': ['120'],
        },
      );

      expect(await submit(container, 'https://example.com/new'), isFalse);

      final notice = noticeOf(container)!;
      expect(notice.tone, FeedbackTone.warning);
      expect(notice.copy, "You're saving too quickly. Try again in 2 minutes.");
    });

    test('a 201 this client cannot read is not reported as a save', () async {
      final container = await makeContainer();
      addTearDown(container.dispose);

      // A `2xx` whose body does not decode. Dio only decodes a status that passed
      // `validateStatus`, so the write committed — and the client still has no
      // created item to show. It may not claim either outcome.
      adapter.onMethod(
        'POST',
        '/saved-items',
        status: 201,
        body: {'data': null, 'message': 'saved item created successfully'},
      );

      expect(await submit(container, 'https://example.com/new'), isFalse);

      final notice = noticeOf(container)!;
      expect(notice.tone, FeedbackTone.uncertain);
      expect(notice.copy, contains("can't confirm"));
    });

    test('a request that never arrives is reported as uncertain', () async {
      final container = await makeContainer();
      addTearDown(container.dispose);

      adapter.onOffline('/saved-items', method: 'POST');

      expect(await submit(container, 'https://example.com/new'), isFalse);

      final notice = noticeOf(container)!;
      expect(notice.tone, FeedbackTone.uncertain);
      expect(notice.copy, contains('may or may not have gone through'));
    });
  });

  group('the listing after a confirmed save', () {
    test('refreshes the newest page and keeps the rows already loaded', () async {
      final container = await makeContainer();
      addTearDown(container.dispose);

      // Page one, then the head as it looks after the save: the new row on top,
      // the row that was already on screen still there.
      adapter.onSequence('/saved-items', [
        FakeReply(
          200,
          SavedItemsFixtures.page(items: [SavedItemsFixtures.item(id: 'a')]),
        ),
        FakeReply(
          200,
          SavedItemsFixtures.page(
            items: [
              SavedItemsFixtures.item(id: 'new'),
              SavedItemsFixtures.item(id: 'a'),
            ],
          ),
        ),
      ]);
      scriptCreated();

      await container.read(savedItemsProvider.future);
      expect(itemIds(container), ['a']);

      expect(await submit(container, 'https://example.com/new'), isTrue);

      // `submit` deliberately does not await the refresh, so the test waits for
      // its effect rather than for the call.
      await untilCalled(() => itemIds(container).contains('new'));

      expect(itemIds(container), ['new', 'a']);
      expect(
        adapter.requests.where((request) => request.method == 'GET').length,
        2,
        reason: 'one page-one read before the save, one after — no paging',
      );
      expect(
        adapter.requests.last.path,
        isNot(contains('cursor')),
        reason: 'a head refresh asks for page one, never a cursor',
      );
    });

    test('a refresh that fails does not take the confirmation with it', () async {
      final container = await makeContainer();
      addTearDown(container.dispose);

      adapter.onSequence('/saved-items', [
        FakeReply(
          200,
          SavedItemsFixtures.page(items: [SavedItemsFixtures.item(id: 'a')]),
        ),
        FakeReply.error(500, 'INTERNAL_SERVER_ERROR'),
      ]);
      scriptCreated();

      await container.read(savedItemsProvider.future);
      expect(await submit(container, 'https://example.com/new'), isTrue);
      expect(noticeOf(container)!.tone, FeedbackTone.success);

      // The refresh `submit` started is not awaited, so this repeats it and
      // awaits *this* one: the assertion below is then about a refresh that has
      // definitively finished and failed.
      await container.read(savedItemsProvider.notifier).refreshHead();

      expect(
        noticeOf(container)!.copy,
        'Saved.',
        reason: 'the save is confirmed; a stale list is a separate problem',
      );
      expect(itemIds(container), [
        'a',
      ], reason: 'a failed read leaves the loaded rows exactly as they were');
    });
  });

  group('the session layer', () {
    test('a terminated session leaves the announcement to sign-in', () async {
      final container = await makeContainer(withSession: true);
      addTearDown(container.dispose);

      adapter.onMethod(
        'POST',
        '/saved-items',
        status: 401,
        body: errorBody('ACCESS_TOKEN_EXPIRED'),
      );
      adapter.onMethod(
        'POST',
        '/auth/refresh',
        status: 401,
        body: errorBody('SESSION_REVOKED'),
      );

      expect(await submit(container, 'https://example.com/new'), isFalse);

      expect(
        savePosts(),
        1,
        reason: 'the replayed request is the same request, not a second save',
      );
      expect(
        noticeOf(container),
        isNull,
        reason: 'every 401 comes from the bearer guard, so nothing was written',
      );
      expect(
        container.read(authStateProvider),
        AuthStatus.signedOut,
        reason: 'the session really ended',
      );
      expect(
        container
            .read(sessionControllerProvider.notifier)
            .consumeSessionEnded(),
        isTrue,
        reason:
            'the one-time flag is still there for the screen that explains it — '
            'the mutation must not consume another layer\'s announcement',
      );
    });

    test(
      'a renewal with no answer reports the save, not the session',
      () async {
        final container = await makeContainer(withSession: true);
        addTearDown(container.dispose);

        adapter.onMethod(
          'POST',
          '/saved-items',
          status: 401,
          body: errorBody('ACCESS_TOKEN_EXPIRED'),
        );
        adapter.onOffline('/auth/refresh', method: 'POST');

        expect(await submit(container, 'https://example.com/new'), isFalse);

        expect(
          savePosts(),
          1,
          reason: 'the POST was never replayed, so it certainly did not happen',
        );
        expect(
          container.read(authStateProvider),
          AuthStatus.signedIn,
          reason: 'an unanswered renewal is not a session that ended',
        );

        final notice = noticeOf(container)!;
        expect(notice.tone, FeedbackTone.warning);
        expect(notice.copy, contains("couldn't renew your session"));
        expect(
          notice.copy,
          contains("wasn't saved"),
          reason: 'the save itself *is* known not to have happened',
        );
        expect(
          notice.copy.toLowerCase(),
          isNot(contains('sign in')),
          reason: 'the credentials were kept; asking to sign in would be wrong',
        );
      },
    );
  });
}
