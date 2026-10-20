import '../domain/user_profile.dart';
import 'models/user_profile_response.dart';

UserIdentity identityFrom(UserIdentityResponse dto) {
  return UserIdentity(
    provider: dto.provider,
    // Null, never `DateTime.now()`: an unreadable timestamp must be omitted,
    // not presented as the day the profile happened to be opened.
    linkedAt: DateTime.tryParse(dto.linkedAt),
    emailSnapshot: dto.emailSnapshot,
    displayNameSnapshot: dto.displayNameSnapshot,
  );
}

UserProfile profileFrom(UserResponse dto) {
  return UserProfile(
    id: dto.id,
    email: dto.email,
    displayName: dto.displayName,
    hasPasswordCredential: dto.hasPasswordCredential,
    // See `identityFrom`. The domain keeps the failure as null so the UI can
    // omit the date without inventing one.
    createdAt: DateTime.tryParse(dto.createdAt),
    identities: dto.identities.map(identityFrom).toList(growable: false),
  );
}
