import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../../theme/hux_tokens.dart';
import 'hux_context_menu_item.dart';
import 'hux_context_menu_divider.dart';

/// HuxContextMenu wraps a child widget and displays a context menu on right-click
///
/// Provides a consistent, themed context menu that follows the Hux UI design system.
/// The menu automatically positions itself to avoid screen overflow and supports
/// keyboard navigation.
///
/// Example:
/// ```dart
/// HuxContextMenu(
///   menuItems: [
///     HuxContextMenuItem(
///       text: 'Copy',
///       icon: Icons.copy,
///       onTap: () => print('Copy'),
///     ),
///     HuxContextMenuItem(
///       text: 'Paste',
///       icon: Icons.paste,
///       onTap: () => print('Paste'),
///       isDisabled: true,
///     ),
///     HuxContextMenuDivider(),
///     HuxContextMenuItem(
///       text: 'Delete',
///       icon: Icons.delete,
///       onTap: () => print('Delete'),
///       isDestructive: true,
///     ),
///   ],
///   child: Container(
///     padding: EdgeInsets.all(20),
///     child: Text('Right-click me!'),
///   ),
/// )
/// ```
class HuxContextMenu extends StatelessWidget {
  /// Creates a HuxContextMenu widget.
  ///
  /// The [child] and [menuItems] parameters are required.
  const HuxContextMenu({
    super.key,
    required this.child,
    required this.menuItems,
    this.enabled = true,
  });

  /// The child widget that will trigger the context menu on right-click
  final Widget child;

  /// List of menu items to display in the context menu
  final List<Widget> menuItems;

  /// Whether the context menu is enabled
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    if (!enabled || menuItems.isEmpty) {
      return child;
    }

    final Widget contextMenuWidget = GestureDetector(
      onSecondaryTapDown: (details) {
        _showContextMenu(context, details.globalPosition);
      },
      onLongPressStart: (details) {
        _showContextMenu(context, details.globalPosition);
      },
      child: child,
    );

    // Prevent browser context menu on web
    _disableBrowserContextMenu();

    return contextMenuWidget;
  }

  void _disableBrowserContextMenu() {
    if (kIsWeb) {
      BrowserContextMenu.disableContextMenu();
    }
  }

  void _showContextMenu(BuildContext context, Offset position) {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final Size overlaySize = overlay.size;

    // Calculate menu size estimation
    const double estimatedItemHeight = 40.0;
    const double menuPadding = 16.0;
    const double maxMenuWidth = 200.0;

    final double menuHeight =
        (menuItems.length * estimatedItemHeight) + menuPadding;
    const double menuWidth = maxMenuWidth;

    // Smart positioning to avoid overflow
    double left = position.dx;
    double top = position.dy;

    // Adjust horizontal position if menu would overflow
    if (left + menuWidth > overlaySize.width) {
      left = overlaySize.width - menuWidth - 8;
    }
    if (left < 8) {
      left = 8;
    }

    // Adjust vertical position if menu would overflow
    if (top + menuHeight > overlaySize.height) {
      top = overlaySize.height - menuHeight - 8;
    }
    if (top < 8) {
      top = 8;
    }

    showMenu<void>(
      context: context,
      position:
          RelativeRect.fromLTRB(left, top, left + menuWidth, top + menuHeight),
      items: [
        PopupMenuItem<void>(
          enabled: false,
          padding: EdgeInsets.zero,
          child: _HuxContextMenuContent(menuItems: menuItems),
        ),
      ],
      elevation: 0,
      color: Colors.transparent,
      shape: const RoundedRectangleBorder(),
    );
  }
}

/// Internal widget that renders the actual context menu content
class _HuxContextMenuContent extends StatelessWidget {
  const _HuxContextMenuContent({
    required this.menuItems,
  });

  final List<Widget> menuItems;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        minWidth: 160,
        maxWidth: 240,
      ),
      decoration: BoxDecoration(
        color: HuxTokens.surfacePrimary(context),
        borderRadius: BorderRadius.circular(HuxTokens.radiusLg(context)),
        border: Border.all(
          color: HuxTokens.borderPrimary(context),
          width: HuxTokens.borderWidth(context),
        ),
        boxShadow: HuxTokens.shadowElevated(context),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: menuItems.map((item) {
            if (item is HuxContextMenuItem) {
              return _HuxContextMenuItemWrapper(
                item: item,
                onItemTap: () {
                  Navigator.of(context).pop();
                  item.onTap?.call();
                },
              );
            } else if (item is HuxContextMenuDivider) {
              return item;
            } else {
              // Custom widget support
              return InkWell(
                onTap: () => Navigator.of(context).pop(),
                child: item,
              );
            }
          }).toList(),
        ),
      ),
    );
  }
}

/// Internal wrapper for context menu items to handle tap events properly
class _HuxContextMenuItemWrapper extends StatelessWidget {
  const _HuxContextMenuItemWrapper({
    required this.item,
    required this.onItemTap,
  });

  final HuxContextMenuItem item;
  final VoidCallback onItemTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: item.isDisabled ? null : onItemTap,
        borderRadius: BorderRadius.circular(HuxTokens.radiusMd(context)),
        hoverColor: HuxTokens.surfaceHover(context),
        splashFactory: NoSplash.splashFactory, // Remove ripple effect
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (item.icon != null) ...[
                Icon(
                  item.icon,
                  size: 16,
                  color: _getIconColor(context),
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  item.text,
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

  Color _getTextColor(BuildContext context) {
    if (item.isDisabled) {
      return HuxTokens.textDisabled(context);
    } else if (item.isDestructive) {
      return HuxTokens.textDestructive(context);
    } else {
      return HuxTokens.textPrimary(context);
    }
  }

  Color _getIconColor(BuildContext context) {
    if (item.isDisabled) {
      return HuxTokens.textDisabled(context);
    } else if (item.isDestructive) {
      return HuxTokens.textDestructive(context);
    } else {
      return HuxTokens.iconSecondary(context);
    }
  }
}
