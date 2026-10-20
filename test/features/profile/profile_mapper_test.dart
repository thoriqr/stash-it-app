import 'package:flutter_test/flutter_test.dart';
import 'package:stash_it_app/features/profile/data/profile_mapper.dart';
import 'package:stash_it_app/features/profile/data/models/user_profile_response.dart';

void main() {
  test('maps profile with identities', () {
    final dto = UserResponse(
      id: '123',
      email: 'test@example.com',
      displayName: 'Test User',
      hasPasswordCredential: true,
      createdAt: '2026-01-01T00:00:00Z',
      identities: [
        const UserIdentityResponse(
          provider: 'google',
          linkedAt: '2026-01-02T00:00:00Z',
          emailSnapshot: 'test@gmail.com',
          displayNameSnapshot: 'Test',
        ),
        const UserIdentityResponse(
          provider: 'email',
          linkedAt: '2026-01-03T00:00:00Z',
        ),
      ],
    );

    final profile = profileFrom(dto);
    expect(profile.email, 'test@example.com');
    expect(profile.displayName, 'Test User');
    expect(profile.hasPasswordCredential, true);
    expect(profile.createdAt, DateTime.utc(2026, 1, 1));
    expect(profile.identities.length, 2);
    expect(profile.identities[0].displayLabel, 'Google');
    expect(profile.identities[0].linkedAt, DateTime.utc(2026, 1, 2));
    expect(profile.identities[1].displayLabel, 'Email & password');
  });

  test('never substitutes a date for an unparseable timestamp', () {
    final profile = profileFrom(
      UserResponse(
        id: '123',
        email: 'test@example.com',
        displayName: 'Test User',
        hasPasswordCredential: false,
        createdAt: 'not-a-date',
        identities: const [
          UserIdentityResponse(provider: 'google', linkedAt: 'nope'),
        ],
      ),
    );

    expect(profile.createdAt, isNull);
    expect(profile.identities.single.linkedAt, isNull);
  });

  test('maps unknown provider to capitalized label', () {
    final identity = identityFrom(
      const UserIdentityResponse(
        provider: 'discord',
        linkedAt: '2026-01-01T00:00:00Z',
      ),
    );
    expect(identity.displayLabel, 'Discord');
  });

  test('handles empty provider gracefully', () {
    final identity = identityFrom(
      const UserIdentityResponse(
        provider: '',
        linkedAt: '2026-01-01T00:00:00Z',
      ),
    );
    expect(identity.displayLabel, 'Unknown');
  });
}
