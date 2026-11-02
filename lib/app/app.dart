import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:stash_it_app/app/feedback/feedback_host.dart';
import 'package:stash_it_app/app/localization/locale_resolution.dart';
import 'package:stash_it_app/app/router/app_router.dart';
import 'package:stash_it_app/app/session/session_boundary.dart';
import 'package:stash_it_app/app/theme/app_theme.dart';
import 'package:stash_it_app/features/pending_urls/application/pending_urls_controller.dart';
import 'package:stash_it_app/features/pending_urls/application/save_pending_urls_controller.dart';
import 'package:stash_it_app/features/pending_urls/application/shared_url_intake.dart';
import 'package:stash_it_app/features/pending_urls/presentation/share_intake_channel.dart';
import 'package:stash_it_app/features/saved_items/application/saved_items_controller.dart';
import 'package:stash_it_app/features/settings/application/language_preference_controller.dart';
import 'package:stash_it_app/features/settings/application/theme_mode_controller.dart';
import 'package:stash_it_app/l10n/app_localizations.dart';

/// Root application widget.
///
/// Stateful because it owns two app-lifetime responsibilities:
/// - The live Android share channel, which reuses the current session
///   controller when a shared URL arrives while the app is running.
/// - Refreshing the device-local URL list when the app resumes, so changes
///   made while backgrounded and expired entries are reflected in the UI.
class StashItApp extends ConsumerStatefulWidget {
  const StashItApp({super.key, this.router});

  /// Optional router override, primarily for tests that need isolated
  /// navigation state or want to bypass authentication redirects.
  ///
  /// When omitted, the router is obtained from [appRouterProvider].
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

    // Handles shares in the live UI engine. Reusing its session controller
    // keeps token renewal under the same serialized session flow.
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
      // Refresh the local list after background activity, including shares
      // handled by the headless engine. Reading the store also enforces expiry.
      //
      // Do not invalidate during a bulk save: that operation reconciles its
      // current list as entries are confirmed. An invalidation could replace
      // that snapshot with a read taken before those removals.
      ref.invalidate(pendingUrlsProvider);
    }
  }

  void _afterShare(ShareSaveOutcome outcome) {
    if (!mounted) return;
    if (outcome.touchedStore) ref.invalidate(pendingUrlsProvider);

    if (outcome == ShareSaveOutcome.saved) {
      // Refresh the Inbox head independently. This is best-effort and cannot
      // turn a confirmed save into an error.
      unawaited(ref.read(savedItemsProvider.notifier).refreshHead());
    }
  }

  @override
  Widget build(BuildContext context) {
    // Keep the session-boundary listener alive for the lifetime of the app.
    // It clears account-scoped caches but leaves device-local URLs untouched.
    ref.watch(sessionBoundaryProvider);

    // Root-level subscriptions ensure theme and language changes are applied
    // across all routes without recreating the router or losing navigation state.
    final themeMode = ref.watch(themeModeControllerProvider);

    final languageLocale = ref
        .watch(languagePreferenceControllerProvider)
        .locale;

    return MaterialApp.router(
      title: 'Stash-it',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      locale: languageLocale,
      supportedLocales: supportedAppLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      // An explicit language choice takes precedence over the device locale.
      // Only System default follows the full ordered device locale list, rather
      // than relying on the single platform locale supplied to the callback.
      localeResolutionCallback: (locale, supported) {
        if (languageLocale != null) {
          return resolveAppLocale([languageLocale], supported);
        }
        return resolveAppLocale(
          WidgetsBinding.instance.platformDispatcher.locales,
          supported,
        );
      },
      // Place shared presentation above the router so every route uses the
      // same skeleton configuration and feedback host.
      //
      // FeedbackHost wraps SkeletonizerConfig so notices remain above routed
      // content, including authentication screens and the navigation bar.
      builder: (context, child) => FeedbackHost(
        child: SkeletonizerConfig(
          data: appSkeletonizerConfig(
            Theme.of(context).brightness,
            reducedMotion: MediaQuery.disableAnimationsOf(context),
          ),
          child: child ?? const SizedBox.shrink(),
        ),
      ),
      // Watch the provider so the router and its authentication refresh
      // listener remain alive for the lifetime of the application.
      routerConfig: widget.router ?? ref.watch(appRouterProvider),
    );
  }
}
