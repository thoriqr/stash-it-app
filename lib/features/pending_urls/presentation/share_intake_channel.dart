import 'package:flutter/services.dart';
import 'package:stash_it_app/features/pending_urls/application/shared_url_intake.dart';

/// The platform channel used by both the live UI engine and the headless share
/// engine.
const String shareIntakeChannelName = 'stash_it/share_intake';

/// Handles one raw share string and returns the typed outcome.
typedef ShareIntakeHandler = Future<ShareSaveOutcome> Function(String rawText);

/// Binds the share-intake protocol to [channel].
///
/// The live app and the headless entrypoint use the same three methods, so the
/// native side cannot drift between the two engines:
///
/// - `ping` answers `true` once the Dart handler is installed;
/// - `handleShare` runs [handle] and returns the outcome and Toast message;
/// - `shutdown` lets the headless host dispose its container before the engine
///   is torn down.
void bindShareIntakeChannel(
  MethodChannel channel,
  ShareIntakeHandler handle, {
  void Function(ShareSaveOutcome outcome)? onOutcome,
  void Function()? onShutdown,
}) {
  channel.setMethodCallHandler((call) async {
    switch (call.method) {
      case 'ping':
        return true;

      case 'handleShare':
        final raw = call.arguments is String ? call.arguments as String : '';
        final outcome = await handle(raw);
        onOutcome?.call(outcome);
        return outcome.toChannelMap();

      case 'shutdown':
        onShutdown?.call();
        return true;

      default:
        return null;
    }
  });
}
