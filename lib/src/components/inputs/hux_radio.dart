import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/hux_tokens.dart';

/// HuxRadio is a customizable radio button component with consistent styling
/// that follows the Hux design system patterns.
///
/// Provides a clean, modern radio button with subtle borders, proper hover states,
/// and automatic theme adaptation. Supports optional labels with consistent sizing.
///
/// Example:
/// ```dart
/// HuxRadio<String>(
///   value: 'option1',
///   groupValue: selectedOption,
///   onChanged: (value) => setState(() => selectedOption = value),
///   label: 'Option 1',
/// )
/// ```
class HuxRadio<T> extends StatelessWidget {
  /// Creates a HuxRadio widget.
  const HuxRadio({
    super.key,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    this.label,
    this.isDisabled = false,
  });

  /// The value represented by this radio button
  final T value;

  /// The currently selected value for this group of radio buttons
  final T? groupValue;

  /// Called when the radio button is selected
  final ValueChanged<T?>? onChanged;

  /// Optional label text displayed next to the radio button
  final String? label;

  /// Whether the radio button is disabled
  final bool isDisabled;

  /// Whether this radio button is currently selected
  bool get isSelected => value == groupValue;

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = !isDisabled && onChanged != null;
    void select() => onChanged?.call(value);

    return MergeSemantics(
      child: Semantics(
        container: true,
        checked: isSelected,
        inMutuallyExclusiveGroup: true,
        enabled: isEnabled,
        label: label,
        child: FocusableActionDetector(
          enabled: isEnabled,
          mouseCursor: isEnabled ? SystemMouseCursors.click : MouseCursor.defer,
          shortcuts: const <ShortcutActivator, Intent>{
            SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
            SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
          },
          actions: <Type, Action<Intent>>{
            ActivateIntent: CallbackAction<ActivateIntent>(
              onInvoke: (_) {
                select();
                return null;
              },
            ),
          },
          child: GestureDetector(
            onTap: isEnabled ? select : null,
            child: Padding(
              padding: const EdgeInsets.all(4), // Touch target padding
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: _radioSize,
                    height: _radioSize,
                    decoration: BoxDecoration(
                      color: _getBackgroundColor(context),
                      border: Border.all(
                        color: _getBorderColor(context),
                        width: 1, // Consistent with Hux border width
                      ),
                      shape: BoxShape.circle, // Radio buttons are circular
                    ),
                    child: isSelected
                        ? Center(
                            child: Container(
                              width: _innerCircleSize,
                              height: _innerCircleSize,
                              decoration: BoxDecoration(
                                color: _getInnerCircleColor(context),
                                shape: BoxShape.circle,
                              ),
                            ),
                          )
                        : null,
                  ),
                  if (label != null) ...[
                    SizedBox(width: _labelSpacing),
                    Flexible(
                      child: Text(
                        label!,
                        style: TextStyle(
                          fontSize: _fontSize,
                          fontWeight:
                              FontWeight.w500, // Consistent with Hux typography
                          color: isDisabled
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
    if (isDisabled) {
      return HuxTokens.surfaceSecondary(context).withValues(alpha: 0.5);
    }
    return HuxTokens.surfaceSecondary(context);
  }

  Color _getBorderColor(BuildContext context) {
    if (isDisabled) {
      return HuxTokens.borderSecondary(context).withValues(alpha: 0.5);
    }
    return HuxTokens.borderSecondary(context);
  }

  Color _getInnerCircleColor(BuildContext context) {
    if (isSelected) {
      if (isDisabled) {
        return HuxTokens.primary(context).withValues(alpha: 0.5);
      }
      return HuxTokens.primary(context);
    }
    return Colors.transparent;
  }

  // Fixed dimensions for consistent sizing
  static const double _radioSize = 18.0;
  static const double _innerCircleSize = 8.0;
  static const double _fontSize = 14.0;
  static const double _labelSpacing = 12.0;
}
