import 'package:flutter/material.dart';
import '../../theme/hux_tokens.dart';

/// A navigation item component designed specifically for sidebars.
///
/// Provides proper left alignment, hover states, and selection indicators
/// that are optimized for sidebar navigation patterns.
///
/// Example:
/// ```dart
/// HuxSidebarItem(
///   icon: LucideIcons.home,
///   label: 'Dashboard',
///   isSelected: true,
///   onTap: () => print('Navigate to Dashboard'),
/// )
/// ```
class HuxSidebarItem extends StatefulWidget {
  /// Creates a HuxSidebarItem widget.
  const HuxSidebarItem({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.isSelected = false,
    this.isDisabled = false,
  });

  /// The icon to display
  final IconData icon;

  /// The text label to display
  final String label;

  /// Callback when the item is tapped
  final VoidCallback onTap;

  /// Whether this item is currently selected
  final bool isSelected;

  /// Whether this item is disabled
  final bool isDisabled;

  @override
  State<HuxSidebarItem> createState() => _HuxSidebarItemState();
}

class _HuxSidebarItemState extends State<HuxSidebarItem> {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(HuxTokens.radiusMd(context)),
      child: InkWell(
        onTap: widget.isDisabled ? null : widget.onTap,
        borderRadius: BorderRadius.circular(HuxTokens.radiusMd(context)),
        splashFactory: NoSplash.splashFactory,
        // Custom hover effect only (no press effect) - same as buttons
        overlayColor: WidgetStateProperty.resolveWith<Color?>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.hovered) && !widget.isDisabled) {
              return HuxTokens.surfaceHover(context);
            }
            return null; // No press effect
          },
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: _getBackgroundColor(context),
            borderRadius: BorderRadius.circular(HuxTokens.radiusMd(context)),
          ),
          child: Row(
            children: [
              Icon(
                widget.icon,
                size: 18,
                color: _getIconColor(context),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: _getTextColor(context),
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getBackgroundColor(BuildContext context) {
    if (widget.isSelected) {
      return HuxTokens.surfaceHover(context);
    }
    // Remove hover background since InkWell handles it
    return Colors.transparent;
  }

  Color _getIconColor(BuildContext context) {
    if (widget.isDisabled) {
      return HuxTokens.textDisabled(context);
    }
    if (widget.isSelected) {
      return HuxTokens.primary(context);
    }
    return HuxTokens.iconPrimary(context);
  }

  Color _getTextColor(BuildContext context) {
    if (widget.isDisabled) {
      return HuxTokens.textDisabled(context);
    }
    if (widget.isSelected) {
      return HuxTokens.primary(context);
    }
    return HuxTokens.textPrimary(context);
  }
}
