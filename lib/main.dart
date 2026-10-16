import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stash_it_app/app/app.dart';

void main() {
  // Startup is synchronous. Nothing needs asynchronous initialization yet, so
  // there is no bootstrap step to add here.
  runApp(const ProviderScope(child: StashItApp()));
}
