import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/hux_tokens.dart';

/// HuxSwitch is a toggle switch component with smooth animations that follows
/// the Hux design system patterns.
///
/// Provides a clean, modern toggle with subtle borders, consistent sizing,
/// and proper theme adaptation. Features smooth 200ms animations for state changes.
///
/// Example:
/// ```dart
/// HuxSwitch(
///   value: isSwitchedOn,
///   onChanged: (value) => setState(() => isSwitchedOn = value),
///   size: HuxSwitchSize.medium,
/// )
/// ```
class HuxSwitch extends StatefulWidget {
  /// Creates a HuxSwitch widget.
  const HuxSwitch({
    super.key,
    required this.value,
    this.onChanged,
    this.isDisabled = false,
    this.size = HuxSwitchSize.medium,
  });

  /// The current switch state
  final bool value;

  /// Called when the switch state changes
  final ValueChanged<bool>? onChanged;

  /// Whether the switch is disabled
  final bool isDisabled;

  /// Size variant of the switch
  final HuxSwitchSize size;

  @override
  State<HuxSwitch> createState() => _HuxSwitchState();
}

class _HuxSwitchState extends State<HuxSwitch> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = !widget.isDisabled && widget.onChanged != null;
    void toggle() => widget.onChanged?.call(!widget.value);

    return Semantics(
      container: true,
      toggled: widget.value,
      enabled: isEnabled,
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
          behavior: HitTestBehavior.opaque,
          onTap: isEnabled ? toggle : null,
          child: Padding(
            padding: const EdgeInsets.all(4), // Touch target padding
            child: AnimatedContainer(
              key: const ValueKey('huxSwitchFocusRing'),
              duration: const Duration(milliseconds: 120),
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                border: Border.all(
                  color: _isFocused
                      ? HuxTokens.primary(context).withValues(alpha: 0.6)
                      : Colors.transparent,
                  width: 2,
                  strokeAlign: BorderSide.strokeAlignOutside,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: _getSwitchWidth(),
                height: _getSwitchHeight(),
                padding: EdgeInsets.all(_getPadding()),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                      10), // Consistent with Hux border radius
                  color: _getBackgroundColor(context),
                  border: Border.all(
                    color: _getBorderColor(context),
                    width: 1, // Consistent with Hux border width
                  ),
                ),
                child: AnimatedAlign(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  alignment: widget.value
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    width: _getHandleSize(),
                    height: _getHandleSize(),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                          8), // Consistent rounded corners
                      color: _getHandleColor(context),
                      border: Border.all(
                        color: _getHandleBorderColor(context),
                        width: 1,
                      ),
                    ),
                  ),
                ),
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
        ? HuxTokens.primary(context).withValues(alpha: 0.1)
        : HuxTokens.surfaceSecondary(context);
  }

  Color _getBorderColor(BuildContext context) {
    if (widget.isDisabled) {
      return HuxTokens.borderSecondary(context);
    }
    return HuxTokens.borderPrimary(context);
  }

  Color _getHandleColor(BuildContext context) {
    if (widget.isDisabled) {
      return HuxTokens.surfaceSecondary(context);
    }
    return widget.value
        ? HuxTokens.primary(context)
        : HuxTokens.surfacePrimary(context);
  }

  Color _getHandleBorderColor(BuildContext context) {
    if (widget.isDisabled) {
      return HuxTokens.borderSecondary(context);
    }
    return widget.value
        ? HuxTokens.primary(context)
        : HuxTokens.borderPrimary(context);
  }

  double _getSwitchWidth() {
    switch (widget.size) {
      case HuxSwitchSize.small:
        return 36;
      case HuxSwitchSize.medium:
        return 44;
      case HuxSwitchSize.large:
        return 52;
    }
  }

  double _getSwitchHeight() {
    switch (widget.size) {
      case HuxSwitchSize.small:
        return 20;
      case HuxSwitchSize.medium:
        return 24;
      case HuxSwitchSize.large:
        return 28;
    }
  }

  double _getHandleSize() {
    switch (widget.size) {
      case HuxSwitchSize.small:
        return 14;
      case HuxSwitchSize.medium:
        return 18;
      case HuxSwitchSize.large:
        return 22;
    }
  }

  double _getPadding() {
    return 2.0;
  }
}

/// Size variants for HuxSwitch
enum HuxSwitchSize {
  /// Small switch for compact layouts
  small,

  /// Medium switch for standard use
  medium,

  /// Large switch for emphasis
  large
}
