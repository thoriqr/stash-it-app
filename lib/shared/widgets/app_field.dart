import 'package:flutter/material.dart';
import 'package:stash_it_app/app/theme/app_theme.dart';

/// The approved input set — `design-system.md` §6.2.
///
/// Exists because several screens need it: sign-in takes an email and a
/// password, the Inbox intake takes a URL, and Search takes a query. The
/// credential and URL fields carry a visible label above the field, which
/// Material's own decoration puts *inside* it instead.
///
/// Every state the specification calls out is represented, and each maps to one
/// token:
///
/// | State | Treatment |
/// | --- | --- |
/// | default | surface fill, 1 px border, 48 px tall |
/// | focused | 2 px accent border **and** a 3 px accent halo |
/// | invalid | 2 px danger border, danger message below |
/// | disabled | disabled fill, disabled border, disabled text |
///
/// **The halo is painted by the focused border, not by a container around the
/// field.** An `InputDecorator` reserves the space for its error message inside
/// its own box, so a decorated box wrapping the whole field also wraps the
/// message: a spread shadow then tints the background behind the error text.
/// The border painter receives only the input box's rectangle, so the halo
/// cannot leak into the message area.
///
/// **Do not set `isDense`.** It collapses Material's vertical content padding
/// to nothing, which is what left the text run flush against the top border.
/// The inset is [AppMetrics.fieldContentPadding], and the height is
/// [AppMetrics.fieldHeight].
///
/// **Validation messages align with the field's leading edge.** `InputDecorator`
/// insets helper and error text by the content padding plus the outline
/// border's `gapPadding`, which lines it up with the input text instead of the
/// border. There is no decoration property for that inset, so the message is
/// translated by that exact amount — see [_buildErrorLine].
///
/// The URL field sets [mono] because the mono face is for machine text; a name
/// or password uses the UI face.
class AppField extends StatefulWidget {
  const AppField({
    this.label,
    this.controller,
    this.placeholder,
    this.enabled = true,
    this.mono = false,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.onSubmitted,
    this.onChanged,
    this.validator,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.onClear,
    super.key,
  }) : assert(
         suffixIcon == null || onClear == null,
         'A field has one trailing edge: pass suffixIcon or onClear, not both.',
       );

  /// The visible label above the field.
  ///
  /// Optional because a field inside a labelled group — the Inbox intake band —
  /// takes its heading from that group instead. Every standalone field has one.
  final String? label;

  final TextEditingController? controller;

  /// Placeholder text inside the field.
  final String? placeholder;

  final bool enabled;

  /// Sets the machine-text face, for URLs and other machine input.
  final bool mono;

  final bool obscureText;

  final TextInputType? keyboardType;

  final TextInputAction? textInputAction;

  final Iterable<String>? autofillHints;

  final ValueChanged<String>? onSubmitted;

  final ValueChanged<String>? onChanged;

  /// Form validation, so the field can live inside a [Form]. The returned message
  /// is rendered below the field in the danger colour with a 2 px danger border,
  /// which is the specification's invalid treatment.
  final String? Function(String?)? validator;

  /// An error to display without a [Form].
  ///
  /// For a screen that validates on submission rather than on every keystroke:
  /// the Search query is checked against the backend's bounds only when the user
  /// submits, and the message must disappear as soon as they edit. Sharing the
  /// same decoration path as [validator] gives the field the approved invalid
  /// border and message instead of a second, bespoke treatment.
  final String? errorText;

  /// An optional leading icon, inside the field.
  ///
  /// The Search field is the only consumer: `design-system.md` §5 gives it a
  /// lens, and the field is the control the icon belongs to. Absent by default,
  /// so every existing field renders exactly as it did.
  final IconData? prefixIcon;

  /// An optional trailing control inside the field.
  ///
  /// The caller owns both the control and its state. Sign-in passes the password
  /// visibility toggle: whether the text is obscured is screen state, not field
  /// state, so the field cannot decide which icon to show.
  ///
  /// Mutually exclusive with [onClear], because both occupy the trailing edge.
  /// Absent by default, so every field that does not pass it renders exactly as
  /// it did.
  final Widget? suffixIcon;

  /// An optional trailing clear action, rendered as a small `X` inside the
  /// field.
  ///
  /// **The caller owns availability.** Pass `null` when there is nothing to
  /// clear — an empty or whitespace-only value — or while clearing would
  /// conflict with an in-flight action. The icon then disappears rather than
  /// disabling into a state `design-system.md` §6.2 does not define.
  ///
  /// Absent by default, so every field that does not pass it renders exactly as
  /// it did, including its 48 px geometry.
  final VoidCallback? onClear;

