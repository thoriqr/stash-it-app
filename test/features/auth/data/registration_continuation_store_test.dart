import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_it_app/features/auth/data/registration_continuation_store.dart';

import '../../../support/fake_http.dart';

void main() {
  late InMemorySecureStorage backend;
  late RegistrationContinuationStore store;

  setUp(() {
    backend = InMemorySecureStorage();
    store = RegistrationContinuationStore(backend);
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
      backend.values[RegistrationContinuationStore.storageKey] = '{not json';

      expect(await store.read(), isNull);
    });

    test('a non-object JSON value reads as null', () async {
      backend.values[RegistrationContinuationStore.storageKey] = '"text"';

      expect(await store.read(), isNull);
    });

    test('missing fields read as null', () async {
      backend.values[RegistrationContinuationStore.storageKey] =
          '{"email":"reader@example.com"}';
      expect(await store.read(), isNull);

      backend.values[RegistrationContinuationStore.storageKey] =
          '{"token":"raw-token"}';
      expect(await store.read(), isNull);
    });

    test('empty fields read as null', () async {
      backend.values[RegistrationContinuationStore.storageKey] =
          '{"email":"","token":"raw-token"}';
      expect(await store.read(), isNull);

      backend.values[RegistrationContinuationStore.storageKey] =
          '{"email":"reader@example.com","token":""}';
      expect(await store.read(), isNull);

      backend.values[RegistrationContinuationStore.storageKey] =
          '{"email":"   ","token":"raw-token"}';
      expect(await store.read(), isNull);
    });

    test(
      'a platform read failure propagates for the caller to decide',
      () async {
        backend.failingReads.add(RegistrationContinuationStore.storageKey);

        await expectLater(store.read(), throwsA(isA<PlatformException>()));
      },
    );
  });

  group('writing', () {
    test('an empty email is a programmer error', () async {
      await expectLater(
        store.write(email: '   ', token: 'raw-token'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('an empty token is a programmer error', () async {
      await expectLater(
        store.write(email: 'reader@example.com', token: ''),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('a platform write failure propagates', () async {
      backend.failingWrites.add(RegistrationContinuationStore.storageKey);

      await expectLater(
        store.write(email: 'reader@example.com', token: 'raw-token'),
        throwsA(isA<PlatformException>()),
      );
    });
  });

  group('clearing', () {
    test('clear removes the record', () async {
      await store.write(email: 'reader@example.com', token: 'raw-token');

      await store.clear();

      expect(await store.read(), isNull);
    });

    test('clear leaves other keys alone and never deletes all', () async {
      backend.values['stash_it.auth.access_token'] = 'access';
      backend.values['stash_it.auth.refresh_token'] = 'refresh';
      backend.values['stash_it.pending.url'] = 'https://example.com';
      await store.write(email: 'reader@example.com', token: 'raw-token');

      await store.clear();

      expect(backend.values['stash_it.auth.access_token'], 'access');
      expect(backend.values['stash_it.auth.refresh_token'], 'refresh');
      expect(backend.values['stash_it.pending.url'], 'https://example.com');
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
      backend.failingReads.add(RegistrationContinuationStore.storageKey);

      await expectLater(
        store.clearIfToken('raw-token'),
        throwsA(isA<PlatformException>()),
      );

      backend.failingReads.clear();
      expect((await store.read())?.token, 'raw-token');
    });
  });
}
