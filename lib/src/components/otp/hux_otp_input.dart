import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/hux_tokens.dart';

/// HuxOtpInput is a customizable OTP (One-Time Password) input component
/// with consistent styling and extensive customization options.
///
/// Provides a clean, modern OTP input with multiple digit fields, automatic
/// focus management, paste support, and validation. Automatically adapts to
/// light and dark themes.
///
/// Example:
/// ```dart
/// HuxOtpInput(
///   length: 6,
///   label: 'Verification Code',
///   onChanged: (value) => print('OTP: $value'),
///   onCompleted: (value) => print('Completed: $value'),
/// )
/// ```
class HuxOtpInput extends StatefulWidget {
  /// Creates a HuxOtpInput widget.
  const HuxOtpInput({
    super.key,
    this.length = 6,
    this.label,
    this.helperText,
    this.errorText,
    this.enabled = true,
    this.obscureText = false,
    this.onChanged,
    this.onCompleted,
    this.validator,
    this.autofocus = false,
    this.width,
  }) : assert(length > 0, 'length must be > 0');

  /// Number of OTP digits (default: 6)
  final int length;

  /// Label text displayed above the OTP input
  final String? label;

  /// Helper text displayed below the OTP input
  final String? helperText;

  /// Error text displayed below the OTP input, overrides helperText
  final String? errorText;

  /// Whether the OTP input is enabled for input
  final bool enabled;

  /// Whether to obscure the digits (for security)
  final bool obscureText;

  /// Called when the OTP value changes
  final ValueChanged<String>? onChanged;

  /// Called when all OTP digits are filled
  final ValueChanged<String>? onCompleted;

  /// Validator function for form validation
  final String? Function(String?)? validator;

  /// Whether to automatically focus the first field
  final bool autofocus;

  /// Width of the OTP input container (optional, defaults to full width)
  final double? width;

  @override
  State<HuxOtpInput> createState() => _HuxOtpInputState();
}