  @override
  State<AppField> createState() => _AppFieldState();
}

class _AppFieldState extends State<AppField> {
  /// The inner form field, so editing can clear the message the last validation
  /// left behind without waiting for another submission.
  final _fieldKey = GlobalKey<FormFieldState<String>>();

  /// `OutlineInputBorder`'s default `gapPadding`. `InputDecorator` adds it to
  /// the content padding when positioning helper and error text, so it is part
  /// of the inset the message is translated by.
  static const double _borderGapPadding = 4;

  /// The message wraps to two lines, as it did through `errorMaxLines`.
  static const int _errorMaxLines = 2;

  void _onChanged(String value) {
    // `FormFieldState.didChange` records the edit but deliberately keeps the
    // message `Form.validate` produced. Editing is the user answering that
    // message, so it goes immediately — only this field's state is touched, so
    // editing Email never clears Password's message. Validation itself still
    // runs on submission, including every rule and message.
    _fieldKey.currentState?.clearError();
    widget.onChanged?.call(value);
  }

  /// The validation message, aligned with the field's leading edge.
  ///
  /// `InputDecorator` positions helper and error text at the content padding
  /// plus the outline border's `gapPadding`, lining it up with the input text
  /// rather than the field's border. No `InputDecoration` property changes that
  /// inset, so a translation moves only the paint; the text slot and its height
  /// stay exactly as they were.
  Widget _buildErrorLine(BuildContext context, String message) {
    final inset = AppMetrics.fieldContentPadding.left + _borderGapPadding;
    final offset = Directionality.of(context) == TextDirection.rtl
        ? inset
        : -inset;

    return Transform.translate(
      offset: Offset(offset, 0),
      child: Text(
        message,
        maxLines: _errorMaxLines,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AppTheme.tokensOf(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label case final label?) ...[
          // A visible label above every field, per the specification.
          Text(
            label,
            style: AppTypography.label.copyWith(color: tokens.textSecondary),
          ),
          const SizedBox(height: AppMetrics.space2),
        ],
        TextFormField(
          key: _fieldKey,
          controller: widget.controller,
          enabled: widget.enabled,
          obscureText: widget.obscureText,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          autofillHints: widget.autofillHints,
          onFieldSubmitted: widget.onSubmitted,
          onChanged: _onChanged,
          validator: widget.validator,
          // The Form's error is only available here, so it takes the same
          // alignment path as the caller-supplied [AppField.errorText].
          errorBuilder: _buildErrorLine,
          style: (widget.mono ? AppTypography.mono : AppTypography.body)
              .copyWith(color: tokens.textPrimary),
          decoration: InputDecoration(
            filled: true,
            fillColor: tokens.surface,
            // Material states a label by default; the specification puts it
            // above the field instead.
            hintText: widget.placeholder,
            hintStyle: AppTypography.body.copyWith(color: tokens.textTertiary),
            prefixIcon: widget.prefixIcon == null
                ? null
                : Icon(
                    widget.prefixIcon,
                    size: AppMetrics.iconSize,
                    color: tokens.textTertiary,
                  ),
            // The default 48 px slot pushes the text too far from the icon for
            // this field's compact search affordance.
            prefixIconConstraints: const BoxConstraints(
              minWidth: 36,
              minHeight: AppMetrics.fieldHeight,
            ),
            // A full 48 px tap target inside the field's own height, with the
            // same 18 px glyph as the leading affordance.
            suffixIcon:
                widget.suffixIcon ??
                (widget.onClear == null
                    ? null
                    : IconButton(
                        onPressed: widget.onClear,
                        tooltip: 'Clear',
                        icon: const Icon(Icons.close),
                        iconSize: AppMetrics.iconSize,
                        color: tokens.textTertiary,
                        padding: EdgeInsets.zero,
                      )),
            // Vertical inset as well as horizontal. Without it the text run
            // sat flush against the top border and the field read as a bar.
            contentPadding: AppMetrics.fieldContentPadding,
            constraints: const BoxConstraints(
              minHeight: AppMetrics.fieldHeight,
            ),
            border: _border(tokens.border),
            enabledBorder: _border(tokens.border),
            // The halo rides on the focused border so it is clipped to the
            // input box and never the error message below it.
            focusedBorder: _border(
              tokens.accent,
              emphasis: true,
              halo: tokens.focusRing,
            ),
            errorBorder: _border(tokens.danger, emphasis: true),
            // No accent halo on an invalid field: the danger border is the
            // error treatment, and a green ring would contradict it. Email and
            // Password therefore share exactly the same error styling.
            focusedErrorBorder: _border(tokens.danger, emphasis: true),
            disabledBorder: _border(tokens.disabledBorder),
            errorStyle: AppTypography.meta.copyWith(color: tokens.danger),
            errorMaxLines: _errorMaxLines,
            // A widget rather than `errorText` because TextFormField forbids
            // combining `errorBuilder` with a static `errorText`, and Form
            // errors use the former. Both paths share [_buildErrorLine].
            error: switch (widget.errorText) {
              final errorText? => _buildErrorLine(context, errorText),
              null => null,
            },
          ),
        ),
      ],
    );
  }

