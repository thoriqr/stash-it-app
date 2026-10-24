import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_it_app/features/profile/application/profile_controller.dart';
import 'package:stash_it_app/features/profile/data/profile_providers.dart';

import '../../../support/fake_profile_repository.dart';

void main() {
  ProviderContainer makeContainer(FakeProfileRepository fake) {
    return ProviderContainer.test(
      overrides: [profileRepositoryProvider.overrideWithValue(fake)],
      retry: (_, _) => null,
    );
  }

  test('a completion for another account changes nothing and refetches '
      'nothing', () async {
    final fake = FakeProfileRepository(
      profile: profileFixture(id: 'account-b', hasPasswordCredential: false),
    );
    final container = makeContainer(fake);
    await container.read(profileProvider.future);

    final applied = container
        .read(profileProvider.notifier)
        .markPasswordCredentialSet(accountId: 'account-a');

    expect(applied, isFalse);
    expect(container.read(profileProvider).value!.id, 'account-b');
    expect(
      container.read(profileProvider).value!.hasPasswordCredential,
      isFalse,
      reason: "account A's write must not claim a credential for account B",
    );
    expect(
      fake.getUserCalls,
      1,
      reason: "another account's completion must not invalidate B's profile",
    );
  });

  test(
    'a completion for the loaded account sets the credential flag',
    () async {
      final fake = FakeProfileRepository(
        profile: profileFixture(id: 'account-b', hasPasswordCredential: false),
      );
      final container = makeContainer(fake);
      await container.read(profileProvider.future);

      final applied = container
          .read(profileProvider.notifier)
          .markPasswordCredentialSet(accountId: 'account-b');

      expect(applied, isTrue);
      expect(
        container.read(profileProvider).value!.hasPasswordCredential,
        isTrue,
      );
      expect(fake.getUserCalls, 1);
    },
  );

  test('a completion while the profile is clearing is ignored', () async {
    final fake = FakeProfileRepository(
      profile: profileFixture(id: 'account-a', hasPasswordCredential: false),
    );
    final container = makeContainer(fake);
    await container.read(profileProvider.future);

    container.read(profileProvider.notifier).clearForSessionChange();
    expect(container.read(profileProvider), isA<AsyncLoading>());

    final applied = container
        .read(profileProvider.notifier)
        .markPasswordCredentialSet(accountId: 'account-a');

    expect(applied, isFalse);
    expect(
      container.read(profileProvider),
      isA<AsyncLoading>(),
      reason:
          "a loading state carries A's value inside it; that is not A's "
          'loaded profile',
    );
    expect(fake.getUserCalls, 1);
  });

  test('a rename completion while the profile is clearing refetches instead of '
      'publishing the old account', () async {
    final fake = FakeProfileRepository(
      profile: profileFixture(id: 'account-a', displayName: 'Alice'),
    );
    final container = makeContainer(fake);
    await container.read(profileProvider.future);

    // What the refetch this should trigger answers with.
    fake.profile = profileFixture(id: 'account-b', displayName: 'Bob');
    container.read(profileProvider.notifier).clearForSessionChange();
    container
        .read(profileProvider.notifier)
        .applyUpdatedProfile(
          profileFixture(id: 'account-a', displayName: 'Alice Renamed'),
        );

    expect(container.read(profileProvider), isA<AsyncLoading>());

    final profile = await container.read(profileProvider.future);
    expect(profile.id, 'account-b');
    expect(profile.displayName, 'Bob');
    expect(fake.getUserCalls, 2);
  });
}
