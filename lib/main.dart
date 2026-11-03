import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stash_it_app/app/app.dart';
import 'package:stash_it_app/app/bootstrap.dart';
import 'package:stash_it_app/features/pending_urls/application/pending_urls_controller.dart';
import 'package:stash_it_app/features/pending_urls/application/shared_url_intake.dart';
import 'package:stash_it_app/features/pending_urls/presentation/share_intake_channel.dart';
import 'package:stash_it_app/features/pending_urls/presentation/share_intake_localization.dart';
import 'package:stash_it_app/features/settings/domain/language_preference.dart';

Future<void> main() async {
  // Complete startup initialization before the first frame. Bootstrap
  // initializes Flutter bindings and loads stored credentials so the router
  // can select the correct initial screen without showing an incorrect
  // destination first.
  final overrides = await bootstrap();

  runApp(ProviderScope(overrides: overrides, child: const StashItApp()));
}

/// Headless entrypoint for Android's transparent share activity.
///
/// This entrypoint does not call `runApp` or create a widget tree. The engine
/// exists only to process shared URLs through the same repository and
/// interceptors used by the main app.
///
/// The provider container is initialized lazily. If bootstrap or URL handling
/// fails, the native side receives a `notStored` outcome instead of waiting
/// indefinitely for its watchdog.
@pragma('vm:entry-point')
Future<void> shareIntakeMain() async {
  WidgetsFlutterBinding.ensureInitialized();

  ProviderContainer? container;
  const channel = MethodChannel(shareIntakeChannelName);

  Future<ShareSaveOutcome> handle(String raw) async {
    try {
      container ??= ProviderContainer(overrides: await bootstrap());
      return await container!.read(sharedUrlIntakeProvider).save(raw);
    } catch (_) {
      return ShareSaveOutcome.notStored;
    }
  }

  String messageFor(ShareSaveOutcome outcome) {
    final current = container;
    final localizations = current == null
        ? shareIntakeLocalizations(LanguagePreference.system)
        : shareIntakeLocalizationsForContainer(current);
    return shareOutcomeMessage(outcome, localizations);
  }

  bindShareIntakeChannel(
    channel,
    handle,
    messageFor: messageFor,
    onOutcome: (outcome) {
      // Refresh the pending URL state only when the outcome indicates that
      // the store was touched and the container is still available.
      if (container == null || !outcome.touchedStore) return;
      container!.invalidate(pendingUrlsProvider);
    },
    onShutdown: () {
      container?.dispose();
      container = null;
    },
  );

  // Signal readiness only after the channel handler has been registered.
  // The native side waits for this signal before sending the shared text.
  await channel.invokeMethod('ready');
}
