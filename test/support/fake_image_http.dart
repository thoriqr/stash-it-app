import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

/// A network transport for `NetworkImage`, without a socket.
///
/// `flutter_test` already blocks real HTTP, but it answers every request with a
/// `400`, which can only ever exercise the failure path. This helper serves a
/// genuine — if tiny — PNG so the success path, the decode path and the
/// transport-failure path are all reachable in a widget test.
///
/// **Install once per test file, in `setUpAll`.** `NetworkImage` builds its
/// `HttpClient` from `HttpOverrides.global` the first time it loads anything in
/// the isolate and keeps it in a `static final` for the rest of the process, so
/// installing the override per test would change nothing after the first load.
/// The returned object is the mutable part: each test sets [fail] or [bytes] and
/// reads [requests], and calls [reset] between cases.
///
/// ```dart
/// late FakeImageHttp images;
/// setUpAll(() => images = installFakeImageHttp());
/// setUp(images.reset);
/// tearDown(() {
///   PaintingBinding.instance.imageCache
///     ..clear()
///     ..clearLiveImages();
/// });
/// ```
FakeImageHttp installFakeImageHttp() {
  final fake = FakeImageHttp._();
  HttpOverrides.global = _FakeImageOverrides(fake);
  return fake;
}

/// The mutable state behind [installFakeImageHttp].
class FakeImageHttp {
  FakeImageHttp._();

  /// Every URL a `NetworkImage` asked for, in order.
  ///
  /// The whole point of the fake is to tell "did not even try" apart from
  /// "tried and fell back", so this records the request rather than only the
  /// response.
  final List<Uri> requests = [];

  int get requestCount => requests.length;

  /// When true, requests fail at the transport, the way an unreachable or
  /// blocked third-party image host does.
  ///
  /// Thrown from `getUrl`, so `NetworkImage` never receives a response. A
  /// non-`200` reply would take a different branch in `NetworkImage` (it drains
  /// the body and throws `NetworkImageLoadException`), and this fake does not
  /// need to model that: the widget's error path is the same for both.
  bool fail = false;

  /// The body served on success. Defaults to [onePixelPng].
  ///
  /// Replace it with garbage to exercise a decode failure, which is a real
  /// outcome for a third-party URL that answers `200` with something that is not
  /// an image.
  Uint8List bytes = onePixelPng;

  /// When set, requests park at the transport until it completes.
  ///
  /// The only way to inspect the loading state without racing the decoder: the
  /// request is recorded, but no response arrives, so the widget stays on its
  /// loading placeholder for as long as the test needs.
  Completer<void>? hold;

  void reset() {
    requests.clear();
    fail = false;
    bytes = onePixelPng;
    hold = null;
  }
}

/// A 1×1 PNG, the smallest body a real decoder will accept.
///
/// Generated from a transparent pixel; the dimensions do not matter — the point
/// is that `Image.network` receives bytes the engine can decode, so the widget
/// takes its loaded branch rather than its error branch.
final Uint8List onePixelPng = Uint8List.fromList(const [
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, //
  0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52, //
  0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, //
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, //
  0x89, 0x00, 0x00, 0x00, 0x0D, 0x49, 0x44, 0x41, //
  0x54, 0x78, 0xDA, 0x63, 0xFC, 0xCF, 0xC0, 0x50, //
  0x0F, 0x00, 0x04, 0x85, 0x01, 0x80, 0x84, 0xA9, //
  0x8C, 0x21, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, //
  0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82, //
]);

class _FakeImageOverrides extends HttpOverrides {
  _FakeImageOverrides(this.fake);

  final FakeImageHttp fake;

  @override
  HttpClient createHttpClient(SecurityContext? context) =>
      _FakeImageHttpClient(fake);
}

/// A minimal [HttpClient]: just the one call `NetworkImage` makes.
///
/// Everything else routes to [noSuchMethod] and fails loudly, so a future
/// `NetworkImage` that starts using another part of the API shows up as a test
/// failure instead of silently speaking to a half-implemented fake.
class _FakeImageHttpClient implements HttpClient {
  _FakeImageHttpClient(this.fake);

  final FakeImageHttp fake;

  @override
  bool autoUncompress = true;

  @override
  Future<HttpClientRequest> getUrl(Uri url) async {
    fake.requests.add(url);
    final hold = fake.hold;
    if (hold != null) await hold.future;
    if (fake.fail) {
      throw const SocketException('simulated image host unreachable');
    }
    return _FakeImageHttpRequest(fake);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnsupportedError(
    '${invocation.memberName} is not used by NetworkImage',
  );
}

class _FakeImageHttpRequest implements HttpClientRequest {
  _FakeImageHttpRequest(this.fake);

  final FakeImageHttp fake;

  @override
  final HttpHeaders headers = _FakeHttpHeaders();

  @override
  Future<HttpClientResponse> close() async =>
      _FakeImageHttpResponse(fake.bytes);

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnsupportedError(
    '${invocation.memberName} is not used by NetworkImage',
  );
}

class _FakeHttpHeaders implements HttpHeaders {
  @override
  void add(String name, Object value, {bool preserveHeaderCase = false}) {}

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnsupportedError(
    '${invocation.memberName} is not used by NetworkImage',
  );
}

/// The `200` reply: the bytes, and the three properties
/// `consolidateHttpClientResponseBytes` reads.
class _FakeImageHttpResponse implements HttpClientResponse {
  _FakeImageHttpResponse(this.bytes);

  final Uint8List bytes;

  @override
  int get statusCode => HttpStatus.ok;

  @override
  int get contentLength => bytes.length;

  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) => Stream<List<int>>.value(bytes).listen(
    onData,
    onError: onError,
    onDone: onDone,
    cancelOnError: cancelOnError,
  );

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnsupportedError(
    '${invocation.memberName} is not used by NetworkImage',
  );
}
