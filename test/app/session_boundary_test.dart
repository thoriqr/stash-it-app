import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_it_app/app/network/network_providers.dart';
import 'package:stash_it_app/app/session/session_boundary.dart';
import 'package:stash_it_app/core/network/token_provider.dart';
import 'package:stash_it_app/core/storage/secure_credential_store.dart';
import 'package:stash_it_app/features/auth/application/auth_state.dart';
import 'package:stash_it_app/features/auth/application/session_controller.dart';
import 'package:stash_it_app/features/auth/data/models/auth_tokens.dart';
import 'package:stash_it_app/features/collections/application/collections_controller.dart';
import 'package:stash_it_app/features/collections/data/collections_providers.dart';
import 'package:stash_it_app/features/collections/domain/collection_page.dart';
import 'package:stash_it_app/features/collections/domain/collection_summary.dart';
import 'package:stash_it_app/features/profile/application/profile_controller.dart';
import 'package:stash_it_app/features/profile/data/profile_providers.dart';
import 'package:stash_it_app/features/profile/domain/user_profile.dart';
import 'package:stash_it_app/features/saved_items/application/saved_items_controller.dart';
import 'package:stash_it_app/features/saved_items/data/saved_items_providers.dart';
import 'package:stash_it_app/features/saved_items/domain/saved_item_page.dart';
import 'package:stash_it_app/features/saved_items/domain/saved_item_summary.dart';

import '../support/fake_collections_repository.dart';
import '../support/fake_http.dart';
import '../support/fake_profile_repository.dart';
import '../support/fake_saved_items_repository.dart';

const _aTokens = AuthTokens(accessToken: 'access-a', refreshToken: 'refresh-a');

const _bTokens = AuthTokens(accessToken: 'access-b', refreshToken: 'refresh-b');

final _aProfile = profileFixture(
  id: 'account-a',
  email: 'a@example.com',
  displayName: 'Alice',
  hasPasswordCredential: false,
);

final _bProfile = profileFixture(
  id: 'account-b',
  email: 'b@example.com',
  displayName: 'Bob',
  hasPasswordCredential: false,
);

SavedItemSummary _item(String id, String collectionName) => SavedItemSummary(
  id: id,
  collectionId: 'collection-$id',
  collectionName: collectionName,
  url: 'https://example.com/$id',
  enrichmentStatus: EnrichmentStatus.completed,
  title: 'Title $id',
);

SavedItemPage _savedPage(SavedItemSummary item) =>
    SavedItemPage(items: [item], nextCursor: null, hasMore: false);

CollectionSummary _collection(String name) => CollectionSummary(
  id: 'collection-$name',
  name: name,
  type: 'user',
  isUnsorted: false,
  savedItemsCount: 1,
  savedItemsCountOverflow: false,
  createdAt: DateTime.utc(2026, 10, 1),
  updatedAt: DateTime.utc(2026, 10, 1),
);

CollectionPage _collectionPage(CollectionSummary collection) =>
    CollectionPage(items: [collection], nextCursor: null, hasMore: false);

typedef _Harness = ({
  ProviderContainer container,
  SecureCredentialStore credentials,
  FakeProfileRepository profiles,
  FakeSavedItemsRepository savedItems,
  FakeCollectionsRepository collections,
});

