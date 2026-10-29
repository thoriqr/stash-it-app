import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stash_it_app/app/app.dart';
import 'package:stash_it_app/app/bootstrap.dart';
import 'package:stash_it_app/features/pending_urls/application/pending_urls_controller.dart';
import 'package:stash_it_app/features/pending_urls/application/shared_url_intake.dart';
import 'package:stash_it_app/features/pending_urls/presentation/share_intake_channel.dart';

Future<void> main() async {
  // Startup is no longer synchronous. `bootstrap` initializes the binding —
  // required before any plugin channel is used, and `flutter_secure_storage` is
  // one — and reads stored credentials before the first frame, so the router can
  // choose between the app and the auth entry screen on its very first
  // navigation instead of showing the wrong one and correcting itself.
  final overrides = await bootstrap();

  runApp(ProviderScope(overrides: overrides, child: const StashItApp()));
}

/// The headless entrypoint used by Android's transparent share activity.
///
/// **No `runApp`, no widget tree, no visible UI.** The engine exists only long
/// enough to run one or more shared URLs through the same repository and
/// interceptor the app uses. The container is built lazily so a bootstrap
/// failure still produces a typed `notStored` outcome instead of hanging the
/// native side until its watchdog fires.
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

  bindShareIntakeChannel(
    channel,
    handle,
    onOutcome: (outcome) {
      if (container == null || !outcome.touchedStore) return;
      container!.invalidate(pendingUrlsProvider);
    },
    onShutdown: () {
      container?.dispose();
      container = null;
    },
  );

  // Tells the native side the handler is installed. It waits for this before
  // sending the shared text.
  await channel.invokeMethod('ready');
}
