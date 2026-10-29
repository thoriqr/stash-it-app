import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stash_it_app/features/pending_urls/data/pending_url_store.dart';
import 'package:stash_it_app/features/pending_urls/domain/pending_url.dart';

import '../../../support/pending_urls.dart';

class _FailingWriteStore extends PendingUrlStore {
  _FailingWriteStore(super.preferences, {super.now});

  @override
  Future<void> writeEntries(List<PendingUrl> entries) async {
    throw const PendingUrlStorageException('simulated write failure');
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const key = PendingUrlStore.storageKey;
  const url = 'https://example.com/articles/crdts-explained';

  Future<SharedPreferences> prefsWith(Map<String, Object> values) async {
    SharedPreferences.setMockInitialValues(values);
    return SharedPreferences.getInstance();
  }

  group('reads', () {
    test('a missing key is an empty snapshot', () async {
      final store = await testPendingUrlStore();

      final snapshot = await store.readAll();

      expect(snapshot.entries, isEmpty);
      expect(snapshot.expiredCount, 0);
    });

    test('a non-string value is treated as empty', () async {
      final preferences = await prefsWith({key: 42});
      final store = PendingUrlStore(preferences);

      expect((await store.readAll()).entries, isEmpty);
    });

    test('malformed JSON is treated as empty', () async {
      final preferences = await prefsWith({key: 'not json'});
      final store = PendingUrlStore(preferences);

      expect((await store.readAll()).entries, isEmpty);
    });

    test(
      'malformed members are skipped without discarding valid ones',
      () async {
        final preferences = await prefsWith({
          key: jsonEncode([
            {
              'url': 'https://example.com/valid',
              'added_at': '2026-10-27T12:00:00Z',
              'uncertain': false,
            },
            'not an object',
            {'url': 7, 'added_at': 'not a date'},
            {'url': 'https://example.com/missing-time'},
          ]),
        });
        final store = PendingUrlStore(
          preferences,
          now: () => DateTime.utc(2026, 10, 28, 12),
        );

        final snapshot = await store.readAll();

        expect(snapshot.entries, hasLength(1));
        expect(snapshot.entries.single.url, 'https://example.com/valid');
        expect(snapshot.entries.single.uncertain, isFalse);
      },
    );

    test('duplicate URLs in a corrupt value collapse to the newest', () async {
      final preferences = await prefsWith({
        key: jsonEncode([
          {'url': url, 'added_at': '2026-10-26T12:00:00Z', 'uncertain': false},
          {'url': url, 'added_at': '2026-10-27T12:00:00Z', 'uncertain': true},
        ]),
      });
      final store = PendingUrlStore(
        preferences,
        now: () => DateTime.utc(2026, 10, 28, 12),
      );

      final entries = (await store.readAll()).entries;

      expect(entries, hasLength(1));
      expect(entries.single.addedAt, DateTime.utc(2026, 10, 27, 12));
      expect(entries.single.uncertain, isTrue);
    });
  });

  group('writes', () {
    test('entries persist across store instances and restart', () async {
      final preferences = await prefsWith({});
      final store = PendingUrlStore(preferences);

      await store.upsert(url: url, uncertain: false);

      final samePreferences = PendingUrlStore(preferences);
      expect((await samePreferences.readAll()).entries, hasLength(1));

      SharedPreferences.resetStatic();
      final restartedPreferences = await SharedPreferences.getInstance();
      final restarted = PendingUrlStore(restartedPreferences);

      final entries = (await restarted.readAll()).entries;
      expect(entries, hasLength(1));
      expect(entries.single.url, url);
      expect(entries.single.uncertain, isFalse);
    });

    test('the same URL refreshes its timestamp and uncertainty', () async {
      final preferences = await prefsWith({});
      var now = DateTime.utc(2026, 10, 28, 12);
      final store = PendingUrlStore(preferences, now: () => now);

      await store.upsert(url: url, uncertain: false);
      now = now.add(const Duration(minutes: 5));
      await store.upsert(url: url, uncertain: true);

      final entries = (await store.readAll()).entries;
      expect(entries, hasLength(1));
      expect(entries.single.addedAt, now);
      expect(entries.single.uncertain, isTrue);
    });

    test('different paths and query strings are separate entries', () async {
      final preferences = await prefsWith({});
      final store = PendingUrlStore(
        preferences,
        now: () => DateTime.utc(2026, 10, 28, 12),
      );

      await store.upsert(url: 'https://example.com/a', uncertain: false);
      await store.upsert(url: 'https://example.com/a?x=1', uncertain: false);
      await store.upsert(url: 'https://example.com/a?x=2', uncertain: false);

      final entries = (await store.readAll()).entries;
      expect(entries, hasLength(3));
      expect(entries.map((entry) => entry.url).toSet(), {
        'https://example.com/a',
        'https://example.com/a?x=1',
        'https://example.com/a?x=2',
      });
    });

    test('newest entries are returned first', () async {
      final preferences = await prefsWith({});
      var now = DateTime.utc(2026, 10, 28, 12);
      final store = PendingUrlStore(preferences, now: () => now);

      await store.upsert(url: 'https://example.com/older', uncertain: false);
      now = now.add(const Duration(minutes: 1));
      await store.upsert(url: 'https://example.com/newer', uncertain: false);

      final entries = (await store.readAll()).entries;
      expect(entries.map((entry) => entry.url), [
        'https://example.com/newer',
        'https://example.com/older',
      ]);
    });

    test('only URL, timestamp and uncertainty are serialized', () async {
      final preferences = await prefsWith({});
      final store = PendingUrlStore(preferences);

      await store.upsert(url: url, uncertain: false);

      final decoded = jsonDecode(preferences.getString(key)!) as List;
      final entry = decoded.single as Map<String, dynamic>;
      expect(entry.keys.toSet(), {'url', 'added_at', 'uncertain'});
      expect(entry.containsKey('user_id'), isFalse);
      expect(entry.containsKey('account_id'), isFalse);
    });

    test('a failed write throws instead of claiming persistence', () async {
      final preferences = await prefsWith({});
      final store = _FailingWriteStore(preferences);

      await expectLater(
        store.upsert(url: url, uncertain: false),
        throwsA(isA<PendingUrlStorageException>()),
      );
    });

    test('removing the exact URL is a no-op for other values', () async {
      final preferences = await prefsWith({});
      final store = PendingUrlStore(preferences);

      await store.upsert(url: url, uncertain: false);
      await store.upsert(url: '$url?other=1', uncertain: false);

      await store.removeExact(url);

      final entries = (await store.readAll()).entries;
      expect(entries, hasLength(1));
      expect(entries.single.url, '$url?other=1');
    });
  });

  group('retention', () {
    test('an entry is kept at six days and removed at seven', () async {
      final preferences = await prefsWith({});
      final created = DateTime.utc(2026, 10, 1, 12);

      final atCreation = PendingUrlStore(preferences, now: () => created);
      await atCreation.upsert(url: url, uncertain: false);

      final atSixDays = PendingUrlStore(
        preferences,
        now: () => created.add(const Duration(days: 6)),
      );
      final kept = await atSixDays.readAll();
      expect(kept.entries, hasLength(1));
      expect(kept.expiredCount, 0);

      final atSevenDays = PendingUrlStore(
        preferences,
        now: () => created.add(const Duration(days: 7)),
      );
      final expired = await atSevenDays.readAll();
      expect(expired.entries, isEmpty);
      expect(expired.expiredCount, 1);
      expect(preferences.getString(key), isNull);
      expect(await atSevenDays.consumeExpiryNotice(), isTrue);
      expect(await atSevenDays.consumeExpiryNotice(), isFalse);
    });

    test('a write-time prune leaves a one-shot notice', () async {
      final preferences = await prefsWith({});
      final created = DateTime.utc(2026, 10, 1, 12);
      final atCreation = PendingUrlStore(preferences, now: () => created);
      await atCreation.upsert(url: 'https://example.com/old', uncertain: false);

      final later = PendingUrlStore(
        preferences,
        now: () => created.add(const Duration(days: 8)),
      );
      await later.upsert(url: 'https://example.com/new', uncertain: false);

      expect(await later.consumeExpiryNotice(), isTrue);
      expect(await later.consumeExpiryNotice(), isFalse);
    });

    test('expiry prunes only the old entries', () async {
      final preferences = await prefsWith({});
      final now = DateTime.utc(2026, 10, 28, 12);
      final store = PendingUrlStore(preferences, now: () => now);

      await store.upsert(url: 'https://example.com/old', uncertain: false);
      await store.upsert(url: 'https://example.com/new', uncertain: false);

      final later = PendingUrlStore(
        preferences,
        now: () => now.add(const Duration(days: 7)),
      );
      final snapshot = await later.readAll();

      expect(snapshot.entries, isEmpty);
      expect(snapshot.expiredCount, 2);
    });

    test(
      'a failed cleanup write still returns the unexpired entries',
      () async {
        final preferences = await prefsWith({});
        final created = DateTime.utc(2026, 10, 1, 12);
        final atCreation = PendingUrlStore(preferences, now: () => created);
        await atCreation.upsert(
          url: 'https://example.com/old',
          uncertain: false,
        );

        final failing = _FailingWriteStore(
          preferences,
          now: () => created.add(const Duration(days: 8)),
        );
        final snapshot = await failing.readAll();

        expect(snapshot.entries, isEmpty);
        expect(snapshot.expiredCount, 1);
        expect(
          await failing.consumeExpiryNotice(),
          isFalse,
          reason: 'the prune was not persisted, so no notice is owed',
        );
      },
    );
  });
}
