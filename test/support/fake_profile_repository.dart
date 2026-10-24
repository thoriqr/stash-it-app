import 'dart:async';

import 'package:dio/dio.dart';
import 'package:stash_it_app/features/profile/data/datasources/profile_api.dart';
import 'package:stash_it_app/features/profile/data/profile_repository.dart';
import 'package:stash_it_app/features/profile/domain/user_profile.dart';

/// A realistic profile with every wire field represented.
///
/// `createdAt` is null on purpose: the UI omits an unreadable date, and these
/// tests are about the profile write outcomes rather than date formatting.
UserProfile profileFixture({
  String id = 'user-1',
  String email = 'reader@example.com',
  String displayName = 'Reader',
  bool hasPasswordCredential = true,
  List<UserIdentity> identities = const [],
}) {
  return UserProfile(
    id: id,
    email: email,
    displayName: displayName,
    hasPasswordCredential: hasPasswordCredential,
    createdAt: null,
    identities: identities,
  );
}

/// A [ProfileRepository] with real success/refusal behaviour and no transport.
///
/// The concrete repository is extended rather than mocked so the controller
/// tests keep the repository's refusal handling out of the picture while still
/// exercising the repository contract the controllers depend on. The API field
/// exists only to satisfy the superclass constructor and is never called.
class FakeProfileRepository extends ProfileRepository {
  FakeProfileRepository({UserProfile? profile})
    : profile = profile ?? profileFixture(),
      super(api: ProfileApi(Dio()));

  /// What `GET /users/me` currently reports.
  UserProfile profile;

  /// A read failure, if any.
  Object? getUserFailure;

  /// Holds the profile read open, for the screen's loading state.
  Completer<void>? getUserGate;

  /// An optional handler for one profile read, receiving the 1-based call index.
  ///
  /// Used where a single [getUserGate] cannot express the case: two reads that
  /// must be released in a chosen order, or a different profile per call. When
  /// null, [profile], [getUserGate] and [getUserFailure] behave as before.
  Future<UserProfile> Function(int call)? onGetUser;

  /// What a rename should return. When null, the fake renames its own [profile].
  UserProfile? renameResult;

  /// A rename failure, if any.
  Object? renameFailure;

  /// A password failure, if any.
  Object? passwordFailure;

  /// Holds a rename open so a test can send a second one while the first is in
  /// flight.
  Completer<void>? renameGate;

  /// Holds a password write open for the same reason.
  Completer<void>? passwordGate;

  int getUserCalls = 0;
  int renameCalls = 0;
  int passwordCalls = 0;

  final List<String> renamedNames = [];
  final List<({String newPassword, String? currentPassword})>
  passwordSubmissions = [];

  @override
  Future<UserProfile> getUser() async {
    getUserCalls++;

    final handler = onGetUser;
    if (handler != null) return handler(getUserCalls);

    final gate = getUserGate;
    if (gate != null) await gate.future;
    final failure = getUserFailure;
    if (failure != null) throw failure;
    return profile;
  }

  @override
  Future<UserProfile> updateDisplayName(String displayName) async {
    renameCalls++;
    renamedNames.add(displayName);

    final gate = renameGate;
    if (gate != null) await gate.future;

    final failure = renameFailure;
    if (failure != null) throw failure;

    final result = renameResult ?? _renamed(profile, displayName);
    profile = result;
    return result;
  }

  @override
  Future<void> setPassword({
    required String newPassword,
    String? currentPassword,
  }) async {
    passwordCalls++;
    passwordSubmissions.add((
      newPassword: newPassword,
      currentPassword: currentPassword,
    ));

    final gate = passwordGate;
    if (gate != null) await gate.future;

    final failure = passwordFailure;
    if (failure != null) throw failure;

    profile = profile.withPasswordCredential(true);
  }

  UserProfile _renamed(UserProfile original, String displayName) {
    return UserProfile(
      id: original.id,
      email: original.email,
      displayName: displayName,
      hasPasswordCredential: original.hasPasswordCredential,
      createdAt: original.createdAt,
      identities: original.identities,
    );
  }
}
