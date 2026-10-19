import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart' show fail;

/// Pumps the event loop until [condition] holds, or fails after [timeout].
///
/// Concurrency tests need a rendezvous point: something has to wait until the
/// requests are genuinely in flight rather than assuming a fixed delay is
/// enough. A microtask drain is not sufficient, because Dio's pipeline crosses
/// several `await`s before the interceptor runs.
Future<void> untilCalled(
  bool Function() condition, {
  Duration timeout = const Duration(seconds: 5),
}) async {
  final deadline = DateTime.now().add(timeout);
  while (!condition()) {
    if (DateTime.now().isAfter(deadline)) {
      fail('Condition was not met within ${timeout.inMilliseconds}ms');
    }
    await Future<void>.delayed(const Duration(milliseconds: 1));
  }
}

/// A scripted [HttpClientAdapter] so tests exercise real Dio behaviour without
/// a socket.
///
/// Dio's `fetch` is the single seam between the interceptor chain and the
/// network, so replacing it keeps the interceptor, the response transformer and
/// the error path exactly as they run in production. Only the transport is
/// substituted.
///
/// Responses are queued by path prefix; anything unscripted is recorded in
/// [requests] and answered with a `500`, which surfaces immediately as a
/// surprising test failure rather than as a hang.
class FakeHttpAdapter implements HttpClientAdapter {
  FakeHttpAdapter();

  /// Handlers keyed by a path prefix, matched in insertion order.
  final Map<String, FakeHandler> _handlers = {};

  /// Every request that reached the adapter, in order.
  ///
  /// Assertions read this rather than counting handler invocations, so they
  /// describe what was sent rather than how often a stub was entered.
  final List<RecordedRequest> requests = [];

  /// The last request whose path contains [fragment], or null.
  RecordedRequest? lastRequestTo(String fragment) {
    for (final request in requests.reversed) {
      if (request.path.contains(fragment)) return request;
    }
    return null;
  }

  /// How many requests reached [fragment].
  int countFor(String fragment) =>
      requests.where((r) => r.path.contains(fragment)).length;

  /// Registers a handler for every path containing [pathFragment].
  void on(
    String pathFragment, {
    int status = 200,
    Object? body,
    Map<String, List<String>> headers = const {},
  }) {
    final reply = FakeReply(status, body, headers: headers);
    _handlers[pathFragment] = (options) async => reply.toResponseBody();
  }

  /// Handlers that answer one HTTP method only, checked before the verb-blind
  /// ones, in insertion order.
  ///
  /// The fragment match alone is verb-blind, which cannot express `POST` and
  /// `GET /saved-items`: they share a path and answer with different bodies, so a
  /// fragment-only handler would answer a create with a page of items — or a
  /// listing with one created item.
  final List<({String method, String fragment, FakeHandler handler})>
  _methodHandlers = [];

  /// Registers a handler for [method] on every path containing [pathFragment].
  void onMethod(
    String method,
    String pathFragment, {
    int status = 200,
    Object? body,
    Map<String, List<String>> headers = const {},
  }) {
    final reply = FakeReply(status, body, headers: headers);
    _methodHandlers.add((
      method: method,
      fragment: pathFragment,
      handler: (options) async => reply.toResponseBody(),
    ));
  }

  /// Registers a handler that fails the way an unreachable network does.
  ///
  /// The adapter throws instead of answering, so Dio produces the shape
  /// `mapApiFailure` treats as groups G and H: a [DioException] carrying no
  /// response, which is the only shape that makes a write's outcome uncertain.
  void onOffline(String pathFragment, {String? method}) {
    Future<ResponseBody> refuse(RequestOptions options) async =>
        throw DioException.connectionError(
          requestOptions: options,
          reason: 'no route to host',
        );

    if (method == null) {
      _handlers[pathFragment] = refuse;
    } else {
      _methodHandlers.add((
        method: method,
        fragment: pathFragment,
        handler: refuse,
      ));
    }
  }

