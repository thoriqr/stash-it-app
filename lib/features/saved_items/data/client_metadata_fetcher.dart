import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';

import 'models/client_metadata.dart';

/// The user agent used for page reads.
///
/// Instagram serves a browser its JavaScript app shell, which has no Open Graph
/// metadata, and serves a non-browser client the page with OG metadata. Do not
/// replace this with a Chrome, Safari, or WebView user agent: the read then
/// returns 200 with no title, description, or image.
const String clientMetadataUserAgent = 'StashIt/1.1.2';

/// Fetches a page on the device and extracts the metadata the server expects
/// for a client-enrichment host.
///
/// The server never fetches these hosts. A failure here is not an error: the
/// caller still saves the URL, sending an empty metadata object so the server
/// records the attempt as failed instead of pending.
///
/// This is a plain [Dio] client with no `appDio` interceptors. The page request
/// must never carry the user's bearer token or any app credential.
///
/// The canonical page is read first. When it has no usable Open Graph metadata,
/// the captioned embed page is read as a fallback. That covers a page that
/// redirects, is rate limited, or returns the app shell.
class ClientMetadataFetcher {
  ClientMetadataFetcher({Dio? dio, this.timeout = const Duration(seconds: 8)})
    : _dio = dio ?? defaultDio();

  /// Total time allowed for one page read, including redirects.
  ///
  /// The canonical page and the embed fallback are separate reads, so the
  /// worst case is twice this duration.
  final Duration timeout;

  final Dio _dio;

  /// A non-browser client for public page HTML.
  ///
  /// Redirects are followed because shared links commonly redirect to the
  /// canonical page. The user agent is deliberately not a browser one; see
  /// [clientMetadataUserAgent].
  static Dio defaultDio() {
    return Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 8),
        receiveTimeout: const Duration(seconds: 8),
        sendTimeout: const Duration(seconds: 8),
        followRedirects: true,
        maxRedirects: 5,
        responseType: ResponseType.plain,
        headers: const {
          'User-Agent': clientMetadataUserAgent,
          'Accept': 'text/html',
        },
        validateStatus: (status) =>
            status != null && status >= 200 && status < 300,
      ),
    );
  }

  /// Returns metadata extracted from [url], or null when neither the canonical
  /// page nor its captioned embed yielded a usable field.
  ///
  /// [platform] is the label the client associates with the host. It is only
  /// included when at least one page field was extracted, so a failed read
  /// still produces an empty object at the call site.
  Future<ClientMetadata?> fetch(String url, {required String platform}) async {
    final pageUrl = Uri.tryParse(url.trim());
    if (pageUrl == null) return null;

    final scheme = pageUrl.scheme.toLowerCase();
    if ((scheme != 'http' && scheme != 'https') || pageUrl.host.isEmpty) {
      return null;
    }

    final page = await _fetchAndParsePage(pageUrl, platform: platform);
    if (page != null) return page;

    final embedUrl = _embedUrlFor(pageUrl);
    if (embedUrl == null) return null;
    return _fetchAndParseEmbed(embedUrl, platform: platform);
  }

  Future<ClientMetadata?> _fetchAndParsePage(
    Uri pageUrl, {
    required String platform,
  }) async {
    final body = await _fetchBody(pageUrl);
    if (body == null) return null;

    return parseClientMetadataFromHtml(
      body,
      pageUrl: pageUrl,
      platform: platform,
    );
  }

  Future<ClientMetadata?> _fetchAndParseEmbed(
    Uri embedUrl, {
    required String platform,
  }) async {
    final body = await _fetchBody(embedUrl);
    if (body == null) return null;

    return parseClientMetadataFromEmbedHtml(
      body,
      pageUrl: embedUrl,
      platform: platform,
    );
  }

  Future<String?> _fetchBody(Uri url) async {
    try {
      final response = await _dio
          .get<String>(
            url.toString(),
            options: Options(
              responseType: ResponseType.plain,
              // Set here rather than relying on the injected client, so a
              // non-2xx page is never parsed as if it were the article.
              validateStatus: (status) =>
                  status != null && status >= 200 && status < 300,
            ),
          )
          .timeout(timeout);

      final body = response.data;
      if (body == null || body.isEmpty) return null;
      return body;
    } on TimeoutException {
      return null;
    } on DioException {
      return null;
    } catch (_) {
      return null;
    }
  }
}

