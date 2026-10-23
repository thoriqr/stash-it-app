import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_it_app/app/theme/app_theme.dart';
import 'package:stash_it_app/shared/widgets/app_button.dart';
import 'package:stash_it_app/shared/widgets/app_confirm_dialog.dart';

/// The shared confirmation treatment: both brightnesses, and the dismissal
/// contract that makes a barrier tap or Back mean "do not continue".
void main() {
  AppConfirmDialog dialog() => const AppConfirmDialog(
    title: 'Delete this item?',
    message: 'This removes the saved item. It cannot be undone.',
    cancelLabel: 'Keep',
    confirmLabel: 'Delete',
    destructive: true,
  );

  for (final (brightness, theme, tokens) in [
    ('light', AppTheme.light(), AppTokens.light),
    ('dark', AppTheme.dark(), AppTokens.dark),
  ]) {
    testWidgets('uses the $brightness raised surface and danger action', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(body: dialog()),
        ),
      );

      final surface = tester.widget<Dialog>(find.byType(Dialog));
      expect(surface.backgroundColor, tokens.surfaceRaised);
      expect(surface.elevation, 0);
      final shape = surface.shape! as RoundedRectangleBorder;
      expect(shape.side.color, tokens.border);

      expect(find.text('Delete this item?'), findsOneWidget);
      expect(
        find.text('This removes the saved item. It cannot be undone.'),
        findsOneWidget,
      );
      expect(find.widgetWithText(AppButton, 'Keep'), findsOneWidget);

      final confirm = tester.widget<AppButton>(
        find.widgetWithText(AppButton, 'Delete'),
      );
      expect(confirm.variant, AppButtonVariant.danger);
    });
  }

  testWidgets('a barrier tap dismisses with null rather than confirming', (
    tester,
  ) async {
    bool? result;
    var opened = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: Builder(
            builder: (context) => AppButton(
              label: 'Open',
              onPressed: () async {
                opened = true;
                result = await showAppConfirmDialog(
                  context: context,
                  title: 'Delete this item?',
                  message: 'This removes the saved item. It cannot be undone.',
                  cancelLabel: 'Keep',
                  confirmLabel: 'Delete',
                  destructive: true,
                );
              },
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(opened, isTrue);
    expect(find.text('Delete this item?'), findsOneWidget);

    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();

    expect(result, isNull);
    expect(find.text('Delete this item?'), findsNothing);
  });

  testWidgets('system back dismisses with null rather than confirming', (
    tester,
  ) async {
    bool? result;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: Builder(
            builder: (context) => AppButton(
              label: 'Open',
              onPressed: () async {
                result = await showAppConfirmDialog(
                  context: context,
                  title: 'Delete this item?',
                  message: 'This removes the saved item. It cannot be undone.',
                  cancelLabel: 'Keep',
                  confirmLabel: 'Delete',
                  destructive: true,
                );
              },
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.text('Delete this item?'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(result, isNull);
    expect(find.text('Delete this item?'), findsNothing);
  });

  testWidgets('Keep returns false and Delete returns true', (tester) async {
    bool? result;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: Builder(
            builder: (context) => AppButton(
              label: 'Open',
              onPressed: () async {
                result = await showAppConfirmDialog(
                  context: context,
                  title: 'Delete this item?',
                  message: 'This removes the saved item. It cannot be undone.',
                  cancelLabel: 'Keep',
                  confirmLabel: 'Delete',
                  destructive: true,
                );
              },
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(AppButton, 'Keep'));
    await tester.pumpAndSettle();
    expect(result, isFalse);

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(AppButton, 'Delete'));
    await tester.pumpAndSettle();
    expect(result, isTrue);
  });
}
