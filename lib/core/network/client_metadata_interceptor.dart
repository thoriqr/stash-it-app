import 'package:dio/dio.dart';

/// Attaches client metadata to outgoing API requests.
///
/// Sends two optional metadata headers:
/// - `X-Platform`: identifies the client platform.
/// - `X-Device-Name`: provides a human-readable device label.
///
/// `X-Installation-ID` is intentionally omitted because this client does not
/// currently implement device identification or device management. Sending
/// it would require generating and maintaining a valid installation UUID.
///
/// These headers describe the client; they are not used for authentication
/// or authorization.
class ClientMetadataInterceptor extends Interceptor {
  const ClientMetadataInterceptor({required this.platform, this.deviceName});

  /// Platform identifier, such as `android` or `ios`.
  final String platform;

  /// Human-readable device label. Null or empty values omit the header.
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