/// One container with the session boundary active and every network edge faked.
///
/// The boundary is activated exactly as `StashItApp` does, so the tests exercise
/// the app-level listener rather than calling the clear methods themselves.
_Harness _makeHarness({
  required AuthTokens restored,
  UserProfile? profile,
  SavedItemPage? listPage,
  CollectionPage? collectionPage,
}) {
  final credentials = SecureCredentialStore(InMemorySecureStorage());
  final profiles = FakeProfileRepository(profile: profile);
  final savedItems = FakeSavedItemsRepository(
    listPage: listPage,
    detailResults: [_item('detail', 'Alice shelf')],
  );
  final collections = FakeCollectionsRepository(
    results: [
      collectionPage ??
          const CollectionPage(items: [], nextCursor: null, hasMore: false),
    ],
  );

  final container = ProviderContainer.test(
    overrides: [
      credentialStoreProvider.overrideWithValue(credentials),
      restoredTokensProvider.overrideWithValue(restored),
      profileRepositoryProvider.overrideWithValue(profiles),
      savedItemsRepositoryProvider.overrideWithValue(savedItems),
      collectionsRepositoryProvider.overrideWithValue(collections),
    ],
    retry: (_, _) => null,
  );

  // What `StashItApp` does at the root. Riverpod pauses a provider with no
  // listeners, and a paused provider's `ref.listen` does not run, so a bare read
  // would not exercise the boundary at all.
  container.listen(sessionBoundaryProvider, (_, _) {});

  return (
    container: container,
    credentials: credentials,
    profiles: profiles,
    savedItems: savedItems,
    collections: collections,
  );
}

/// Ends the current session locally, as every sign-out and terminal path does.
///
/// Reading the status is what makes the boundary observe the transition before
/// the next one begins: a real sign-out is followed by a frame on sign-in, not by
/// a second status change in the same microtask.
void _signOut(_Harness harness) {
  harness.container.read(sessionControllerProvider.notifier).discard();
  expect(harness.container.read(authStateProvider), AuthStatus.signedOut);
}

void _signIn(_Harness harness) {
  harness.container.read(sessionControllerProvider.notifier).adopt(_bTokens);
  expect(harness.container.read(authStateProvider), AuthStatus.signedIn);
}

