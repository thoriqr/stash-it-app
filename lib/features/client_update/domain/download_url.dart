/// Returns [value] as a URI when it is a usable release download URL.
///
/// A usable URL must use HTTPS and name [allowedHost]. Only the host is
/// compared, because each release has its own path. The comparison ignores
/// case and surrounding whitespace.
///
/// Returns null for empty, relative, or malformed values, for another scheme,
/// and for a different host. A null result means the manifest must not be
/// acted on.
Uri? validatedDownloadUrl(String? value, {required String allowedHost}) {
  final raw = value?.trim() ?? '';
  if (raw.isEmpty) return null;

  final uri = Uri.tryParse(raw);
  if (uri == null || !uri.hasAuthority) return null;
  if (uri.scheme.toLowerCase() != 'https') return null;

  final host = uri.host.trim().toLowerCase();
  final expected = allowedHost.trim().toLowerCase();
  if (host.isEmpty || expected.isEmpty || host != expected) return null;

  return uri;
}
