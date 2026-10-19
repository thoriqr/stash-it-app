/// Whether this client will send [value] as a saved item's URL.
///
/// **A local gate for the common mistake, not the contract.** The backend binds
/// `validate:"required,url,max=2048"` and then derives a domain from the
/// hostname (`saved_item/request.go`, `service.go`), and it stays the authority
/// for everything this cannot see: whether the host resolves, whether the product
/// accepts the domain, and the 2048-byte cap. What is checked here is the part
/// that is decidable from the string alone, so the common failure never
/// round-trips (§2.9).
///
/// A value passes when, after trimming:
///
/// 1. it parses as a URI;
/// 2. its scheme is `http` or `https` (case-insensitively — the parser
///    normalises the scheme, and this does not rely on that);
/// 3. it has a host, and that host is a name rather than an escape: no
///    whitespace, no control characters, no bare `%`;
/// 4. its port, if any, is one a client can address (up to 65535).
///
/// **What it deliberately does not do.**
///
/// - **No network call.** Reachability is not a format question, and probing a
///   URL would leak the user's links to a third party before they are saved.
/// - **No allowlist** of platforms, domains, social networks or TLDs. That would
///   refuse valid links the server accepts, which is the one failure this check
///   must not introduce.
/// - **No dot requirement.** `http://intranet-host/wiki` is an absolute URL with
///   a host; a single-label name is a local DNS question, not this client's.
/// - **No length cap.** The server's 2048-byte limit is real, but its honest copy
///   is not "that doesn't look like a link", so the server keeps that refusal.
/// - **No normalisation.** The value is judged and then sent as written (after
///   the trim); the server stores what it is given.
bool isSubmittableUrl(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) return false;

  final uri = Uri.tryParse(trimmed);
  if (uri == null) return false;

  final scheme = uri.scheme.toLowerCase();
  if (scheme != 'http' && scheme != 'https') return false;

  // A host must be a name. `Uri.parse` is lenient: it percent-encodes what it
  // cannot keep verbatim, so `https://exa mple.com` parses with the host
  // `exa%20mple.com`, and `https://%zz` with `%25zz`. Decoding the host and
  // refusing whitespace, control characters and a bare `%` catches both — and
  // leaves the escapes an internationalised host legitimately compiles to alone:
  // `例え.jp` arrives as `%E4%BE%8B…` and decodes back to itself.
  //
  // The parser never emits an escape it cannot decode, so this guard is about
  // being total rather than about a case a caller can reach: a gate that can
  // throw would turn a malformed link into a crashed save.
  final String host;
  try {
    host = Uri.decodeComponent(uri.host);
  } on ArgumentError {
    return false;
  }
  if (host.isEmpty) return false;
  if (host.contains('%')) return false;
  if (host.runes.any((rune) => rune <= 0x20 || rune == 0x7F)) return false;

  // `Uri` accepts a numeric port above the addressable range; nothing can
  // connect to it, so it is not a URL this client should try to save.
  return !uri.hasPort || uri.port <= 65535;
}
