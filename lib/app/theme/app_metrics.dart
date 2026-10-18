import 'package:flutter/widgets.dart';

/// The approved design system's **shape and rhythm** — `design-system.md` §4 and §5.
///
/// Split from [AppTokens] because none of it changes with brightness: there is one
/// spacing scale, one radius scale and one border width, and giving dark mode a
/// second set would imply a difference that does not exist.
///
/// **Nothing here is above 4 px on a control.** A control's corner radius is a
/// decision, not a preference: a rounded button reads as a consumer app, and the
/// approved direction is deliberately square.
abstract final class AppMetrics {
  // ---- spacing scale: 4 · 8 · 12 · 16 · 20 · 24 · 32 ----
  static const double space1 = 4;
  static const double space2 = 8;
  static const double space3 = 12;
  static const double space4 = 16;
  static const double space5 = 20;
  static const double space6 = 24;
  static const double space7 = 32;

  /// Horizontal screen padding. Profile and search groups use [space5].
  static const double screenPadding = space4;

  // ---- radii: 0 · 2 · 3 · 4 ----
  static const double radius0 = 0;
  static const double radius1 = 2;
  static const double radius2 = 3;
  static const double radius3 = 4;

  /// Inputs and chips: 2 px.
  static const Radius controlRadius = Radius.circular(radius1);

  /// Inventory slots: 3 px.
  static const Radius slotRadius = Radius.circular(radius2);

  // ---- borders ----
  static const double borderWidth = 1;

  /// Focus and error borders: 2 px.
  static const double borderWidthEmphasis = 2;

  /// The halo drawn around a focused field, outside its border.
  static const double focusHaloWidth = 3;

  // ---- icons ----
  static const double iconSize = 18;

  /// The brand mark beside the wordmark on an auth screen.
  static const double brandMarkSize = 26;

  // ---- control heights ----
  static const double buttonHeight = 34;
  static const double buttonHeightSmall = 24;

  /// Input height.
  ///
  /// **48 px, not 40.** The specification states 40 in §6.2, and 40 was what
  /// shipped first — but the rendered field put its 20 px text run flush against
  /// the top border with 20 px of dead space beneath it, so it read as a thin
  /// text bar rather than a control, and it was under Material's 48 px minimum
  /// touch target. 48 keeps the specified geometry's proportions while making
  /// the field comfortably tappable, which is what the field is for.
  static const double fieldHeight = 48;

  /// Vertical inset inside a field.
  ///
  /// This is the rule that makes the height read as a filled control. Supplying
  /// a horizontal inset only — combined with `isDense`, which collapses
  /// Material's own vertical padding — left the text touching the top border.
  static const EdgeInsets fieldContentPadding = EdgeInsets.symmetric(
    horizontal: space3,
    vertical: space3,
  );

  // ---- inventory slot ----
  static const double slotThumbSize = 56;

  /// Internal slot padding.
  static const EdgeInsets slotPadding = EdgeInsets.symmetric(
    horizontal: 12,
    vertical: 11,
  );

  /// Gap between a slot's thumbnail and its text column.
  static const double slotGap = 12;
}
