import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_it_app/features/client_update/domain/client_update_release.dart';
import 'package:stash_it_app/features/client_update/domain/client_update_status.dart';
import 'package:stash_it_app/features/client_update/domain/release_download.dart';
import 'package:stash_it_app/features/client_update/presentation/client_update_screen.dart';
import 'package:stash_it_app/l10n/app_localizations.dart';

ClientUpdatePrompt _prompt({
  bool required = false,
  String? notes = '- Fixed things',
}) {
  return ClientUpdatePrompt(
    status: required
        ? ClientUpdateStatus.required
        : ClientUpdateStatus.optional,
    release: ClientUpdateRelease(
      version: '1.1.1',
      build: 3,
      downloadUrl: Uri.parse(
        'https://downloads.stashit.thoriqr.my.id/android/stash-it-1.1.1-3.apk',
      ),
      sha256: List.filled(64, 'a').join(),
      releaseNotes: notes,
      fileSizeBytes: 1000,
    ),
  );
}

Widget _app({
  required ClientUpdateDownloadState download,
  bool required = false,
  String platform = 'android',
  String? notes = '- Fixed things',
}) {
  return MaterialApp(
    locale: const Locale('en'),
    supportedLocales: const [Locale('en')],
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    home: ClientUpdateScreen(
      prompt: _prompt(required: required, notes: notes),
      download: download,
      platform: platform,
      onDownload: () {},
      onRetry: () {},
      onOpenAgain: () {},
      onLater: required ? null : () {},
      onBack: required ? null : () {},
      onExit: () {},
    ),
  );
}

void main() {
  testWidgets('an idle optional update offers download and later', (
    tester,
  ) async {
    await tester.pumpWidget(_app(download: const ClientUpdateDownloadState()));
    await tester.pump();

    expect(find.text('Download'), findsOneWidget);
    expect(find.text('Later'), findsOneWidget);
    expect(find.text('Try again'), findsNothing);
  });

  testWidgets('downloading shows a determinate progress row', (tester) async {
    await tester.pumpWidget(
      _app(
        download: const ClientUpdateDownloadState(
          stage: ClientUpdateDownloadStage.downloading,
          receivedBytes: 25,
          totalBytes: 100,
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Downloading…'), findsOneWidget);
    expect(find.text('25 B of 100 B'), findsOneWidget);
    expect(find.text('Later'), findsOneWidget);
    expect(find.text('Download'), findsNothing);
  });

  testWidgets('verifying shows its own status and no download action', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        download: const ClientUpdateDownloadState(
          stage: ClientUpdateDownloadStage.verifying,
          receivedBytes: 25,
          totalBytes: 100,
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Verifying…'), findsOneWidget);
    expect(find.text('Later'), findsOneWidget);
    expect(find.text('Download'), findsNothing);
  });

  testWidgets('a checksum failure offers retry and later', (tester) async {
    await tester.pumpWidget(
      _app(
        download: const ClientUpdateDownloadState(
          stage: ClientUpdateDownloadStage.failed,
          error: ClientUpdateDownloadError.checksumMismatch,
        ),
      ),
    );
    await tester.pump();

    expect(
      find.text('The downloaded file couldn\'t be verified. Try again.'),
      findsOneWidget,
    );
    expect(find.text('Try again'), findsOneWidget);
    expect(find.text('Later'), findsOneWidget);
  });

  testWidgets('a required installer failure keeps retry and exit', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        required: true,
        download: const ClientUpdateDownloadState(
          stage: ClientUpdateDownloadStage.failed,
          filePath: '/cache/app.apk',
          error: ClientUpdateDownloadError.installerFailed,
        ),
      ),
    );
    await tester.pump();

    expect(
      find.text('The installer couldn\'t be opened. Try again.'),
      findsOneWidget,
    );
    expect(find.text('Try again'), findsOneWidget);
    expect(find.text('Exit'), findsOneWidget);
    expect(find.text('Later'), findsNothing);
  });

  testWidgets('an install permission failure offers a specific retry', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        download: const ClientUpdateDownloadState(
          stage: ClientUpdateDownloadStage.failed,
          filePath: '/cache/app.apk',
          error: ClientUpdateDownloadError.installPermission,
        ),
      ),
    );
    await tester.pump();

    expect(
      find.text('Allow Stash-it to install apps, then try again.'),
      findsOneWidget,
    );
    expect(find.text('Try again'), findsOneWidget);
    expect(find.text('Later'), findsOneWidget);
  });

  testWidgets('an unsupported platform offers exit without retry', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        required: true,
        download: const ClientUpdateDownloadState(
          stage: ClientUpdateDownloadStage.failed,
          error: ClientUpdateDownloadError.unsupportedPlatform,
        ),
      ),
    );
    await tester.pump();

    expect(
      find.text('Updates are not supported on this device.'),
      findsOneWidget,
    );
    expect(find.text('Try again'), findsNothing);
    expect(find.text('Exit'), findsOneWidget);
  });

  testWidgets('Windows explains the ZIP handoff and can reopen it', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        platform: 'windows',
        download: const ClientUpdateDownloadState(
          stage: ClientUpdateDownloadStage.opened,
          filePath: r'C:\cache\app.zip',
        ),
      ),
    );
    await tester.pump();

    expect(
      find.text('The ZIP was opened. Extract it and run the app.'),
      findsOneWidget,
    );
    expect(find.text('Open again'), findsOneWidget);
    expect(find.text('Later'), findsOneWidget);
  });

  testWidgets('long release notes scroll while the actions stay pinned', (
    tester,
  ) async {
    final notes = List.generate(120, (index) => '- Note $index').join('\n');
    await tester.pumpWidget(
      _app(download: const ClientUpdateDownloadState(), notes: notes),
    );
    await tester.pump();

    expect(find.byType(SelectableText), findsOneWidget);
    expect(find.text('Download'), findsOneWidget);

    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -600),
    );
    await tester.pumpAndSettle();

    expect(find.text('Download'), findsOneWidget);
    expect(find.text('Later'), findsOneWidget);
  });
}
