/// Identifies the collection detail route that opened a saved-item detail.
///
/// Passed through `GoRouterState.extra` rather than the route location because
/// it is navigation context, not part of the item's identity.
///
/// Used when the originating collection is deleted while its item detail is
/// open. The app can then return past the deleted collection instead of
/// navigating back to a screen that no longer exists.
final class SavedItemDetailOrigin {
  const SavedItemDetailOrigin.collection(this.collectionId);

  /// ID of the collection whose contents screen opened the item detail.
  final String collectionId;
}

/// Requests the password-reset screen to show the email form.
///
/// Passed through `GoRouterState.extra` without carrying a continuation token.
/// Allows the screen to return to email selection without clearing or exposing
/// an existing continuation stored on the device.
final class PasswordResetEmailSelection {
  const PasswordResetEmailSelection();
}

/// Carries the Google ID token required for account-link confirmation.
///
/// Passed through `GoRouterState.extra`, never through the route location or
/// query parameters. The confirmation ID identifies the pending link operation,
/// while the ID token proves control of the Google identity.
final class GoogleAccountLinkArgs {
  const GoogleAccountLinkArgs({required this.idToken});

  final String idToken;
}

/// Carries local information for social registration through the existing
/// registration verification route.
///
/// Its presence identifies the registration as a social flow. The email is
/// used to scope the continuation record, and the display name can prefill
/// the finalization form. Neither value establishes the user's identity;
/// that is verified using the Google ID token.
final class SocialRegistrationVerification {
  const SocialRegistrationVerification({this.email, this.displayName});

  final String? email;
  final String? displayName;
}

/// Carries the continuation token and optional display-name hint for social
/// registration finalization.
///
/// Passed through `GoRouterState.extra` rather than the route location so the
/// single-use continuation token is not exposed in navigation URLs.
final class FinalizeSocialRegistrationArgs {
  const FinalizeSocialRegistrationArgs({
    required this.continuationToken,
    this.suggestedDisplayName,
  });

  final String continuationToken;
  final String? suggestedDisplayName;
}

/// Centralized route definitions for the application.
///
/// Keeping route paths in one place avoids duplicating path strings across
/// navigation call sites.
abstract final class AppRoutes {
  /// Recent saved items across collections.
  static const String inbox = '/inbox';

  /// The collection browser.
  static const String collections = '/collections';

  static const String search = '/search';

  static const String profile = '/profile';

  /// App-wide preferences.
  ///
  /// A secondary route outside the main navigation shell. Returning from
  /// Settings restores the destination that opened it.
  static const String settings = '/settings';

  /// Landing screen for signed-out users.
  ///
  /// Outside the main navigation shell. Signed-out users can access this
  /// screen and the sign-in and registration routes.
  static const String auth = '/auth';

  /// Manual sign-in.
  ///
  /// Outside the main navigation shell and accessible while signed out.
  /// Allows direct navigation from the authentication entry screen.
  static const String signIn = '/sign-in';

  /// Start of manual registration.
  ///
  /// Outside the main navigation shell and accessible while signed out.
  ///
  /// Starting registration does not create an authenticated session. The user
  /// must complete the subsequent verification and finalization steps.
  static const String signUp = '/sign-up';

  /// Enter the PIN sent for registration verification.
  ///
  /// The verification ID is carried as a path parameter. This route is
  /// accessible while signed out.
  static const String signUpVerify = '/sign-up/verify/:verificationId';

  /// Builds the registration verification location for [verificationId].
  ///
  /// Centralizes the route format and encodes the parameter before inserting
  /// it into the path.
  static String signUpVerifyFor(String verificationId) =>
      '/sign-up/verify/${Uri.encodeComponent(verificationId)}';

  /// Finalize manual registration using a continuation token passed through
  /// route `extra`.
  ///
  /// Outside the main navigation shell and accessible while signed out.
  static const String finalizeRegistration = '/sign-up/finalize';

