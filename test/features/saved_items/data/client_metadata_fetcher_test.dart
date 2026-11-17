import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_it_app/features/saved_items/data/client_metadata_fetcher.dart';
import 'package:stash_it_app/features/saved_items/data/models/client_metadata.dart';

import '../../../support/fake_http.dart';

void main() {
  final pageUrl = Uri.parse('https://www.instagram.com/reel/abc/');

  group('parseClientMetadataFromHtml', () {
    test('extracts Open Graph fields and the platform', () {
      const html = '''
        <html><head>
        <meta property="og:title" content="Author on Instagram: &quot;Caption&quot;" />
        <meta property="og:description" content="Line one &amp; two" />
        <meta property="og:image" content="/media/preview.jpg" />
        </head></html>
      ''';

      final metadata = parseClientMetadataFromHtml(
        html,
        pageUrl: pageUrl,
        platform: 'Instagram',
      );

      expect(metadata!.title, 'Author on Instagram: "Caption"');
      expect(metadata.description, 'Line one & two');
      expect(metadata.imageUrl, 'https://www.instagram.com/media/preview.jpg');
      expect(metadata.platform, 'Instagram');
    });

    test(
      'ignores a title element when the page has no Open Graph metadata',
      () {
        final metadata = parseClientMetadataFromHtml(
          '<html><head><title>Instagram</title></head>'
          '<body>app shell</body></html>',
          pageUrl: pageUrl,
          platform: 'Instagram',
        );

        expect(metadata, isNull);
      },
    );

    test('keeps the raw title and description without truncation', () {
      final caption = 'x'.padRight(1500, 'x');
      final longTitle = 'Author on Instagram: "$caption"';
      final longDescription = 'y'.padRight(12000, 'y');

      final metadata = parseClientMetadataFromHtml(
        '<meta property="og:title" '
        'content="Author on Instagram: &quot;$caption&quot;">'
        '<meta property="og:description" content="$longDescription">',
        pageUrl: pageUrl,
        platform: 'Instagram',
      );

      expect(metadata!.title, longTitle);
      expect(metadata.description, longDescription);
    });

    test('treats a blank value as absent', () {
      final metadata = parseClientMetadataFromHtml(
        '<meta property="og:title" content="   ">'
        '<meta property="og:description" content="">',
        pageUrl: pageUrl,
        platform: 'Instagram',
      );

      expect(metadata, isNull);
    });

    test('drops an image URL that is not absolute http or https', () {
      final metadata = parseClientMetadataFromHtml(
        '<meta property="og:image" content="data:image/png;base64,AAAA">',
        pageUrl: pageUrl,
        platform: 'Instagram',
      );

      expect(metadata, isNull);
    });

    test('serializes an empty metadata object as an empty map', () {
      expect(const ClientMetadata().toJson(), isEmpty);
    });
  });

  group('parseClientMetadataFromEmbedHtml', () {
    test('reads the caption, thumbnail, and platform', () {
      const html = r'''
        <script type="application/json">{"shortcode_media":{
          "edge_media_to_caption":{"edges":[{"node":{"text":"Caption \u0026 more"}}]},
          "thumbnail_src":"https:\/\/scontent.cdninstagram.com\/thumb.jpg",
          "display_url":"https:\/\/scontent.cdninstagram.com\/full.jpg"
        }}</script>
      ''';

      final metadata = parseClientMetadataFromEmbedHtml(
        html,
        pageUrl: pageUrl,
        platform: 'Instagram',
      );

      expect(metadata, isNotNull);
      expect(metadata!.title, isNull);
      expect(metadata.description, 'Caption & more');
      expect(metadata.imageUrl, 'https://scontent.cdninstagram.com/thumb.jpg');
      expect(metadata.platform, 'Instagram');
    });

    test('uses display_url when thumbnail_src is absent', () {
      const html = r'''
        <script>{"edge_media_to_caption":{"edges":[{"node":{"text":"Caption"}}]},
        "display_url":"https:\/\/scontent.cdninstagram.com\/full.jpg"}</script>
      ''';

      final metadata = parseClientMetadataFromEmbedHtml(
        html,
        pageUrl: pageUrl,
        platform: 'Instagram',
      );

      expect(metadata!.imageUrl, 'https://scontent.cdninstagram.com/full.jpg');
    });

    test('reads a JavaScript-escaped embed payload', () {
      // Mirrors the real shape: a JSON object inside a JavaScript string, so
      // every JSON quote and escape arrives doubled.
      const html = r'''
        <script>window.__additionalDataLoaded('...', "{\"shortcode_media\":{\"edge_media_to_caption\":{\"edges\":[{\"node\":{\"text\":\"Caption \\u0026 more\"}}]},\"thumbnail_src\":\"https:\\\/\\\/scontent.cdninstagram.com\\\/thumb.jpg\"}}");</script>
      ''';

      final metadata = parseClientMetadataFromEmbedHtml(
        html,
        pageUrl: pageUrl,
        platform: 'Instagram',
      );

      expect(metadata!.description, 'Caption & more');
      expect(metadata.imageUrl, 'https://scontent.cdninstagram.com/thumb.jpg');
    });

    test('returns null when the embed has neither a caption nor an image', () {
      final metadata = parseClientMetadataFromEmbedHtml(
        '<html></html>',
        pageUrl: pageUrl,
        platform: 'Instagram',
      );

      expect(metadata, isNull);
    });
  });

  group('ClientMetadataFetcher', () {
    late FakeHttpAdapter adapter;
    late Dio dio;

    setUp(() {
      adapter = FakeHttpAdapter();
      dio = Dio(BaseOptions(responseType: ResponseType.plain));
      dio.httpClientAdapter = adapter;
    });

    test('uses a non-browser user agent', () {
      final headers = ClientMetadataFetcher.defaultDio().options.headers;
      final userAgent =
          headers.entries
                  .firstWhere(
                    (entry) => entry.key.toLowerCase() == 'user-agent',
                  )
                  .value
              as String;

      expect(userAgent, isNot(contains('Mozilla')));
      expect(userAgent, startsWith('StashIt/'));
    });

    test('returns metadata for a canonical page', () async {
      adapter.on(
        'instagram.com',
        body: '<meta property="og:title" content="Reel">',
      );
      final fetcher = ClientMetadataFetcher(dio: dio);

      final metadata = await fetcher.fetch(
        'https://www.instagram.com/reel/abc/',
        platform: 'Instagram',
      );

      expect(metadata!.title, 'Reel');
      expect(metadata.platform, 'Instagram');
    });

    test('falls back to the captioned embed when the page has no Open Graph '
        'metadata', () async {
      adapter.on('/embed/captioned/', body: _embedHtml);
      adapter.on(
        'reel/abc/',
        body: '<html><head><title>Instagram</title></head></html>',
      );
      final fetcher = ClientMetadataFetcher(dio: dio);

      final metadata = await fetcher.fetch(
        'https://www.instagram.com/reel/abc/',
        platform: 'Instagram',
      );

      expect(metadata, isNotNull);
      expect(metadata!.title, isNull);
      expect(metadata.description, 'Caption & more');
      expect(metadata.imageUrl, 'https://scontent.cdninstagram.com/thumb.jpg');
      expect(metadata.platform, 'Instagram');
    });

    test('returns null when both the page and the embed fail', () async {
      adapter.on('instagram.com', status: 404, body: 'not found');
      final fetcher = ClientMetadataFetcher(dio: dio);

      final metadata = await fetcher.fetch(
        'https://www.instagram.com/reel/abc/',
        platform: 'Instagram',
      );

      expect(metadata, isNull);
    });

    test('does not send an Authorization header to the page host', () async {
      adapter.on(
        'instagram.com',
        body: '<meta property="og:title" content="Reel">',
      );
      final fetcher = ClientMetadataFetcher(dio: dio);

      await fetcher.fetch(
        'https://www.instagram.com/reel/abc/',
        platform: 'Instagram',
      );

      final request = adapter.lastRequestTo('instagram.com')!;
      expect(request.headers.containsKey('Authorization'), isFalse);
    });
  });
}

const String _embedHtml = r'''
<script type="application/json">{"shortcode_media":{
  "edge_media_to_caption":{"edges":[{"node":{"text":"Caption \u0026 more"}}]},
  "thumbnail_src":"https:\/\/scontent.cdninstagram.com\/thumb.jpg"
}}</script>
''';
