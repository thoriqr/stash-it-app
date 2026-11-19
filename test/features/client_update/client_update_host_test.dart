import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:stash_it_app/features/client_update/application/client_update_controller.dart';
import 'package:stash_it_app/features/client_update/data/client_update_providers.dart';
import 'package:stash_it_app/features/client_update/data/datasources/client_release_api.dart';
import 'package:stash_it_app/features/client_update/presentation/client_update_host.dart';
import 'package:stash_it_app/features/settings/application/package_info_provider.dart';
import 'package:stash_it_app/l10n/app_localizations.dart';

import '../../support/fake_http.dart';

const _validUrl =
    'https://downloads.stashit.thoriqr.my.id/android/stash-it-1.0.0-1.apk';

Map<String, dynamic> _releaseBody({
  String status = 'optional',
  String? downloadUrl = _validUrl,
}) {
  return {
    'data': {
      'status': status,
      'latest': {
        'version': '1.1.0',
        'build': 2,
        'download_url': downloadUrl,
        'release_notes': '- Fixed things',
        'file_size_bytes': 48231001,
      },
    },
    'message': 'client release check completed successfully',
  };
}

Future<ProviderContainer> _pumpWith(
  WidgetTester tester,
  Map<String, dynamic> body,
) async {
  final adapter = FakeHttpAdapter();
  adapter.on('/client-releases/latest', body: body);

  final dio = Dio(
    BaseOptions(
      baseUrl: 'http://fake.test',
      contentType: Headers.jsonContentType,
    ),
  )..httpClientAdapter = adapter;

  final container = ProviderContainer(
    overrides: [
      packageInfoProvider.overrideWithValue(
        Future.value(
          PackageInfo(
            appName: 'Stash-it',
            packageName: 'id.my.thoriqr.stashit',
            version: '1.0.0',
            buildNumber: '1',
          ),
        ),
      ),
      clientPlatformProvider.overrideWithValue('android'),
      clientReleaseApiProvider.overrideWithValue(ClientReleaseApi(dio)),
    ],
  );
  addTearDown(container.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        locale: const Locale('en'),
        supportedLocales: const [Locale('en'), Locale('id')],
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: const Scaffold(body: Text('underlying screen')),
        // Match the app: the host sits above the Navigator, so the overlay is
        // outside the Navigator's own Overlay.
        builder: (context, child) =>
            ClientUpdateHost(child: child ?? const SizedBox.shrink()),
      ),
    ),
  );

  // The check performs a real (faked) HTTP round trip, so it must run outside
  // the widget test's fake async zone.
  await tester.runAsync(
    () => container.read(clientUpdateProvider.notifier).check(automatic: true),
  );
  await tester.pumpAndSettle();

  return container;
}

void main() {
  testWidgets('an optional update can be postponed', (tester) async {
    await _pumpWith(tester, _releaseBody());

    expect(find.text('Update available'), findsOneWidget);
    expect(find.text('Version 1.1.0'), findsOneWidget);
    expect(find.text('- Fixed things'), findsOneWidget);
    expect(find.text('Download size: 46 MB'), findsOneWidget);
    expect(find.text('Download'), findsOneWidget);

    await tester.tap(find.text('Later'));
    await tester.pumpAndSettle();

    expect(find.text('Update available'), findsNothing);
    expect(find.text('underlying screen'), findsOneWidget);
  });

  testWidgets('a required update only offers download and exit', (
    tester,
  ) async {
    await _pumpWith(tester, _releaseBody(status: 'required'));

    expect(find.text('Update required'), findsOneWidget);
    expect(find.text('Exit'), findsOneWidget);
    expect(find.text('Download'), findsOneWidget);
    expect(find.text('Later'), findsNothing);
  });

  testWidgets('a manifest with another download host shows no prompt', (
    tester,
  ) async {
    await _pumpWith(
      tester,
      _releaseBody(
        status: 'required',
        downloadUrl: 'https://evil.example/android/app.apk',
      ),
    );

    expect(find.text('Update required'), findsNothing);
    expect(find.text('underlying screen'), findsOneWidget);
  });
}
