import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:stash_it_app/app/router/app_router.dart';
import 'package:stash_it_app/app/theme/app_theme.dart';

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
    return MaterialApp.router(
      title: 'Stash It',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      // Inside the builder, not around the MaterialApp: below it the app has a
      // `Theme` and a `MediaQuery` to read, and above the router so every route
      // inherits one treatment. See `skeleton_theme.dart`.
      builder: (context, child) => SkeletonizerConfig(
        data: appSkeletonizerConfig(
          Theme.of(context).brightness,
          reducedMotion: MediaQuery.disableAnimationsOf(context),
        ),
        child: child ?? const SizedBox.shrink(),
      ),
      // Watched rather than read: the router owns a listener on the auth state,
      // and `refreshListenable` needs that listener registered for the whole life
      // of the app. Watching keeps this widget subscribed so the notifier is
      // created and stays alive.
      routerConfig: router ?? ref.watch(appRouterProvider),
    );
  }
}
