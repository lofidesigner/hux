import 'package:flutter/material.dart';
import '../../theme/hux_tokens.dart';
import 'hux_sidebar_item.dart';

/// A complete sidebar navigation component that manages multiple navigation items.
///
/// Provides a consistent sidebar layout with header, navigation items, and optional footer.
/// Handles selection state management and provides a clean API for sidebar navigation.
///
/// Example:
/// ```dart
/// HuxSidebar(
///   header: Column(
///     children: [
///       Text('My App'),
///       Text('Navigation'),
///     ],
///   ),
///   items: [
///     HuxSidebarItemData(
///       id: 'dashboard',
///       icon: LucideIcons.home,
///       label: 'Dashboard',
///     ),
///     HuxSidebarItemData(
///       id: 'settings',
///       icon: LucideIcons.settings,
///       label: 'Settings',
///     ),
///   ],
///   selectedItemId: 'dashboard',
///   onItemSelected: (itemId) => print('Selected: $itemId'),
/// )
/// ```
class HuxSidebar extends StatelessWidget {
  /// Creates a HuxSidebar widget.
  const HuxSidebar({
    super.key,
    required this.items,
    required this.onItemSelected,
    this.selectedItemId,
    this.header,
    this.footer,
    this.width = 250,
    this.padding = const EdgeInsets.symmetric(vertical: 16),
  });

  /// List of navigation items to display
  final List<HuxSidebarItemData> items;

  /// Callback when an item is selected
  final ValueChanged<String> onItemSelected;

  /// Currently selected item ID
  final String? selectedItemId;

  /// Optional header widget displayed at the top
  final Widget? header;

  /// Optional footer widget displayed at the bottom
  final Widget? footer;

  /// Width of the sidebar
  final double width;

  /// Padding around the sidebar content
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: HuxTokens.surfacePrimary(context),
          border: Border(
            right: BorderSide(
              color: HuxTokens.borderSecondary(context),
              width: HuxTokens.borderWidth(context),
            ),
          ),
        ),
        child: Column(
          children: [
            if (header != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                child: header,
              ),
            ],
            Expanded(
              child: Padding(
                padding: padding,
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: HuxSidebarItem(
                        icon: item.icon,
                        label: item.label,
                        isSelected: selectedItemId == item.id,
                        isDisabled: item.isDisabled,
                        onTap: () => onItemSelected(item.id),
                      ),
                    );
                  },
                ),
              ),
            ),
            if (footer != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                child: footer,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Data class representing a sidebar navigation item.
class HuxSidebarItemData {
  /// Creates a HuxSidebarItemData.
  const HuxSidebarItemData({
    required this.id,
    required this.icon,
    required this.label,
    this.isDisabled = false,
  });

  /// Unique identifier for the item
  final String id;

  /// Icon to display
  final IconData icon;

  /// Text label to display
  final String label;

  /// Whether this item is disabled
  final bool isDisabled;
}