/// Builds the captioned embed URL for a reel or post.
///
/// Only the two post kinds that expose `/embed/captioned/` are supported. Every
/// other path returns null, so no fallback read is attempted.
Uri? _embedUrlFor(Uri pageUrl) {
  final segments = pageUrl.pathSegments
      .where((segment) => segment.isNotEmpty)
      .toList(growable: false);
  if (segments.length < 2) return null;

  final kind = switch (segments[0].toLowerCase()) {
    'reel' || 'reels' => 'reel',
    'p' => 'p',
    _ => null,
  };
  if (kind == null) return null;

  final shortcode = segments[1].trim();
  if (shortcode.isEmpty) return null;

  return Uri.https('www.instagram.com', '/$kind/$shortcode/embed/captioned/');
}

/// The longest HTML prefix inspected for metadata.
///
/// Metadata lives in the document head. Bounding the scan keeps a pathological
/// response from making the regular expressions expensive. It does not bound
/// the download; the fetch already carries its own timeout.
const int _maxHtmlCharacters = 1000000;

/// The server rejects an image URL longer than this, so an over-long value is
/// dropped rather than sent.
const int _maxImageUrlLength = 2048;

final RegExp _metaTag = RegExp(r'<meta\b[^>]*>', caseSensitive: false);
final RegExp _attribute = RegExp(
  r'''([a-zA-Z_:][-a-zA-Z0-9_:.]*)\s*=\s*(?:"([^"]*)"|'([^']*)')''',
);
final RegExp _entity = RegExp(r'&(#x?[0-9a-fA-F]+|[a-zA-Z]+);');

final RegExp _embedCaption = RegExp(
  r'"edge_media_to_caption"\s*:\s*\{\s*"edges"\s*:\s*\[\s*\{\s*"node"\s*:\s*\{\s*"text"\s*:\s*"((?:\\.|[^"\\])*)"',
);
final RegExp _embedThumbnail = RegExp(
  r'"thumbnail_src"\s*:\s*"((?:\\.|[^"\\])*)"',
);
final RegExp _embedDisplayImage = RegExp(
  r'"display_url"\s*:\s*"((?:\\.|[^"\\])*)"',
);

/// Extracts metadata from a canonical page's HTML.
///
/// Only Open Graph fields are used. A `<title>` or Twitter tag is deliberately
/// ignored: Instagram's app shell has a generic `<title>`, and treating it as
/// metadata would hide the fact that the page carried no article metadata.
/// A page without any of the three OG fields returns null so the caller can try
/// the embed fallback.
///
/// The title and description are returned as extracted, without truncation. The
/// server applies its own Instagram title handling and owns the field limits.
/// Values are trimmed and HTML entities are decoded. A relative image URL is
/// resolved against [pageUrl]; one that is not absolute http/https within the
/// length limit is dropped rather than sent.
ClientMetadata? parseClientMetadataFromHtml(
  String html, {
  required Uri pageUrl,
  required String platform,
}) {
  final meta = _metaContents(_scoped(html));

  final title = _cleanText(meta['og:title']);
  final description = _cleanText(meta['og:description']);
  final imageUrl = _cleanImageUrl(meta['og:image'], pageUrl: pageUrl);

  if (title == null && description == null && imageUrl == null) return null;

  return ClientMetadata(
    title: title,
    description: description,
    imageUrl: imageUrl,
    platform: _cleanText(platform),
  );
}

/// Extracts metadata from an Instagram captioned embed page.
///
/// The caption comes from `edge_media_to_caption`, unescaped as JSON, and the
/// image from `thumbnail_src` or `display_url`. The embed's username is not
/// used as an author: it can name a collaborator rather than the poster. The
/// title is left null; a description, image, and platform are enough for the
/// server to store the attempt as completed.
///
/// Returns null when neither a caption nor an image could be read.
ClientMetadata? parseClientMetadataFromEmbedHtml(
  String html, {
  required Uri pageUrl,
  required String platform,
}) {
  final scoped = _scoped(html);

  var description = _embedCaptionText(scoped);
  var imageUrl = _embedImageUrl(scoped, pageUrl: pageUrl);

  // The embed payload is a JSON object inside a JavaScript string, so its
  // quotes and escapes arrive doubled (`\"edge_media...`, `\\ud83d`). When the
  // raw form yields nothing, retry on the unescaped document, then on the
  // HTML-decoded form used when the payload sits in an attribute.
  if (description == null && imageUrl == null) {
    final unescaped = _decodeEntities(_unescapeEmbeddedJson(scoped));
    description = _embedCaptionText(unescaped);
    imageUrl = _embedImageUrl(unescaped, pageUrl: pageUrl);
  }

  if (description == null && imageUrl == null) return null;

  return ClientMetadata(
    description: description,
    imageUrl: imageUrl,
    platform: _cleanText(platform),
  );
}