  /// Registers a handler that never completes until [releaseBlocked].
  ///
  /// Used to hold several requests open at once, which is what a genuine
  /// concurrent-expiry test needs — issuing them without a barrier would let
  /// them complete in sequence and never actually overlap.
  void onBlocking(String pathFragment, FakeReply reply) {
    final gate = Completer<void>();
    _handlers[pathFragment] = (options) async {
      await gate.future;
      return reply.toResponseBody();
    };
    _gates[pathFragment] = gate;
  }

  final Map<String, Completer<void>> _gates = {};

  /// Releases every request parked by [onBlocking].
  void releaseBlocked() {
    for (final gate in _gates.values) {
      if (!gate.isCompleted) gate.complete();
    }
  }

  /// Registers a handler that answers with each response in turn.
  ///
  /// The last entry repeats once the sequence is exhausted, so a test scripts
  /// "expire then succeed" without counting requests by hand. This is how the
  /// expiry-then-retry cases are expressed, rather than reaching into [_handlers].
  void onSequence(String pathFragment, List<FakeReply> replies) {
    var index = 0;
    _handlers[pathFragment] = (options) async {
      final reply =
          replies[index < replies.length ? index : replies.length - 1];
      index++;
      return reply.toResponseBody();
    };
  }

  /// Answers each request from [replies] in turn (the last entry repeating), but
  /// parks the [holdAt]-th (1-based) one until [releaseBlocked].
  ///
  /// What a read/write race needs and neither [onSequence] nor [onBlocking] can
  /// express: two operations on one path complete in the order the transport
  /// answers them, so a test that wants the *later* request to answer first has
  /// to hold one of them open.
  void onSequenceHolding(
    String pathFragment,
    List<FakeReply> replies, {
    required int holdAt,
  }) {
    final gate = Completer<void>();
    _gates['$pathFragment@$holdAt'] = gate;
    var arrived = 0;

    _handlers[pathFragment] = (options) async {
      final position = ++arrived;
      final reply =
          replies[position - 1 < replies.length
              ? position - 1
              : replies.length - 1];
      if (position == holdAt) await gate.future;
      return reply.toResponseBody();
    };
  }

  /// Answers [pathFragment] with [expiredReply] until [RequestOptions.extra]
  /// carries [retriedMarker], then with [successReply].
  ///
  /// The behaviour a real endpoint has, and the only way to script a
  /// concurrency test honestly: a shared counter would hand the first arrival
  /// the expiry and the second the success regardless of which request is the
  /// replay, so overlapping requests would be resolved by arrival order rather
  /// than by what they actually are.
  void onExpiring(
    String pathFragment,
    FakeReply expiredReply,
    FakeReply successReply, {
    required String retriedMarker,
  }) {
    _handlers[pathFragment] = (options) async {
      final alreadyRetried = options.extra[retriedMarker] == true;
      return (alreadyRetried ? successReply : expiredReply).toResponseBody();
    };
  }

  /// Holds every request to [pathFragment] until [count] of them have arrived.
  ///
  /// Concurrency tests fail silently without this. Two requests issued back to
  /// back can complete in sequence, in which case the second never overlaps the
  /// first and a single-flight implementation is never actually exercised.
  /// Blocking until both are in flight makes the overlap real.
  void onBlockingUntil(String pathFragment, int count, FakeReply reply) {
    final gate = Completer<void>();
    var arrived = 0;

    _handlers[pathFragment] = (options) async {
      arrived++;
      if (arrived >= count && !gate.isCompleted) gate.complete();
      await gate.future;
      return reply.toResponseBody();
    };
  }

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(RecordedRequest.from(options));

    for (final entry in _methodHandlers) {
      if (options.method == entry.method &&
          options.uri.toString().contains(entry.fragment)) {
        return entry.handler(options);
      }
    }

    for (final entry in _handlers.entries) {
      if (options.uri.toString().contains(entry.key)) {
        return entry.value(options);
      }
    }

    throw StateError(
      'FakeHttpAdapter received an unscripted request: ${options.method} '
      '${options.uri}. Register it with on(), onMethod(), onOffline(), '
      'onSequence(), onExpiring() or onBlockingUntil().',
    );
  }

  @override
  void close({bool force = false}) {}
}

typedef FakeHandler = Future<ResponseBody> Function(RequestOptions options);

/// A scripted reply: a status, a body, and optional response headers.
class FakeReply {
  const FakeReply(this.status, this.body, {this.headers = const {}});

