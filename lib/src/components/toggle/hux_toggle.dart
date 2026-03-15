import 'package:flutter/material.dart';
import '../../theme/hux_tokens.dart';
import '../../utils/hux_wcag.dart';
import '../buttons/hux_button.dart';

/// HuxToggle is a two-state button component that can be toggled on/off.
/// Commonly used for formatting controls (bold, italic) or feature toggles.
///
/// Features:
/// - Icon-only or icon with text
/// - Accessible naming via label or semanticLabel
/// - Smooth animations for state changes
/// - Proper theme adaptation
/// - Multiple size and style variants
///
/// Example:
/// ```dart
/// HuxToggle(
///   value: isBold,
///   onChanged: (value) => setState(() => isBold = value),
///   icon: Icons.format_bold,
///   label: 'Bold', // Optional visual label
///   semanticLabel: 'Bold', // Required for icon-only toggles
///   size: HuxToggleSize.medium,
///   variant: HuxButtonVariant.primary,
/// )
/// ```
class HuxToggle extends StatefulWidget {
  /// Creates a HuxToggle widget.
  const HuxToggle({
    super.key,
    required this.value,
    this.onChanged,
    required this.icon,
    this.label,
    this.semanticLabel,
    this.size = HuxToggleSize.medium,
    this.variant = HuxButtonVariant.primary,
    this.isDisabled = false,
    this.primaryColor,
  }) : assert(
          label != null || semanticLabel != null,
          'Icon-only HuxToggle requires a semanticLabel when label is null.',
        );

  /// The current toggle state
  final bool value;

  /// Called when the toggle state changes
  final ValueChanged<bool>? onChanged;

  /// The icon to display
  final IconData icon;

  /// Optional label text to display next to the icon
  final String? label;

  /// Optional accessibility label used when [label] is not provided.
  final String? semanticLabel;

  /// Size variant of the toggle
  final HuxToggleSize size;

  /// Visual variant of the toggle
  final HuxButtonVariant variant;

  /// Whether the toggle is disabled
  final bool isDisabled;

  /// Primary color used for styling (optional, defaults to theme primary)
  final Color? primaryColor;

  @override
  State<HuxToggle> createState() => _HuxToggleState();
}

