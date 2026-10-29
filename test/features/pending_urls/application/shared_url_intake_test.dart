import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stash_it_app/app/network/network_providers.dart';
import 'package:stash_it_app/core/error/api_error_codes.dart';
import 'package:stash_it_app/core/storage/secure_credential_store.dart';
import 'package:stash_it_app/features/auth/application/session_controller.dart';
import 'package:stash_it_app/features/auth/data/models/auth_tokens.dart';
import 'package:stash_it_app/features/pending_urls/application/shared_url_intake.dart';
import 'package:stash_it_app/features/pending_urls/data/pending_url_store.dart';
import 'package:stash_it_app/features/pending_urls/domain/pending_url.dart';
import 'package:stash_it_app/features/saved_items/data/datasources/saved_items_api.dart';
import 'package:stash_it_app/features/saved_items/data/saved_items_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../support/fake_http.dart';
import '../../../support/pending_urls.dart';
import '../../../support/saved_items_fixtures.dart';

class _FailingStore extends PendingUrlStore {
  _FailingStore(super.preferences);

  @override
  Future<void> writeEntries(List<PendingUrl> entries) async {
    throw const PendingUrlStorageException('simulated write failure');
  }
}

class _ThrowingRepository extends SavedItemsRepository {
  _ThrowingRepository() : super(api: SavedItemsApi(Dio()));

  @override
  Future<void> create({required String url}) async {
    throw StateError('unexpected repository failure');
  }
}

