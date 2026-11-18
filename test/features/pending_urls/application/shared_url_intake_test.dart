import 'dart:async';

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
import 'package:stash_it_app/features/saved_items/data/client_metadata_fetcher.dart';
import 'package:stash_it_app/features/saved_items/data/datasources/saved_items_api.dart';
import 'package:stash_it_app/features/saved_items/data/models/client_metadata.dart';
import 'package:stash_it_app/features/saved_items/data/saved_items_providers.dart';
import 'package:stash_it_app/features/saved_items/data/saved_items_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../support/fake_client_metadata_fetcher.dart';
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
  Future<void> create({
    required String url,
    String? note,
    ClientMetadata? metadata,
  }) async {
    throw StateError('unexpected repository failure');
  }
}

class _HangingRepository extends SavedItemsRepository {
  _HangingRepository() : super(api: SavedItemsApi(Dio()));

  final Completer<void> release = Completer<void>();

  @override
  Future<void> create({
    required String url,
    String? note,
    ClientMetadata? metadata,
  }) => release.future;
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
    ClientMetadataFetcher? metadataFetcher,
  }) async {
    final credentials = SecureCredentialStore(backend);
    if (session != null) await credentials.write(session);

    final container = ProviderContainer(
      overrides: [
        credentialStoreProvider.overrideWithValue(credentials),
        restoredTokensProvider.overrideWithValue(session),
        pendingUrlStoreProvider.overrideWithValue(store),
        if (metadataFetcher != null)
          clientMetadataFetcherProvider.overrideWithValue(metadataFetcher),
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
      expect(
        (adapter.lastRequestTo('/saved-items')!.body as Map<String, dynamic>)
            .containsKey('note'),
        isFalse,
        reason: 'Quick Share never composes a note',
      );
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

    test('a note from the share card travels with the create', () async {
      adapter.onMethod(
        'POST',
        '/saved-items',
        status: 201,
        body: SavedItemsFixtures.created(url: url),
      );
      final store = await testPendingUrlStore();
      final container = await makeContainer(store: store);

      await container
          .read(sharedUrlIntakeProvider)
          .save(url, note: 'Watch later.');

      final body =
          adapter.lastRequestTo('/saved-items')!.body as Map<String, dynamic>;
      expect(body['note'], 'Watch later.');
      expect((await store.readAll()).entries, isEmpty);
    });

    test('a failed save keeps the note with the local URL', () async {
      adapter.onMethod(
        'POST',
        '/saved-items',
        status: 500,
        body: errorBody(ApiErrorCode.internalServerError),
      );
      final store = await testPendingUrlStore();
      final container = await makeContainer(store: store);

      final outcome = await container
          .read(sharedUrlIntakeProvider)
          .save(url, note: 'Watch later.');

      expect(outcome, ShareSaveOutcome.storedAfterFailure);
      final entry = (await store.readAll()).entries.single;
      expect(entry.url, url);
      expect(entry.note, 'Watch later.');
    });

    test('a blank note is omitted from the create', () async {
      adapter.onMethod(
        'POST',
        '/saved-items',
        status: 201,
        body: SavedItemsFixtures.created(url: url),
      );
      final store = await testPendingUrlStore();
      final container = await makeContainer(store: store);

      await container.read(sharedUrlIntakeProvider).save(url, note: '   ');

      final body =
          adapter.lastRequestTo('/saved-items')!.body as Map<String, dynamic>;
      expect(body.containsKey('note'), isFalse);
    });

    test(
      'an Instagram save sends the metadata extracted on the device',
      () async {
        const instagramUrl = 'https://www.instagram.com/reel/abc/';
        adapter.onMethod(
          'POST',
          '/saved-items',
          status: 201,
          body: SavedItemsFixtures.created(url: instagramUrl),
        );
        final store = await testPendingUrlStore();
        final fetcher = FakeClientMetadataFetcher(
          const ClientMetadata(
            title: 'Reel title',
            description: 'Reel description',
            imageUrl: 'https://cdn.example.com/reel.jpg',
          ),
        );
        final container = await makeContainer(
          store: store,
          metadataFetcher: fetcher,
        );

        final outcome = await container
            .read(sharedUrlIntakeProvider)
            .save(instagramUrl);

        expect(outcome, ShareSaveOutcome.saved);
        expect(fetcher.urls, [instagramUrl]);
        expect(
          (adapter.lastRequestTo('/saved-items')!.body
              as Map<String, dynamic>)['metadata'],
          {
            'title': 'Reel title',
            'description': 'Reel description',
            'image_url': 'https://cdn.example.com/reel.jpg',
          },
        );
      },
    );

    test('an Instagram save with a failed read sends empty metadata', () async {
      const instagramUrl = 'https://instagram.com/reel/abc/';
      adapter.onMethod(
        'POST',
        '/saved-items',
        status: 201,
        body: SavedItemsFixtures.created(url: instagramUrl),
      );
      final store = await testPendingUrlStore();
      final fetcher = FakeClientMetadataFetcher();
      final container = await makeContainer(
        store: store,
        metadataFetcher: fetcher,
      );

      await container.read(sharedUrlIntakeProvider).save(instagramUrl);

      expect(fetcher.urls, [instagramUrl]);
      final body =
          adapter.lastRequestTo('/saved-items')!.body as Map<String, dynamic>;
      expect(body.containsKey('metadata'), isTrue);
      expect(body['metadata'], isEmpty);
    });

    test('a non-Instagram save omits metadata', () async {
      adapter.onMethod(
        'POST',
        '/saved-items',
        status: 201,
        body: SavedItemsFixtures.created(url: url),
      );
      final store = await testPendingUrlStore();
      final fetcher = FakeClientMetadataFetcher(
        const ClientMetadata(title: 'unused'),
      );
      final container = await makeContainer(
        store: store,
        metadataFetcher: fetcher,
      );

      await container.read(sharedUrlIntakeProvider).save(url);

      expect(fetcher.urls, isEmpty);
      final body =
          adapter.lastRequestTo('/saved-items')!.body as Map<String, dynamic>;
      expect(body.containsKey('metadata'), isFalse);
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
          metadataFetcher: FakeClientMetadataFetcher(),
        );

        final outcome = await intake.save(url);

        expect(outcome, ShareSaveOutcome.storedAfterUncertain);
        expect((await store.readAll()).entries.single.uncertain, isTrue);
      },
    );

    test('the URL is kept while the request is still in flight', () async {
      final store = await testPendingUrlStore();
      final repository = _HangingRepository();
      final intake = SharedUrlIntake(
        repository: repository,
        store: store,
        metadataFetcher: FakeClientMetadataFetcher(),
      );

      final result = intake.save(url, note: 'Draft note');
      await pumpEventQueue();

      final pending = (await store.readAll()).entries;
      expect(pending, hasLength(1));
      expect(pending.single.url, url);
      expect(pending.single.uncertain, isTrue);
      expect(pending.single.note, 'Draft note');

      repository.release.complete();
      expect(await result, ShareSaveOutcome.saved);
      expect((await store.readAll()).entries, isEmpty);
    });

    test(
      'a failed local pre-write does not block a confirmed remote save',
      () async {
        SharedPreferences.setMockInitialValues({});
        final preferences = await SharedPreferences.getInstance();
        final store = _FailingStore(preferences);
        adapter.onMethod(
          'POST',
          '/saved-items',
          status: 201,
          body: SavedItemsFixtures.created(url: url),
        );
        final container = await makeContainer(store: store);

        final outcome = await container.read(sharedUrlIntakeProvider).save(url);

        expect(outcome, ShareSaveOutcome.saved);
      },
    );
  });
}
