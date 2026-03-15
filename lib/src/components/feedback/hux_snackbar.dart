import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/hux_tokens.dart';

/// Visual variants for HuxSnackbar.
enum HuxSnackbarVariant {
  /// Blue styling for informational messages.
  info,

  /// Green styling for success confirmations.
  success,

  /// Orange styling for warning messages.
  warning,

  /// Red styling for error messages.
  error,
}

/// A proper snackbar component that provides temporary notification messages.
///
/// Built using composition to avoid inheritance conflicts with SnackBar.
/// Follows Hux design system principles with consistent theming and accessibility.
class HuxSnackbar {
  /// Creates a snackbar with the specified properties.
  const HuxSnackbar({
    this.key,
    required this.message,
    this.variant = HuxSnackbarVariant.info,
    this.title,
    this.onDismiss,
    this.showIcon = true,
    this.duration = const Duration(seconds: 4),
    this.action,
    this.behavior = SnackBarBehavior.floating,
    this.backgroundColor,
    this.textColor,
    this.actionTextColor,
    this.elevation = 6,
    this.margin = const EdgeInsets.only(left: 16, bottom: 16),
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    this.shape,
  });

  /// The key for the snackbar.
  final Key? key;

  /// The message text to display in the snackbar.
  final String message;

  /// The visual variant of the snackbar.
  final HuxSnackbarVariant variant;

  /// Optional title text displayed above the message.
  final String? title;

  /// Callback when the snackbar is dismissed.
  final VoidCallback? onDismiss;

  /// Whether to show an icon in the snackbar.
  final bool showIcon;

  /// Duration the snackbar is displayed.
  final Duration duration;

  /// Optional action button.
  final SnackBarAction? action;

  /// Behavior of the snackbar.
  final SnackBarBehavior behavior;

  /// Custom background color override.
  final Color? backgroundColor;

  /// Custom text color override.
  final Color? textColor;

  /// Custom action text color override.
  final Color? actionTextColor;

  /// Elevation of the snackbar.
  final double elevation;

  /// Margin around the snackbar.
  final EdgeInsetsGeometry margin;

  /// Padding inside the snackbar.
  final EdgeInsetsGeometry padding;

  /// Shape of the snackbar.
  final ShapeBorder? shape;

  /// Builds the SnackBar widget.
  SnackBar build(BuildContext context) {
    return SnackBar(
      key: key,
      content: _buildContent(context),
      duration: duration,
      action: action,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      elevation: 0,
      margin: margin,
      padding: EdgeInsets.zero,
      shape: shape,
    );
  }

  Widget _buildContent(BuildContext context) {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Container(
        width: 400,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12), // Consistent with Hux cards
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.black.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: Theme.of(context).brightness == Brightness.dark ? 10 : 5,
              sigmaY: Theme.of(context).brightness == Brightness.dark ? 10 : 5,
            ),
            child: Container(
              key: const ValueKey('huxSnackbarContainer'),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getContainerBackgroundColor(context),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _getBorderColor(context),
                  width: 1, // Consistent with Hux border width
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (showIcon) ...[
                    Icon(
                      _getIcon(),
                      color: _getIconColor(context),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (title != null) ...[
                          Text(
                            title!,
                            style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight
                                          .w600, // Consistent with Hux typography
                                      color:
                                          textColor ?? _getTextColor(context),
                                    ) ??
                                TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: textColor ?? _getTextColor(context),
                                ),
                          ),
                          const SizedBox(height: 4),
                        ],
                        Text(
                          message,
                          style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: textColor ?? _getTextColor(context),
                                  ) ??
                              TextStyle(
                                fontSize: 12,
                                color: textColor ?? _getTextColor(context),
                              ),
                        ),
                      ],
                    ),
                  ),
                  if (onDismiss != null) ...[
                    const SizedBox(width: 8),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: onDismiss,
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Icon(
                            LucideIcons.x,
                            size: 16,
                            color: textColor ?? _getTextColor(context),
                          ),
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
    switch (variant) {
      case HuxSnackbarVariant.info:
        return HuxTokens.surfaceElevated(context);
      case HuxSnackbarVariant.success:
        return HuxTokens.surfaceOverlay(context);
      case HuxSnackbarVariant.warning:
        return HuxTokens.surfaceOverlay(context);
      case HuxSnackbarVariant.error:
        return HuxTokens.surfaceOverlay(context);
    }
  }

  Color _getBorderColor(BuildContext context) {
    switch (variant) {
      case HuxSnackbarVariant.info:
        return HuxTokens.borderSecondary(context);
      case HuxSnackbarVariant.success:
        return HuxTokens.borderSecondary(context);
      case HuxSnackbarVariant.warning:
        return const Color(0xFFF59E0B); // Amber border
      case HuxSnackbarVariant.error:
        return HuxTokens.borderSecondary(context);
    }
  }

  Color _getIconColor(BuildContext context) {
    switch (variant) {
      case HuxSnackbarVariant.info:
        return HuxTokens.textSecondary(context);
      case HuxSnackbarVariant.success:
        return HuxTokens.textSuccess(context);
      case HuxSnackbarVariant.warning:
        return const Color(0xFFF59E0B); // Amber icon
      case HuxSnackbarVariant.error:
        return HuxTokens.textDestructive(context);
    }
  }

  Color _getTextColor(BuildContext context) {
    if (textColor != null) return textColor!;

    switch (variant) {
      case HuxSnackbarVariant.info:
        return HuxTokens.textPrimary(context);
      case HuxSnackbarVariant.success:
        return HuxTokens.textSuccess(context);
      case HuxSnackbarVariant.warning:
        return const Color(0xFFF59E0B);
      case HuxSnackbarVariant.error:
        return HuxTokens.textDestructive(context);
    }
  }

  Color _getContainerBackgroundColor(BuildContext context) {
    if (backgroundColor != null) return backgroundColor!;

    final baseColor = _getBackgroundColor(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return baseColor.withValues(alpha: isDark ? 0.72 : 0.78);
  }

  IconData _getIcon() {
    switch (variant) {
      case HuxSnackbarVariant.info:
        return LucideIcons.info;
      case HuxSnackbarVariant.success:
        return LucideIcons.checkCircle;
      case HuxSnackbarVariant.warning:
        return LucideIcons.alertTriangle;
      case HuxSnackbarVariant.error:
        return LucideIcons.alertCircle;
    }
  }
}

/// Extension to easily show HuxSnackbar.
extension HuxSnackbarExtension on BuildContext {
  /// Shows a HuxSnackbar with the given parameters.
  void showHuxSnackbar({
    required String message,
    HuxSnackbarVariant variant = HuxSnackbarVariant.info,
    String? title,
    VoidCallback? onDismiss,
    bool showIcon = true,
    Duration duration = const Duration(seconds: 4),
    SnackBarAction? action,
    SnackBarBehavior behavior = SnackBarBehavior.floating,
    Color? backgroundColor,
    Color? textColor,
    Color? actionTextColor,
    double elevation = 6,
    EdgeInsets margin = const EdgeInsets.all(16),
    EdgeInsets padding =
        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ShapeBorder? shape,
  }) {
    final snackbar = HuxSnackbar(
      message: message,
      variant: variant,
      title: title,
      onDismiss: onDismiss,
      showIcon: showIcon,
      duration: duration,
      action: action,
      behavior: behavior,
      backgroundColor: backgroundColor,
      textColor: textColor,
      actionTextColor: actionTextColor,
      elevation: elevation,
      margin: margin,
      padding: padding,
      shape: shape,
    );

    ScaffoldMessenger.of(this).showSnackBar(snackbar.build(this));
  }
}