  /// Finalize social registration using the continuation token obtained
  /// during registration verification.
  ///
  /// The token is passed through route `extra`, never through the route
  /// location. This route is accessible while signed out.
  static const String finalizeSocialRegistration = '/sign-up/finalize/social';

  /// Confirm linking a Google identity to an existing Stash-it account.
  ///
  /// The confirmation ID is a path parameter. The Google ID token required
  /// to prove control of the identity is passed through route `extra`.
  static const String googleAccountLinkPattern =
      '/sign-in/google/account-link/:confirmationId';

  /// Builds the Google account-link confirmation location for
  /// [confirmationId].
  static String googleAccountLinkFor(String confirmationId) =>
      '/sign-in/google/account-link/${Uri.encodeComponent(confirmationId)}';

  /// Start or resume a password reset.
  ///
  /// Outside the main navigation shell and accessible while signed out.
  /// Reuses a saved reset continuation when one is available; otherwise,
  /// the screen presents the email form.
  ///
  /// Continuation tokens are never included in the route location.
  static const String forgotPassword = '/forgot-password';

  /// Enter the PIN sent for password reset verification.
  ///
  /// The verification ID is a path parameter. The email is passed through
  /// route `extra` for local scoping, while the continuation token is kept
  /// outside the route.
  static const String forgotPasswordVerify =
      '/forgot-password/verify/:verificationId';

  /// Builds the password-reset verification location for [verificationId].
  static String forgotPasswordVerifyFor(String verificationId) =>
      '/forgot-password/verify/${Uri.encodeComponent(verificationId)}';

  /// Choose and submit a new password.
  ///
  /// The continuation token is read from secure storage rather than from
  /// the route or query parameters. A direct entry without a saved reset
  /// continuation displays the appropriate no-reset state.
  static const String forgotPasswordFinalize = '/forgot-password/finalize';

  /// URLs kept on this device when a shared save could not be confirmed.
  ///
  /// A secondary route outside the main navigation shell, accessible from
  /// the authentication entry screen and Inbox.
  ///
  /// The screen reads device-local storage and remains available while signed
  /// out, including before an account has been created. Saving items requires
  /// an explicit user action.
  static const String savedOnDevice = '/saved-on-device';

  /// Create or change the account password.
  ///
  /// A secondary route outside the main navigation shell, opened from Profile.
  /// Returning restores the Profile destination and its navigation state.
  ///
  /// The screen uses the loaded profile to determine which form to display.
  /// When opened directly without a previous route, Back navigation returns
  /// to [profile].
  static const String password = '/profile/password';

  /// Detail screen for an individual saved item.
  ///
  /// A secondary route outside the main navigation shell, opened from an item
  /// row. Returning restores the destination that opened it.
  ///
  /// When opened directly without a previous route, Back navigation returns
  /// to [inbox].
  static const String savedItemDetailPattern = '/saved-items/:id';

  /// Builds the saved-item detail location for [id].
  ///
  /// Centralizes the route format and encodes the parameter before inserting
  /// it into the path.
  static String savedItemDetail(String id) =>
      '/saved-items/${Uri.encodeComponent(id)}';

  /// Detail screen showing the saved items inside one collection.
  ///
  /// A secondary route outside the main navigation shell, opened from a
  /// collection tile. Returning restores the Collections destination,
  /// including its sort choice and scroll position.
  ///
  /// When opened directly without a previous route, Back navigation returns
  /// to [collections].
  static const String collectionDetailPattern = '/collections/:id';

  /// Builds the collection detail location for [id].
  ///
  /// Centralizes the route format and encodes the parameter before inserting
  /// it into the path.
  static String collectionDetail(String id) =>
      '/collections/${Uri.encodeComponent(id)}';

  /// Initial destination when the application opens.
  ///
  /// The Inbox is the entry point for the primary save-and-organize workflow.
  static const String initial = inbox;
}
