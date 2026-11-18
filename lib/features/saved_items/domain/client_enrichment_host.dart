/// Hosts whose enrichment is performed by the client instead of the server.
///
/// This set must match the server's `CLIENT_ENRICHMENT_HOSTS`. For these hosts
/// the server neither fetches the page nor enqueues a worker, so the save or
/// enrich request itself is the enrichment attempt. Sending no metadata for one
/// of these hosts stores the item as failed, not pending.
///
/// The server derives the platform from the URL host, so the client sends no
/// platform field with the extracted metadata.
const Set<String> _clientEnrichmentHosts = {
  'instagram.com',
  'www.instagram.com',
};

/// Whether [url] belongs to a host the server leaves to the client.
///
/// Matching is exact on the lowercased host: a different subdomain is not in
/// the server's list and therefore keeps server-side enrichment.
bool isClientEnrichmentHost(String url) {
  final host = Uri.tryParse(url.trim())?.host;
  if (host == null || host.isEmpty) return false;
  return _clientEnrichmentHosts.contains(host.toLowerCase());
}
