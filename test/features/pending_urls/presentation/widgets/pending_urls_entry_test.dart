import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_it_app/app/theme/app_theme.dart';
import 'package:stash_it_app/features/pending_urls/presentation/widgets/pending_urls_entry.dart';

void main() {
  Future<void> pumpEntry(
    WidgetTester tester, {
    required int count,
    VoidCallback? onTap,
    ThemeData? theme,
  }) {
    return tester.pumpWidget(
      MaterialApp(
        theme: theme ?? AppTheme.light(),
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(AppMetrics.space4),
            child: PendingUrlsEntry(count: count, onTap: onTap ?? () {}),
          ),
        ),
      ),
    );
  }

  BoxDecoration cardDecoration(WidgetTester tester) {
    final box = tester.widget<DecoratedBox>(
      find
          .descendant(
            of: find.byType(PendingUrlsEntry),
            matching: find.byType(DecoratedBox),
          )
          .first,
    );
    return box.decoration as BoxDecoration;
  }

  test('formats counts at the display boundary', () {
    expect(pendingUrlCountLabel(0), '0');
    expect(pendingUrlCountLabel(1), '1');
    expect(pendingUrlCountLabel(99), '99');
    expect(pendingUrlCountLabel(100), '99+');
    expect(pendingUrlCountLabel(1000), '99+');
  });

  testWidgets('renders the title, count, subtitle and navigation affordance', (
    tester,
  ) async {
    var taps = 0;
    await pumpEntry(tester, count: 3, onTap: () => taps++);

    expect(find.text('Saved on this device'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(
      find.text('Kept on this device. Open to review them.'),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.bookmark_border), findsOneWidget);
    expect(find.byIcon(Icons.chevron_right), findsOneWidget);

    await tester.tap(find.text('Saved on this device'));
    expect(taps, 1, reason: 'the whole card is the target');
  });

  for (final (count, label) in <(int, String)>[
    (1, '1'),
    (99, '99'),
    (100, '99+'),
    (1000, '99+'),
  ]) {
    testWidgets('shows $label for $count', (tester) async {
      await pumpEntry(tester, count: count);

      expect(find.text(label), findsOneWidget);
    });
  }

  testWidgets('shows a neutral zero state', (tester) async {
    await pumpEntry(tester, count: 0);

    expect(find.text('0'), findsOneWidget);
    expect(
      find.text("Links that couldn't be saved will appear here."),
      findsOneWidget,
    );

    final decoration = cardDecoration(tester);
    expect(decoration.color, AppTokens.light.surface);
    expect((decoration.border! as Border).top.color, AppTokens.light.border);
  });

  for (final (name, theme, tokens) in <(String, ThemeData, AppTokens)>[
    ('light', AppTheme.light(), AppTokens.light),
    ('dark', AppTheme.dark(), AppTokens.dark),
  ]) {
    testWidgets('uses the warning tokens in $name', (tester) async {
      await pumpEntry(tester, count: 3, theme: theme);

      final decoration = cardDecoration(tester);
      expect(decoration.color, tokens.warningSoft);
      expect((decoration.border! as Border).top.color, tokens.warningBorder);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('meets the minimum tap target and exposes a button label', (
    tester,
  ) async {
    await pumpEntry(tester, count: 3);

    expect(
      tester.getSize(find.byType(PendingUrlsEntry)).height,
      greaterThanOrEqualTo(48),
    );

    final data = tester
        .getSemantics(find.byType(PendingUrlsEntry))
        .getSemanticsData();
    expect(data.label, contains('Saved on this device'));
    expect(data.label, contains('3 links'));
    expect(data.hasAction(SemanticsAction.tap), isTrue);
  });

  testWidgets('describes an overflow count in words', (tester) async {
    await pumpEntry(tester, count: 100);

    final data = tester
        .getSemantics(find.byType(PendingUrlsEntry))
        .getSemanticsData();
    expect(data.label, contains('more than 99 links'));
  });

  testWidgets('wraps at 320 px without overflowing', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await pumpEntry(tester, count: 100);

    expect(tester.takeException(), isNull);
    expect(find.text('Saved on this device'), findsOneWidget);
  });
}
