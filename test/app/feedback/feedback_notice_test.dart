import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_it_app/app/feedback/app_feedback.dart';
import 'package:stash_it_app/app/feedback/feedback_host.dart';
import 'package:stash_it_app/app/theme/app_theme.dart';

/// The feedback band's treatment: `design-system.md` §6.5, in both brightnesses.
///
/// The rule these tests defend is that a tone is a *semantic* colour, resolved
/// through the active theme, and never a hard-coded hex. A notice drawn over the
/// dark canvas must use B-Dark's `--success-soft`, not B · Inventory's, which is
/// what makes `AppTheme.tokensOf` — rather than a Material `ColorScheme` role —
/// the right lookup.
///
/// The second rule is §6.5's one **non-colour** distinction: the uncertain row
/// shares the warning row's fill and border and is separated from it by a hollow
/// mark. "Same colours, different meaning" is exactly the pair a colour-only
/// table would collapse, so the hollow/filled contrast is asserted here directly.
void main() {
  Future<void> pumpNotice(
    WidgetTester tester, {
    required FeedbackTone tone,
    required ThemeData theme,
    String copy = 'A notice.',
  }) {
    return tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: Scaffold(
          body: Center(
            child: FeedbackNotice(
              feedback: AppFeedback(tone: tone, copy: copy),
            ),
          ),
        ),
      ),
    );
  }

  /// The band: the notice's own container.
  ///
  /// It is the only decorated box with **both** a fill and a border, which is what
  /// separates it from a hollow mark — that one has a border and no fill.
  Container band(WidgetTester tester) => tester
      .widgetList<Container>(
        find.descendant(
          of: find.byType(FeedbackNotice),
          matching: find.byType(Container),
        ),
      )
      .firstWhere((container) {
        final decoration = container.decoration;
        return decoration is BoxDecoration &&
            decoration.color != null &&
            decoration.border != null;
      });

  /// The mark itself, which carries the filled/hollow decision.
  FeedbackMark mark(WidgetTester tester) =>
      tester.widget<FeedbackMark>(find.byType(FeedbackMark));

  /// The band's rounded clip.
  ///
  /// The radius lives on a `ClipRRect` rather than in the decoration: `BoxBorder`
  /// refuses a radius on a border whose sides are not all one colour, and the
  /// leading edge is deliberately the tone's own token.
  ClipRRect clip(WidgetTester tester) => tester.widget<ClipRRect>(
    find.descendant(
      of: find.byType(FeedbackNotice),
      matching: find.byType(ClipRRect),
    ),
  );

  /// The mark's own box, to check how that decision is drawn.
  Container markBox(WidgetTester tester) => tester.widget<Container>(
    find.descendant(
      of: find.byType(FeedbackMark),
      matching: find.byType(Container),
    ),
  );

  group('the tone table', () {
    test('every tone resolves the tokens §6.5 names, in both themes', () {
      // Exhaustive and pure: the whole mapping, for the whole palette. If a tone
      // is ever pointed at the wrong token pair this fails before any widget is
      // pumped.
      for (final tokens in [AppTokens.light, AppTokens.dark]) {
        expect(feedbackTreatment(tokens, FeedbackTone.success), (
          fill: tokens.successSoft,
          border: tokens.successBorder,
          mark: tokens.success,
          hollowMark: false,
        ));
        expect(feedbackTreatment(tokens, FeedbackTone.warning), (
          fill: tokens.warningSoft,
          border: tokens.warningBorder,
          mark: tokens.warning,
          hollowMark: false,
        ));
        expect(feedbackTreatment(tokens, FeedbackTone.danger), (
          fill: tokens.dangerSoft,
          border: tokens.dangerBorder,
          mark: tokens.danger,
          hollowMark: false,
        ));
      }
    });

    test('the uncertain row is the warning row, plus a hollow mark', () {
      // §6.5's table, literally: same fill, same border, same token for the mark,
      // and the hollow flag as the only difference.
      for (final tokens in [AppTokens.light, AppTokens.dark]) {
        final warning = feedbackTreatment(tokens, FeedbackTone.warning);
        final uncertain = feedbackTreatment(tokens, FeedbackTone.uncertain);

        expect(uncertain.fill, warning.fill);
        expect(uncertain.border, warning.border);
        expect(uncertain.mark, warning.mark);
        expect(uncertain.hollowMark, isTrue);
        expect(warning.hollowMark, isFalse);
      }
    });

    test('every tone is a distinct treatment', () {
      // The tones are semantic, not decorative: collapsing two of them onto one
      // treatment would make a spent budget look like a failure. Compared as whole
      // records rather than by fill alone, because `warning` and `uncertain`
      // deliberately share a fill and differ only in the mark.
      for (final tokens in [AppTokens.light, AppTokens.dark]) {
        expect({
          for (final tone in FeedbackTone.values)
            feedbackTreatment(tokens, tone),
        }, hasLength(FeedbackTone.values.length));
      }
    });
  });

  group('rendering', () {
    for (final (brightness, theme, tokens) in <(String, ThemeData, AppTokens)>[
      ('light', AppTheme.light(), AppTokens.light),
      ('dark', AppTheme.dark(), AppTokens.dark),
    ]) {
      for (final tone in FeedbackTone.values) {
        testWidgets('$brightness: $tone draws §6.5\'s fill, border and mark', (
          WidgetTester tester,
        ) async {
          await pumpNotice(tester, tone: tone, theme: theme);

          final treatment = feedbackTreatment(tokens, tone);
          final decoration = band(tester).decoration! as BoxDecoration;
          final border = decoration.border! as Border;

          expect(decoration.color, treatment.fill);

          // `.ds-note`: a 1 px `<tone>-border` hairline on three sides, and a
          // 3 px leading edge in the tone's own token.
          expect(border.left.color, treatment.mark, reason: 'the leading edge');
          expect(border.left.width, 3, reason: 'border-left-width: 3px');
          for (final (name, side) in [
            ('top', border.top),
            ('right', border.right),
            ('bottom', border.bottom),
          ]) {
            expect(side.color, treatment.border, reason: '$name side');
            expect(side.width, 1, reason: '$name side');
          }

          expect(
            band(tester).padding,
            const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
            reason: "`.ds-note`'s 9px 11px",
          );
          expect(
            clip(tester).borderRadius,
            const BorderRadius.all(AppMetrics.controlRadius),
            reason: 'a control radius — §4 keeps every radius at or below 4 px',
          );
          expect(mark(tester).color, treatment.mark);
          expect(mark(tester).hollow, treatment.hollowMark);
          expect(
            markBox(tester).constraints,
            const BoxConstraints.tightFor(width: 6, height: 6),
            reason: '`.ds-note__mark` is 6 × 6',
          );
          expect(
            tester
                .widget<Text>(
                  find.descendant(
                    of: find.byType(FeedbackNotice),
                    matching: find.byType(Text),
                  ),
                )
                .style
                ?.color,
            tokens.textPrimary,
            reason:
                'copy is the theme\'s primary text step, in either brightness',
          );
        });
      }
    }

    testWidgets('dark mode resolves B-Dark tokens, not the light ones', (
      WidgetTester tester,
    ) async {
      await pumpNotice(
        tester,
        tone: FeedbackTone.danger,
        theme: AppTheme.dark(),
      );

      final decoration = band(tester).decoration! as BoxDecoration;

      expect(decoration.color, AppTokens.dark.dangerSoft);
      expect(
        decoration.color,
        isNot(AppTokens.light.dangerSoft),
        reason: 'the two palettes differ, so this cannot pass by accident',
      );
    });

    testWidgets('a confirmed tone draws a filled mark', (
      WidgetTester tester,
    ) async {
      // Success, a spent budget and a known failure are all *determinate*
      // outcomes, and §6.5 gives each of them a filled mark. Only the uncertain
      // row is different, and it is asserted separately below.
      for (final tone in [
        FeedbackTone.success,
        FeedbackTone.warning,
        FeedbackTone.danger,
      ]) {
        await pumpNotice(tester, tone: tone, theme: AppTheme.light());

        expect(mark(tester).hollow, isFalse);
        expect(markBox(tester).color, isNotNull);
        expect(
          markBox(tester).decoration,
          isNull,
          reason: 'a hollow mark would be drawn as a border, not a fill',
        );
      }
    });

    testWidgets('the uncertain tone draws a hollow mark in the warning colour', (
      WidgetTester tester,
    ) async {
      // §6.5: "it is the only state that may not claim the item is unsaved, so it
      // must not look like a confirmed failure". The ring is what carries that.
      await pumpNotice(
        tester,
        tone: FeedbackTone.uncertain,
        theme: AppTheme.light(),
      );

      expect(mark(tester).hollow, isTrue);

      final box = markBox(tester);
      expect(box.color, isNull, reason: 'hollow means no fill');

      final decoration = box.decoration! as BoxDecoration;
      expect(decoration.color, isNull);
      expect(decoration.border, isNotNull);
      expect(
        (decoration.border! as Border).top.color,
        AppTokens.light.warning,
        reason: 'the ring is the tone token, not a separate uncertain colour',
      );
      expect(
        (decoration.border! as Border).top.width,
        1,
        reason: 'the ring is `--border-width`, the same hairline as the band',
      );
      expect(
        box.constraints,
        const BoxConstraints.tightFor(width: 6, height: 6),
        reason: 'the same box as a filled mark, in another state',
      );
    });

    testWidgets('the copy is client-owned and rendered as-is', (
      WidgetTester tester,
    ) async {
      await pumpNotice(
        tester,
        tone: FeedbackTone.success,
        theme: AppTheme.light(),
        copy: 'Saved.',
      );

      expect(
        tester
            .widget<Text>(
              find.descendant(
                of: find.byType(FeedbackNotice),
                matching: find.byType(Text),
              ),
            )
            .data,
        'Saved.',
      );
    });

    testWidgets('the mark is squared to the first line, not the band top', (
      WidgetTester tester,
    ) async {
      await pumpNotice(
        tester,
        tone: FeedbackTone.success,
        theme: AppTheme.light(),
      );

      final row = tester.widget<Row>(
        find
            .descendant(
              of: find.byType(FeedbackNotice),
              matching: find.byType(Row),
            )
            .first,
      );
      expect(
        row.crossAxisAlignment,
        CrossAxisAlignment.start,
        reason: 'the mark and the copy share a top edge to hang from',
      );

      final markPadding = tester.widget<Padding>(
        find
            .ancestor(
              of: find.byType(FeedbackMark),
              matching: find.byType(Padding),
            )
            .first,
      );
      expect(
        markPadding.padding,
        const EdgeInsets.only(top: 5),
        reason: "`.ds-note__mark`'s margin-top, not the band's padding",
      );
    });

    for (final (brightness, theme) in <(String, ThemeData)>[
      ('light', AppTheme.light()),
      ('dark', AppTheme.dark()),
    ]) {
      testWidgets('$brightness: long copy wraps inside the band, unclipped', (
        WidgetTester tester,
      ) async {
        // The band is not width-constrained by its own copy: the `Stack` gives
        // it the screen width and this is what a long sentence does inside that.
        final copy = List.generate(30, (index) => 'word$index').join(' ');
        await tester.pumpWidget(
          MaterialApp(
            theme: theme,
            home: Scaffold(
              body: Center(
                child: SizedBox(
                  width: 240,
                  child: FeedbackNotice(
                    feedback: AppFeedback(
                      tone: FeedbackTone.uncertain,
                      copy: copy,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );

        final paragraph = tester.renderObject<RenderParagraph>(find.text(copy));
        expect(paragraph.didExceedMaxLines, isFalse);
        expect(
          paragraph.size.height,
          greaterThan(2 * 15),
          reason: 'the copy takes several lines rather than being cut off',
        );

        final note = tester.getRect(find.byType(FeedbackNotice));
        final text = tester.getRect(find.text(copy));
        expect(
          text.left,
          greaterThan(note.left + 3),
          reason: 'the leading edge and padding stay clear of the copy',
        );
        expect(text.right, lessThanOrEqualTo(note.right));
        expect(
          text.bottom,
          lessThanOrEqualTo(note.bottom),
          reason: 'nothing is clipped or spills out of the band',
        );
        expect(tester.takeException(), isNull);
      });
    }
  });
}
