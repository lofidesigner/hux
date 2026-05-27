import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/hux_tokens.dart';

/// HuxInput is a customizable text input component with consistent styling
/// and extensive customization options.
///
/// Provides a clean, modern text input with support for labels, hints,
/// validation, icons, and different sizes. Automatically adapts to light
/// and dark themes.
///
/// Example:
/// ```dart
/// HuxInput(
///   label: 'Email Address',
///   hint: 'Enter your email',
///   prefixIcon: Icon(Icons.email),
///   keyboardType: TextInputType.emailAddress,
///   validator: (value) {
///     if (value?.isEmpty ?? true) return 'Email is required';
///     if (!value!.contains('@')) return 'Invalid email';
///     return null;
///   },
///   onChanged: (value) => print('Email: $value'),
/// )
/// ```
class HuxInput extends StatefulWidget {
  /// Creates a HuxInput widget.
  const HuxInput({
    super.key,
    this.focusNode,
    this.controller,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.enabled = true,
    this.maxLines = 1,
    this.minLines = 1,
    this.autoValidateMode = AutovalidateMode.disabled,
    this.inputFormatters,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.iconSize,
    this.width,
  });

  /// Focus node for managing focus state of the text field
  final FocusNode? focusNode;

  /// Controller for the text field
  final TextEditingController? controller;

  /// Label text displayed above the text field
  final String? label;

  /// Hint text displayed inside the text field when empty
  final String? hint;

  /// Helper text displayed below the text field
  final String? helperText;

  /// Error text displayed below the text field, overrides helperText
  final String? errorText;

  /// Widget displayed at the beginning of the text field
  final Widget? prefixIcon;

  /// Widget displayed at the end of the text field
  final Widget? suffixIcon;

  /// Whether to obscure the text (for passwords)
  final bool obscureText;

  /// Whether the text field is enabled for input
  final bool enabled;

  /// Maximum number of lines for the text field
  final int maxLines;

  /// Minimum number of lines for the text field (optional, defaults to 1)
  final int minLines;

  /// Autovalidate mode for the text field (optional, defaults to disabled)
  final AutovalidateMode autoValidateMode;

  /// Input formatters for the text field (optional)
  final List<TextInputFormatter>? inputFormatters;

  /// The type of keyboard to use for editing the text
  final TextInputType? keyboardType;

  /// The type of action button to use for the keyboard
  final TextInputAction? textInputAction;

  /// Called when the text field value changes
  final ValueChanged<String>? onChanged;

  /// Called when the user submits the text field
  final ValueChanged<String>? onSubmitted;

  /// Validator function for form validation
  final String? Function(String?)? validator;

  /// Custom size for the prefix and suffix icons
  final double? iconSize;

  /// Width of the text field (optional, defaults to full width)
  final double? width;

  @override
  State<HuxInput> createState() => _HuxInputState();
}

