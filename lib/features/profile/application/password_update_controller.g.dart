// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'password_update_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// One `PUT /users/me/password` per explicit submission.
///
/// **The mode is captured by the screen for the whole visit and passed in.** This
/// controller does not read the profile to decide whether to send a current
/// password: the form the user is looking at is the form the request must match,
/// and re-deriving the mode mid-visit could send a body the visible form never
/// showed. The server remains authoritative and answers a mismatch with one of
/// the mode-conflict codes.
///
/// **No optimistic update.** `has_password_credential` is set only after a
/// confirmed `200`. An ambiguous outcome refetches the profile instead of assuming
/// either result, and no copy claims the password is unchanged when the client
/// cannot know.
///
/// **The caller's session is preserved by a change and no sign-out follows a
/// success.** The backend revokes the account's other sessions; already-issued
/// access tokens remain usable until their own expiry, which the change-mode note
/// states.

@ProviderFor(PasswordUpdate)
final passwordUpdateProvider = PasswordUpdateProvider._();

/// One `PUT /users/me/password` per explicit submission.
///
/// **The mode is captured by the screen for the whole visit and passed in.** This
/// controller does not read the profile to decide whether to send a current
/// password: the form the user is looking at is the form the request must match,
/// and re-deriving the mode mid-visit could send a body the visible form never
/// showed. The server remains authoritative and answers a mismatch with one of
/// the mode-conflict codes.
///
/// **No optimistic update.** `has_password_credential` is set only after a
/// confirmed `200`. An ambiguous outcome refetches the profile instead of assuming
/// either result, and no copy claims the password is unchanged when the client
/// cannot know.
///
/// **The caller's session is preserved by a change and no sign-out follows a
/// success.** The backend revokes the account's other sessions; already-issued
/// access tokens remain usable until their own expiry, which the change-mode note
/// states.
final class PasswordUpdateProvider
    extends $NotifierProvider<PasswordUpdate, bool> {
  /// One `PUT /users/me/password` per explicit submission.
  ///
  /// **The mode is captured by the screen for the whole visit and passed in.** This
  /// controller does not read the profile to decide whether to send a current
  /// password: the form the user is looking at is the form the request must match,
  /// and re-deriving the mode mid-visit could send a body the visible form never
  /// showed. The server remains authoritative and answers a mismatch with one of
  /// the mode-conflict codes.
  ///
  /// **No optimistic update.** `has_password_credential` is set only after a
  /// confirmed `200`. An ambiguous outcome refetches the profile instead of assuming
  /// either result, and no copy claims the password is unchanged when the client
  /// cannot know.
  ///
  /// **The caller's session is preserved by a change and no sign-out follows a
  /// success.** The backend revokes the account's other sessions; already-issued
  /// access tokens remain usable until their own expiry, which the change-mode note
  /// states.
  PasswordUpdateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'passwordUpdateProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$passwordUpdateHash();

  @$internal
  @override
  PasswordUpdate create() => PasswordUpdate();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$passwordUpdateHash() => r'39e8e72fd0fd50995839eae87aaa6b78d84b3e36';

/// One `PUT /users/me/password` per explicit submission.
///
/// **The mode is captured by the screen for the whole visit and passed in.** This
/// controller does not read the profile to decide whether to send a current
/// password: the form the user is looking at is the form the request must match,
/// and re-deriving the mode mid-visit could send a body the visible form never
/// showed. The server remains authoritative and answers a mismatch with one of
/// the mode-conflict codes.
///
/// **No optimistic update.** `has_password_credential` is set only after a
/// confirmed `200`. An ambiguous outcome refetches the profile instead of assuming
/// either result, and no copy claims the password is unchanged when the client
/// cannot know.
///
/// **The caller's session is preserved by a change and no sign-out follows a
/// success.** The backend revokes the account's other sessions; already-issued
/// access tokens remain usable until their own expiry, which the change-mode note
/// states.

abstract class _$PasswordUpdate extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
