import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:stash_it_app/app/feedback/feedback_host.dart';
import 'package:stash_it_app/app/router/app_router.dart';
import 'package:stash_it_app/app/session/session_boundary.dart';
import 'package:stash_it_app/app/theme/app_theme.dart';
import 'package:stash_it_app/features/settings/application/theme_mode_controller.dart';

/// The application widget.
class StashItApp extends ConsumerWidget {
  const StashItApp({super.key, this.router});

  /// The router to use. Defaults to the one from [appRouterProvider].
  ///
  /// Overridable so a test can pass a router that carries no navigation history
  /// from a previous test, and so a test can bypass the auth redirect entirely
  /// when it is testing something else.
  final GoRouter? router;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watched at the app root so the listener that clears user-scoped caches on
    // an account change lives for as long as the app does. It holds no value;
    // watching it is how it is kept alive.
    ref.watch(sessionBoundaryProvider);

    // Watched at the app root so a selection repaints every route immediately.
    // The router is watched too, but its provider value does not change here:
    // only `themeMode` does, so navigation state is not rebuilt from scratch.
    final themeMode = ref.watch(themeModeControllerProvider);

    return MaterialApp.router(
      title: 'Stash It',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      // Inside the builder, not around the MaterialApp: below it the app has a
      // `Theme` and a `MediaQuery` to read, and above the router so every route
      // inherits one treatment. See `skeleton_theme.dart`.
      //
      // `FeedbackHost` is the outermost of the two, so one notice serves every
      // route — including sign-in, which sits outside the shell — and sits above
      // the shell's navigation bar rather than inside a destination's Scaffold.
      // See `feedback/feedback_host.dart` for why that position is where it is.
      builder: (context, child) => FeedbackHost(
        child: SkeletonizerConfig(
          data: appSkeletonizerConfig(
            Theme.of(context).brightness,
            reducedMotion: MediaQuery.disableAnimationsOf(context),
          ),
          child: child ?? const SizedBox.shrink(),
        ),
      ),
      // Watched rather than read: the router owns a listener on the auth state,
      // and `refreshListenable` needs that listener registered for the whole life
      // of the app. Watching keeps this widget subscribed so the notifier is
      // created and stays alive.
      routerConfig: router ?? ref.watch(appRouterProvider),
    );
  }
}