class _HuxInputState extends State<HuxInput> {
  bool _obscureText = false;
  bool _isPasswordField = false;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
    _isPasswordField = widget.obscureText;
  }

  @override
  void didUpdateWidget(HuxInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.obscureText != widget.obscureText) {
      _obscureText = widget.obscureText;
      _isPasswordField = widget.obscureText;
    }
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  Widget? _buildPasswordToggleIcon(BuildContext context) {
    if (!_isPasswordField) return null;

    final effectiveIconSize = widget.iconSize ?? _getDefaultIconSize();
    final outerPadding = _getIconHorizontalPadding();
    const innerPadding = 4.0;

    return GestureDetector(
      onTap: _togglePasswordVisibility,
      child: Padding(
        padding: EdgeInsets.only(
          left: innerPadding,
          right: outerPadding,
        ),
        child: SizedBox(
          width: effectiveIconSize,
          height: effectiveIconSize,
          child: Center(
            child: IconTheme(
              data: IconThemeData(
                size: effectiveIconSize,
                color: HuxTokens.iconSecondary(context),
              ),
              child: Icon(
                _obscureText ? LucideIcons.eye : LucideIcons.eyeOff,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (widget.label != null) ...[
        Text(
          widget.label!,
          style: TextStyle(
            fontSize: Theme.of(context).textTheme.labelMedium?.fontSize ?? 12,
            fontWeight: FontWeight.w300,
            color: HuxTokens.textSecondary(context),
          ),
        ),
        const SizedBox(height: 6),
      ],
      SizedBox(
        width: widget.width,
        child: TextFormField(
          focusNode: widget.focusNode,
          controller: widget.controller,
          obscureText: _obscureText,
          enabled: widget.enabled,

          maxLines: widget.maxLines,
          minLines: widget.minLines,
          inputFormatters: widget.inputFormatters,
          autovalidateMode: widget.autoValidateMode,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onSubmitted,
          validator: widget.validator,
          style: const TextStyle(
            fontSize: 14, // Small text size for all text fields
            height: 1.4,
          ),
          decoration: InputDecoration(
            isDense: true,
            visualDensity: VisualDensity.comfortable,
            hintText: widget.hint,
            prefixIcon: widget.prefixIcon != null
                ? _buildIcon(widget.prefixIcon!,
                    isPrefix: true, context: context)
                : null,
            suffixIcon: _isPasswordField
                ? _buildPasswordToggleIcon(context)
                : (widget.suffixIcon != null
                    ? _buildIcon(widget.suffixIcon!,
                        isPrefix: false, context: context)
                    : null),
            prefixIconConstraints: widget.prefixIcon != null
                ? BoxConstraints(
                    minWidth: _getIconConstraintWidth(),
                    maxWidth: _getIconConstraintWidth(),
                  )
                : null,
            suffixIconConstraints:
                (_isPasswordField || widget.suffixIcon != null)
                    ? BoxConstraints(
                        minWidth: _getIconConstraintWidth(),
                        maxWidth: _getIconConstraintWidth(),
                      )
                    : null,
            errorText: widget.errorText,
            helperText: widget.helperText,
            contentPadding: EdgeInsets.symmetric(
              horizontal: _getHorizontalPadding(),
              vertical: _getVerticalPadding(),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: HuxTokens.borderPrimary(context),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: HuxTokens.borderPrimary(context),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: HuxTokens.primary(context).withValues(alpha: 0.5),
                width: 1,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: HuxTokens.borderSecondary(context),
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: HuxTokens.textDestructive(context),
                width: 2,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: HuxTokens.borderSecondary(context),
              ),
            ),
            filled: true,
            fillColor: widget.enabled
                ? HuxTokens.surfacePrimary(context)
                : HuxTokens.surfaceSecondary(context),
          ),
        ),
      ),
    ]);
  }

  // Note: The height of the text field is determined by the content padding and font size, so we don't set a fixed height.
  // This allows the text field to adapt to different content and maintain consistent spacing across all variants.
  // double _getHeight() {
  //   return 40; // Single consistent height for all text fields
  // }

  Widget _buildIcon(Widget icon,
      {required bool isPrefix, required BuildContext context}) {
    final effectiveIconSize = widget.iconSize ?? _getDefaultIconSize();
    final outerPadding = _getIconHorizontalPadding();
    const innerPadding = 4.0; // Small gap between icon and text

    return Padding(
      padding: EdgeInsets.only(
        left: isPrefix ? outerPadding : innerPadding,
        right: isPrefix ? innerPadding : outerPadding,
      ),
      child: SizedBox(
        width: effectiveIconSize,
        height: effectiveIconSize,
        child: Center(
          child: IconTheme(
            data: IconThemeData(
              size: effectiveIconSize,
              color: HuxTokens.iconSecondary(context),
            ),
            child: icon,
          ),
        ),
      ),
    );
  }

  double _getIconConstraintWidth() {
    final effectiveIconSize = widget.iconSize ?? _getDefaultIconSize();
    final outerPadding = _getIconHorizontalPadding();
    const innerPadding = 5.0;
    return effectiveIconSize + outerPadding + innerPadding;
  }

  double _getIconHorizontalPadding() {
    return 14; // Single consistent icon padding for all text fields
  }

  double _getDefaultIconSize() {
    return 18; // Single consistent icon size for all text fields
  }

  double _getHorizontalPadding() {
    return 18; // Single consistent horizontal padding for all text fields
  }

  double _getVerticalPadding() {
    return 12; // Single consistent vertical padding for all text fields
  }
}
