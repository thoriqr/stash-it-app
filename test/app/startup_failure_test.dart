import 'package:flutter_test/flutter_test.dart';
import 'package:stash_it_app/app/startup/startup_failure.dart';

void main() {
  testWidgets('the startup failure app shows a plain message', (tester) async {
    await tester.pumpWidget(const StartupFailureApp());
    await tester.pumpAndSettle();

    expect(find.text("Stash-it couldn't start"), findsOneWidget);
    expect(find.text('Please close the app and try again.'), findsOneWidget);
  });

  testWidgets('the build-error fallback is self-contained', (tester) async {
    await tester.pumpWidget(const StartupFailureView());
    await tester.pumpAndSettle();

    expect(find.textContaining("Stash-it couldn't start"), findsOneWidget);
  });
}