  _AppFieldBorder _border(Color color, {bool emphasis = false, Color? halo}) {
    return _AppFieldBorder(
      borderRadius: const BorderRadius.all(AppMetrics.controlRadius),
      borderSide: BorderSide(
        color: color,
        width: emphasis
            ? AppMetrics.borderWidthEmphasis
            : AppMetrics.borderWidth,
      ),
      gapPadding: _borderGapPadding,
      haloColor: halo,
    );
  }
}

/// An outline border that can paint the focused field's halo.
///
/// `OutlineInputBorder.paint` receives the input box's rectangle, which excludes
/// the error/helper text below it. Painting the halo here keeps it around the
/// control itself even when an error message expands the field's height.
class _AppFieldBorder extends OutlineInputBorder {
  const _AppFieldBorder({
    super.borderSide,
    super.borderRadius,
    super.gapPadding,
    this.haloColor,
  });

  /// The halo's colour, or `null` when this border does not draw one.
  final Color? haloColor;

  @override
  void paint(
    Canvas canvas,
    Rect rect, {
    double? gapStart,
    double gapExtent = 0.0,
    double gapPercentage = 0.0,
    TextDirection? textDirection,
  }) {
    final halo = haloColor;
    if (halo != null && halo.a > 0) {
      final inner = borderRadius.resolve(textDirection).toRRect(rect);
      final outer = inner.inflate(AppMetrics.focusHaloWidth);
      // Only the ring outside the field: a filled inflated rectangle would
      // paint over the field's own fill.
      final ring = Path.combine(
        PathOperation.difference,
        Path()..addRRect(outer),
        Path()..addRRect(inner),
      );
      canvas.drawPath(ring, Paint()..color = halo);
    }

    super.paint(
      canvas,
      rect,
      gapStart: gapStart,
      gapExtent: gapExtent,
      gapPercentage: gapPercentage,
      textDirection: textDirection,
    );
  }

  @override
  _AppFieldBorder copyWith({
    BorderSide? borderSide,
    BorderRadius? borderRadius,
    double? gapPadding,
  }) {
    return _AppFieldBorder(
      borderSide: borderSide ?? this.borderSide,
      borderRadius: borderRadius ?? this.borderRadius,
      gapPadding: gapPadding ?? this.gapPadding,
      haloColor: haloColor,
    );
  }

  @override
  _AppFieldBorder scale(double t) {
    return _AppFieldBorder(
      borderSide: borderSide.scale(t),
      borderRadius: borderRadius * t,
      gapPadding: gapPadding * t,
      haloColor: haloColor,
    );
  }

  @override
  ShapeBorder? lerpFrom(ShapeBorder? a, double t) {
    final border = super.lerpFrom(a, t);
    if (border is OutlineInputBorder) {
      return _AppFieldBorder(
        borderSide: border.borderSide,
        borderRadius: border.borderRadius,
        gapPadding: border.gapPadding,
        haloColor: Color.lerp(
          a is _AppFieldBorder ? a.haloColor : null,
          haloColor,
          t,
        ),
      );
    }
    return border;
  }

  @override
  ShapeBorder? lerpTo(ShapeBorder? b, double t) {
    final border = super.lerpTo(b, t);
    if (border is OutlineInputBorder) {
      return _AppFieldBorder(
        borderSide: border.borderSide,
        borderRadius: border.borderRadius,
        gapPadding: border.gapPadding,
        haloColor: Color.lerp(
          haloColor,
          b is _AppFieldBorder ? b.haloColor : null,
          t,
        ),
      );
    }
    return border;
  }

  @override
  bool operator ==(Object other) {
    return other is _AppFieldBorder &&
        other.borderSide == borderSide &&
        other.borderRadius == borderRadius &&
        other.gapPadding == gapPadding &&
        other.haloColor == haloColor;
  }

  @override
  int get hashCode =>
      Object.hash(borderSide, borderRadius, gapPadding, haloColor);
}
