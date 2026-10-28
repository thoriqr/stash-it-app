import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_it_app/features/auth/data/password_reset_continuation_store.dart';

import '../../../support/fake_http.dart';

void main() {
  late InMemorySecureStorage backend;
  late PasswordResetContinuationStore store;

  setUp(() {
    backend = InMemorySecureStorage();
    store = PasswordResetContinuationStore(backend);
  });

  group('reading', () {
    test('an empty store reads as null', () async {
      expect(await store.read(), isNull);
    });

    test('a written record round-trips with a normalized email', () async {
      await store.write(email: '  Reader@Example.COM ', token: 'raw-token');

      final stored = await store.read();
      expect(stored, isNotNull);
      expect(stored!.email, 'reader@example.com');
      expect(stored.token, 'raw-token');
    });

    test('a later write replaces the previous record', () async {
      await store.write(email: 'first@example.com', token: 'first-token');
      await store.write(email: 'second@example.com', token: 'second-token');

      final stored = await store.read();
      expect(stored!.email, 'second@example.com');
      expect(stored.token, 'second-token');
    });

    test('malformed JSON reads as null rather than throwing', () async {
      backend.values[PasswordResetContinuationStore.storageKey] = '{not json';

      expect(await store.read(), isNull);
    });

    test('a non-object JSON value reads as null', () async {
      backend.values[PasswordResetContinuationStore.storageKey] = '"text"';

      expect(await store.read(), isNull);
    });

    test('missing or empty fields read as null', () async {
      for (final raw in [
        '{"email":"reader@example.com"}',
        '{"token":"raw-token"}',
        '{"email":"","token":"raw-token"}',
        '{"email":"reader@example.com","token":""}',
        '{"email":"   ","token":"raw-token"}',
      ]) {
        backend.values[PasswordResetContinuationStore.storageKey] = raw;
        expect(await store.read(), isNull, reason: raw);
      }
    });

    test('a platform read failure propagates', () async {
      backend.failingReads.add(PasswordResetContinuationStore.storageKey);

      await expectLater(store.read(), throwsA(isA<PlatformException>()));
    });
  });

  group('writing', () {
    test('empty arguments are programmer errors', () async {
      await expectLater(
        store.write(email: '   ', token: 'raw-token'),
        throwsA(isA<ArgumentError>()),
      );
      await expectLater(
        store.write(email: 'reader@example.com', token: ''),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('a platform write failure propagates', () async {
      backend.failingWrites.add(PasswordResetContinuationStore.storageKey);

      await expectLater(
        store.write(email: 'reader@example.com', token: 'raw-token'),
        throwsA(isA<PlatformException>()),
      );
    });
  });

  group('clearing', () {
    test('clear removes only this record', () async {
      backend.values['stash_it.auth.access_token'] = 'access';
      backend.values['stash_it.auth.refresh_token'] = 'refresh';
      backend.values['stash_it.auth.registration_continuation'] =
          '{"email":"other@example.com","token":"registration-token"}';
      await store.write(email: 'reader@example.com', token: 'raw-token');

      await store.clear();

      expect(await store.read(), isNull);
      expect(backend.values['stash_it.auth.access_token'], 'access');
      expect(backend.values['stash_it.auth.refresh_token'], 'refresh');
      expect(
        backend.values['stash_it.auth.registration_continuation'],
        isNotNull,
      );
      expect(backend.clearAllCalls, 0);
    });

    test('clearIfToken removes only a matching token', () async {
      await store.write(email: 'reader@example.com', token: 'raw-token');

      await store.clearIfToken('another-token');
      expect((await store.read())?.token, 'raw-token');

      await store.clearIfToken('raw-token');
      expect(await store.read(), isNull);
    });

    test('clearIfToken on an empty store is harmless', () async {
      await store.clearIfToken('raw-token');

      expect(await store.read(), isNull);
    });

    test('clearIfToken does not clear when the read fails', () async {
      await store.write(email: 'reader@example.com', token: 'raw-token');
      backend.failingReads.add(PasswordResetContinuationStore.storageKey);

      await expectLater(
        store.clearIfToken('raw-token'),
        throwsA(isA<PlatformException>()),
      );

      backend.failingReads.clear();
      expect((await store.read())?.token, 'raw-token');
    });
  });
}