  /// A backend error envelope, as `httpx.NewErrorHandler` writes it.
  factory FakeReply.error(int status, String code) =>
      FakeReply(status, errorBody(code));

  /// A backend error envelope with a `Retry-After`.
  factory FakeReply.errorWithRetryAfter(int status, String code, int seconds) =>
      FakeReply(
        status,
        errorBody(code),
        headers: {
          'retry-after': ['$seconds'],
        },
      );

  final int status;
  final Object? body;
  final Map<String, List<String>> headers;

  ResponseBody toResponseBody() {
    final payload = switch (body) {
      null => '',
      final String text => text,
      final Object value => jsonEncode(value),
    };

    return ResponseBody.fromString(
      payload,
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
        ...headers,
      },
    );
  }
}

/// A request as it left the interceptor chain.
class RecordedRequest {
  RecordedRequest({
    required this.method,
    required this.path,
    required this.headers,
    required this.extra,
    required this.body,
  });

  factory RecordedRequest.from(RequestOptions options) => RecordedRequest(
    method: options.method,
    path: options.uri.toString(),
    headers: Map<String, dynamic>.from(options.headers),
    extra: Map<String, dynamic>.from(options.extra),
    body: options.data,
  );

  final String method;
  final String path;
  final Map<String, dynamic> headers;
  final Map<String, dynamic> extra;

  /// The request body, as handed to the transport.
  ///
  /// Present so a test can assert *which* credential was presented — the whole
  /// point of the "only the current refresh token is submitted" check. Captured
  /// for assertions only; the fake never prints it and no diagnostic path reads
  /// it, because for `/auth/login` it holds a password.
  final Object? body;

  /// The bearer token sent, or null when no `Authorization` header was attached.
  String? get bearer {
    final value = headers['Authorization'];
    if (value is! String || !value.startsWith('Bearer ')) return null;
    return value.substring('Bearer '.length);
  }

  /// The value sent for [key] in a JSON body, or null.
  ///
  /// Used to check which refresh token a renewal presented without asserting on
  /// a whole body.
  Object? jsonField(String key) {
    final data = body;
    if (data is! Map) return null;
    return data[key];
  }
}

/// Builds a backend error body exactly as `httpx.NewErrorHandler` writes it.
Map<String, dynamic> errorBody(
  String code, {
  List<Map<String, String>> fields = const [],
}) {
  return {
    'error': {'code': code, 'message': 'redacted for tests', 'fields': fields},
  };
}

/// An in-memory [FlutterSecureStorage].
///
/// Extends the real class rather than implementing its interface, so a method
/// added in a future release cannot turn into a compile error here — only the
/// four methods the credential store actually calls are overridden, and the rest
/// stay unreachable.
///
/// Lets the storage layer's own behaviour — including its all-or-nothing write
/// and its refusal to treat a half-present pair as a session — be tested without
/// a platform channel.
class InMemorySecureStorage extends FlutterSecureStorage {
  InMemorySecureStorage();

  final Map<String, String> values = {};

  /// Keys whose **write** should throw, used to simulate a storage failure
  /// partway through a rotation.
  final Set<String> failingWrites = {};

  /// Keys whose **read** should throw, used to simulate an unreachable store.
  final Set<String> failingReads = {};

  /// Keys whose **delete** should throw, used to simulate a cleanup that
  /// reports it did not happen.
  final Set<String> failingDeletes = {};

  int clearAllCalls = 0;

  @override
  Future<void> write({
    required String key,
    required String? value,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (failingWrites.contains(key)) {
      throw PlatformException(code: 'simulated', message: 'write failed');
    }
    if (value == null) {
      values.remove(key);
    } else {
      values[key] = value;
    }
  }

  @override
  Future<String?> read({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (failingReads.contains(key)) {
      throw PlatformException(code: 'simulated', message: 'read failed');
    }
    return values[key];
  }

  @override
  Future<void> delete({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (failingDeletes.contains(key)) {
      throw PlatformException(code: 'simulated', message: 'delete failed');
    }
    values.remove(key);
  }

  @override
  Future<void> deleteAll({
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    clearAllCalls++;
    values.clear();
  }
}
