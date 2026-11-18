import 'package:flutter/services.dart';
import 'package:stash_it_app/features/pending_urls/application/shared_url_intake.dart';

/// The platform channel used by both the live UI engine and the headless share
/// engine.
const String shareIntakeChannelName = 'stash_it/share_intake';

/// Handles one share and returns the typed outcome.
///
/// [rawText] is the shared text. [note] is optional user text from the native
/// share card.
typedef ShareIntakeHandler =
    Future<ShareSaveOutcome> Function(String rawText, {String? note});

/// Resolves the localized message for an outcome.
typedef ShareIntakeMessageResolver = String Function(ShareSaveOutcome outcome);

/// Binds the share-intake protocol to [channel].
///
/// The live app and the headless entrypoint use the same three methods, so the
/// native side cannot drift between the two engines:
///
/// - `ping` answers `true` once the Dart handler is installed;
/// - `handleShare` runs [handle] and returns the outcome and message;
/// - `shutdown` lets the headless host dispose its container before the engine
///   is torn down.
void bindShareIntakeChannel(
  MethodChannel channel,
  ShareIntakeHandler handle, {
  required ShareIntakeMessageResolver messageFor,
  void Function(ShareSaveOutcome outcome)? onOutcome,
  void Function()? onShutdown,
}) {
  channel.setMethodCallHandler((call) async {
    switch (call.method) {
      case 'ping':
        return true;

      case 'handleShare':
        // The native share card sends `{text, note}`. A plain string is still
        // accepted so a host that predates the card cannot break the channel.
        final arguments = call.arguments;

        var raw = '';
        String? note;
        if (arguments is String) {
          raw = arguments;
        } else if (arguments is Map<Object?, Object?>) {
          final text = arguments['text'];
          if (text is String) raw = text;

          final value = arguments['note'];
          if (value is String) note = value;
        }

        final outcome = await handle(raw, note: note);
        onOutcome?.call(outcome);
        return outcome.toChannelMap(messageFor(outcome));

      case 'shutdown':
        onShutdown?.call();
        return true;

      default:
        return null;
    }
  });
}
