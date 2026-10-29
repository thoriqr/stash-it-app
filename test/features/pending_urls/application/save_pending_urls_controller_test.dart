import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stash_it_app/app/feedback/feedback_controller.dart';
import 'package:stash_it_app/app/network/network_providers.dart';
import 'package:stash_it_app/core/error/api_error_codes.dart';
import 'package:stash_it_app/core/error/api_failure.dart';
import 'package:stash_it_app/core/network/auth_interceptor.dart';
import 'package:stash_it_app/core/storage/secure_credential_store.dart';
import 'package:stash_it_app/features/auth/application/session_controller.dart';
import 'package:stash_it_app/features/auth/data/models/auth_tokens.dart';
import 'package:stash_it_app/features/pending_urls/application/pending_url_save_failure_policy.dart';
import 'package:stash_it_app/features/pending_urls/application/pending_url_save_state.dart';
import 'package:stash_it_app/features/pending_urls/application/pending_urls_controller.dart';
import 'package:stash_it_app/features/pending_urls/application/save_pending_urls_controller.dart';
import 'package:stash_it_app/features/pending_urls/data/pending_url_store.dart';
import 'package:stash_it_app/features/pending_urls/domain/pending_url.dart';
import 'package:stash_it_app/features/saved_items/data/saved_items_providers.dart';

import '../../../support/fake_http.dart';
import '../../../support/fake_saved_items_repository.dart';
import '../../../support/pending_urls.dart';
import '../../../support/saved_items_fixtures.dart';

class _FailingRemovalStore extends PendingUrlStore {
  _FailingRemovalStore(super.preferences, {super.now});

  bool failWrites = false;

  @override
  Future<void> writeEntries(List<PendingUrl> entries) async {
    if (failWrites) {
      throw const PendingUrlStorageException('simulated local write failure');
    }
    return super.writeEntries(entries);
  }
}

