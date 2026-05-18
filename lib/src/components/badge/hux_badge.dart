import 'package:flutter/material.dart';
import '../../theme/hux_tokens.dart';
import '../../utils/hux_wcag.dart';

/// HuxBadge is a small notification indicator component that displays text or
/// numbers in a clean, pill-shaped container.
///
/// Follows the Hux design system with consistent border radius, padding,
/// and semantic color tokens. Perfect for notifications, status indicators,
/// and counters.
///
/// Example:
/// ```dart
/// HuxBadge(
///   label: '3',
///   variant: HuxBadgeVariant.error,
///   size: HuxBadgeSize.medium,
/// )
/// ```
class HuxBadge extends StatelessWidget {
  /// Creates a HuxBadge widget.
  const HuxBadge({
    super.key,
    required this.label,
    this.variant = HuxBadgeVariant.primary,
    this.size = HuxBadgeSize.medium,
    this.customColor,
  });

  /// The text or number to display inside the badge
  final String label;

  /// Visual variant of the badge
  final HuxBadgeVariant variant;

  /// Size variant of the badge
  final HuxBadgeSize size;

  /// Optional custom background color (overrides variant)
  final Color? customColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: _getHorizontalPadding(),
        vertical: _getVerticalPadding(),
      ),
      decoration: BoxDecoration(
        color: customColor ?? _getBackgroundColor(context),
        borderRadius: BorderRadius.circular(HuxTokens.radiusMd(context)),
        border: Border.all(
          color: _getBorderColor(context),
          width: HuxTokens.borderWidth(context),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: _getTextColor(context),
          fontSize: _getFontSize(),
          fontWeight: HuxTokens.fontWeightEmphasis(context),
          height: 1.0,
        ),
      ),
    );
  }

  Color _getBackgroundColor(BuildContext context) {
    if (customColor != null) return customColor!;

    switch (variant) {
      case HuxBadgeVariant.primary:
        return HuxTokens.primary(context);
      case HuxBadgeVariant.secondary:
        return HuxTokens.surfaceSecondary(context);
      case HuxBadgeVariant.success:
        return HuxTokens.surfaceSuccess(context);
      case HuxBadgeVariant.outline:
        return Colors.transparent;
      case HuxBadgeVariant.error:
        return HuxTokens.surfaceDestructive(
            context); // Use destructive surface token
      case HuxBadgeVariant.destructive:
        return HuxTokens.surfaceDestructive(context);
    }
  }

  Color _getBorderColor(BuildContext context) {
    if (customColor != null) {
      return customColor!.withValues(alpha: 0.3);
    }

    switch (variant) {
      case HuxBadgeVariant.primary:
        return HuxTokens.borderPrimary(context); // Use border primary token
      case HuxBadgeVariant.secondary:
        return HuxTokens.borderSecondary(context);
      case HuxBadgeVariant.success:
        return HuxTokens.borderSecondary(context);
      case HuxBadgeVariant.outline:
        return HuxTokens.buttonSecondaryBorder(context);
      case HuxBadgeVariant.error:
        return HuxTokens.borderSecondary(context);
      case HuxBadgeVariant.destructive:
        return HuxTokens.borderSecondary(context);
    }
  }

  Color _getTextColor(BuildContext context) {
    if (customColor != null) {
      // Calculate contrasting color for custom backgrounds
      return HuxWCAG.getContrastingTextColor(
        backgroundColor: customColor!,
        context: context,
      );
    }

    switch (variant) {
      case HuxBadgeVariant.primary:
        final primaryColor = HuxTokens.primary(context);
        return HuxWCAG.getContrastingTextColor(
          backgroundColor: primaryColor,
          context: context,
        );
      case HuxBadgeVariant.secondary:
        return HuxTokens.textPrimary(context);
      case HuxBadgeVariant.success:
        return HuxTokens.textSuccess(context);
      case HuxBadgeVariant.outline:
        return HuxTokens.buttonSecondaryText(context);
      case HuxBadgeVariant.error:
        return HuxTokens.textDestructive(context); // Use destructive text token
      case HuxBadgeVariant.destructive:
        return HuxTokens.textDestructive(context);
    }
  }

  double _getFontSize() {
    switch (size) {
      case HuxBadgeSize.small:
        return 11;
      case HuxBadgeSize.medium:
        return 12;
      case HuxBadgeSize.large:
        return 14;
    }
  }

  double _getHorizontalPadding() {
    switch (size) {
      case HuxBadgeSize.small:
        return 8;
      case HuxBadgeSize.medium:
        return 12;
      case HuxBadgeSize.large:
        return 16;
    }
  }

  double _getVerticalPadding() {
    switch (size) {
      case HuxBadgeSize.small:
        return 4;
      case HuxBadgeSize.medium:
        return 6;
      case HuxBadgeSize.large:
        return 8;
    }
  }
}

/// Badge variant types following Hux design patterns
enum HuxBadgeVariant {
  /// Primary badge using theme primary color
  primary,

  /// Secondary badge with subtle styling
  secondary,

  /// Success badge with green styling
  success,

  /// Outline badge with transparent background and border
  outline,

  /// Error badge with red styling
  error,

  /// Destructive badge with destructive styling
  destructive
}

/// Size variants for HuxBadge
enum HuxBadgeSize {
  /// Small badge for compact displays
  small,

  /// Medium badge for standard use
  medium,

  /// Large badge for emphasis
  large
}
