import 'package:stash_it_app/features/saved_items/application/open_saved_item_url.dart';

/// A launcher whose answers are supplied by the test.
///
/// Extends the concrete launcher rather than implementing an interface, for the
/// same reason the repository fakes do: the production class deliberately has no
/// interface for a single implementation (`AGENTS.md` §2).
///
/// [results] is read in order, with the last entry repeating. `true` is an
/// accepted handoff, `false` a reported refusal, and any other value is thrown —
/// which is exactly how Android reports a refused intent. [launched] records every
/// URL that reached the launcher, so a test can assert both the exact value handed
/// over and that a value this client refused never arrived.
class FakeSavedItemUrlLauncher extends SavedItemUrlLauncher {
  FakeSavedItemUrlLauncher({this.results = const [true]});

  /// One outcome per launch: `true`, `false`, or an object to throw.
  final List<Object> results;

  /// Every URL this launcher was asked to open, in order.
  final List<Uri> launched = [];

  int get calls => launched.length;

  @override
  Future<bool> launch(Uri url) async {
    launched.add(url);
    final index = launched.length - 1;
    final result = results[index < results.length ? index : results.length - 1];
    if (result is bool) return result;
    throw result;
  }
}
