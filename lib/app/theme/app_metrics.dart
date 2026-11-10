import 'package:flutter/widgets.dart';

/// Shared layout and component dimensions.
///
/// These values are independent of the active theme, so spacing, radii, and
/// border widths use the same scale in light and dark mode.
abstract final class AppMetrics {
  // ---- spacing ----

  static const double space1 = 4;
  static const double space2 = 8;
  static const double space3 = 12;
  static const double space4 = 16;
  static const double space5 = 20;
  static const double space6 = 24;
  static const double space7 = 32;

  /// Default horizontal screen padding.
  ///
  /// Profile and Search groups use [space5] instead.
  static const double screenPadding = space4;

  // ---- radii ----

  static const double radius0 = 0;
  static const double radius1 = 2;
  static const double radius2 = 3;
  static const double radius3 = 4;

  /// Corner radius for inputs and chips.
  static const Radius controlRadius = Radius.circular(radius1);

  /// Corner radius for inventory slots.
  static const Radius slotRadius = Radius.circular(radius2);

  // ---- borders ----

  static const double borderWidth = 1;

  /// Used for emphasized borders, such as focused and invalid fields.
  static const double borderWidthEmphasis = 2;

  /// Width of the halo outside a focused field's border.
  static const double focusHaloWidth = 3;

  // ---- icons ----

  static const double iconSize = 18;

  /// Size of the brand mark beside the wordmark on authentication screens.
  static const double brandMarkSize = 36;

  // ---- control heights ----

  static const double buttonHeight = 34;
  static const double buttonHeightSmall = 24;

  /// Input height.
  ///
  /// Kept at 48 px rather than the originally specified 40 px. At 40 px, the
  /// rendered text appeared too close to the top border, leaving excessive
  /// empty space below it. The larger height provides balanced vertical
  /// spacing and meets Material's 48 px minimum touch-target size.
  static const double fieldHeight = 48;

  /// Content inset inside input fields.
  ///
  /// Vertical padding is required because dense Material fields can collapse
  /// their default vertical spacing. Without it, text sits too close to the
  /// top border.
  static const EdgeInsets fieldContentPadding = EdgeInsets.symmetric(
    horizontal: space3,
    vertical: space3,
  );

  // ---- inventory slots ----

  static const double slotThumbSize = 56;

  /// Internal padding around slot content.
  static const EdgeInsets slotPadding = EdgeInsets.symmetric(
    horizontal: 12,
    vertical: 11,
  );

  /// Gap between the thumbnail and the text column.
  static const double slotGap = 12;

  // ---- feedback notes ----

  /// Internal content padding.
  ///
  /// The border is outside this inset. The leading side also includes
  /// [noticeEdgeWidth].
  static const EdgeInsets noticePadding = EdgeInsets.symmetric(
    horizontal: 11,
    vertical: 9,
  );

  /// Width of the colored leading edge of a feedback note.
  ///
  /// The remaining sides use the standard [borderWidth].
  static const double noticeEdgeWidth = 3;

  /// Size of the square mark displayed inside a feedback note.
  static const double noticeMarkSize = 6;

  /// Vertical offset of the mark from the top of the first text line.
  ///
  /// Aligns the mark with the note text rather than with the container padding.
  static const double noticeMarkTop = 5;
}
