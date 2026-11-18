import 'package:stash_it_app/features/saved_items/data/client_metadata_fetcher.dart';
import 'package:stash_it_app/features/saved_items/data/models/client_metadata.dart';

/// A [ClientMetadataFetcher] whose result is supplied by the test.
///
/// A null [result] models a failed page read. [urls] records what was fetched
/// so a test can assert that a server-enriched host was never fetched at all.
class FakeClientMetadataFetcher implements ClientMetadataFetcher {
  FakeClientMetadataFetcher([this.result]);

  final ClientMetadata? result;
  final List<String> urls = [];

  @override
  final Duration timeout = Duration.zero;

  @override
  Future<ClientMetadata?> fetch(String url) async {
    urls.add(url);
    return result;
  }
}
