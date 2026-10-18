import 'package:dio/dio.dart';

/// Attaches the client metadata the backend records against a session.
///
/// `session.ExtractMetadata` reads three optional headers. Only two are sent:
///
/// - `X-Platform` — free-form, describes the client.
/// - `X-Device-Name` — free-form, shown in a device list.
///
/// `X-Installation-ID` is deliberately **not** sent. It must parse as a UUID or
/// login fails with `400 INVALID_INSTALLATION_ID`
/// (`session/metadata.go:35`), and it is the one header that would force a UUID
/// dependency for a device list this phase does not build. `decisions.md` D10
/// defers device management and Q7 leaves the headers open; the other two cost
/// nothing and are recorded from session creation onwards, so sending them now
/// avoids a retrofit later.
///
/// Neither header is an authorization mechanism — ownership is `user_id`, and
/// nothing keys off these.
class ClientMetadataInterceptor extends Interceptor {
  const ClientMetadataInterceptor({required this.platform, this.deviceName});

  /// Describes the client, e.g. `android` or `ios`.
  final String platform;

  /// A human-readable label for the device. Null simply omits the header.
  final String? deviceName;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers['X-Platform'] = platform;

    final name = deviceName;
    if (name != null && name.isNotEmpty) {
      options.headers['X-Device-Name'] = name;
    }

    handler.next(options);
  }
}
