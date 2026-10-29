import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:stash_it_app/app/feedback/feedback_host.dart';
import 'package:stash_it_app/app/router/app_router.dart';
import 'package:stash_it_app/app/session/session_boundary.dart';
import 'package:stash_it_app/app/theme/app_theme.dart';
import 'package:stash_it_app/features/pending_urls/application/pending_urls_controller.dart';
import 'package:stash_it_app/features/pending_urls/application/save_pending_urls_controller.dart';
import 'package:stash_it_app/features/pending_urls/application/shared_url_intake.dart';
import 'package:stash_it_app/features/pending_urls/presentation/share_intake_channel.dart';
import 'package:stash_it_app/features/saved_items/application/saved_items_controller.dart';
import 'package:stash_it_app/features/settings/application/theme_mode_controller.dart';

/// The application widget.
///
/// Stateful for two app-lifetime concerns that must outlive every route:
///
/// - the live engine's side of the Android share channel, so a share handled
///   while the app is already open uses the existing session controller and its
///   serialized refresh; and
/// - a resume-time invalidation of the device-local URL list, so entries
///   created or expired while the app was backgrounded are visible when the
///   user returns.
class StashItApp extends ConsumerStatefulWidget {
  const StashItApp({super.key, this.router});

  /// The router to use. Defaults to the one from [appRouterProvider].
  ///
  /// Overridable so a test can pass a router that carries no navigation history
  /// from a previous test, and so a test can bypass the auth redirect entirely
  /// when it is testing something else.
  final GoRouter? router;

  @override
  ConsumerState<StashItApp> createState() => _StashItAppState();
}

class _StashItAppState extends ConsumerState<StashItApp>
    with WidgetsBindingObserver {
  static const MethodChannel _shareChannel = MethodChannel(
    shareIntakeChannelName,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // This handler exists only in the UI engine. If the app is alive, the
    // transparent ShareActivity invokes it instead of starting a second engine,
    // so the live SessionController remains the only owner of token renewal.
    bindShareIntakeChannel(
      _shareChannel,
      (raw) => ref.read(sharedUrlIntakeProvider).save(raw),
      onOutcome: _afterShare,
    );
  }

  @override
  void dispose() {
    _shareChannel.setMethodCallHandler(null);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        !ref.read(savePendingUrlsProvider).isRunning) {
      // Local data can change while the app is backgrounded (a share handled by
      // the headless path), and seven-day expiry is enforced on read. Rebuild
      // the list once on return; the Inbox listing keeps its own refresh rules.
      //
      // A bulk save reconciles the list in place as each entry is confirmed.
      // Invalidating during one could replace the run's current snapshot with a
      // pre-removal read, so the run owns the list until it finishes.
      ref.invalidate(pendingUrlsProvider);
    }
  }

  void _afterShare(ShareSaveOutcome outcome) {
    if (!mounted) return;
    if (outcome.touchedStore) ref.invalidate(pendingUrlsProvider);

    if (outcome == ShareSaveOutcome.saved) {
      // Same best-effort head refresh the Inbox's own save uses. It never
      // throws, so a refresh failure cannot turn a confirmed save into an error.
      unawaited(ref.read(savedItemsProvider.notifier).refreshHead());
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watched at the app root so the listener that clears user-scoped caches on
    // an account change lives for as long as the app does. It holds no value;
    // watching it is how it is kept alive. The device-local URL list is not one
    // of the caches it clears.
    ref.watch(sessionBoundaryProvider);

    // Watched at the app root so a selection repaints every route immediately.
    // The router is watched too, but its provider value does not change here:
    // only `themeMode` does, so navigation state is not rebuilt from scratch.
    final themeMode = ref.watch(themeModeControllerProvider);

    return MaterialApp.router(
      title: 'Stash-it',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      // Inside the builder, not around the MaterialApp: below it the app has a
      // `Theme` and a `MediaQuery` to read, and above the router so every route
      // inherits one treatment. See `skeleton_theme.dart`.
      //
      // `FeedbackHost` is the outermost of the two, so one notice serves every
      // route — including the auth screens, which sit outside the shell — and
      // sits above the shell's navigation bar rather than inside a destination's
      // Scaffold.
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
      routerConfig: widget.router ?? ref.watch(appRouterProvider),
    );
  }
}
