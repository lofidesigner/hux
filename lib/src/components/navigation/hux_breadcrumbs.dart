import 'package:flutter/material.dart';
import '../../theme/hux_tokens.dart';
import '../../theme/hux_variant.dart';

/// Visual variants for HuxBreadcrumbs.
enum HuxBreadcrumbVariant {
  /// Default breadcrumbs with text separators
  default_,

  /// Breadcrumbs with icon separators
  icon,
}

/// Size variants for HuxBreadcrumbs.
enum HuxBreadcrumbSize {
  /// Small breadcrumbs for compact layouts
  small,

  /// Medium breadcrumbs for standard layouts (default)
  medium,

  /// Large breadcrumbs for prominent navigation
  large,
}

/// HuxBreadcrumbItem represents a single breadcrumb with its properties.
class HuxBreadcrumbItem {
  /// Creates a HuxBreadcrumbItem.
  const HuxBreadcrumbItem({
    required this.label,
    required this.onTap,
    this.icon,
    this.isDisabled = false,
    this.isActive = false,
  });

  /// The text label displayed on the breadcrumb
  final String label;

  /// The callback function called when this breadcrumb is tapped
  final VoidCallback onTap;

  /// Optional icon displayed before the label
  final IconData? icon;

  /// Whether this breadcrumb is disabled
  final bool isDisabled;

  /// Whether this breadcrumb is the current/active page
  final bool isActive;
}

/// HuxBreadcrumbs is a customizable breadcrumb component that provides
/// clear navigation hierarchy and context for users.
///
/// The breadcrumbs automatically adapt to light and dark themes and provide
/// a clean, modern appearance with proper spacing and accessibility.
///
/// Example:
/// ```dart
/// HuxBreadcrumbs(
///   items: [
///     HuxBreadcrumbItem(
///       label: 'Home',
///       onTap: () => Navigator.popUntil(context, (route) => route.isFirst),
///       icon: Icons.home,
///     ),
///     HuxBreadcrumbItem(
///       label: 'Products',
///       onTap: () => Navigator.pushNamed(context, '/products'),
///     ),
///     HuxBreadcrumbItem(
///       label: 'Current Page',
///       onTap: () {},
///       isActive: true,
///     ),
///   ],
/// )
/// ```
class HuxBreadcrumbs extends StatelessWidget {
  /// Creates a HuxBreadcrumbs widget.
  const HuxBreadcrumbs({
    super.key,
    required this.items,
    this.variant = HuxBreadcrumbVariant.default_,
    this.size = HuxBreadcrumbSize.medium,
    this.maxItems,
    this.overflowIndicator,
  });

  /// List of breadcrumb items to display
  final List<HuxBreadcrumbItem> items;

  /// Visual variant of the breadcrumbs
  final HuxBreadcrumbVariant variant;

  /// Size variant of the breadcrumbs
  final HuxBreadcrumbSize size;

  /// Maximum number of breadcrumb items to show before overflow
  final int? maxItems;

  /// Custom overflow indicator widget when maxItems is exceeded
  final Widget? overflowIndicator;

  @override
  Widget build(BuildContext context) {
    final displayItems = _getDisplayItems();
    final screenWidth = MediaQuery.of(context).size.width;
    final isNarrow = screenWidth < 768;

    return Semantics(
      label: 'Breadcrumb navigation',
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Use scrollable if width is constrained and narrow
          if (isNarrow || constraints.maxWidth < 500) {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: _buildBreadcrumbList(context, displayItems),
              ),
            );
          }
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: _buildBreadcrumbList(context, displayItems),
          );
        },
      ),
    );
  }

  List<HuxBreadcrumbItem> _getDisplayItems() {
    if (maxItems == null || items.length <= maxItems!) {
      return items;
    }

    // If we have overflow, show first item, overflow indicator, and last items
    final visibleItems = <HuxBreadcrumbItem>[];

    // Always show first item
    visibleItems.add(items.first);

    // Add overflow indicator
    visibleItems.add(HuxBreadcrumbItem(
      label: '...',
      onTap: () {},
      isDisabled: true,
    ));

    // Add remaining items (last maxItems - 2 items)
    final remainingCount = maxItems! - 2;
    visibleItems.addAll(items.skip(items.length - remainingCount));

    return visibleItems;
  }

  List<Widget> _buildBreadcrumbList(
      BuildContext context, List<HuxBreadcrumbItem> displayItems) {
    final widgets = <Widget>[];

    for (int i = 0; i < displayItems.length; i++) {
      final item = displayItems[i];

      // Add breadcrumb item
      widgets.add(_buildBreadcrumbItem(context, item));

      // Add separator if not the last item
      if (i < displayItems.length - 1) {
        widgets.add(_buildSeparator(context));
      }
    }

    return widgets;
  }

  Widget _buildBreadcrumbItem(BuildContext context, HuxBreadcrumbItem item) {
    final isOverflow = item.label == '...';

    if (isOverflow && overflowIndicator != null) {
      return overflowIndicator!;
    }

    return _BreadcrumbItemWidget(
      item: item,
      size: size,
      variant: variant,
      isOverflow: isOverflow,
    );
  }

  Widget _buildSeparator(BuildContext context) {
    final separatorPadding =
        EdgeInsets.symmetric(horizontal: _getSeparatorSpacing());

    switch (variant) {
      case HuxBreadcrumbVariant.default_:
        return Padding(
          padding: separatorPadding,
          child: Text(
            '/',
            style: _getSeparatorTextStyle(context),
          ),
        );
      case HuxBreadcrumbVariant.icon:
        return Padding(
          padding: separatorPadding,
          child: Icon(
            Icons.chevron_right,
            size: _getIconSize(),
            color: HuxTokens.iconSecondary(context),
          ),
        );
    }
  }

  TextStyle _getSeparatorTextStyle(BuildContext context) {
    return TextStyle(
      color: HuxTokens.iconSecondary(context),
      fontSize: _getFontSize(),
      fontWeight: FontWeight.w400,
    );
  }

  double _getFontSize() {
    switch (size) {
      case HuxBreadcrumbSize.small:
        return 12;
      case HuxBreadcrumbSize.medium:
        return 14;
      case HuxBreadcrumbSize.large:
        return 16;
    }
  }

  double _getIconSize() {
    switch (size) {
      case HuxBreadcrumbSize.small:
        return 14;
      case HuxBreadcrumbSize.medium:
        return 16;
      case HuxBreadcrumbSize.large:
        return 18;
    }
  }

  double _getSeparatorSpacing() {
    switch (size) {
      case HuxBreadcrumbSize.small:
        return 4;
      case HuxBreadcrumbSize.medium:
        return 6;
      case HuxBreadcrumbSize.large:
        return 8;
    }
  }
}

