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

  /// Manual sign-in.
  ///
  /// **Not a fifth destination.** D1 fixes four bottom-navigation destinations
  /// and this is not one of them: it sits outside the `StatefulShellRoute`
  /// entirely, has no navigation-bar entry, and is replaced by the shell once
  /// a session exists.
  static const String signIn = '/sign-in';

  /// The destination the app opens on. The core loop is share → save → Inbox,
  /// so the Inbox is the entry point.
  static const String initial = inbox;
}
