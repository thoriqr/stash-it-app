import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stash_it_app/features/pending_urls/data/pending_url_store.dart';

/// A real [PendingUrlStore] over the plugin's in-memory preferences.
///
/// Used wherever a test pumps a screen that watches the pending-URL provider, or
/// drives the store through its public API. No platform channel is hit:
/// `setMockInitialValues` installs the in-memory implementation.
Future<PendingUrlStore> testPendingUrlStore({
  Map<String, Object> values = const {},
  DateTime Function() now = DateTime.now,
}) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues(values);
  final preferences = await SharedPreferences.getInstance();
  return PendingUrlStore(preferences, now: now);
}
