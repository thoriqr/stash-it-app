import 'package:flutter_test/flutter_test.dart';
import 'package:stash_it_app/core/storage/secure_credential_store.dart';
import 'package:stash_it_app/features/auth/data/models/auth_tokens.dart';

import '../../support/fake_http.dart';

void main() {
  const accessKey = 'stash_it.auth.access_token';
  const refreshKey = 'stash_it.auth.refresh_token';

  late InMemorySecureStorage backend;
  late SecureCredentialStore store;

  setUp(() {
    backend = InMemorySecureStorage();
    store = SecureCredentialStore(backend);
  });

  group('reading', () {
    test('an empty store reads as no session', () async {
      expect(await store.read(), isNull);
    });

    test('a complete pair reads back unchanged', () async {
      backend.values[accessKey] = 'access-1';
      backend.values[refreshKey] = 'refresh-1';

      expect(
        await store.read(),
        const AuthTokens(accessToken: 'access-1', refreshToken: 'refresh-1'),
      );
    });

    test('an access token without a refresh token is not a session', () async {
      // Nothing could renew it, so reporting a session here would produce a
      // 401 on the first request and no way back.
      backend.values[accessKey] = 'access-1';

      expect(await store.read(), isNull);
    });

    test('a refresh token without an access token is not a session', () async {
      backend.values[refreshKey] = 'refresh-1';

      expect(await store.read(), isNull);
    });

    test('an empty string is treated as absent', () async {
      backend.values[accessKey] = '';
      backend.values[refreshKey] = 'refresh-1';

      expect(await store.read(), isNull);
    });

    test('the access token reads on its own for the interceptor', () async {
      backend.values[accessKey] = 'access-1';
      backend.values[refreshKey] = 'refresh-1';

      expect(await store.readAccessToken(), 'access-1');
    });

    test(
      'the refresh token reads on its own at the moment of renewal',
      () async {
        backend.values[refreshKey] = 'refresh-1';

        expect(await store.readRefreshToken(), 'refresh-1');
      },
    );

    test('a later read observes a rotated token, not a cached one', () async {
      // The renewal path reads at the moment it begins so a request whose 401
      // arrived after an earlier rotation uses the token that rotation produced.
      backend.values[refreshKey] = 'refresh-1';
      expect(await store.readRefreshToken(), 'refresh-1');

      backend.values[refreshKey] = 'refresh-2';
      expect(await store.readRefreshToken(), 'refresh-2');
    });
  });

  group('writing', () {
    test('a pair round-trips', () async {
      await store.write(
        const AuthTokens(accessToken: 'access-1', refreshToken: 'refresh-1'),
      );

      expect(
        await store.read(),
        const AuthTokens(accessToken: 'access-1', refreshToken: 'refresh-1'),
      );
    });

    test('writing replaces the previous pair', () async {
      await store.write(
        const AuthTokens(accessToken: 'a1', refreshToken: 'r1'),
      );
      await store.write(
        const AuthTokens(accessToken: 'a2', refreshToken: 'r2'),
      );

      expect(
        await store.read(),
        const AuthTokens(accessToken: 'a2', refreshToken: 'r2'),
      );
    });

    test('a write that fails partway leaves nothing behind', () async {
      // The backend rotates both tokens together, so a half-written pair is
      // indistinguishable from a real session once persisted — and unusable.
      backend.failingWrites.add(accessKey);

      await expectLater(
        store.write(
          const AuthTokens(accessToken: 'access-2', refreshToken: 'refresh-2'),
        ),
        throwsA(isA<Exception>()),
      );

      expect(
        backend.values,
        isEmpty,
        reason: 'the partial write must be rolled back',
      );
      expect(await store.read(), isNull);
    });

    test('a failed write does not silently keep the old pair', () async {
      await store.write(
        const AuthTokens(accessToken: 'a1', refreshToken: 'r1'),
      );

      backend.failingWrites.add(accessKey);
      await expectLater(
        store.write(const AuthTokens(accessToken: 'a2', refreshToken: 'r2')),
        throwsA(isA<Exception>()),
      );

      expect(
        await store.read(),
        isNull,
        reason: 'a mismatched pair is worse than no pair',
      );
    });
  });

  group('clearing', () {
    test('removes both tokens', () async {
      await store.write(
        const AuthTokens(accessToken: 'a1', refreshToken: 'r1'),
      );

      await store.clear();

      expect(backend.values, isEmpty);
      expect(await store.read(), isNull);
    });

    test('clearing an empty store is harmless', () async {
      await store.clear();

      expect(await store.read(), isNull);
    });

    test('other keys in the same store are left alone', () async {
      // The pending-URL queue will share this store. Clearing credentials must
      // not take it with them, which `deleteAll` would.
      backend.values['stash_it.pending.url'] = 'https://example.com';
      await store.write(
        const AuthTokens(accessToken: 'a1', refreshToken: 'r1'),
      );

      await store.clear();

      expect(backend.values['stash_it.pending.url'], 'https://example.com');
      expect(backend.clearAllCalls, 0, reason: 'deleteAll would be too broad');
    });
  });
}
