import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/hux_tokens.dart';
import '../../utils/hux_wcag.dart';

/// HuxCheckbox is a customizable checkbox component with consistent styling
/// that follows the Hux design system patterns.
///
/// Provides a clean, modern checkbox with subtle borders, proper hover states,
/// and automatic theme adaptation. Supports optional labels and multiple sizes.
///
/// Example:
/// ```dart
/// HuxCheckbox(
///   value: isChecked,
///   onChanged: (value) => setState(() => isChecked = value ?? false),
///   label: 'Accept terms and conditions',
///   size: HuxCheckboxSize.medium,
/// )
/// ```
class HuxCheckbox extends StatefulWidget {
  /// Creates a HuxCheckbox widget.
  const HuxCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.size = HuxCheckboxSize.medium,
    this.isDisabled = false,
  });

  /// The current checked state of the checkbox
  final bool value;

  /// Called when the checkbox state changes
  final ValueChanged<bool?>? onChanged;

  /// Optional label text displayed next to the checkbox
  final String? label;

  /// Size variant of the checkbox
  final HuxCheckboxSize size;

  /// Whether the checkbox is disabled
  final bool isDisabled;

  @override
  State<HuxCheckbox> createState() => _HuxCheckboxState();
}

class _HuxCheckboxState extends State<HuxCheckbox> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = !widget.isDisabled && widget.onChanged != null;
    void toggle() => widget.onChanged?.call(!widget.value);

    return MergeSemantics(
      child: Semantics(
        container: true,
        checked: widget.value,
        enabled: isEnabled,
        label: widget.label,
        child: FocusableActionDetector(
          enabled: isEnabled,
          mouseCursor: isEnabled ? SystemMouseCursors.click : MouseCursor.defer,
          onShowFocusHighlight: (isFocused) {
            if (_isFocused != isFocused) {
              setState(() => _isFocused = isFocused);
            }
          },
          shortcuts: const <ShortcutActivator, Intent>{
            SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
            SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
          },
          actions: <Type, Action<Intent>>{
            ActivateIntent: CallbackAction<ActivateIntent>(
              onInvoke: (_) {
                toggle();
                return null;
              },
            ),
          },
          child: GestureDetector(
            onTap: isEnabled ? toggle : null,
            child: Padding(
              padding: const EdgeInsets.all(4), // Touch target padding
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    key: const ValueKey('huxCheckboxFocusRing'),
                    duration: const Duration(milliseconds: 120),
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _isFocused
                            ? HuxTokens.primary(context).withValues(alpha: 0.6)
                            : Colors.transparent,
                        width: 2,
                        strokeAlign: BorderSide.strokeAlignOutside,
                      ),
                    ),
                    child: Container(
                      width: _getCheckboxSize(),
                      height: _getCheckboxSize(),
                      decoration: BoxDecoration(
                        color: _getBackgroundColor(context),
                        border: Border.all(
                          color: _getBorderColor(context),
                          width: 1, // Consistent with Hux border width
                        ),
                        borderRadius: BorderRadius.circular(
                            6), // Slightly rounded like cards
                      ),
                      child: widget.value
                          ? Icon(
                              Icons.check,
                              size: _getIconSize(),
                              color: _getCheckColor(context),
                            )
                          : null,
                    ),
                  ),
                  if (widget.label != null) ...[
                    SizedBox(width: _getLabelSpacing()),
                    Flexible(
                      child: Text(
                        widget.label!,
                        style: TextStyle(
                          fontSize: _getFontSize(),
                          fontWeight:
                              FontWeight.w500, // Consistent with Hux typography
                          color: widget.isDisabled
                              ? HuxTokens.textDisabled(context)
                              : HuxTokens.textPrimary(context),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getBackgroundColor(BuildContext context) {
    if (widget.isDisabled) {
      return HuxTokens.surfaceSecondary(context).withValues(alpha: 0.5);
    }
    return widget.value
        ? HuxTokens.primary(context)
        : HuxTokens.surfacePrimary(context);
  }

  Color _getBorderColor(BuildContext context) {
    if (widget.isDisabled) {
      return HuxTokens.borderSecondary(context);
    }
    return widget.value
        ? HuxTokens.primary(context)
        : HuxTokens.borderPrimary(context);
  }

  Color _getCheckColor(BuildContext context) {
    if (widget.value) {
      final primaryColor = HuxTokens.primary(context);
      return HuxWCAG.getContrastingTextColor(
        backgroundColor: primaryColor,
        context: context,
      );
    }
    return Colors.transparent;
  }

  double _getCheckboxSize() {
    switch (widget.size) {
      case HuxCheckboxSize.small:
        return 16;
      case HuxCheckboxSize.medium:
        return 20;
      case HuxCheckboxSize.large:
        return 24;
    }
  }

  double _getIconSize() {
    switch (widget.size) {
      case HuxCheckboxSize.small:
        return 12;
      case HuxCheckboxSize.medium:
        return 14;
      case HuxCheckboxSize.large:
        return 16;
    }
  }

  double _getFontSize() {
    switch (widget.size) {
      case HuxCheckboxSize.small:
        return 14;
      case HuxCheckboxSize.medium:
        return 16;
      case HuxCheckboxSize.large:
        return 18;
    }
  }

  double _getLabelSpacing() {
    switch (widget.size) {
      case HuxCheckboxSize.small:
        return 8;
      case HuxCheckboxSize.medium:
        return 12;
      case HuxCheckboxSize.large:
        return 16;
    }
  }
}

/// Size variants for HuxCheckbox
enum HuxCheckboxSize {
  /// Small checkbox for compact layouts
  small,

  /// Medium checkbox for standard use
  medium,

  /// Large checkbox for emphasis
  large
}