class _HuxToggleState extends State<HuxToggle> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = !widget.isDisabled && widget.onChanged != null;
    final height = widget.size == HuxToggleSize.small
        ? 32.0
        : widget.size == HuxToggleSize.medium
            ? 40.0
            : 48.0;
    final width = widget.label == null ? height : null;

    return Semantics(
      container: true,
      button: true,
      enabled: isEnabled,
      toggled: widget.value,
      label: widget.label ?? widget.semanticLabel,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: isEnabled ? () => widget.onChanged?.call(!widget.value) : null,
          onFocusChange: (isFocused) {
            if (_isFocused != isFocused) {
              setState(() => _isFocused = isFocused);
            }
          },
          splashFactory: NoSplash.splashFactory,
          overlayColor: WidgetStateProperty.resolveWith<Color?>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.focused)) {
                return HuxTokens.primary(context).withValues(alpha: 0.12);
              }
              if (states.contains(WidgetState.hovered)) {
                if (widget.value) {
                  return switch (widget.variant) {
                    HuxButtonVariant.primary =>
                      HuxTokens.buttonPrimaryHover(context),
                    HuxButtonVariant.secondary =>
                      HuxTokens.surfaceHover(context).withValues(alpha: 0.2),
                    HuxButtonVariant.outline ||
                    HuxButtonVariant.ghost =>
                      HuxTokens.surfaceHover(context),
                  };
                }
                return HuxTokens.surfaceHover(context);
              }
              return null;
            },
          ),
          child: SizedBox(
            height: height,
            width: width,
            child: AnimatedContainer(
              key: const ValueKey('huxToggleFocusRing'),
              duration: const Duration(milliseconds: 120),
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isFocused
                      ? HuxTokens.primary(context).withValues(alpha: 0.6)
                      : Colors.transparent,
                  width: 2,
                  strokeAlign: BorderSide.strokeAlignOutside,
                ),
              ),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(
                  horizontal: _getHorizontalPadding(),
                  vertical: _getVerticalPadding(),
                ),
                decoration: BoxDecoration(
                  color: _getBackgroundColor(context),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _getBorderColor(context),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      widget.icon,
                      size: _getIconSize(),
                      color: _getIconColor(context),
                    ),
                    if (widget.label != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        widget.label!,
                        style: TextStyle(
                          fontSize: _getFontSize(),
                          fontWeight: FontWeight.w500,
                          color: _getTextColor(context),
                        ),
                      ),
                    ],
                  ],
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

    if (!widget.value) {
      return switch (widget.variant) {
        HuxButtonVariant.primary ||
        HuxButtonVariant.secondary =>
          HuxTokens.surfacePrimary(context),
        HuxButtonVariant.outline ||
        HuxButtonVariant.ghost =>
          Colors.transparent,
      };
    }

    return switch (widget.variant) {
      HuxButtonVariant.primary =>
        widget.primaryColor ?? Theme.of(context).colorScheme.primary,
      HuxButtonVariant.secondary =>
        HuxTokens.buttonSecondaryBackground(context),
      HuxButtonVariant.outline ||
      HuxButtonVariant.ghost =>
        HuxTokens.surfaceSecondary(context),
    };
  }

  Color _getBorderColor(BuildContext context) {
    if (widget.isDisabled) {
      return HuxTokens.borderSecondary(context);
    }

    if (!widget.value) {
      return switch (widget.variant) {
        HuxButtonVariant.primary ||
        HuxButtonVariant.secondary ||
        HuxButtonVariant.outline =>
          HuxTokens.borderPrimary(context),
        HuxButtonVariant.ghost => Colors.transparent,
      };
    }

    return switch (widget.variant) {
      HuxButtonVariant.primary =>
        widget.primaryColor ?? Theme.of(context).colorScheme.primary,
      HuxButtonVariant.secondary => HuxTokens.buttonSecondaryBorder(context),
      HuxButtonVariant.outline =>
        widget.primaryColor ?? Theme.of(context).colorScheme.primary,
      HuxButtonVariant.ghost => Colors.transparent,
    };
  }

  Color _getIconColor(BuildContext context) {
    if (widget.isDisabled) {
      return HuxTokens.iconSecondary(context);
    }

    if (!widget.value) {
      return HuxTokens.iconPrimary(context);
    }

    final effectivePrimaryColor =
        widget.primaryColor ?? Theme.of(context).colorScheme.primary;
    return switch (widget.variant) {
      HuxButtonVariant.primary => HuxWCAG.getContrastingTextColor(
          backgroundColor: effectivePrimaryColor,
          context: context,
        ),
      HuxButtonVariant.secondary => HuxTokens.buttonSecondaryText(context),
      HuxButtonVariant.outline ||
      HuxButtonVariant.ghost =>
        effectivePrimaryColor,
    };
  }

  Color _getTextColor(BuildContext context) {
    if (widget.isDisabled) {
      return HuxTokens.textDisabled(context);
    }

    if (!widget.value) {
      return HuxTokens.textPrimary(context);
    }

    final effectivePrimaryColor =
        widget.primaryColor ?? Theme.of(context).colorScheme.primary;
    return switch (widget.variant) {
      HuxButtonVariant.primary => HuxWCAG.getContrastingTextColor(
          backgroundColor: effectivePrimaryColor,
          context: context,
        ),
      HuxButtonVariant.secondary => HuxTokens.buttonSecondaryText(context),
      HuxButtonVariant.outline ||
      HuxButtonVariant.ghost =>
        effectivePrimaryColor,
    };
  }

  double _getIconSize() {
    switch (widget.size) {
      case HuxToggleSize.small:
        return 16;
      case HuxToggleSize.medium:
        return 18;
      case HuxToggleSize.large:
        return 20;
    }
  }

  double _getFontSize() {
    switch (widget.size) {
      case HuxToggleSize.small:
        return 12;
      case HuxToggleSize.medium:
        return 14;
      case HuxToggleSize.large:
        return 16;
    }
  }

  double _getHorizontalPadding() {
    if (widget.label == null) return 0; // Icon-only button
    switch (widget.size) {
      case HuxToggleSize.small:
        return 12;
      case HuxToggleSize.medium:
        return 16;
      case HuxToggleSize.large:
        return 24;
    }
  }

  double _getVerticalPadding() {
    if (widget.label == null) return 0; // Icon-only button
    switch (widget.size) {
      case HuxToggleSize.small:
        return 6;
      case HuxToggleSize.medium:
        return 8;
      case HuxToggleSize.large:
        return 12;
    }
  }
}

/// Size variants for HuxToggle
enum HuxToggleSize {
  /// Small toggle for compact layouts
  small,

  /// Medium toggle for standard use
  medium,

  /// Large toggle for emphasis
  large,
}
