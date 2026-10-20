import 'package:flutter/foundation.dart';

@immutable
class UserIdentity {
  const UserIdentity({
    required this.provider,
    required this.linkedAt,
    this.emailSnapshot,
    this.displayNameSnapshot,
  });

  final String provider;

  /// Null when the API sent a value this client could not parse.
  ///
  /// The UI omits the date rather than substituting one.
  final DateTime? linkedAt;

  final String? emailSnapshot;
  final String? displayNameSnapshot;

  String get displayLabel {
    switch (provider.toLowerCase()) {
      case 'google':
        return 'Google';
      case 'apple':
        return 'Apple';
      case 'github':
        return 'GitHub';
      case 'facebook':
        return 'Facebook';
      case 'twitter':
      case 'x':
        return 'X';
      case 'email':
      case 'password':
      case 'local':
      case 'credentials':
        return 'Email & password';
      default:
        // Capitalize first letter of unknown providers
        if (provider.isEmpty) return 'Unknown';
        return provider[0].toUpperCase() + provider.substring(1);
    }
  }

  @override
  bool operator ==(Object other) =>
      other is UserIdentity &&
      other.provider == provider &&
      other.linkedAt == linkedAt &&
      other.emailSnapshot == emailSnapshot &&
      other.displayNameSnapshot == displayNameSnapshot;

  @override
  int get hashCode =>
      Object.hash(provider, linkedAt, emailSnapshot, displayNameSnapshot);
}

@immutable
class UserProfile {
  const UserProfile({
    required this.id,
    required this.email,
    required this.displayName,
    required this.hasPasswordCredential,
    required this.createdAt,
    required this.identities,
  });

  final String id;
  final String email;
  final String displayName;
  final bool hasPasswordCredential;

  /// Null when the API sent a value this client could not parse.
  ///
  /// The UI omits the date rather than substituting one.
  final DateTime? createdAt;

  final List<UserIdentity> identities;

  @override
  bool operator ==(Object other) =>
      other is UserProfile &&
      other.id == id &&
      other.email == email &&
      other.displayName == displayName &&
      other.hasPasswordCredential == hasPasswordCredential &&
      other.createdAt == createdAt &&
      listEquals(other.identities, identities);

  @override
  int get hashCode => Object.hash(
    id,
    email,
    displayName,
    hasPasswordCredential,
    createdAt,
    Object.hashAll(identities),
  );
}
