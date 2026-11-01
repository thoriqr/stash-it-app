/// Whether [value] can be submitted as a saved item's URL.
///
/// This is a client-side check for common URL format mistakes, not the
/// authoritative validation contract. The server remains responsible for
/// validation that cannot be determined from the string alone, including
/// hostname resolution, supported domains, and the 2048-byte limit.
///
/// After trimming, a value passes when:
///
/// 1. It parses as a URI.
/// 2. Its scheme is `http` or `https`, case-insensitively.
/// 3. It has a hostname containing no whitespace, control characters, or
///    remaining percent signs.
/// 4. Its port, if present, is within the addressable range (0–65535).
///
/// **What this check deliberately does not do:**
///
/// - **No network requests.** Reachability is not a format check. Probing a URL
///   would expose the user's link to a third party before it is saved.
/// - **No domain or platform allowlist.** Valid links must not be rejected
///   simply because their domain, platform, or TLD is not recognised.
/// - **No dot requirement.** A single-label hostname such as
///   `http://intranet-host/wiki` can be a valid local address.
/// - **No length limit.** The server enforces the 2048-byte limit because the
///   client cannot give that rejection an accurate URL-format explanation.
/// - **No normalisation.** The trimmed value is checked and submitted as-is;
///   this check does not rewrite the URL.
bool isSubmittableUrl(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) return false;

  final uri = Uri.tryParse(trimmed);
  if (uri == null) return false;

  final scheme = uri.scheme.toLowerCase();
  if (scheme != 'http' && scheme != 'https') return false;

  // Uri parsing can percent-encode characters that are not valid in a
  // hostname. Decode the host so whitespace and control characters remain
  // detectable, then reject any remaining percent signs. Legitimate encoded
  // internationalised hostnames still decode to their original characters.
  //
  // Keep decoding guarded so malformed input cannot cause this validation
  // check to throw.
  final String host;
  try {
    host = Uri.decodeComponent(uri.host);
  } on ArgumentError {
    return false;
  }
  if (host.isEmpty) return false;
  if (host.contains('%')) return false;
  if (host.runes.any((rune) => rune <= 0x20 || rune == 0x7F)) return false;

  // Reject ports outside the range a client can address.
  return !uri.hasPort || uri.port <= 65535;
}
