import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_it_app/features/pending_urls/application/shared_url_intake.dart';
import 'package:stash_it_app/features/pending_urls/presentation/share_intake_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel(shareIntakeChannelName);
  const codec = StandardMethodCodec();

  tearDown(() => channel.setMethodCallHandler(null));

  Future<Object?> invokeNative(String method, Object? arguments) async {
    final reply = Completer<ByteData?>();
    await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .handlePlatformMessage(
          shareIntakeChannelName,
          codec.encodeMethodCall(MethodCall(method, arguments)),
          reply.complete,
        );
    return reply.future.then((data) => codec.decodeEnvelope(data!));
  }

  test('handleShare forwards the note from the card payload', () async {
    String? seenText;
    String? seenNote;
    bindShareIntakeChannel(channel, (text, {note}) async {
      seenText = text;
      seenNote = note;
      return ShareSaveOutcome.saved;
    }, messageFor: (_) => 'Saved.');

    final result = await invokeNative('handleShare', {
      'text': 'https://example.com/reel/1',
      'note': 'Watch later',
    });

    expect(seenText, 'https://example.com/reel/1');
    expect(seenNote, 'Watch later');
    expect((result as Map<Object?, Object?>)['outcome'], 'saved');
  });

  test('handleShare still accepts a plain string payload', () async {
    String? seenText;
    String? seenNote;
    bindShareIntakeChannel(channel, (text, {note}) async {
      seenText = text;
      seenNote = note;
      return ShareSaveOutcome.invalid;
    }, messageFor: (_) => 'Not a link.');

    await invokeNative('handleShare', 'just text');

    expect(seenText, 'just text');
    expect(seenNote, isNull);
  });

  test('a missing note is passed as null', () async {
    String? seenNote = 'sentinel';
    bindShareIntakeChannel(channel, (text, {note}) async {
      seenNote = note;
      return ShareSaveOutcome.saved;
    }, messageFor: (_) => 'Saved.');

    await invokeNative('handleShare', {'text': 'https://example.com'});

    expect(seenNote, isNull);
  });
}