class _HuxOtpInputState extends State<HuxOtpInput> {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;
  String _currentValue = '';
  bool _isPasting = false;
  bool _hasCompleted = false;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.length,
      (index) => TextEditingController(),
    );
    _focusNodes = List.generate(
      widget.length,
      (index) => FocusNode(),
    );

    for (int i = 0; i < widget.length; i++) {
      _controllers[i].addListener(() => _onControllerChanged(i));
    }

    if (widget.autofocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNodes[0].requestFocus();
      });
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _onControllerChanged(int index) {
    if (_isPasting) return;

    final text = _controllers[index].text;
    if (text.length > 1) {
      _controllers[index].text = text[0];
      return;
    }

    _updateValue();

    if (text.isNotEmpty && index < widget.length - 1) {
      _focusNodes[index + 1].requestFocus();
    }
  }

  void _updateValue() {
    final newValue = _controllers.map((c) => c.text).join();
    if (newValue == _currentValue) return;

    final wasComplete = _currentValue.length == widget.length;
    _currentValue = newValue;
    final isComplete = _currentValue.length == widget.length;

    widget.onChanged?.call(_currentValue);

    if (isComplete && !wasComplete && !_hasCompleted) {
      _hasCompleted = true;
      widget.onCompleted?.call(_currentValue);
    } else if (!isComplete) {
      _hasCompleted = false;
    }
  }

  bool _handleKeyEvent(int index, KeyEvent event) {
    if (event.logicalKey == LogicalKeyboardKey.backspace) {
      if (_controllers[index].text.isEmpty && index > 0) {
        _focusNodes[index - 1].requestFocus();
        _controllers[index - 1].clear();
      } else {
        _controllers[index].clear();
      }
      return true;
    }

    if (event.logicalKey == LogicalKeyboardKey.arrowLeft && index > 0) {
      _focusNodes[index - 1].requestFocus();
      return true;
    }

    if (event.logicalKey == LogicalKeyboardKey.arrowRight &&
        index < widget.length - 1 &&
        _controllers[index].text.isNotEmpty) {
      _focusNodes[index + 1].requestFocus();
      return true;
    }

    return false;
  }

  void _handlePaste(String pastedText, int fieldIndex) {
    final digits = pastedText.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return;

    _isPasting = true;
    for (int i = 0;
        i < digits.length && (fieldIndex + i) < widget.length;
        i++) {
      _controllers[fieldIndex + i].text = digits[i];
    }
    _isPasting = false;

    final nextIndex = (fieldIndex + digits.length < widget.length)
        ? fieldIndex + digits.length
        : widget.length - 1;
    _focusNodes[nextIndex].requestFocus();
    _updateValue();
  }

  bool _canFocusField(int index) {
    for (int i = 0; i < index; i++) {
      if (_controllers[i].text.isEmpty) return false;
    }
    return true;
  }

  void _focusFirstEmpty(int beforeIndex) {
    for (int i = 0; i < beforeIndex; i++) {
      if (_controllers[i].text.isEmpty) {
        _focusNodes[i].requestFocus();
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null ||
        (widget.validator != null && widget.validator!(_currentValue) != null);
    final errorMessage = hasError
        ? (widget.errorText ?? widget.validator!(_currentValue) ?? '')
        : null;

    return SizedBox(
      width: widget.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (widget.label != null) ...[
            Text(
              widget.label!,
              style: TextStyle(
                fontSize:
                    Theme.of(context).textTheme.labelMedium?.fontSize ?? 12,
                fontWeight: FontWeight.w300,
                color: HuxTokens.textSecondary(context),
              ),
            ),
            const SizedBox(height: 6),
          ],
          LayoutBuilder(
            builder: (context, constraints) {
              final fieldWidth = _getFieldWidth(constraints.maxWidth);
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _buildDigitFields(context, hasError, fieldWidth),
              );
            },
          ),
          if (widget.helperText != null && !hasError) ...[
            const SizedBox(height: 6),
            Text(
              widget.helperText!,
              style: TextStyle(
                fontSize:
                    Theme.of(context).textTheme.labelSmall?.fontSize ?? 11,
                color: HuxTokens.textSecondary(context),
              ),
            ),
          ],
          if (errorMessage != null) ...[
            const SizedBox(height: 6),
            Text(
              errorMessage,
              style: TextStyle(
                fontSize:
                    Theme.of(context).textTheme.labelSmall?.fontSize ?? 11,
                color: HuxTokens.textDestructive(context),
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<Widget> _buildDigitFields(
    BuildContext context,
    bool hasError,
    double fieldWidth,
  ) {
    final children = <Widget>[];

    for (int i = 0; i < widget.length; i++) {
      if (i == 3 && widget.length == 6) {
        children.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Container(
              width: 12,
              height: 1,
              decoration: BoxDecoration(
                color: HuxTokens.borderPrimary(context),
                borderRadius: BorderRadius.circular(0.5),
              ),
            ),
          ),
        );
      }

      children.add(
        Padding(
          padding: EdgeInsets.only(
            left: i == 0 ? 0 : 4,
            right: i == widget.length - 1 ? 0 : 4,
          ),
          child: _buildDigitField(context, i, hasError, fieldWidth),
        ),
      );
    }

    return children;
  }

  double _getFieldWidth(double maxWidth) {
    if (widget.length <= 0) {
      return 48;
    }

    if (!maxWidth.isFinite || maxWidth <= 0) {
      return 48;
    }

    final totalSpacing = widget.length == 6
        ? ((widget.length - 1) * 8) + 20
        : (widget.length - 1) * 8;
    final availableWidth = maxWidth - totalSpacing;
    return (availableWidth / widget.length).clamp(36, 48).toDouble();
  }

  Widget _buildDigitField(
    BuildContext context,
    int index,
    bool hasError,
    double fieldWidth,
  ) {
    final canFocus = _canFocusField(index);
    final isFocused = _focusNodes[index].hasFocus;
    final borderColor = _getBorderColor(context, hasError, isFocused);

    return SizedBox(
      width: fieldWidth,
      height: 48,
      child: AbsorbPointer(
        absorbing: !canFocus,
        child: Focus(
          canRequestFocus: canFocus,
          onKeyEvent: (node, event) {
            if (event is KeyDownEvent) {
              return _handleKeyEvent(index, event)
                  ? KeyEventResult.handled
                  : KeyEventResult.ignored;
            }
            return KeyEventResult.ignored;
          },
          child: GestureDetector(
            onTap: canFocus
                ? () {
                    _controllers[index].selection = TextSelection(
                      baseOffset: 0,
                      extentOffset: _controllers[index].text.length,
                    );
                    _focusNodes[index].requestFocus();
                  }
                : () => _focusFirstEmpty(index),
            child: TextField(
              controller: _controllers[index],
              focusNode: _focusNodes[index],
              enabled: widget.enabled,
              obscureText: widget.obscureText,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                _OtpInputFormatter(
                  onPaste: (text) => _handlePaste(text, index),
                ),
              ],
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                height: 1.4,
                color: widget.enabled
                    ? HuxTokens.textPrimary(context)
                    : HuxTokens.textDisabled(context),
              ),
              decoration: _buildInputDecoration(
                  context, hasError, isFocused, borderColor),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(
    BuildContext context,
    bool hasError,
    bool isFocused,
    Color borderColor,
  ) {
    final borderRadius = BorderRadius.circular(8);
    final errorColor = HuxTokens.textDestructive(context);
    final focusedErrorWidth = isFocused && hasError ? 2.0 : 1.0;

    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(vertical: 12),
      border: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(color: borderColor, width: focusedErrorWidth),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(
          color: hasError
              ? errorColor
              : HuxTokens.primary(context).withValues(alpha: 0.5),
          width: focusedErrorWidth,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(color: HuxTokens.borderSecondary(context)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(color: errorColor, width: 2),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(color: HuxTokens.borderSecondary(context)),
      ),
      filled: true,
      fillColor: widget.enabled
          ? HuxTokens.surfacePrimary(context)
          : HuxTokens.surfaceSecondary(context),
    );
  }

  Color _getBorderColor(BuildContext context, bool hasError, bool isFocused) {
    if (!widget.enabled || hasError) {
      return HuxTokens.borderSecondary(context);
    }
    if (isFocused) {
      return HuxTokens.primary(context).withValues(alpha: 0.5);
    }
    return HuxTokens.borderPrimary(context);
  }
}

/// Custom TextInputFormatter for OTP input that handles paste operations
class _OtpInputFormatter extends TextInputFormatter {
  _OtpInputFormatter({required this.onPaste});

  final void Function(String) onPaste;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.length > 1) {
      onPaste(newValue.text);
      return oldValue;
    }
    return newValue;
  }
}
