import 'package:flutter/material.dart';
import 'package:stash_it_app/app/theme/app_theme.dart';

/// The approved input set — `design-system.md` §6.2.
///
/// Exists because **two** screens need it: sign-in takes an email and a password,
/// and the Inbox intake takes a URL. All three carry a visible label above the
/// field, which Material's own decoration puts *inside* it instead.
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
/// **Do not set `isDense`.** It collapses Material's vertical content padding
/// to nothing, which is what left the text run flush against the top border.
/// The inset is [AppMetrics.fieldContentPadding], and the height is
/// [AppMetrics.fieldHeight].
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
    super.key,
  });

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

  @override
  State<AppField> createState() => _AppFieldState();
}

class _AppFieldState extends State<AppField> {
  final _focusNode = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    // Only the halo is focus-driven, and the field subtree is small, so this is
    // cheaper than plumbing a ValueNotifier into the decoration.
    if (mounted && _focused != _focusNode.hasFocus) {
      setState(() => _focused = _focusNode.hasFocus);
    }
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
        Container(
          // The halo: a hard ring just outside the field's border, drawn as a
          // spread shadow so it does not eat the field's own 2 px border.
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(AppMetrics.controlRadius),
            boxShadow: [
              if (_focused)
                BoxShadow(
                  color: tokens.focusRing,
                  spreadRadius: AppMetrics.focusHaloWidth,
                ),
            ],
          ),
          child: TextFormField(
            controller: widget.controller,
            focusNode: _focusNode,
            enabled: widget.enabled,
            obscureText: widget.obscureText,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            autofillHints: widget.autofillHints,
            onFieldSubmitted: widget.onSubmitted,
            onChanged: widget.onChanged,
            validator: widget.validator,
            style: (widget.mono ? AppTypography.mono : AppTypography.body)
                .copyWith(color: tokens.textPrimary),
            decoration: InputDecoration(
              filled: true,
              fillColor: tokens.surface,
              // Material states a label by default; the specification puts it
              // above the field instead.
              hintText: widget.placeholder,
              hintStyle: AppTypography.body.copyWith(
                color: tokens.textTertiary,
              ),
              // Vertical inset as well as horizontal. Without it the text run
              // sat flush against the top border and the field read as a bar.
              contentPadding: AppMetrics.fieldContentPadding,
              constraints: const BoxConstraints(
                minHeight: AppMetrics.fieldHeight,
              ),
              border: _border(tokens.border),
              enabledBorder: _border(tokens.border),
              focusedBorder: _border(tokens.accent, emphasis: true),
              errorBorder: _border(tokens.danger, emphasis: true),
              focusedErrorBorder: _border(tokens.danger, emphasis: true),
              disabledBorder: _border(tokens.disabledBorder),
              errorStyle: AppTypography.meta.copyWith(color: tokens.danger),
              errorMaxLines: 2,
            ),
          ),
        ),
      ],
    );
  }

  OutlineInputBorder _border(Color color, {bool emphasis = false}) {
    return OutlineInputBorder(
      borderRadius: const BorderRadius.all(AppMetrics.controlRadius),
      borderSide: BorderSide(
        color: color,
        width: emphasis
            ? AppMetrics.borderWidthEmphasis
            : AppMetrics.borderWidth,
      ),
    );
  }
}
