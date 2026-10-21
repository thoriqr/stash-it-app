import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_it_app/app/theme/app_theme.dart';
import 'package:stash_it_app/shared/widgets/app_field.dart';

/// The shared input's geometry.
///
/// These pin the two properties the device screenshots exposed: the field is a
/// comfortable touch target, and the text inside it is **centred** rather than
/// pressed against the top border. Both are invisible in a code review and easy
/// to undo with a one-token change, so they are asserted rather than described.
void main() {
  Future<void> pumpField(
    WidgetTester tester, {
    bool mono = false,
    double width = 360,
    VoidCallback? onClear,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: width,
              child: AppField(
                label: 'Email',
                controller: TextEditingController(text: 'reader@example.com'),
                mono: mono,
                onClear: onClear,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('the field is the shared height, not a screen-specific one', (
    tester,
  ) async {
    await pumpField(tester);

    expect(
      tester.getSize(find.byType(TextFormField)).height,
      AppMetrics.fieldHeight,
    );
    expect(
      AppMetrics.fieldHeight,
      greaterThanOrEqualTo(48),
      reason: 'Material\'s minimum interactive dimension',
    );
  });

  testWidgets('the text is vertically balanced inside the field', (
    tester,
  ) async {
    await pumpField(tester);

    final field = tester.getRect(find.byType(TextFormField));
    final text = tester.getRect(find.byType(EditableText));

    final above = text.top - field.top;
    final below = field.bottom - text.bottom;

    expect(above, greaterThan(0), reason: 'text must not touch the top border');
    expect(
      (above - below).abs(),
      lessThan(1),
      reason: 'the text run should be centred: $above above, $below below',
    );
  });

  testWidgets('the mono variant has the same geometry as the UI variant', (
    tester,
  ) async {
    await pumpField(tester);
    final ui = tester.getSize(find.byType(TextFormField));

    await pumpField(tester, mono: true);
    final machine = tester.getSize(find.byType(TextFormField));

    expect(machine, ui, reason: 'a URL field must not be a different control');
  });

  testWidgets('the decoration is not dense', (tester) async {
    // `isDense` collapses Material's vertical padding to nothing. That is the
    // original defect: the text sat on the top border and the 40 px box held
    // 20 px of dead space beneath it.
    await pumpField(tester);

    expect(
      tester
          .widget<InputDecorator>(find.byType(InputDecorator))
          .decoration
          .isDense,
      isNot(true),
    );
  });

  testWidgets('the field still shrinks to a narrow width without overflowing', (
    tester,
  ) async {
    await pumpField(tester, width: 200);

    expect(tester.takeException(), isNull);
    expect(
      tester.getSize(find.byType(TextFormField)).height,
      AppMetrics.fieldHeight,
    );
  });

  testWidgets('a clear action fits inside the field without changing it', (
    tester,
  ) async {
    var cleared = false;
    await pumpField(tester, onClear: () => cleared = true);

    expect(find.byIcon(Icons.close), findsOneWidget);
    expect(
      tester.getSize(find.byType(TextFormField)).height,
      AppMetrics.fieldHeight,
    );
    expect(tester.takeException(), isNull);

    final field = tester.getRect(find.byType(TextFormField));
    final icon = tester.getRect(find.byIcon(Icons.close));
    expect(field.contains(icon.center), isTrue);
    expect(icon.center.dx, greaterThan(field.center.dx));

    await tester.tap(find.byIcon(Icons.close));
    expect(cleared, isTrue);
  });

  testWidgets('a label is optional, so a grouped field can omit it', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 360,
              child: AppField(controller: TextEditingController()),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // No stray empty label, and therefore no stray gap above the field.
    expect(
      find.byWidgetPredicate((w) => w is Text && (w.data ?? '').isEmpty),
      findsNothing,
    );
    expect(
      tester.getTopLeft(find.byType(TextFormField)).dy,
      moreOrLessEquals(tester.getTopLeft(find.byType(AppField)).dy),
    );
  });
}
