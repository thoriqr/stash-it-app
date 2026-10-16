import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stash_it_app/app/router/app_router.dart';
import 'package:stash_it_app/app/theme/app_theme.dart';

/// The application widget.
class StashItApp extends StatelessWidget {
  const StashItApp({super.key, this.router});

  /// The router to use. Defaults to [appRouter].
  ///
  /// Overridable so a test can pass a router that carries no navigation history
  /// from a previous test.
  final GoRouter? router;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Stash It',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      routerConfig: router ?? appRouter,
    );
  }
}