void main() {
  test('signing in as another account clears A before B loads', () async {
    final harness = _makeHarness(restored: _aTokens, profile: _aProfile);
    await harness.container.read(profileProvider.future);
    expect(harness.container.read(profileProvider).value!.id, 'account-a');

    _signOut(harness);

    final cleared = harness.container.read(profileProvider);
    expect(
      cleared,
      isA<AsyncLoading>(),
      reason: "A's profile must not remain a loaded value after the sign-out",
    );
    expect(cleared.isLoading, isTrue);
    expect(
      harness.profiles.getUserCalls,
      1,
      reason: 'clearing on sign-out must not issue an unauthenticated read',
    );

    final gate = Completer<void>();
    harness.profiles
      ..profile = _bProfile
      ..getUserGate = gate;

    _signIn(harness);

    // Riverpod carries A's value inside the AsyncLoading. The isolation contract
    // is that no consumer treats a loading state as loaded data, so the state's
    // kind — not `hasValue` — is what must change here.
    final loading = harness.container.read(profileProvider);
    expect(
      loading,
      isA<AsyncLoading>(),
      reason: "A's profile must not be published as data while B is loading",
    );
    expect(loading.isLoading, isTrue);
    expect(harness.profiles.getUserCalls, 2);

    gate.complete();
    await harness.container.read(profileProvider.future);

    expect(harness.container.read(profileProvider).value!.id, 'account-b');
    expect(harness.profiles.getUserCalls, 2);
  });

  test('a late account-A profile reply cannot replace B', () async {
    final aGate = Completer<void>();
    final bGate = Completer<void>();
    final harness = _makeHarness(restored: _aTokens, profile: _aProfile);

    harness.profiles.onGetUser = (call) async {
      if (call == 1) {
        await aGate.future;
        return _aProfile;
      }
      await bGate.future;
      return _bProfile;
    };

    // A's first read never completes until the end of the test.
    harness.container.read(profileProvider.future).ignore();
    await untilCalled(() => harness.profiles.getUserCalls == 1);

    _signOut(harness);
    _signIn(harness);

    final bFuture = harness.container.read(profileProvider.future);
    await untilCalled(() => harness.profiles.getUserCalls == 2);
    expect(harness.container.read(profileProvider), isA<AsyncLoading>());

    bGate.complete();
    await bFuture;
    expect(harness.container.read(profileProvider).value!.id, 'account-b');

    // A's reply lands after B's build has already produced the current value.
    aGate.complete();
    await Future<void>.delayed(Duration.zero);

    expect(
      harness.container.read(profileProvider).value!.id,
      'account-b',
      reason: "a superseded build must not overwrite B's profile",
    );
    expect(harness.profiles.getUserCalls, 2);
  });

  test('a terminal renewal clears every loaded user-scoped provider', () async {
    final harness = _makeHarness(
      restored: _aTokens,
      profile: _aProfile,
      listPage: _savedPage(_item('saved-a', 'Alice shelf')),
      collectionPage: _collectionPage(_collection('Alice shelf')),
    );

    await harness.container.read(profileProvider.future);
    await harness.container.read(savedItemsProvider.future);
    await harness.container.read(collectionsProvider.future);

    expect(
      harness.container.read(savedItemsProvider).value!.items.single.id,
      'saved-a',
    );
    expect(
      harness.container.read(collectionsProvider).value!.items.single.name,
      'Alice shelf',
    );

    final profileCalls = harness.profiles.getUserCalls;
    final savedCalls = harness.savedItems.listCalls;
    final collectionCalls = harness.collections.listCalls;

    // The harness restores a pair without writing one to the store, so there is
    // no refresh token. `SessionController` treats that as terminal: it clears,
    // discards, and the boundary sees `signedOut`.
    await expectLater(
      harness.container
          .read(sessionControllerProvider.notifier)
          .refreshAccessToken(),
      throwsA(isA<SessionExpiredException>()),
    );
    expect(harness.container.read(authStateProvider), AuthStatus.signedOut);

    expect(harness.container.read(profileProvider), isA<AsyncLoading>());
    expect(harness.container.read(savedItemsProvider), isA<AsyncLoading>());
    expect(harness.container.read(collectionsProvider), isA<AsyncLoading>());
    expect(harness.profiles.getUserCalls, profileCalls);
    expect(harness.savedItems.listCalls, savedCalls);
    expect(harness.collections.listCalls, collectionCalls);

    harness.profiles.profile = _bProfile;
    harness.savedItems.onList = (_) async =>
        _savedPage(_item('saved-b', 'Bob shelf'));
    harness.collections.onList = (call, sort, cursor) async =>
        _collectionPage(_collection('Bob shelf'));

    _signIn(harness);

    expect(
      (await harness.container.read(profileProvider.future)).id,
      'account-b',
    );
    expect(
      (await harness.container.read(savedItemsProvider.future)).items.single.id,
      'saved-b',
    );
    expect(
      (await harness.container.read(
        collectionsProvider.future,
      )).items.single.name,
      'Bob shelf',
    );
  });

  test('token rotation keeps user data and does not refetch', () async {
    final harness = _makeHarness(restored: _aTokens, profile: _aProfile);
    final adapter = FakeHttpAdapter()
      ..on(
        '/auth/refresh',
        body: {
          'data': {'access_token': 'access-a2', 'refresh_token': 'refresh-a2'},
          'message': 'session refreshed',
        },
      );
    harness.container.read(refreshDioProvider).httpClientAdapter = adapter;

    await harness.credentials.write(_aTokens);
    await harness.container.read(profileProvider.future);
    final calls = harness.profiles.getUserCalls;

    final access = await harness.container
        .read(sessionControllerProvider.notifier)
        .refreshAccessToken();

    expect(access, 'access-a2');
    expect(harness.container.read(authStateProvider), AuthStatus.signedIn);
    expect(
      harness.container.read(profileProvider).value!.id,
      'account-a',
      reason: 'a rotation is not an account change',
    );
    expect(
      harness.profiles.getUserCalls,
      calls,
      reason: 'the boundary must not invalidate on a token rotation',
    );
    expect(adapter.countFor('/auth/refresh'), 1);
  });

  test('the Inbox and Collections do not expose A while B loads', () async {
    final harness = _makeHarness(
      restored: _aTokens,
      profile: _aProfile,
      listPage: _savedPage(_item('saved-a', 'Alice shelf')),
      collectionPage: _collectionPage(_collection('Alice shelf')),
    );

    await harness.container.read(savedItemsProvider.future);
    await harness.container.read(collectionsProvider.future);

    expect(
      harness.container
          .read(savedItemsProvider)
          .value!
          .items
          .single
          .collectionName,
      'Alice shelf',
    );
    expect(
      harness.container.read(collectionsProvider).value!.items.single.name,
      'Alice shelf',
    );

    final savedCalls = harness.savedItems.listCalls;
    final collectionCalls = harness.collections.listCalls;

    _signOut(harness);

    expect(harness.container.read(savedItemsProvider), isA<AsyncLoading>());
    expect(harness.container.read(collectionsProvider), isA<AsyncLoading>());
    expect(harness.savedItems.listCalls, savedCalls);
    expect(harness.collections.listCalls, collectionCalls);

    final savedGate = Completer<void>();
    final collectionGate = Completer<void>();
    harness.savedItems.onList = (_) async {
      await savedGate.future;
      return _savedPage(_item('saved-b', 'Bob shelf'));
    };
    harness.collections.onList = (call, sort, cursor) async {
      await collectionGate.future;
      return _collectionPage(_collection('Bob shelf'));
    };

    _signIn(harness);

    final savedFuture = harness.container.read(savedItemsProvider.future);
    final collectionsFuture = harness.container.read(
      collectionsProvider.future,
    );

    expect(
      harness.container.read(savedItemsProvider),
      isA<AsyncLoading>(),
      reason: "A's rows must not be published as data while B is loading",
    );
    expect(
      harness.container.read(collectionsProvider),
      isA<AsyncLoading>(),
      reason:
          "A's collection names must not be published as data while B loads",
    );

    savedGate.complete();
    collectionGate.complete();

    final saved = await savedFuture;
    final collections = await collectionsFuture;

    expect(saved.items.map((item) => item.id), ['saved-b']);
    expect(saved.items.map((item) => item.collectionName), ['Bob shelf']);
    expect(collections.items.map((item) => item.name), ['Bob shelf']);
    expect(harness.savedItems.listCalls, savedCalls + 1);
    expect(harness.collections.listCalls, collectionCalls + 1);
  });

  test('explicit clears drop state without a request', () async {
    final harness = _makeHarness(
      restored: _aTokens,
      profile: _aProfile,
      listPage: _savedPage(_item('saved-a', 'Alice shelf')),
      collectionPage: _collectionPage(_collection('Alice shelf')),
    );

    await harness.container.read(profileProvider.future);
    await harness.container.read(savedItemsProvider.future);
    await harness.container.read(collectionsProvider.future);

    final profileCalls = harness.profiles.getUserCalls;
    final savedCalls = harness.savedItems.listCalls;
    final collectionCalls = harness.collections.listCalls;

    harness.container.read(profileProvider.notifier).clearForSessionChange();
    harness.container.read(savedItemsProvider.notifier).clearForSessionChange();
    harness.container
        .read(collectionsProvider.notifier)
        .clearForSessionChange();

    expect(harness.container.read(profileProvider), isA<AsyncLoading>());
    expect(harness.container.read(savedItemsProvider), isA<AsyncLoading>());
    expect(harness.container.read(collectionsProvider), isA<AsyncLoading>());
    expect(harness.container.read(profileProvider).isLoading, isTrue);
    expect(harness.container.read(savedItemsProvider).isLoading, isTrue);
    expect(harness.container.read(collectionsProvider).isLoading, isTrue);

    expect(harness.profiles.getUserCalls, profileCalls);
    expect(harness.savedItems.listCalls, savedCalls);
    expect(harness.collections.listCalls, collectionCalls);
  });
}
