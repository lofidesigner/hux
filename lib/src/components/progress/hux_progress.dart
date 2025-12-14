import 'package:flutter/material.dart';
import '../../theme/hux_tokens.dart';

/// HuxProgress is a customizable linear progress indicator that displays
/// the completion status of a task or process.
///
/// Follows the Hux design system with consistent styling, theme adaptation,
/// and support for different sizes and variants. Perfect for showing upload
/// progress, download status, or any task completion percentage.
///
/// Example:
/// ```dart
/// // Basic progress indicator
/// HuxProgress(value: 0.5)
///
/// // Progress with label and custom variant
/// HuxProgress(
///   value: 0.75,
///   label: 'Uploading',
///   variant: HuxProgressVariant.success,
///   showValue: true,
/// )
/// ```
class HuxProgress extends StatelessWidget {
  /// Creates a HuxProgress widget.
  const HuxProgress({
    super.key,
    required this.value,
    this.min = 0.0,
    this.max = 1.0,
    this.label,
    this.showValue = false,
    this.size = HuxProgressSize.medium,
    this.variant = HuxProgressVariant.primary,
    this.backgroundColor,
    this.color,
    this.borderRadius,
  });

  /// The current progress value (between min and max)
  final double value;

  /// Minimum value for the progress. Defaults to 0.0
  final double min;

  /// Maximum value for the progress. Defaults to 1.0
  final double max;

  /// Optional label displayed above the progress bar
  final String? label;

  /// Whether to show the current value as a percentage or number
  final bool showValue;

  /// Size variant of the progress bar
  final HuxProgressSize size;

  /// Visual variant of the progress bar
  final HuxProgressVariant variant;

  /// Custom background color for the progress track. If null, uses theme-based default
  final Color? backgroundColor;

  /// Custom color for the progress fill. If null, uses variant-based default
  final Color? color;

  /// Border radius for the progress bar. If null, uses size-based default
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    final progressValue = _clampValue(value);
    final progressPercentage =
        ((progressValue - min) / (max - min)).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null || showValue) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (label != null)
                Text(
                  label!,
                  style: TextStyle(
                    fontSize:
                        Theme.of(context).textTheme.labelMedium?.fontSize ?? 12,
                    fontWeight: FontWeight.w400,
                    color: HuxTokens.textSecondary(context),
                  ),
                ),
              if (showValue)
                Text(
                  _formatValue(progressValue),
                  style: TextStyle(
                    fontSize:
                        Theme.of(context).textTheme.labelMedium?.fontSize ?? 12,
                    fontWeight: FontWeight.w500,
                    color: HuxTokens.textSecondary(context),
                  ),
                ),
            ],
          ),
          SizedBox(height: _getLabelSpacing()),
        ],
        ClipRRect(
          borderRadius:
              BorderRadius.circular(borderRadius ?? _getBorderRadius()),
          child: Container(
            height: _getHeight(),
            decoration: BoxDecoration(
              color: backgroundColor ?? _getBackgroundColor(context),
              borderRadius:
                  BorderRadius.circular(borderRadius ?? _getBorderRadius()),
            ),
            child: Stack(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                  width: double.infinity,
                  height: double.infinity,
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: progressPercentage,
                    child: Container(
                      decoration: BoxDecoration(
                        color: color ?? _getProgressColor(context),
                        borderRadius: BorderRadius.circular(
                          borderRadius ?? _getBorderRadius(),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  double _clampValue(double val) {
    return val.clamp(min, max);
  }

  String _formatValue(double val) {
    if (max == 1.0 && min == 0.0) {
      // Show as percentage
      return '${(val * 100).toStringAsFixed(0)}%';
    } else {
      // Show as number
      return val.toStringAsFixed(val == val.roundToDouble() ? 0 : 1);
    }
  }

  Color _getProgressColor(BuildContext context) {
    if (color != null) return color!;

    switch (variant) {
      case HuxProgressVariant.primary:
        return HuxTokens.primary(context);
      case HuxProgressVariant.success:
        return HuxTokens.success(context);
      case HuxProgressVariant.destructive:
        return HuxTokens.destructive(context);
    }
  }

  Color _getBackgroundColor(BuildContext context) {
    if (backgroundColor != null) return backgroundColor!;
    return HuxTokens.surfaceSecondary(context);
  }

  double _getHeight() {
    switch (size) {
      case HuxProgressSize.small:
        return 4.0;
      case HuxProgressSize.medium:
        return 6.0;
      case HuxProgressSize.large:
        return 8.0;
    }
  }

  double _getBorderRadius() {
    switch (size) {
      case HuxProgressSize.small:
        return 2.0;
      case HuxProgressSize.medium:
        return 3.0;
      case HuxProgressSize.large:
        return 4.0;
    }
  }

  double _getLabelSpacing() {
    switch (size) {
      case HuxProgressSize.small:
        return 4.0;
      case HuxProgressSize.medium:
        return 6.0;
      case HuxProgressSize.large:
        return 8.0;
    }
  }
}

/// Visual variants for HuxProgress
enum HuxProgressVariant {
  /// Primary progress using theme primary color
  primary,

  /// Success progress using green color
  success,

  /// Destructive progress using red color
  destructive,
}

/// Size variants for HuxProgress
enum HuxProgressSize {
  /// Small progress bar (4px height)
  small,

  /// Medium progress bar (6px height)
  medium,

  /// Large progress bar (8px height)
  large,
}
