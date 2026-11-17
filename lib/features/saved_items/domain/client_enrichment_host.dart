/// Hosts whose enrichment is performed by the client instead of the server.
///
/// This list must match the server's `CLIENT_ENRICHMENT_HOSTS`. For these
/// hosts the server neither fetches the page nor enqueues a worker, so the save
/// or enrich request itself is the enrichment attempt. Sending no metadata for
/// one of these hosts stores the item as failed, not pending.
const Map<String, String> _clientEnrichmentPlatforms = {
  'instagram.com': 'Instagram',
  'www.instagram.com': 'Instagram',
};

/// Returns the platform label for [url] when the server leaves its enrichment
/// to the client, or null for every other host.
///
/// Matching is exact on the lowercased host: a different subdomain is not in
/// the server's list and therefore keeps server-side enrichment.
String? clientEnrichmentPlatformForUrl(String url) {
  final host = Uri.tryParse(url.trim())?.host;
  if (host == null || host.isEmpty) return null;
  return _clientEnrichmentPlatforms[host.toLowerCase()];
}

/// Whether [url] belongs to a host the server leaves to the client.
bool isClientEnrichmentUrl(String url) =>
    clientEnrichmentPlatformForUrl(url) != null;
