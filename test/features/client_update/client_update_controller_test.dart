import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:stash_it_app/app/feedback/app_feedback.dart';
import 'package:stash_it_app/app/feedback/feedback_controller.dart';
import 'package:stash_it_app/features/client_update/application/client_update_controller.dart';
import 'package:stash_it_app/features/client_update/data/client_update_providers.dart';
import 'package:stash_it_app/features/client_update/data/datasources/client_release_api.dart';
import 'package:stash_it_app/features/client_update/domain/client_update_status.dart';
import 'package:stash_it_app/features/settings/application/package_info_provider.dart';

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

({ProviderContainer container, FakeHttpAdapter adapter}) _setup({
  String buildNumber = '1',
}) {
  final adapter = FakeHttpAdapter();
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
            buildNumber: buildNumber,
          ),
        ),
      ),
      clientPlatformProvider.overrideWithValue('android'),
      clientReleaseApiProvider.overrideWithValue(ClientReleaseApi(dio)),
    ],
  );
  addTearDown(container.dispose);

  return (container: container, adapter: adapter);
}

void main() {
  group('ClientUpdate', () {
    test(
      'sends the platform and build and presents an optional update',
      () async {
        final (:container, :adapter) = _setup(buildNumber: '2');
        adapter.on('/client-releases/latest', body: _releaseBody());

        await container
            .read(clientUpdateProvider.notifier)
            .check(automatic: true);

        final request = adapter.lastRequestTo('/client-releases/latest');
        expect(request, isNotNull);
        expect(request!.path, contains('platform=android'));
        expect(request.path, contains('build=2'));

        final prompt = container.read(clientUpdateProvider).prompt;
        expect(prompt, isNotNull);
        expect(prompt!.status, ClientUpdateStatus.optional);
        expect(prompt.release.version, '1.1.0');
      },
    );

    test('presents a required update', () async {
      final (:container, :adapter) = _setup();
      adapter.on(
        '/client-releases/latest',
        body: _releaseBody(status: 'required'),
      );

      await container
          .read(clientUpdateProvider.notifier)
          .check(automatic: true);

      expect(container.read(clientUpdateProvider).prompt?.isRequired, isTrue);
    });

    test('does nothing when the build number cannot be parsed', () async {
      final (:container, :adapter) = _setup(buildNumber: 'not-a-number');

      await container
          .read(clientUpdateProvider.notifier)
          .check(automatic: true);

      expect(adapter.requests, isEmpty);
      expect(container.read(clientUpdateProvider).prompt, isNull);
    });

    test('does nothing when there is no update', () async {
      final (:container, :adapter) = _setup();
      adapter.on(
        '/client-releases/latest',
        body: _releaseBody(status: 'none', downloadUrl: null),
      );

      await container
          .read(clientUpdateProvider.notifier)
          .check(automatic: true);

      expect(container.read(clientUpdateProvider).prompt, isNull);
      expect(container.read(feedbackProvider), isNull);
    });

    test('an automatic failure stays silent', () async {
      final (:container, :adapter) = _setup();
      adapter.on(
        '/client-releases/latest',
        status: 500,
        body: errorBody('INTERNAL_SERVER_ERROR'),
      );

      await container
          .read(clientUpdateProvider.notifier)
          .check(automatic: true);

      expect(container.read(clientUpdateProvider).prompt, isNull);
      expect(container.read(feedbackProvider), isNull);
    });

    test('a manual failure publishes a short notice', () async {
      final (:container, :adapter) = _setup();
      adapter.on('/client-releases/latest', body: 'not json');

      await container
          .read(clientUpdateProvider.notifier)
          .check(automatic: false);

      final feedback = container.read(feedbackProvider);
      expect(feedback, isNotNull);
      expect(feedback!.tone, FeedbackTone.warning);
      expect(feedback.message, isNotNull);
    });

    test('a manual check with no update publishes a success notice', () async {
      final (:container, :adapter) = _setup();
      adapter.on(
        '/client-releases/latest',
        body: _releaseBody(status: 'none', downloadUrl: null),
      );

      await container
          .read(clientUpdateProvider.notifier)
          .check(automatic: false);

      expect(container.read(feedbackProvider)?.tone, FeedbackTone.success);
    });

    test(
      'an invalid download host produces no prompt, even when required',
      () async {
        final (:container, :adapter) = _setup();
        adapter.on(
          '/client-releases/latest',
          body: _releaseBody(
            status: 'required',
            downloadUrl: 'https://evil.example/android/app.apk',
          ),
        );

        await container
            .read(clientUpdateProvider.notifier)
            .check(automatic: true);

        expect(container.read(clientUpdateProvider).prompt, isNull);
      },
    );

    test('an unknown status produces no prompt', () async {
      final (:container, :adapter) = _setup();
      adapter.on(
        '/client-releases/latest',
        body: _releaseBody(status: 'mandatory-ish'),
      );

      await container
          .read(clientUpdateProvider.notifier)
          .check(automatic: true);

      expect(container.read(clientUpdateProvider).prompt, isNull);
    });

    test(
      'a postponed optional update stays hidden until a manual check',
      () async {
        final (:container, :adapter) = _setup();
        adapter.on('/client-releases/latest', body: _releaseBody());

        final controller = container.read(clientUpdateProvider.notifier);
        await controller.check(automatic: true);
        expect(container.read(clientUpdateProvider).prompt, isNotNull);

        controller.dismiss();
        expect(container.read(clientUpdateProvider).prompt, isNull);

        await controller.check(automatic: true);
        expect(container.read(clientUpdateProvider).prompt, isNull);

        await controller.check(automatic: false);
        expect(container.read(clientUpdateProvider).prompt, isNotNull);
      },
    );

    test('a required update cannot be dismissed', () async {
      final (:container, :adapter) = _setup();
      adapter.on(
        '/client-releases/latest',
        body: _releaseBody(status: 'required'),
      );

      final controller = container.read(clientUpdateProvider.notifier);
      await controller.check(automatic: true);

      controller.dismiss();

      expect(container.read(clientUpdateProvider).prompt, isNotNull);
    });
  });
}