void main() {
  const url = 'https://example.com/articles/crdts-explained';

  late FakeHttpAdapter adapter;
  late InMemorySecureStorage backend;

  setUp(() {
    adapter = FakeHttpAdapter();
    backend = InMemorySecureStorage();
  });

  Future<ProviderContainer> makeContainer({
    required PendingUrlStore store,
    AuthTokens? session,
  }) async {
    final credentials = SecureCredentialStore(backend);
    if (session != null) await credentials.write(session);

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

  group('URL extraction', () {
    test('accepts a whole URL', () {
      expect(extractSharedUrl('  $url  '), url);
    });

    test('finds the first URL in surrounding text', () {
      expect(extractSharedUrl('Look at this $url and this other one'), url);
    });

    test('returns null when there is no URL', () {
      expect(extractSharedUrl('not a link at all'), isNull);
      expect(extractSharedUrl('   '), isNull);
    });
  });

  group('remote outcomes', () {
    test('a confirmed create is saved and leaves no local entry', () async {
      adapter.onMethod(
        'POST',
        '/saved-items',
        status: 201,
        body: SavedItemsFixtures.created(url: url),
      );
      final store = await testPendingUrlStore();
      final container = await makeContainer(store: store);

      final outcome = await container.read(sharedUrlIntakeProvider).save(url);

      expect(outcome, ShareSaveOutcome.saved);
      expect((await store.readAll()).entries, isEmpty);
    });

    for (final (status, code) in [
      (400, ApiErrorCode.invalidUrl),
      (500, ApiErrorCode.internalServerError),
      (429, ApiErrorCode.userRateLimitExceeded),
    ]) {
      test('a known $status failure is stored as certain', () async {
        adapter.onMethod(
          'POST',
          '/saved-items',
          status: status,
          body: errorBody(code),
        );
        final store = await testPendingUrlStore();
        final container = await makeContainer(store: store);

        final outcome = await container.read(sharedUrlIntakeProvider).save(url);

        expect(outcome, ShareSaveOutcome.storedAfterFailure);
        final entries = (await store.readAll()).entries;
        expect(entries, hasLength(1));
        expect(entries.single.url, url);
        expect(entries.single.uncertain, isFalse);
      });
    }

    test('a transport failure is stored as uncertain', () async {
      adapter.onOffline('/saved-items', method: 'POST');
      final store = await testPendingUrlStore();
      final container = await makeContainer(store: store);

      final outcome = await container.read(sharedUrlIntakeProvider).save(url);

      expect(outcome, ShareSaveOutcome.storedAfterUncertain);
      final entries = (await store.readAll()).entries;
      expect(entries.single.uncertain, isTrue);
    });

    test('an unreadable 201 is stored as uncertain', () async {
      adapter.onMethod('POST', '/saved-items', status: 201, body: 'not JSON');
      final store = await testPendingUrlStore();
      final container = await makeContainer(store: store);

      final outcome = await container.read(sharedUrlIntakeProvider).save(url);

      expect(outcome, ShareSaveOutcome.storedAfterUncertain);
      expect((await store.readAll()).entries.single.uncertain, isTrue);
    });

    test(
      'a signed-out refusal is a known failure and does not refresh',
      () async {
        adapter.onMethod(
          'POST',
          '/saved-items',
          status: 401,
          body: errorBody(ApiErrorCode.invalidAuthorizationHeader),
        );
        final store = await testPendingUrlStore();
        final container = await makeContainer(store: store);

        final outcome = await container.read(sharedUrlIntakeProvider).save(url);

        expect(outcome, ShareSaveOutcome.storedAfterFailure);
        expect((await store.readAll()).entries.single.uncertain, isFalse);
        expect(adapter.countFor('/auth/refresh'), 0);
      },
    );

    test(
      'an expired access token refreshes and replays through the interceptor',
      () async {
        adapter.onSequence('/saved-items', [
          FakeReply(401, errorBody(ApiErrorCode.accessTokenExpired)),
          FakeReply(201, SavedItemsFixtures.created(url: url)),
        ]);
        adapter.onMethod(
          'POST',
          '/auth/refresh',
          body: {
            'data': {'access_token': 'access-2', 'refresh_token': 'refresh-2'},
            'message': 'session refreshed',
          },
        );

        final store = await testPendingUrlStore();
        final container = await makeContainer(
          store: store,
          session: const AuthTokens(
            accessToken: 'access-1',
            refreshToken: 'refresh-1',
          ),
        );

        final outcome = await container.read(sharedUrlIntakeProvider).save(url);

        expect(outcome, ShareSaveOutcome.saved);
        expect((await store.readAll()).entries, isEmpty);
        expect(adapter.countFor('/auth/refresh'), 1);
        expect(adapter.countFor('/saved-items'), 2);
        expect(backend.values['stash_it.auth.access_token'], 'access-2');
        expect(backend.values['stash_it.auth.refresh_token'], 'refresh-2');
      },
    );

    test(
      'an existing local entry is removed after a later confirmed save',
      () async {
        final store = await testPendingUrlStore();
        await store.upsert(url: url, uncertain: true);
        adapter.onMethod(
          'POST',
          '/saved-items',
          status: 201,
          body: SavedItemsFixtures.created(url: url),
        );
        final container = await makeContainer(store: store);

        final outcome = await container.read(sharedUrlIntakeProvider).save(url);

        expect(outcome, ShareSaveOutcome.saved);
        expect((await store.readAll()).entries, isEmpty);
      },
    );

    test('a shared text with surrounding words saves the first URL', () async {
      adapter.onMethod(
        'POST',
        '/saved-items',
        status: 201,
        body: SavedItemsFixtures.created(url: url),
      );
      final store = await testPendingUrlStore();
      final container = await makeContainer(store: store);

      final outcome = await container
          .read(sharedUrlIntakeProvider)
          .save('Look at this $url please');

      expect(outcome, ShareSaveOutcome.saved);
      expect(adapter.lastRequestTo('/saved-items')!.jsonField('url'), url);
    });
  });

  group('local behavior', () {
    test('invalid shared text is not sent and not stored', () async {
      final store = await testPendingUrlStore();
      final container = await makeContainer(store: store);

      final outcome = await container
          .read(sharedUrlIntakeProvider)
          .save('not a link');

      expect(outcome, ShareSaveOutcome.invalid);
      expect(adapter.requests, isEmpty);
      expect((await store.readAll()).entries, isEmpty);
    });

    test('empty shared text is ignored', () async {
      final store = await testPendingUrlStore();
      final container = await makeContainer(store: store);

      final outcome = await container.read(sharedUrlIntakeProvider).save('  ');

      expect(outcome, ShareSaveOutcome.ignored);
      expect(adapter.requests, isEmpty);
      expect((await store.readAll()).entries, isEmpty);
    });

    test(
      'a repeat failure refreshes one entry rather than duplicating it',
      () async {
        var now = DateTime.utc(2026, 10, 28, 12);
        final store = await testPendingUrlStore(now: () => now);
        adapter.onMethod(
          'POST',
          '/saved-items',
          status: 500,
          body: errorBody(ApiErrorCode.internalServerError),
        );
        final container = await makeContainer(store: store);

        await container.read(sharedUrlIntakeProvider).save(url);
        now = now.add(const Duration(minutes: 5));
        await container.read(sharedUrlIntakeProvider).save(url);

        final entries = (await store.readAll()).entries;
        expect(entries, hasLength(1));
        expect(entries.single.addedAt, now);
        expect(entries.single.uncertain, isFalse);
      },
    );

    test('a local write failure is reported as not stored', () async {
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();
      final store = _FailingStore(preferences);
      adapter.onMethod(
        'POST',
        '/saved-items',
        status: 500,
        body: errorBody(ApiErrorCode.internalServerError),
      );
      final container = await makeContainer(store: store);

      final outcome = await container.read(sharedUrlIntakeProvider).save(url);

      expect(outcome, ShareSaveOutcome.notStored);
    });

    test(
      'an unclassified exception is treated as uncertain and stored',
      () async {
        final store = await testPendingUrlStore();
        final intake = SharedUrlIntake(
          repository: _ThrowingRepository(),
          store: store,
        );

        final outcome = await intake.save(url);

        expect(outcome, ShareSaveOutcome.storedAfterUncertain);
        expect((await store.readAll()).entries.single.uncertain, isTrue);
      },
    );

    test('the outcome copy is short and uncertainty-safe', () {
      expect(ShareSaveOutcome.saved.message, 'Saved to your account.');
      expect(
        ShareSaveOutcome.storedAfterFailure.message,
        "Couldn't save it. Kept on this device.",
      );
      expect(
        ShareSaveOutcome.storedAfterUncertain.message,
        'Save not confirmed. Kept on this device.',
      );
      expect(
        ShareSaveOutcome.invalid.message,
        "That's not a link, so nothing was saved.",
      );
      expect(
        ShareSaveOutcome.notStored.message,
        "Couldn't save or keep this link.",
      );
      expect(ShareSaveOutcome.ignored.message, isEmpty);

      expect(
        ShareSaveOutcome.storedAfterUncertain.message,
        isNot(contains("couldn't save")),
        reason: 'an unconfirmed outcome must not claim a known failure',
      );

      for (final outcome in ShareSaveOutcome.values) {
        expect(
          outcome.message.length,
          lessThanOrEqualTo(60),
          reason: '${outcome.name} must fit comfortably in a brief Toast',
        );
      }
    });
  });
}