String _scoped(String html) => html.length > _maxHtmlCharacters
    ? html.substring(0, _maxHtmlCharacters)
    : html;

/// Reverses the JavaScript-string escaping around an embedded JSON payload.
///
/// Instagram wraps the embed JSON in a JavaScript string, so a JSON quote
/// arrives as `\"` and a JSON escape as `\\`. Replacing the quote escape first
/// keeps a literal `\"escape` inside a caption readable as one JSON escape.
String _unescapeEmbeddedJson(String html) {
  return html.replaceAll(r'\"', '"').replaceAll(r'\\', r'\');
}

/// Collects `content` values keyed by the meta tag's `property` or `name`.
///
/// The first occurrence of a key wins. Both attribute orders and single or
/// double quotes are accepted.
Map<String, String> _metaContents(String html) {
  final result = <String, String>{};

  for (final tag in _metaTag.allMatches(html)) {
    String? key;
    String? content;

    for (final attribute in _attribute.allMatches(tag.group(0)!)) {
      final name = attribute.group(1)!.toLowerCase();
      final value = attribute.group(2) ?? attribute.group(3) ?? '';

      if (name == 'property' || name == 'name') {
        key ??= value.trim().toLowerCase();
      } else if (name == 'content') {
        content ??= value;
      }
    }

    if (key == null || key.isEmpty || content == null) continue;
    result.putIfAbsent(key, () => content!);
  }

  return result;
}

String? _embedCaptionText(String html) {
  final match = _embedCaption.firstMatch(html);
  if (match == null) return null;
  return _cleanText(_unescapeJsonString(match.group(1)!));
}

String? _embedImageUrl(String html, {required Uri pageUrl}) {
  final raw =
      _firstJsonString(html, _embedThumbnail) ??
      _firstJsonString(html, _embedDisplayImage);
  if (raw == null) return null;
  return _cleanImageUrl(raw, pageUrl: pageUrl);
}

String? _firstJsonString(String html, RegExp pattern) {
  final match = pattern.firstMatch(html);
  if (match == null) return null;
  return _unescapeJsonString(match.group(1)!);
}

/// Decodes the escapes of a JSON string captured without its quotes.
String? _unescapeJsonString(String raw) {
  try {
    final decoded = jsonDecode('"$raw"');
    return decoded is String ? decoded : null;
  } on FormatException {
    return null;
  }
}

String? _cleanText(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) return null;

  final decoded = _decodeEntities(trimmed).trim();
  if (decoded.isEmpty) return null;
  return decoded;
}

String? _cleanImageUrl(String? raw, {required Uri pageUrl}) {
  final trimmed = raw?.trim();
  if (trimmed == null || trimmed.isEmpty) return null;

  var decoded = _decodeEntities(trimmed).trim();
  if (decoded.isEmpty) return null;

  // An embed payload can carry one more JavaScript escaping level around its
  // JSON slashes. Remove them until the value is a normal URL.
  while (decoded.contains(r'\/')) {
    decoded = decoded.replaceAll(r'\/', '/');
  }

  final parsed = Uri.tryParse(decoded);
  if (parsed == null) return null;

  final resolved = parsed.hasScheme
      ? parsed
      : Uri.tryParse(pageUrl.resolveUri(parsed).toString());
  if (resolved == null) return null;

  final scheme = resolved.scheme.toLowerCase();
  if ((scheme != 'http' && scheme != 'https') ||
      !resolved.hasAuthority ||
      resolved.host.isEmpty) {
    return null;
  }

  final resolvedUrl = resolved.toString();
  if (resolvedUrl.length > _maxImageUrlLength) return null;
  return resolvedUrl;
}

String _decodeEntities(String value) {
  return value.replaceAllMapped(_entity, (match) {
    final entity = match.group(1)!;

    switch (entity) {
      case 'amp':
        return '&';
      case 'lt':
        return '<';
      case 'gt':
        return '>';
      case 'quot':
        return '"';
      case 'apos':
        return "'";
      case 'nbsp':
        return ' ';
    }

    final int? code;
    if (entity.startsWith('#x') || entity.startsWith('#X')) {
      code = int.tryParse(entity.substring(2), radix: 16);
    } else if (entity.startsWith('#')) {
      code = int.tryParse(entity.substring(1));
    } else {
      code = null;
    }

    if (code == null || code < 0 || code > 0x10FFFF) return match.group(0)!;
    return String.fromCharCode(code);
  });
}
