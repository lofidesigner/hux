import 'package:flutter/material.dart';
import '../../theme/hux_tokens.dart';

/// HuxTextarea is a customizable multi-line text input component with consistent
/// styling and extensive customization options.
///
/// Provides a clean, modern textarea with support for labels, hints, validation,
/// and different sizes. Automatically adapts to light and dark themes.
/// Optimized for multi-line text input with proper height handling.
///
/// Example:
/// ```dart
/// HuxTextarea(
///   label: 'Description',
///   hint: 'Enter your description',
///   minLines: 3,
///   maxLines: 6,
///   validator: (value) {
///     if (value?.isEmpty ?? true) return 'Description is required';
///     if (value!.length < 10) return 'Description must be at least 10 characters';
///     return null;
///   },
///   onChanged: (value) => print('Description: $value'),
/// )
/// ```
class HuxTextarea extends StatefulWidget {
  /// Creates a HuxTextarea widget.
  const HuxTextarea({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.enabled = true,
    this.minLines = 3,
    this.maxLines = 6,
    this.maxLength,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.width,
    this.showCharacterCount = false,
  });

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

  /// Whether the text field is enabled for input
  final bool enabled;

  /// Minimum number of lines for the textarea
  final int minLines;

  /// Maximum number of lines for the textarea
  final int? maxLines;

  /// Maximum character length
  final int? maxLength;

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

  /// Width of the text field (optional, defaults to full width)
  final double? width;

  /// Whether to show character count when maxLength is set
  final bool showCharacterCount;

  @override
  State<HuxTextarea> createState() => _HuxTextareaState();
}

class _HuxTextareaState extends State<HuxTextarea> {
  late TextEditingController _internalController;
  bool _isInternalController = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _internalController = widget.controller!;
    } else {
      _internalController = TextEditingController();
      _isInternalController = true;
    }
    _internalController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _internalController.removeListener(_onTextChanged);
    if (_isInternalController) {
      _internalController.dispose();
    }
    super.dispose();
  }

  void _onTextChanged() {
    if (widget.showCharacterCount && widget.maxLength != null) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: TextStyle(
              fontSize: Theme.of(context).textTheme.labelMedium?.fontSize ?? 12,
              fontWeight: FontWeight.w400,
              color: HuxTokens.textSecondary(context),
            ),
          ),
          const SizedBox(height: 6),
        ],
        SizedBox(
          width: widget.width,
          child: TextFormField(
            controller: _internalController,
            enabled: widget.enabled,
            minLines: widget.minLines,
            maxLines: widget.maxLines,
            maxLength: widget.maxLength,
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
              hintText: widget.hint,
              errorText: widget.errorText,
              helperText: _buildHelperText(context),
              contentPadding: EdgeInsets.symmetric(
                horizontal: _getHorizontalPadding(),
                vertical: _getVerticalPadding(),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(HuxTokens.radiusMd(context)),
                borderSide: BorderSide(
                  color: HuxTokens.borderPrimary(context),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(HuxTokens.radiusMd(context)),
                borderSide: BorderSide(
                  color: HuxTokens.borderPrimary(context),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(HuxTokens.radiusMd(context)),
                borderSide: BorderSide(
                  color: HuxTokens.primary(context).withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(HuxTokens.radiusMd(context)),
                borderSide: BorderSide(
                  color: HuxTokens.borderSecondary(context),
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(HuxTokens.radiusMd(context)),
                borderSide: BorderSide(
                  color: HuxTokens.textDestructive(context),
                  width: 2,
                ),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(HuxTokens.radiusMd(context)),
                borderSide: BorderSide(
                  color: HuxTokens.borderSecondary(context),
                ),
              ),
              filled: true,
              fillColor: widget.enabled
                  ? HuxTokens.surfacePrimary(context)
                  : HuxTokens.surfaceSecondary(context),
              counterText: widget.showCharacterCount && widget.maxLength != null
                  ? _buildCharacterCount(context)
                  : widget.maxLength != null && !widget.showCharacterCount
                      ? ''
                      : null,
            ),
          ),
        ),
      ],
    );
  }

  String? _buildHelperText(BuildContext context) {
    if (widget.errorText != null) return null;
    if (widget.helperText != null) return widget.helperText;
    return null;
  }

  String? _buildCharacterCount(BuildContext context) {
    if (!widget.showCharacterCount || widget.maxLength == null) return null;

    final currentLength = _internalController.text.length;

    return '$currentLength / ${widget.maxLength}';
  }

  double _getHorizontalPadding() {
    return 12; // Compact padding for textarea (no icons, more text-focused)
  }

  double _getVerticalPadding() {
    return 12; // Single consistent vertical padding for all text fields
  }
}