class _BreadcrumbItemWidget extends StatelessWidget {
  const _BreadcrumbItemWidget({
    required this.item,
    required this.size,
    required this.variant,
    required this.isOverflow,
  });

  final HuxBreadcrumbItem item;
  final HuxBreadcrumbSize size;
  final HuxBreadcrumbVariant variant;
  final bool isOverflow;

  @override
  Widget build(BuildContext context) {
    final textStyle = _getTextStyle(context);
    final iconSize = _getIconSize();

    if (isOverflow) {
      return Text(
        item.label,
        style: textStyle.copyWith(
          color: HuxTokens.textDisabled(context),
        ),
      );
    }

    if (item.isDisabled) {
      return _buildDisabledItem(context, textStyle, iconSize);
    }

    return _buildInteractiveItem(context, textStyle, iconSize);
  }

  Widget _buildDisabledItem(
      BuildContext context, TextStyle textStyle, double iconSize) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (item.icon != null) ...[
          Icon(
            item.icon,
            size: iconSize,
            color: HuxTokens.iconPrimary(context),
          ),
          const SizedBox(width: 6),
        ],
        Text(
          item.label,
          style: textStyle.copyWith(
            color: HuxTokens.textDisabled(context),
          ),
        ),
      ],
    );
  }

  Widget _buildInteractiveItem(
      BuildContext context, TextStyle textStyle, double iconSize) {
    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(_getBorderRadius(context)),
      hoverColor: HuxTokens.surfaceHover(context),
      splashFactory: NoSplash.splashFactory,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: _getHorizontalPadding(),
          vertical: _getVerticalPadding(),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (item.icon != null) ...[
              Icon(
                item.icon,
                size: iconSize,
                color: item.isActive
                    ? HuxTokens.primary(context)
                    : HuxTokens.iconPrimary(context),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              item.label,
              style: textStyle.copyWith(
                color: item.isActive
                    ? HuxTokens.primary(context)
                    : HuxTokens.textSecondary(context),
                fontWeight: item.isActive ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  TextStyle _getTextStyle(BuildContext context) {
    final baseStyle = Theme.of(context).textTheme.bodyMedium;

    switch (size) {
      case HuxBreadcrumbSize.small:
        return baseStyle?.copyWith(fontSize: 12) ??
            const TextStyle(fontSize: 12);
      case HuxBreadcrumbSize.medium:
        return baseStyle?.copyWith(fontSize: 14) ??
            const TextStyle(fontSize: 14);
      case HuxBreadcrumbSize.large:
        return baseStyle?.copyWith(fontSize: 16) ??
            const TextStyle(fontSize: 16);
    }
  }

  double _getIconSize() {
    switch (size) {
      case HuxBreadcrumbSize.small:
        return 14;
      case HuxBreadcrumbSize.medium:
        return 16;
      case HuxBreadcrumbSize.large:
        return 18;
    }
  }

  double _getBorderRadius(BuildContext context) {
    if (HuxScope.of(context) == HuxVariant.brutalist) return 0;
    switch (size) {
      case HuxBreadcrumbSize.small:
        return 4;
      case HuxBreadcrumbSize.medium:
        return 6;
      case HuxBreadcrumbSize.large:
        return 8;
    }
  }

  double _getHorizontalPadding() {
    switch (size) {
      case HuxBreadcrumbSize.small:
        return 4;
      case HuxBreadcrumbSize.medium:
        return 6;
      case HuxBreadcrumbSize.large:
        return 8;
    }
  }

  double _getVerticalPadding() {
    switch (size) {
      case HuxBreadcrumbSize.small:
        return 2;
      case HuxBreadcrumbSize.medium:
        return 4;
      case HuxBreadcrumbSize.large:
        return 6;
    }
  }
}
