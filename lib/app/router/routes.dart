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

  /// Finalize a manual registration using a continuation token passed via route
  /// extra. Sits outside the shell and is reachable only while signed out.
  static const String finalizeRegistration = '/sign-up/finalize';

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
