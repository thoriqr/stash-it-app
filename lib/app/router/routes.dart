/// The collection detail route a saved-item detail was pushed from.
///
/// **In-memory only.** It travels through `GoRouterState.extra`, never through the
/// location, because the detail route still names one item and nothing else. It
/// exists for one case: after the user deletes the collection the detail was
/// opened from, the detail must pop that collection route as well instead of
/// returning to a screen whose collection no longer exists.
final class SavedItemDetailOrigin {
  const SavedItemDetailOrigin.collection(this.collectionId);

  /// The collection whose contents screen pushed the item detail.
  final String collectionId;
}

/// Opens the password-reset request screen on the email form even when a
/// continuation is stored.
///
/// **In-memory only.** It travels through `GoRouterState.extra` and carries no
/// token. The finalization screen uses it to return to email selection without
/// clearing or exposing the saved continuation.
final class PasswordResetEmailSelection {
  const PasswordResetEmailSelection();
}

/// The Google ID token for a pending account-link confirmation.
///
/// **In-memory only.** It travels through `GoRouterState.extra`, never through
/// the location or a query parameter. The confirmation id is the path parameter;
/// this token is the proof of the Google identity that may complete it.
final class GoogleAccountLinkArgs {
  const GoogleAccountLinkArgs({required this.idToken});

  final String idToken;
}

/// The local Google hints for the existing registration PIN route.
///
/// Their presence identifies the route as a social registration. [email] scopes
/// the continuation record for recovery; [displayName] pre-fills the social
/// finalization form. Neither value is trusted as backend identity: only the
/// Google ID token submitted to the login route is.
final class SocialRegistrationVerification {
  const SocialRegistrationVerification({this.email, this.displayName});

  final String? email;
  final String? displayName;
}

/// The single-use continuation and display-name hint for social finalization.
///
/// **In-memory only.** The token is never in the location. The finalization
/// screen reads it from this route extra, exactly as the manual finalization
/// route does.
final class FinalizeSocialRegistrationArgs {
  const FinalizeSocialRegistrationArgs({
    required this.continuationToken,
    this.suggestedDisplayName,
  });

  final String continuationToken;
  final String? suggestedDisplayName;
}

/// Route definitions for the application.
///
/// All paths are declared here so navigation stays centralised, as required by
/// `AGENTS.md` §2. Adding a destination means adding a path here and a branch in
/// `app_router.dart` — not editing paths inline at call sites.
abstract final class AppRoutes {
  /// Recent saved items across collections (D26).
  static const String inbox = '/inbox';

  /// The collection browser (D26).
  static const String collections = '/collections';

  static const String search = '/search';

  static const String profile = '/profile';

  /// App-wide preferences.
  ///
  /// **Not a fifth destination.** Settings is a full-screen secondary route
  /// outside the shell, reached from each destination's app bar and popped back
  /// to the same retained branch.
  static const String settings = '/settings';

  /// The landing screen for a signed-out user.
  ///
  /// **Not a fifth destination.** D1 fixes four bottom-navigation destinations
  /// and this is not one of them: it sits outside the `StatefulShellRoute`
  /// entirely and has no navigation-bar entry. Signed-out users are allowed
  /// here and on [signIn]; every other location redirects here.
  static const String auth = '/auth';

  /// Manual sign-in.
  ///
  /// **Not a fifth destination.** D1 fixes four bottom-navigation destinations
  /// and this is not one of them: it sits outside the `StatefulShellRoute`
  /// entirely, has no navigation-bar entry, and is replaced by the shell once
  /// a session exists. Reached from [auth], and allowed as a direct entry while
  /// signed out so the entry screen's Sign in action cannot bounce back.
  static const String signIn = '/sign-in';

  /// Start of manual registration.
  ///
  /// **Not a fifth destination.** Like [signIn], it sits outside the shell, has
  /// no navigation-bar entry, and is reachable only while signed out. Reached
  /// from [auth], and allowed as a direct entry for the same reason: the entry
  /// screen's account-creation action navigates here.
  ///
  /// **Does not create a session.** The route covers only the first two of the
  /// eight registration steps — starting the registration and requesting its
  /// first emailed PIN — so a route that redirects on `signedIn` is not what
  /// makes it safe to revisit.
  static const String signUp = '/sign-up';

  /// Enter the PIN sent for a registration verification.
  ///
  /// Carries the server-issued verification id as a path parameter. Sits
  /// outside the shell like the other auth routes and is reachable only while
  /// signed out.
  static const String signUpVerify = '/sign-up/verify/:verificationId';

  /// The location of the PIN screen for [verificationId].
  ///
  /// A helper rather than string interpolation at the call site, so the route
  /// shape has one owner. The id is URL-encoded defensively; backend ids are
  /// UUIDs, which contain no characters that encoding changes.
  static String signUpVerifyFor(String verificationId) =>
      '/sign-up/verify/${Uri.encodeComponent(verificationId)}';