void main() {
  const urlA = 'https://example.com/a';
  const urlB = 'https://example.com/b';
  const urlC = 'https://example.com/c';

  const session = AuthTokens(
    accessToken: 'access-1',
    refreshToken: 'refresh-1',
  );

  /// A store whose entries are seeded oldest-first, so the provider returns
  /// them newest-first: `[urls.last, …, urls.first]`.
  Future<PendingUrlStore> seededStore(List<String> urls) async {
    var now = DateTime.utc(2026, 10, 29, 12);
    final store = await testPendingUrlStore(now: () => now);
    for (final url in urls) {
      await store.upsert(url: url, uncertain: false);
      now = now.add(const Duration(minutes: 1));
    }
    return store;
  }

  Future<ProviderContainer> makeContainer({
    required PendingUrlStore store,
    required FakeSavedItemsRepository repository,
    bool signedIn = true,
  }) async {
    final backend = InMemorySecureStorage();
    final credentials = SecureCredentialStore(backend);
    if (signedIn) await credentials.write(session);

    final container = ProviderContainer(
      overrides: [
        credentialStoreProvider.overrideWithValue(credentials),
        restoredTokensProvider.overrideWithValue(signedIn ? session : null),
        pendingUrlStoreProvider.overrideWithValue(store),
        savedItemsRepositoryProvider.overrideWithValue(repository),
      ],
      retry: (_, _) => null,
    );
    addTearDown(container.dispose);
    return container;
  }

  /// A container over the real saved-items repository, so the Dio
  /// `AuthInterceptor` and its one replay are exercised.
  Future<ProviderContainer> makeLiveContainer({
    required PendingUrlStore store,
    required FakeHttpAdapter adapter,
  }) async {
    final backend = InMemorySecureStorage();
    final credentials = SecureCredentialStore(backend);
    await credentials.write(session);

    final container = ProviderContainer(
      overrides: [
        credentialStoreProvider.overrideWithValue(credentials),
        restoredTokensProvider.overrideWithValue(session),
        pendingUrlStoreProvider.overrideWithValue(store),
      ],
      retry: (_, _) => null,
    );
    addTearDown(container.dispose);
    container.read(appDioProvider).httpClientAdapter = adapter;
    container.read(refreshDioProvider).httpClientAdapter = adapter;
    return container;
  }

  test('saves newest first, one request at a time', () async {
    final store = await seededStore([urlA, urlB, urlC]);
    var inFlight = 0;
    var maxInFlight = 0;
    final repository = FakeSavedItemsRepository(
      onCreate: (url) async {
        inFlight++;
        if (inFlight > maxInFlight) maxInFlight = inFlight;
        await Future<void>.delayed(Duration.zero);
        inFlight--;
      },
    );
    final container = await makeContainer(store: store, repository: repository);
    await container.read(pendingUrlsProvider.future);

    await container.read(savePendingUrlsProvider.notifier).saveAll();

    expect(repository.createUrls, [urlC, urlB, urlA]);
    expect(maxInFlight, 1, reason: 'the run is sequential');
    expect((await store.readAll()).entries, isEmpty);
    expect(container.read(pendingUrlCountProvider), 0);
    final state = container.read(savePendingUrlsProvider);
    expect(state.isRunning, isFalse);
    expect(state.lastSummary?.saved, 3);
    expect(state.lastSummary?.remaining, 0);
  });

  test('a second call while running starts no second run', () async {
    final store = await seededStore([urlA, urlB]);
    final gate = Completer<void>();
    final repository = FakeSavedItemsRepository(
      onCreate: (url) => url == urlB ? gate.future : Future<void>.value(),
    );
    final container = await makeContainer(store: store, repository: repository);
    await container.read(pendingUrlsProvider.future);

    final first = container.read(savePendingUrlsProvider.notifier).saveAll();
    await Future<void>.delayed(Duration.zero);

    expect(container.read(savePendingUrlsProvider).isRunning, isTrue);
    await container.read(savePendingUrlsProvider.notifier).saveAll();
    expect(repository.createCalls, 1);

    gate.complete();
    await first;

    expect(repository.createCalls, 2);
    expect(repository.createUrls, [urlB, urlA]);
  });

  test('a validation refusal stops before the later entries', () async {
    final store = await seededStore([urlA, urlB, urlC]);
    final repository = FakeSavedItemsRepository(
      createResults: [const ApiFailureValidation([])], // C
    );
    final container = await makeContainer(store: store, repository: repository);
    await container.read(pendingUrlsProvider.future);

    await container.read(savePendingUrlsProvider.notifier).saveAll();

    expect(repository.createUrls, [urlC]);
    final entries = (await store.readAll()).entries;
    expect(entries.map((entry) => entry.url), [urlC, urlB, urlA]);
    expect(container.read(pendingUrlCountProvider), 3);

    final summary = container.read(savePendingUrlsProvider).lastSummary!;
    expect(summary.saved, 0);
    expect(summary.knownFailed, 1);
    expect(summary.notAttempted, 2);
    expect(summary.remaining, 3);
    expect(summary.stoppedBy, PendingUrlSaveStop.unknown);
  });

  test('a refreshed and replayed save continues to the next URL', () async {
    final store = await seededStore([urlA, urlB]); // newest first: B, A
    final adapter = FakeHttpAdapter();

    // The listing refresh after the run is a GET and must not consume the
    // POST expiry script below.
    adapter.onMethod(
      'GET',
      '/saved-items',
      body: SavedItemsFixtures.emptyPage(),
    );
    adapter.onMethod(
      'POST',
      '/auth/refresh',
      body: {
        'data': {'access_token': 'access-2', 'refresh_token': 'refresh-2'},
        'message': 'session refreshed',
      },
    );
    adapter.onExpiring(
      '/saved-items',
      FakeReply.error(401, ApiErrorCode.accessTokenExpired),
      FakeReply(201, SavedItemsFixtures.created()),
      retriedMarker: AuthInterceptor.retriedKey,
    );

    final container = await makeLiveContainer(store: store, adapter: adapter);
    await container.read(pendingUrlsProvider.future);

    await container.read(savePendingUrlsProvider.notifier).saveAll();
    await Future<void>.delayed(Duration.zero);

    final posts = adapter.requests
        .where(
          (request) =>
              request.method == 'POST' && request.path.contains('/saved-items'),
        )
        .length;
    expect(posts, 4, reason: 'two originals and one replay each');
    expect(
      adapter.countFor('/auth/refresh'),
      2,
      reason: 'each expired original is renewed before its replay',
    );
    expect((await store.readAll()).entries, isEmpty);

    final summary = container.read(savePendingUrlsProvider).lastSummary!;
    expect(summary.saved, 2);
    expect(summary.knownFailed, 0);
    expect(summary.uncertain, 0);
    expect(summary.stoppedBy, PendingUrlSaveStop.none);
  });

  test('a server failure stops before the later entries', () async {
    final store = await seededStore([urlA, urlB, urlC]);
    final repository = FakeSavedItemsRepository(
      createResults: [
        null, // C
        const ApiFailureServerUnavailable(code: 'IP_RATE_LIMIT_UNAVAILABLE'),
      ],
    );
    final container = await makeContainer(store: store, repository: repository);
    await container.read(pendingUrlsProvider.future);

    await container.read(savePendingUrlsProvider.notifier).saveAll();

    expect(repository.createUrls, [urlC, urlB]);
    final entries = (await store.readAll()).entries;
    expect(entries.map((entry) => entry.url), [urlB, urlA]);

    final summary = container.read(savePendingUrlsProvider).lastSummary!;
    expect(summary.saved, 1);
    expect(summary.knownFailed, 1);
    expect(summary.notAttempted, 1);
    expect(summary.remaining, 2);
    expect(summary.stoppedBy, PendingUrlSaveStop.server);
  });

  test('a rate limit stops and keeps the server wait', () async {
    final store = await seededStore([urlA, urlB]);
    final repository = FakeSavedItemsRepository(
      createResults: [
        const ApiFailureRateLimited(
          code: 'USER_RATE_LIMIT_EXCEEDED',
          retryAfter: Duration(seconds: 42),
        ),
      ],
    );
    final container = await makeContainer(store: store, repository: repository);
    await container.read(pendingUrlsProvider.future);

    await container.read(savePendingUrlsProvider.notifier).saveAll();

    expect(repository.createCalls, 1);
    final summary = container.read(savePendingUrlsProvider).lastSummary!;
    expect(summary.saved, 0);
    expect(summary.knownFailed, 1);
    expect(summary.remaining, 2);
    expect(summary.stoppedBy, PendingUrlSaveStop.rateLimited);
    expect(summary.retryAfter, const Duration(seconds: 42));
  });

  test('a transport failure keeps the entry uncertain and stops', () async {
    final now = DateTime.utc(2026, 10, 29, 12);
    final store = await testPendingUrlStore(now: () => now);
    await store.upsert(url: urlA, uncertain: false);
    final before = (await store.readAll()).entries.single;

    final repository = FakeSavedItemsRepository(
      createResults: [const ApiFailureTransport()],
    );
    final container = await makeContainer(store: store, repository: repository);
    await container.read(pendingUrlsProvider.future);

    await container.read(savePendingUrlsProvider.notifier).saveAll();

    final after = (await store.readAll()).entries.single;
    expect(after.url, urlA);
    expect(after.uncertain, isTrue);
    expect(after.addedAt, before.addedAt, reason: 'retention is not extended');
    expect(repository.createCalls, 1);
    expect(container.read(pendingUrlCountProvider), 1);

    final summary = container.read(savePendingUrlsProvider).lastSummary!;
    expect(summary.uncertain, 1);
    expect(summary.saved, 0);
    expect(summary.stoppedBy, PendingUrlSaveStop.unknown);
  });

  test('an unreadable reply keeps the entry uncertain and stops', () async {
    final store = await seededStore([urlA]);
    final repository = FakeSavedItemsRepository(
      createResults: [const ApiFailureUnreadableResponse()],
    );
    final container = await makeContainer(store: store, repository: repository);
    await container.read(pendingUrlsProvider.future);

    await container.read(savePendingUrlsProvider.notifier).saveAll();

    final entry = (await store.readAll()).entries.single;
    expect(entry.uncertain, isTrue);
    final summary = container.read(savePendingUrlsProvider).lastSummary!;
    expect(summary.uncertain, 1);
    expect(summary.stoppedBy, PendingUrlSaveStop.unknown);
  });

  test('a later run retries only the entries that remain', () async {
    final store = await seededStore([urlA, urlB, urlC]);
    var attempts = 0;
    final repository = FakeSavedItemsRepository(
      onCreate: (url) async {
        attempts++;
        if (attempts == 2) {
          throw const ApiFailureServerUnavailable(
            code: 'IP_RATE_LIMIT_UNAVAILABLE',
          );
        }
      },
    );
    final container = await makeContainer(store: store, repository: repository);
    await container.read(pendingUrlsProvider.future);

    await container.read(savePendingUrlsProvider.notifier).saveAll();
    expect(repository.createUrls, [urlC, urlB]);
    expect((await store.readAll()).entries.map((entry) => entry.url), [
      urlB,
      urlA,
    ]);

    await container.read(savePendingUrlsProvider.notifier).saveAll();

    expect(repository.createUrls, [urlC, urlB, urlB, urlA]);
    expect((await store.readAll()).entries, isEmpty);
    expect(
      container.read(savePendingUrlsProvider).lastSummary?.saved,
      2,
      reason: 'the second run reports only what it saved',
    );
  });

  test('expiry during a run prunes and skips the expired entry', () async {
    final created = DateTime.utc(2026, 10, 1, 12);
    var now = created;
    final store = await testPendingUrlStore(now: () => now);
    await store.upsert(url: urlA, uncertain: false);
    now = created.add(const Duration(minutes: 1));
    await store.upsert(url: urlB, uncertain: false);

    final repository = FakeSavedItemsRepository(
      onCreate: (url) async {
        if (url == urlB) {
          now = created.add(const Duration(days: 8));
        }
      },
    );
    final container = await makeContainer(store: store, repository: repository);
    await container.read(pendingUrlsProvider.future);

    await container.read(savePendingUrlsProvider.notifier).saveAll();
    await Future<void>.delayed(Duration.zero);

    expect(repository.createUrls, [urlB], reason: 'A expired before its turn');
    expect((await store.readAll()).entries, isEmpty);
    expect(container.read(pendingUrlCountProvider), 0);
    expect(
      container.read(feedbackProvider)?.copy,
      'Some links saved on this device expired after seven days.',
      reason: 'the prune is still a notified event',
    );

    final summary = container.read(savePendingUrlsProvider).lastSummary!;
    expect(summary.saved, 1);
    expect(summary.remaining, 0);
  });

  test(
    'a share during a run is not submitted and appears in the list',
    () async {
      final store = await seededStore([urlA]);
      final repository = FakeSavedItemsRepository(
        onCreate: (url) async {
          await store.upsert(url: urlC, uncertain: false);
        },
      );
      final container = await makeContainer(
        store: store,
        repository: repository,
      );
      await container.read(pendingUrlsProvider.future);

      await container.read(savePendingUrlsProvider.notifier).saveAll();

      expect(repository.createUrls, [urlA]);
      expect((await store.readAll()).entries.map((entry) => entry.url), [urlC]);
      expect(container.read(pendingUrlCountProvider), 1);
    },
  );

  test('a signed-out container starts no run', () async {
    final store = await seededStore([urlA]);
    final repository = FakeSavedItemsRepository(createResults: [null]);
    final container = await makeContainer(
      store: store,
      repository: repository,
      signedIn: false,
    );
    await container.read(pendingUrlsProvider.future);

    await container.read(savePendingUrlsProvider.notifier).saveAll();

    expect(repository.createCalls, 0);
    final state = container.read(savePendingUrlsProvider);
    expect(state.isRunning, isFalse);
    expect(state.lastSummary, isNull);
  });

  test('a local removal failure stops without claiming removal', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    var now = DateTime.utc(2026, 10, 29, 12);
    final store = _FailingRemovalStore(preferences, now: () => now);
    await store.upsert(url: urlA, uncertain: false);
    store.failWrites = true;

    final repository = FakeSavedItemsRepository(createResults: [null]);
    final container = await makeContainer(store: store, repository: repository);
    await container.read(pendingUrlsProvider.future);

    await container.read(savePendingUrlsProvider.notifier).saveAll();

    expect(repository.createCalls, 1);
    expect((await store.readAll()).entries.map((entry) => entry.url), [urlA]);
    final summary = container.read(savePendingUrlsProvider).lastSummary!;
    expect(summary.saved, 1);
    expect(summary.stoppedBy, PendingUrlSaveStop.localList);
    expect(summary.remaining, 1);
  });

  test('a confirmed save refreshes the Inbox head once', () async {
    final store = await seededStore([urlA]);
    final repository = FakeSavedItemsRepository(createResults: [null]);
    final container = await makeContainer(store: store, repository: repository);
    await container.read(pendingUrlsProvider.future);

    await container.read(savePendingUrlsProvider.notifier).saveAll();
    await Future<void>.delayed(Duration.zero);

    expect(repository.listCalls, greaterThanOrEqualTo(1));
  });

  test('a run with no confirmed save does not refresh the Inbox', () async {
    final store = await seededStore([urlA]);
    final repository = FakeSavedItemsRepository(
      createResults: [const ApiFailureTransport()],
    );
    final container = await makeContainer(store: store, repository: repository);
    await container.read(pendingUrlsProvider.future);

    await container.read(savePendingUrlsProvider.notifier).saveAll();

    expect(repository.listCalls, 0);
  });

  group('failure disposition', () {
    test('validation also stops the queue', () {
      expect(
        pendingUrlSaveDisposition(const ApiFailureValidation([])),
        PendingUrlSaveDisposition.stop,
      );
      expect(
        pendingUrlSaveDisposition(const ApiFailureMalformedRequest()),
        PendingUrlSaveDisposition.stop,
      );
    });

    test('transport and unreadable replies are uncertain', () {
      expect(
        pendingUrlSaveDisposition(const ApiFailureTransport()),
        PendingUrlSaveDisposition.uncertain,
      );
      expect(
        pendingUrlSaveDisposition(const ApiFailureUnreadableResponse()),
        PendingUrlSaveDisposition.uncertain,
      );
    });

    test('shared and unreachable failures stop', () {
      final failures = <ApiFailure>[
        const ApiFailureRateLimited(code: 'USER_RATE_LIMIT_EXCEEDED'),
        const ApiFailureServerUnavailable(code: 'IP_RATE_LIMIT_UNAVAILABLE'),
        const ApiFailureServerFault(),
        const ApiFailurePinEmailDeliveryFailed(),
        const ApiFailureAuthRequired(),
        const ApiFailureSessionEnded(code: 'SESSION_REVOKED'),
        const ApiFailureRefreshUncertain(cause: ApiFailureTransport()),
        ApiFailureCredentialStorage(cause: StateError('local failure')),
        const ApiFailureNotFound(code: 'RESOURCE_NOT_FOUND'),
        const ApiFailureUserNotFound(code: 'USER_NOT_FOUND'),
        const ApiFailureCollectionNameAlreadyExists(
          code: 'COLLECTION_NAME_ALREADY_EXISTS',
        ),
        const ApiFailureRegistrationAlreadyCompleted(
          code: 'REGISTRATION_ALREADY_COMPLETED',
        ),
        const ApiFailureInvalidGoogleToken(code: 'INVALID_GOOGLE_TOKEN'),
        const ApiFailurePasswordResetExpired(code: 'PASSWORD_RESET_EXPIRED'),
      ];

      for (final failure in failures) {
        expect(
          pendingUrlSaveDisposition(failure),
          PendingUrlSaveDisposition.stop,
          reason: '$failure',
        );
      }
    });
  });
}
