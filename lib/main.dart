import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stash_it_app/app/app.dart';
import 'package:stash_it_app/app/bootstrap.dart';

Future<void> main() async {
  // Startup is no longer synchronous. `bootstrap` initializes the binding —
  // required before any plugin channel is used, and `flutter_secure_storage` is
  // one — and reads stored credentials before the first frame, so the router can
  // choose between the app and sign-in on its very first navigation instead of
  // showing the wrong one and correcting itself.
  final overrides = await bootstrap();

  runApp(ProviderScope(overrides: overrides, child: const StashItApp()));
}