  /// Finalize a manual registration using a continuation token passed via route
  /// extra. Sits outside the shell and is reachable only while signed out.
  static const String finalizeRegistration = '/sign-up/finalize';

  /// Finalize a social registration using the continuation token from the
  /// existing registration PIN verification.
  ///
  /// Sits outside the shell, is signed-out only, and receives the single-use
  /// continuation token in route `extra` — never in the location.
  static const String finalizeSocialRegistration = '/sign-up/finalize/social';

  /// Confirm linking a Google identity to an existing Stash-it account.
  ///
  /// The confirmation id is the path parameter; the Google ID token that proves
  /// control of the identity travels in route `extra` only.
  static const String googleAccountLinkPattern =
      '/sign-in/google/account-link/:confirmationId';

  /// The location of the account-link confirmation for [confirmationId].
  static String googleAccountLinkFor(String confirmationId) =>
      '/sign-in/google/account-link/${Uri.encodeComponent(confirmationId)}';

  /// Start or resume a password reset.
  ///
  /// **Not a fifth destination.** Sits outside the shell, reachable only while
  /// signed out, and reached from the sign-in form's Forgot password action.
  ///
  /// If this device holds a saved reset continuation, the screen offers to
  /// continue it; otherwise it shows the email form. It never puts a token in
  /// the location.
  static const String forgotPassword = '/forgot-password';

  /// Enter the PIN sent for a password reset.
  ///
  /// The server-issued verification id is a path parameter; the email travels in
  /// route `extra` for local scoping. The continuation token is not in the route.
  static const String forgotPasswordVerify =
      '/forgot-password/verify/:verificationId';

  /// The location of the password-reset PIN screen for [verificationId].
  static String forgotPasswordVerifyFor(String verificationId) =>
      '/forgot-password/verify/${Uri.encodeComponent(verificationId)}';

  /// Choose and submit the new password.
  ///
  /// The continuation token is read from secure storage, never from the route or
  /// query. A direct entry without a stored reset shows the no-reset state.
  static const String forgotPasswordFinalize = '/forgot-password/finalize';

  /// Create or change the account's password.
  ///
  /// **Not a fifth destination.** A full-screen secondary route outside the
  /// shell, pushed from the Profile destination and popped back to it. The route
  /// reads the loaded profile to decide which form to show; a direct entry with
  /// nothing beneath it falls back to [profile] on Back.
  ///
  /// **Two segments under `/profile`**, so it cannot shadow the Profile branch:
  /// that branch matches `/profile` exactly.
  static const String password = '/profile/password';

  /// One saved item's detail screen (S10).
  ///
  /// **Not a fifth destination.** D1 fixes four bottom-navigation destinations;
  /// this is a full-screen secondary route outside the shell, reached by pushing
  /// from a row. Returning pops back to the destination that opened it with its
  /// retained branch state. A direct entry with nothing beneath it falls back to
  /// [inbox].
  ///
  /// The `:id` segment is the saved item's backend-issued UUID.
  static const String savedItemDetailPattern = '/saved-items/:id';

  /// The location of the detail screen for [id].
  ///
  /// A helper rather than string interpolation at the call site, so the route
  /// shape has one owner. The id is URL-encoded defensively; backend ids are
  /// UUIDs, which contain no characters that encoding changes.
  static String savedItemDetail(String id) =>
      '/saved-items/${Uri.encodeComponent(id)}';

  /// One collection's saved items (the collection detail screen).
  ///
  /// **Not a fifth destination.** D1 fixes four bottom-navigation destinations;
  /// this is a full-screen secondary route outside the shell, reached by pushing
  /// from a collection tile. Returning pops back to the Collections destination
  /// with its retained branch state — its sort choice and scroll position. A
  /// direct entry with nothing beneath it falls back to [collections].
  ///
  /// **Two segments, so it cannot shadow the Collections branch.** [collections]
  /// matches `/collections` exactly; `/collections/:id` is one segment longer, so
  /// the two never compete.
  ///
  /// The `:id` segment is the collection's backend-issued UUID.
  static const String collectionDetailPattern = '/collections/:id';

  /// The location of the detail screen for the collection named [id].
  ///
  /// A helper rather than string interpolation at the call site, so the route
  /// shape has one owner. The id is URL-encoded defensively; backend ids are
  /// UUIDs, which contain no characters that encoding changes.
  static String collectionDetail(String id) =>
      '/collections/${Uri.encodeComponent(id)}';

  /// The destination the app opens on. The core loop is share → save → Inbox,
  /// so the Inbox is the entry point.
  static const String initial = inbox;
}
