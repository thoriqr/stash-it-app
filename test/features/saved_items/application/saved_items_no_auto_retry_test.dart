import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_it_app/app/network/network_providers.dart';
import 'package:stash_it_app/core/error/api_failure.dart';
import 'package:stash_it_app/core/storage/secure_credential_store.dart';
import 'package:stash_it_app/features/auth/application/session_controller.dart';
import 'package:stash_it_app/features/auth/data/models/auth_tokens.dart';
import 'package:stash_it_app/features/saved_items/application/saved_items_controller.dart';

import '../../../support/fake_http.dart';
import '../../../support/saved_items_fixtures.dart';

/// `savedItemsProvider` must not retry itself.
///
/// ## The defect
///
/// Riverpod retries a failed provider build by default — ten rebuilds on a 200 ms
/// doubling backoff capped at 6.4 s — and its only exclusions are
/// `ProviderException` and `Error`. An `ApiFailure` is a plain sealed class, so
/// every failure this provider can produce was being retried, including
/// `ApiFailureRefreshUncertain`.
///
/// Each rebuild issues a brand-new `RequestOptions`, so the interceptor's
/// one-replay bound restarts and `POST /auth/refresh` presents the **same**
/// refresh token again. The backend reads that as reuse, revokes the session and
/// answers `SESSION_REVOKED` — so an automatic retry destroyed, roughly 200 ms
/// later and with no user action, exactly the session the client had deliberately
/// preserved.
///
/// ## Why this file exists separately
///
/// `saved_items_controller_test.dart` passes `retry: (_, _) => null` to its
/// container, which is correct for its error-path and request-count assertions and
/// **would mask this defect entirely**. Every container here is therefore built
/// on Riverpod's real default policy; suppressing retry is the provider's job,
/// asserted below.
///
/// Time is advanced by waiting rather than with `fake_async`, which is not a
/// declared dependency. [retryWindow] clears the two retries Riverpod would have
/// scheduled by 200 ms and 600 ms, with margin, so a regression is unambiguous:
/// the counts below become 3 rather than 1.
void main() {
  const accessKey = 'stash_it.auth.access_token';
  const refreshKey = 'stash_it.auth.refresh_token';

  /// Past the 200 ms and 600 ms retries the default policy would have run.
  const retryWindow = Duration(milliseconds: 1200);

  late FakeHttpAdapter adapter;
  late InMemorySecureStorage backend;

  setUp(() {
    adapter = FakeHttpAdapter();
    backend = InMemorySecureStorage();
  });

  /// A container on Riverpod's **default** retry policy, holding a session whose
  /// access token has expired and whose refresh token is still good.
  ///
  /// The tokens go into the **store**, not only into `restoredTokensProvider`,
  /// because that is where `AuthInterceptor` reads the bearer from and where
  /// `SessionController` reads the refresh token from. Both clients point at the
  /// scripted transport, so no socket is opened.
  ///
  /// A listener is attached, and it is load-bearing rather than incidental.
  /// `invalidateSelf` only schedules a rebuild while the element `isActive`, and
  /// `isActive` is `listenerCount > 0` (`riverpod/lib/src/core/element.dart`). An
  /// unlistened provider is mounted but inert, so the retry this file exists to
  /// catch would never rebuild it and every assertion below would pass against the
  /// unfixed code. `InboxScreen` supplies that listener in the real app by
  /// watching the provider, so attaching one here is modelling the screen rather
  /// than inventing behaviour.
  ProviderContainer makeContainer() {
    const session = AuthTokens(
      accessToken: 'access-1',
      refreshToken: 'refresh-1',
    );
    backend.values[accessKey] = session.accessToken;
    backend.values[refreshKey] = session.refreshToken;

    final container = ProviderContainer(
      overrides: [
        credentialStoreProvider.overrideWithValue(
          SecureCredentialStore(backend),
        ),
        restoredTokensProvider.overrideWithValue(session),
      ],
      // Deliberately **no** `retry:`. Riverpod's default policy is what makes
      // these tests meaningful.
    );
    container.read(appDioProvider).httpClientAdapter = adapter;
    container.read(refreshDioProvider).httpClientAdapter = adapter;

    final subscription = container.listen(savedItemsProvider, (_, _) {});
    addTearDown(() {
      subscription.close();
      container.dispose();
    });
    return container;
  }

  /// The ambiguous failure this file is about: the listing request reports an
  /// expired access token, and the renewal that answers it fails without the
  /// client learning whether the server committed the rotation.
  void scriptAmbiguousRenewalFailure() {
    adapter.on(
      '/saved-items',
      status: 401,
      body: errorBody('ACCESS_TOKEN_EXPIRED'),
    );
    adapter.on(
      '/auth/refresh',
      status: 500,
      body: errorBody('INTERNAL_SERVER_ERROR'),
    );
  }

  group('the provider opts out of Riverpod automatic retry', () {
    test('the override is attached to the provider itself', () {
      // Belt and braces for the behavioural cases below: if the annotation ever
      // loses its `retry:`, this fails first and says so.
      expect(
        savedItemsProvider.retry,
        isNotNull,
        reason: 'the provider must carry its own retry policy, not the default',
      );
    });

    test('a failed load is not retried automatically', () async {
      final container = makeContainer();
      scriptAmbiguousRenewalFailure();

      container.read(savedItemsProvider);
      await Future<void>.delayed(retryWindow);

      expect(
        adapter.countFor('/saved-items'),
        1,
        reason:
            'the listing is fetched once. Without the override Riverpod rebuilds '
            'this provider after 200 ms and 600 ms, and every rebuild is another '
            'GET /saved-items.',
      );
      expect(
        adapter.countFor('/auth/refresh'),
        1,
        reason:
            'the renewal is attempted once. Presenting the refresh token a '
            'second time is what the backend treats as reuse, and it revokes the '
            'session over.',
      );
    });

    test('an ambiguous renewal failure keeps the stored credentials', () async {
      // The reason no retry may be automatic: the client cannot know whether the
      // server committed the rotation, so discarding the refresh token would
      // discard the only chance of recovering.
      final container = makeContainer();
      scriptAmbiguousRenewalFailure();

      container.read(savedItemsProvider);
      await Future<void>.delayed(retryWindow);

      expect(backend.values[refreshKey], 'refresh-1');
      expect(backend.values[accessKey], 'access-1');
      expect(
        container.read(sessionControllerProvider),
        isNotNull,
        reason: 'no renewal failed terminally, so the session still stands',
      );
    });
  });

  group('the failure is reported, not hidden', () {
    test('the provider settles into an error state instead of loading', () async {
      // `InboxScreen._body` switches on exactly this: `AsyncError` renders the
      // inline error and its Retry action, while anything else — notably the
      // `AsyncLoading` Riverpod publishes *while* a retry is pending — renders the
      // skeleton. Settling into `AsyncError` is what makes Retry reachable.
      final container = makeContainer();
      scriptAmbiguousRenewalFailure();

      container.read(savedItemsProvider);
      await Future<void>.delayed(retryWindow);

      final listing = container.read(savedItemsProvider);
      expect(listing, isA<AsyncError>());
      expect(listing.hasError, isTrue);
      expect(
        listing.isLoading,
        isFalse,
        reason: 'a pending retry would leave the Inbox showing a skeleton',
      );
      expect(listing.error, isA<ApiFailureRefreshUncertain>());
    });
  });

  group('explicit retry is still the only way back', () {
    test('the notifier retry refetches the listing', () async {
      // The same call the Inbox's Retry button makes, through the real graph.
      final container = makeContainer();
      scriptAmbiguousRenewalFailure();

      container.read(savedItemsProvider);
      await Future<void>.delayed(retryWindow);
      expect(container.read(savedItemsProvider), isA<AsyncError>());

      adapter.on('/saved-items', body: SavedItemsFixtures.page());

      container.read(savedItemsProvider.notifier).retry();
      await Future<void>.delayed(retryWindow);

      expect(
        adapter.countFor('/saved-items'),
        2,
        reason: 'the user asked for another attempt, and it happened',
      );
      expect(
        container.read(savedItemsProvider),
        isA<AsyncData>(),
        reason: 'the recovered page replaces the error',
      );
    });
  });
}
