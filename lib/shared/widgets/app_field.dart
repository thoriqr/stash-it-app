import 'package:flutter/material.dart';
import 'package:stash_it_app/app/theme/app_theme.dart';
import 'package:stash_it_app/l10n/app_localizations.dart';

/// A shared text field with consistent styling, validation, and input states.
///
/// Supports an optional label, machine-text typography, leading and trailing
/// controls, and both form-based and externally supplied validation errors.
///
/// The focused halo is painted by the border itself rather than by a container
/// around the field. This keeps the halo within the input area and prevents it
/// from tinting the validation message below the field.
///
/// Do not set `isDense`. It collapses Material's vertical content padding.
/// The field uses [AppMetrics.fieldContentPadding] and
/// [AppMetrics.fieldHeight] to maintain its intended geometry.
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

  /// Optional label displayed above the field.
  ///
  /// Omit when the field already belongs to a group with its own visible
  /// heading.
  final String? label;

  final TextEditingController? controller;

  /// Placeholder text displayed inside the field.
  final String? placeholder;

  final bool enabled;

  /// Uses machine-text typography, suitable for URLs and similar input.
  final bool mono;

  final bool obscureText;

  final TextInputType? keyboardType;

  final TextInputAction? textInputAction;

  final Iterable<String>? autofillHints;

  final ValueChanged<String>? onSubmitted;

  final ValueChanged<String>? onChanged;

  /// Validates the field when its enclosing [Form] is validated.
  ///
  /// The returned message uses the same error styling and layout as
  /// [errorText].
  final String? Function(String?)? validator;

  /// Displays an external validation error without requiring a [Form].
  ///
  /// Useful when validation happens on submission rather than on every
  /// keystroke. The message is cleared when the user edits the field.
  final String? errorText;

  /// Optional leading icon displayed inside the field.
  final IconData? prefixIcon;

  /// Optional trailing control displayed inside the field.
  ///
  /// The caller owns the control and its state. For example, password
  /// visibility is controlled by the screen rather than by the field.
  ///
  /// Mutually exclusive with [onClear], since both occupy the trailing edge.
  final Widget? suffixIcon;

  /// Optional trailing clear action.
  ///
  /// The caller controls whether this action is available. Pass null when
  /// there is nothing to clear or when clearing is temporarily unavailable.
  final VoidCallback? onClear;

  @override
  State<AppField> createState() => _AppFieldState();
}

class _AppFieldState extends State<AppField> {
  /// Allows editing to clear the validation message for this field only.
  final _fieldKey = GlobalKey<FormFieldState<String>>();

  /// Default gap between the outline border and its content.
  ///
  /// InputDecorator includes this value when positioning helper and error
  /// text, so it must be included when aligning the error message.
  static const double _borderGapPadding = 4;

  static const int _errorMaxLines = 2;

  void _onChanged(String value) {
    // Clear this field's previous validation error immediately after editing.
    // Other fields retain their own validation state.
    _fieldKey.currentState?.clearError();
    widget.onChanged?.call(value);
  }

  /// Builds a validation message aligned with the input text.
  ///
  /// InputDecorator adds content padding and the outline border's gap padding
  /// to the error text inset. Translating the message compensates for that
  /// offset without changing its layout slot or height.
  ///
  /// The offset accounts for RTL layouts as well.
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
          // Form validation errors use the same alignment as external errors.
          errorBuilder: _buildErrorLine,
          style: (widget.mono ? AppTypography.mono : AppTypography.body)
              .copyWith(color: tokens.textPrimary),
          decoration: InputDecoration(
            filled: true,
            fillColor: tokens.surface,
            hintText: widget.placeholder,
            hintStyle: AppTypography.body.copyWith(color: tokens.textTertiary),
            prefixIcon: widget.prefixIcon == null
                ? null
                : Icon(
                    widget.prefixIcon,
                    size: AppMetrics.iconSize,
                    color: tokens.textTertiary,
                  ),
            // Reduce the leading icon slot so it fits the compact field layout.
            prefixIconConstraints: const BoxConstraints(
              minWidth: 36,
              minHeight: AppMetrics.fieldHeight,
            ),
            // Prefer a caller-supplied trailing control. Otherwise, show the
            // clear action when one is available.
            suffixIcon:
                widget.suffixIcon ??
                (widget.onClear == null
                    ? null
                    : IconButton(
                        onPressed: widget.onClear,
                        tooltip: AppLocalizations.of(context).clearTooltip,
                        icon: const Icon(Icons.close),
                        iconSize: AppMetrics.iconSize,
                        color: tokens.textTertiary,
                        padding: EdgeInsets.zero,
                      )),
            contentPadding: AppMetrics.fieldContentPadding,
            constraints: const BoxConstraints(
              minHeight: AppMetrics.fieldHeight,
            ),
            border: _border(tokens.border),
            enabledBorder: _border(tokens.border),
            // Paint the focus halo within the input rectangle so it does not
            // extend into the validation message below the field.
            focusedBorder: _border(
              tokens.accent,
              emphasis: true,
              halo: tokens.focusRing,
            ),
            errorBorder: _border(tokens.danger, emphasis: true),
            // Keep the danger treatment when an invalid field is focused.
            focusedErrorBorder: _border(tokens.danger, emphasis: true),
            disabledBorder: _border(tokens.disabledBorder),
            errorStyle: AppTypography.meta.copyWith(color: tokens.danger),
            errorMaxLines: _errorMaxLines,
            // Use a widget for external errors because errorBuilder and
            // errorText cannot be combined. Both error sources share the
            // same alignment through _buildErrorLine.
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

/// An outline border that can paint a halo around the focused input.
///
/// OutlineInputBorder.paint receives the input box rectangle without the
/// helper or error text below it. Painting the halo here keeps it confined
/// to the input control even when the validation message expands the layout.
class _AppFieldBorder extends OutlineInputBorder {
  const _AppFieldBorder({
    super.borderSide,
    super.borderRadius,
    super.gapPadding,
    this.haloColor,
  });

  /// The halo color, or null when this border does not draw a halo.
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

      // Draw only the area outside the input border to preserve its fill.
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
