import '../domain/user_profile.dart';
import 'models/user_profile_response.dart';

UserIdentity identityFrom(UserIdentityResponse dto) {
  final linkedAt = DateTime.tryParse(dto.linkedAt) ?? DateTime.now();
  return UserIdentity(
    provider: dto.provider,
    linkedAt: linkedAt,
    emailSnapshot: dto.emailSnapshot,
    displayNameSnapshot: dto.displayNameSnapshot,
  );
}

UserProfile profileFrom(UserResponse dto) {
  final createdAt = DateTime.tryParse(dto.createdAt) ?? DateTime.now();
  return UserProfile(
    id: dto.id,
    email: dto.email,
    displayName: dto.displayName,
    hasPasswordCredential: dto.hasPasswordCredential,
    createdAt: createdAt,
    identities: dto.identities.map(identityFrom).toList(growable: false),
  );
}
