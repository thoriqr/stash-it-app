import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_it_app/app/theme/app_theme.dart';
import 'package:stash_it_app/features/saved_items/domain/saved_item_summary.dart';
import 'package:stash_it_app/features/saved_items/presentation/widgets/saved_item_preview.dart';
import 'package:stash_it_app/features/saved_items/presentation/widgets/saved_item_skeleton.dart';

import '../../../support/fake_image_http.dart';

/// The preview well's state matrix, exercised through the widget every screen
/// uses.
///
/// The well is the one place that decides whether an item is pending, has no
/// image, is loading one, or failed to load one, so the Inbox, collection
/// contents, Search and the detail screen cannot disagree. These tests pin that
/// matrix down here rather than repeating it per screen.
///
/// Images go through a fake transport ([installFakeImageHttp]): `flutter_test`
/// blocks real HTTP, and a blocked request can only prove the failure path.
void main() {
  late FakeImageHttp images;

  setUpAll(() {
    // `NetworkImage` keeps its client in a `static final`, created on the first
    // load, so the override has to be in place before any test runs.
    images = installFakeImageHttp();
  });

  setUp(() {
    images.reset();
    PaintingBinding.instance.imageCache
      ..clear()
      ..clearLiveImages();
  });

  tearDown(() {
    PaintingBinding.instance.imageCache
      ..clear()
      ..clearLiveImages();
  });

  Widget host({
    String? imageUrl,
    EnrichmentStatus status = EnrichmentStatus.completed,
    ThemeData? theme,
    double width = AppMetrics.slotThumbSize,
    double height = AppMetrics.slotThumbSize,
  }) {
    return MaterialApp(
      theme: theme ?? AppTheme.light(),
      home: Scaffold(
        body: Center(
          child: SavedItemPreview(
            imageUrl: imageUrl,
            enrichmentStatus: status,
            width: width,
            height: height,
          ),
        ),
      ),
    );
  }

  /// Pumps [widget], then waits in real time until [done] holds.
  ///
  /// The image path leaves the fake clock twice — the transport and the engine
  /// decoder — so `pumpAndSettle` can return before either has finished. Each
  /// iteration yields to the real event loop and then pumps the frames the
  /// widget scheduled.
  Future<void> pumpUntil(
    WidgetTester tester,
    Widget widget,
    bool Function() done,
  ) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(widget);
      for (var attempt = 0; attempt < 200 && !done(); attempt++) {
        await Future<void>.delayed(const Duration(milliseconds: 5));
        await tester.pump();
      }
    });
    await tester.pump();
    expect(
      done(),
      isTrue,
      reason: 'the preview never reached the expected state',
    );
  }

  group('pending', () {
    testWidgets('shows the pending placeholder instead of an empty well', (
      tester,
    ) async {
      await tester.pumpWidget(host(status: EnrichmentStatus.pending));

      expect(
        find.byKey(SavedItemPreview.pendingPlaceholderKey),
        findsOneWidget,
      );
      expect(
        find.byKey(SavedItemPreview.unavailablePlaceholderKey),
        findsNothing,
      );
      // Static by design: a pending item can stay pending indefinitely, so the
      // placeholder must not promise progress.
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(LinearProgressIndicator), findsNothing);
    });

    testWidgets('prefers the placeholder over a URL and requests nothing', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          imageUrl: 'https://images.example.test/gallery/pending.png',
          status: EnrichmentStatus.pending,
        ),
      );

      expect(
        find.byKey(SavedItemPreview.pendingPlaceholderKey),
        findsOneWidget,
      );
      expect(find.byType(Image), findsNothing);
      expect(
        images.requestCount,
        0,
        reason: 'pending takes precedence over an anomalous URL',
      );
    });
  });

  group('unavailable', () {
    testWidgets('completed with a null URL shows the neutral well', (
      tester,
    ) async {
      await tester.pumpWidget(host());

      expect(
        find.byKey(SavedItemPreview.unavailablePlaceholderKey),
        findsOneWidget,
      );
      expect(find.byType(Image), findsNothing);
      expect(images.requestCount, 0);
    });

    testWidgets('failed with a null URL shows the same neutral well', (
      tester,
    ) async {
      await tester.pumpWidget(host(status: EnrichmentStatus.failed));

      expect(
        find.byKey(SavedItemPreview.unavailablePlaceholderKey),
        findsOneWidget,
      );
      expect(find.byType(Image), findsNothing);
    });

    for (final url in <String>[
      '',
      '   ',
      'not a url at all',
      '/relative/image.png',
      'image.png',
      'ftp://images.example.test/gallery/unsupported.png',
      'data:image/png;base64,iVBORw0KGgo=',
      'https://',
    ]) {
      testWidgets('an unusable URL is not loaded: "$url"', (tester) async {
        await tester.pumpWidget(host(imageUrl: url));

        expect(
          find.byKey(SavedItemPreview.unavailablePlaceholderKey),
          findsOneWidget,
        );
        expect(find.byType(Image), findsNothing);
        expect(
          images.requestCount,
          0,
          reason: 'an unusable value must not become a request',
        );
      });
    }
  });

  group('loaded', () {
    testWidgets('renders a network image and decodes it at the slot size', (
      tester,
    ) async {
      const url = 'https://images.example.test/gallery/loaded.png';

      await tester.pumpWidget(host(imageUrl: url));
      // Loading state first: the reserved frame is already in place.
      expect(tester.getSize(find.byType(SavedItemPreview)), const Size(56, 56));
      expect(find.byKey(SavedItemPreview.pendingPlaceholderKey), findsNothing);

      await pumpUntil(
        tester,
        host(imageUrl: url),
        () => tester.any(find.byType(RawImage)),
      );

      expect(images.requests.single.toString(), url);
      expect(
        find.byKey(SavedItemPreview.unavailablePlaceholderKey),
        findsNothing,
      );
      expect(find.byKey(SavedItemPreview.pendingPlaceholderKey), findsNothing);
      expect(
        tester.getSize(find.byType(SavedItemPreview)),
        const Size(56, 56),
        reason: 'the image must not change the reserved layout',
      );

      final image = tester.widget<Image>(find.byType(Image));
      expect(image.fit, BoxFit.cover);
      // `Image` reports its decode size through the provider it hands to the
      // image cache; there is no public `cacheWidth` getter on the widget.
      final resize = image.image as ResizeImage;
      expect(
        resize.width,
        (AppMetrics.slotThumbSize * tester.view.devicePixelRatio).round(),
        reason: 'a thumbnail decodes to its own pixels, not the source size',
      );
      expect(resize.height, isNull, reason: 'one axis preserves the ratio');
    });

    testWidgets('a wide band with no finite width resizes by height', (
      tester,
    ) async {
      const url = 'https://images.example.test/gallery/band.png';

      await pumpUntil(
        tester,
        host(imageUrl: url, width: double.infinity, height: 110),
        () => tester.any(find.byType(RawImage)),
      );

      final resize =
          tester.widget<Image>(find.byType(Image)).image as ResizeImage;
      expect(resize.width, isNull);
      expect(resize.height, (110 * tester.view.devicePixelRatio).round());
      expect(tester.getSize(find.byType(SavedItemPreview)).height, 110);
    });

    testWidgets('an explicit size is kept for a loaded image', (tester) async {
      const url = 'https://images.example.test/gallery/custom.png';

      await pumpUntil(
        tester,
        host(imageUrl: url, width: 80, height: 40),
        () => tester.any(find.byType(RawImage)),
      );

      expect(tester.getSize(find.byType(SavedItemPreview)), const Size(80, 40));
    });
  });

  group('load failure', () {
    testWidgets('an unreachable host falls back to the neutral well', (
      tester,
    ) async {
      const url = 'https://images.example.test/gallery/unreachable.png';
      images.fail = true;

      await pumpUntil(
        tester,
        host(imageUrl: url),
        () =>
            tester.any(find.byKey(SavedItemPreview.unavailablePlaceholderKey)),
      );

      expect(images.requestCount, 1);
      expect(find.byType(RawImage), findsNothing);
    });

    testWidgets('a response that is not an image falls back too', (
      tester,
    ) async {
      const url = 'https://images.example.test/gallery/garbage.png';
      // A `200` carrying something the decoder rejects.
      images.bytes = Uint8List.fromList(const [0x00, 0x01, 0x02, 0x03, 0x04]);

      await pumpUntil(
        tester,
        host(imageUrl: url),
        () =>
            tester.any(find.byKey(SavedItemPreview.unavailablePlaceholderKey)),
      );

      expect(images.requestCount, 1);
      expect(find.byType(RawImage), findsNothing);
    });
  });

  testWidgets('the loading state keeps the hatch and the reserved frame', (
    tester,
  ) async {
    const url = 'https://images.example.test/gallery/slow.png';
    images.hold = Completer<void>();

    await tester.pumpWidget(host(imageUrl: url));
    await tester.pump();

    expect(images.requestCount, 1, reason: 'the request has started');
    expect(
      find.byType(RawImage),
      findsNothing,
      reason: 'the hatch stands in until the first frame arrives',
    );
    expect(
      find.byKey(SavedItemPreview.unavailablePlaceholderKey),
      findsNothing,
    );
    expect(find.byKey(SavedItemPreview.pendingPlaceholderKey), findsNothing);
    expect(tester.getSize(find.byType(SavedItemPreview)), const Size(56, 56));

    images.hold!.complete();

    await pumpUntil(
      tester,
      host(imageUrl: url),
      () => tester.any(find.byType(RawImage)),
    );
  });

  group('theme', () {
    for (final (name, theme) in <(String, ThemeData)>[
      ('light', AppTheme.light()),
      ('dark', AppTheme.dark()),
    ]) {
      testWidgets('the well is framed with the $name tokens', (tester) async {
        await tester.pumpWidget(host(theme: theme));

        final expected = name == 'light' ? AppTokens.light : AppTokens.dark;
        final tokens = AppTheme.tokensOf(
          tester.element(find.byType(SavedItemPreview)),
        );
        expect(tokens.canvas, expected.canvas);
        expect(
          Theme.of(tester.element(find.byType(SavedItemPreview))).brightness,
          theme.brightness,
        );

        final container = tester.widget<Container>(
          find.descendant(
            of: find.byType(SavedItemPreview),
            matching: find.byType(Container),
          ),
        );
        final decoration = container.decoration! as BoxDecoration;

        expect(decoration.color, expected.canvas);
        final border = decoration.border! as Border;
        expect(border.top.color, expected.border);
        expect(border.top.width, AppMetrics.borderWidth);
        expect(container.clipBehavior, Clip.antiAlias);
        expect(
          decoration.borderRadius,
          const BorderRadius.all(AppMetrics.controlRadius),
        );
      });
    }

    testWidgets('the two palettes are actually different', (tester) async {
      // Guards the test above from passing because both themes resolve to the
      // same values.
      expect(AppTokens.light.canvas, isNot(AppTokens.dark.canvas));
      expect(AppTokens.light.slotHatch1, isNot(AppTokens.dark.slotHatch1));
    });
  });

  testWidgets('a skeleton never creates a network image request', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: const Scaffold(body: SavedItemSkeleton()),
      ),
    );
    await tester.pump();

    // A skeleton is not an item: it must not carry a URL, and `pending` is what
    // gives it the reserved well without a request.
    expect(find.byType(Image), findsNothing);
    expect(find.byKey(SavedItemPreview.pendingPlaceholderKey), findsOneWidget);
    expect(images.requestCount, 0);
  });
}
