import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../theme/hux_tokens.dart';

/// HuxAlert is a feedback message component that follows the Hux design system
/// with consistent styling, borders, and semantic color tokens.
///
/// Provides clear communication with users through contextual colors, optional
/// icons, and dismissible functionality. Matches the clean aesthetic of other
/// Hux components.
///
/// Example:
/// ```dart
/// HuxAlert(
///   variant: HuxAlertVariant.success,
///   title: 'Success!',
///   message: 'Your operation completed successfully.',
///   showIcon: true,
///   onDismiss: () => print('Alert dismissed'),
/// )
/// ```
class HuxAlert extends StatelessWidget {
  /// Creates a HuxAlert widget.
  const HuxAlert({
    super.key,
    required this.variant,
    this.title,
    required this.message,
    this.showIcon = true,
    this.onDismiss,
  });

  /// The visual variant of the alert
  final HuxAlertVariant variant;

  /// Optional title text displayed prominently
  final String? title;

  /// The main message content
  final String message;

  /// Whether to show an icon for the alert variant
  final bool showIcon;

  /// Optional callback for dismissing the alert
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(
        maxWidth: 500,
      ),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getBackgroundColor(context),
        border: Border.all(
          color: _getBorderColor(context),
          width: 1, // Consistent with Hux border width
        ),
        borderRadius: BorderRadius.circular(12), // Consistent with Hux cards
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight:
                              FontWeight.w600, // Consistent with Hux typography
                          color: _getTextColor(context),
                        ),
                  ),
                  const SizedBox(height: 4),
                ],
                Text(
                  message,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: _getTextColor(context),
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
                    color: _getTextColor(context),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getBackgroundColor(BuildContext context) {
    switch (variant) {
      case HuxAlertVariant.info:
        return HuxTokens.surfaceSecondary(context);
      case HuxAlertVariant.success:
        return HuxTokens.surfaceSuccess(context);
      case HuxAlertVariant.warning:
        return const Color(0xFFF59E0B)
            .withValues(alpha: 0.1); // Amber background
      case HuxAlertVariant.error:
        return HuxTokens.surfaceDestructive(context);
    }
  }

  Color _getBorderColor(BuildContext context) {
    switch (variant) {
      case HuxAlertVariant.info:
        return HuxTokens.borderSecondary(context);
      case HuxAlertVariant.success:
        return HuxTokens.borderSecondary(context);
      case HuxAlertVariant.warning:
        return const Color(0xFFF59E0B); // Amber border
      case HuxAlertVariant.error:
        return HuxTokens.borderSecondary(context);
    }
  }

  Color _getTextColor(BuildContext context) {
    switch (variant) {
      case HuxAlertVariant.info:
        return HuxTokens.textPrimary(context);
      case HuxAlertVariant.success:
        return HuxTokens.textSuccess(context);
      case HuxAlertVariant.warning:
        return const Color(0xFFF59E0B); // Amber text
      case HuxAlertVariant.error:
        return HuxTokens.textDestructive(context);
    }
  }

  Color _getIconColor(BuildContext context) {
    switch (variant) {
      case HuxAlertVariant.info:
        return HuxTokens.textSecondary(context);
      case HuxAlertVariant.success:
        return HuxTokens.textSuccess(context);
      case HuxAlertVariant.warning:
        return const Color(0xFFF59E0B); // Amber icon
      case HuxAlertVariant.error:
        return HuxTokens.textDestructive(context);
    }
  }

  IconData _getIcon() {
    switch (variant) {
      case HuxAlertVariant.info:
        return LucideIcons.info;
      case HuxAlertVariant.success:
        return LucideIcons.checkCircle;
      case HuxAlertVariant.warning:
        return LucideIcons.alertTriangle;
      case HuxAlertVariant.error:
        return LucideIcons.alertCircle;
    }
  }
}

/// Alert variant types following Hux design patterns
enum HuxAlertVariant {
  /// Informational alert with blue accent
  info,

  /// Success alert with green accent
  success,

  /// Warning alert with amber accent
  warning,

  /// Error alert with red accent
  error
}
