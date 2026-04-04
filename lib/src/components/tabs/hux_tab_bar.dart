import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hux/hux.dart';

/// Controller for managing HuxChromeTabs state.
///
/// Use this controller to programmatically manage tabs, including adding,
/// removing, reordering, and setting the active tab.
class HuxTabBarController extends ChangeNotifier {
  /// Creates a HuxTabBarController.
  ///
  /// [initialTabs] - The initial list of tabs. Defaults to empty list.
  /// [initialIndex] - The index of the initially active tab. Defaults to 0.
  HuxTabBarController({
    List<HuxTabBarItem> initialTabs = const [],
    int initialIndex = 0,
  })  : _tabs = List.from(initialTabs),
        _activeIndex = initialIndex > -1 && initialIndex < initialTabs.length
            ? initialIndex
            : 0;

  bool _indexIsValid(int index) => index > -1 && index < _tabs.length;

  final List<HuxTabBarItem> _tabs;
  int _activeIndex;

  /// Returns the index of the currently active tab.
  int get activeIndex => _activeIndex;

  /// Returns the content widget of the currently active tab.
  /// Returns null if there are no tabs.
  Widget? get getContent =>
      _indexIsValid(_activeIndex) ? _tabs[_activeIndex].content : null;

  /// Returns the number of tabs.
  int get tabCount => _tabs.length;

  /// Adds a new tab to the tab bar.
  ///
  /// [tab] - The tab item to add.
  /// [autoActivate] - Whether to automatically activate the newly added tab. Default is true.
  void addTab(HuxTabBarItem tab, [bool autoActivate = true]) {
    _tabs.add(tab);
    if (autoActivate) _activeIndex = _tabs.length - 1;
    notifyListeners();
  }

  /// Removes a tab at the specified index.
  ///
  /// [index] - The index of the tab to remove.
  void removeTab(int index) {
    if (_tabs.isEmpty) return;
    _tabs.removeAt(index);
    if (_activeIndex >= _tabs.length && _tabs.isNotEmpty) {
      _activeIndex = _tabs.length - 1;
    } else if (_activeIndex > index && _activeIndex > 0) {
      _activeIndex--;
    }
    if (_tabs.isEmpty) {
      _activeIndex = 0;
    }
    notifyListeners();
  }

  /// Sets the active tab by index.
  ///
  /// [index] - The index of the tab to activate.
  void setActiveIndex(int index) {
    if (index >= 0 && index < _tabs.length) {
      _activeIndex = index;
      notifyListeners();
    }
  }

  /// Reorders tabs by moving a tab from [oldIndex] to [newIndex].
  ///
  /// [oldIndex] - The current index of the tab to move.
  /// [newIndex] - The target index where the tab should be moved to.
  void reorderTabs(int oldIndex, int newIndex) {
    if (oldIndex == newIndex) return;

    if (newIndex > oldIndex) {
      newIndex -= 1;
    }

    final item = _tabs.removeAt(oldIndex);
    _tabs.insert(newIndex, item);

    // Update active index
    if (_activeIndex == oldIndex) {
      _activeIndex = newIndex;
    } else if (oldIndex < _activeIndex && newIndex >= _activeIndex) {
      _activeIndex--;
    } else if (oldIndex > _activeIndex && newIndex <= _activeIndex) {
      _activeIndex++;
    }

    notifyListeners();
  }

  /// Get a tab at a given index
  HuxTabBarItem getTab(int index) {
    assert(_indexIsValid(index), 'Invalid index');
    return _tabs[index];
  }
}

/// Orientation for HuxChromeTabs.
enum HuxTabBarOrientation {
  /// Horizontal tabs (like Chrome browser)
  horizontal,

  /// Vertical tabs (for future support)
  vertical,
}

/// Size variants for HuxChromeTabs.
enum HuxChromeTabsSize {
  /// Small tabs for compact layouts
  small,

  /// Medium tabs for standard layouts (default)
  medium,

  /// Large tabs for prominent navigation
  large,
}

/// HuxChromeTabItem represents a single Chrome-style tab with its content and properties.
class HuxTabBarItem {
  /// Creates a HuxChromeTabItem.
  const HuxTabBarItem({
    required this.label,
    required this.content,
    this.icon,
    this.isClosable = true,
  });

  /// The text label displayed on the tab
  final String label;

  /// The content widget displayed when this tab is active
  final Widget content;

  /// Optional icon displayed before the label
  final IconData? icon;

  /// Whether this tab can be closed
  final bool isClosable;
}

/// A Chrome-style tab bar widget with drag-to-reorder support.
///
/// Supports dynamic tab addition, removal, and drag-to-reorder functionality.
/// For touch devices, long press is required before dragging to distinguish
/// between scroll and drag operations.
class HuxTabBar extends StatefulWidget {
  /// Creates a HuxTabBar widget.
  ///
  /// [controller] - The HuxTabBarController to manage tab state (required).
  /// [size] - The size variant of the tabs. Defaults to medium.
  /// [orientation] - The orientation of tabs. Defaults to horizontal.
  /// [onActiveChanged] - Callback when the active tab changes.
  /// [onTabsReordered] - Callback when tabs are reordered.
  /// [onTabClosed] - Callback when a tab is closed.
  /// [onAddTab] - Callback when the add button is pressed.
  /// [maxWidth] - Maximum width for each tab.
  /// [minWidth] - Minimum width for each tab. Defaults to 80.
  /// [useIntrinsicWidth] - Whether to use intrinsic width calculation.
  const HuxTabBar({
    super.key,
    required this.controller,
    this.size = HuxChromeTabsSize.medium,
    this.orientation = HuxTabBarOrientation.horizontal,
    this.onActiveChanged,
    this.onTabsReordered,
    this.onTabClosed,
    this.onAddTab,
    this.maxWidth,
    this.minWidth = 80,
    this.useIntrinsicWidth = true,
  });

  /// Controller for managing tabs state
  final HuxTabBarController controller;

  /// Size variant of the tabs
  final HuxChromeTabsSize size;

  /// Orientation of the tabs
  final HuxTabBarOrientation orientation;

  /// Callback when the active tab changes
  final ValueChanged<int>? onActiveChanged;

  /// Callback when tabs are reordered
  final void Function(int oldIndex, int newIndex)? onTabsReordered;

  /// Callback when a tab is closed
  final ValueChanged<int>? onTabClosed;

  /// Callback when the add button is pressed
  final VoidCallback? onAddTab;

  /// Maximum width for each tab (null for auto-sizing based on content)
  final double? maxWidth;

  /// Minimum width for each tab
  final double minWidth;

  /// Whether to enable intrinsic sizing for better performance
  final bool useIntrinsicWidth;

  @override
  State<HuxTabBar> createState() => _HuxTabBarState();
}

class _HuxTabBarState extends State<HuxTabBar> {
  HuxButtonSize get _buttonSize => HuxButtonSize.values[widget.size.index];

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() {
    setState(() {});
  }

  void _onTabTap(int index) {
    widget.controller.setActiveIndex(index);
    widget.onActiveChanged?.call(index);
  }

  void _onTabClose(int index) {
    widget.controller.removeTab(index);
    widget.onTabClosed?.call(index);
    widget.onActiveChanged?.call(widget.controller.activeIndex);
  }

  void _onReorder(int oldIndex, int newIndex) {
    widget.controller.reorderTabs(oldIndex, newIndex);
    widget.onTabsReordered?.call(oldIndex, newIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _getTabHeight(),
      decoration: BoxDecoration(
        color: HuxTokens.surfaceSecondary(context),
      ),
      child: Row(
        children: [
          Expanded(
            child: Listener(
              onPointerHover: (_) {
                final wasInactive = !_mouseTimer.isActive;
                _mouseTimer.cancel();
                _mouseTimer = Timer(Duration(milliseconds: 500), () {
                  setState(() {}); // _mouseTimer.isActive = false;
                });
                if (wasInactive) setState(() {}); // isActive = true;
              },
              child: ReorderableListView.builder(
                scrollDirection: Axis.horizontal,
                buildDefaultDragHandles: false,
                onReorder: _onReorder,
                proxyDecorator: (child, index, animation) {
                  return Material(
                    color: Colors.transparent,
                    child: child,
                  );
                },
                onReorderStart: widget.controller.setActiveIndex,
                itemCount: widget.controller.tabCount,
                itemBuilder: _mouseTimer
                        .isActive // Touch requires delay to distinguish drag from scroll
                    ? (context, index) {
                        final tab = widget.controller.getTab(index);
                        return ReorderableDragStartListener(
                          key: ValueKey(tab.label + index.toString()),
                          index: index,
                          child: _buildTab(context, index),
                        );
                      }
                    : (context, index) {
                        final tab = widget.controller.getTab(index);
                        return ReorderableDelayedDragStartListener(
                          key: ValueKey(tab.label + index.toString()),
                          index: index,
                          child: _buildTab(context, index),
                        );
                      },
              ),
            ),
          ),
          if (widget.onAddTab != null)
            // Add button
            Padding(
              padding: EdgeInsets.all(3),
              child: HuxButton(
                variant: HuxButtonVariant.ghost,
                size: _buttonSize,
                onPressed: widget.onAddTab,
                icon: Icons.add,
                child: SizedBox.shrink(),
              ),
            ),
        ],
      ),
    );
  }

  Timer _mouseTimer = Timer(Duration.zero, () {})..cancel();

  Widget _buildTab(BuildContext context, int index) {
    final tab = widget.controller.getTab(index);
    final isActive = index == widget.controller.activeIndex;

    final tabContent = Padding(
      padding: EdgeInsets.symmetric(
        horizontal: _getHorizontalPadding(),
        vertical: _getVerticalPadding(),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (tab.icon != null) ...[
            Icon(
              tab.icon,
              size: _getIconSize(),
              color: isActive
                  ? HuxTokens.textPrimary(context)
                  : HuxTokens.textSecondary(context),
            ),
            const SizedBox(width: 8),
          ],
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: widget.maxWidth ?? double.infinity,
            ),
            child: Text(
              tab.label,
              style: TextStyle(
                fontSize: _getFontSize(),
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: isActive
                    ? HuxTokens.textPrimary(context)
                    : HuxTokens.textSecondary(context),
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          if (tab.isClosable) ...[
            const SizedBox(width: 8),
            HuxButton(
              width: HuxButtonWidth.expand,
              widthValue: 5,
              variant: HuxButtonVariant.ghost,
              size: _buttonSize,
              onPressed: () => _onTabClose(index),
              icon: Icons.close,
              child: SizedBox.shrink(),
            ),
          ],
        ],
      ),
    );

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => _onTabTap(index),
        onTertiaryTapUp: (_) => _onTabClose(index),
        child: widget.useIntrinsicWidth
            ? IntrinsicWidth(
                child: Stack(
                  children: [
                    CustomPaint(
                      painter: _ChromeTabPainter(
                        isActive: isActive,
                        backgroundColor: isActive
                            ? HuxTokens.surfacePrimary(context)
                            : Colors.transparent,
                        borderColor: HuxTokens.borderSecondary(context),
                      ),
                      child: SizedBox(
                        height: double.infinity,
                        width: double.infinity,
                      ),
                    ),
                    tabContent,
                  ],
                ),
              )
            : Container(
                constraints: BoxConstraints(
                  minWidth: widget.minWidth,
                  maxWidth: widget.maxWidth ?? double.infinity,
                ),
                child: Stack(
                  children: [
                    CustomPaint(
                      painter: _ChromeTabPainter(
                        isActive: isActive,
                        backgroundColor: isActive
                            ? HuxTokens.surfacePrimary(context)
                            : Colors.transparent,
                        borderColor: HuxTokens.borderSecondary(context),
                      ),
                      child: SizedBox(
                        height: double.infinity,
                        width: double.infinity,
                      ),
                    ),
                    tabContent,
                  ],
                ),
              ),
      ),
    );
  }

  double _getTabHeight() {
    switch (widget.size) {
      case HuxChromeTabsSize.small:
        return 32;
      case HuxChromeTabsSize.medium:
        return 40;
      case HuxChromeTabsSize.large:
        return 48;
    }
  }

  double _getHorizontalPadding() {
    switch (widget.size) {
      case HuxChromeTabsSize.small:
        return 12;
      case HuxChromeTabsSize.medium:
        return 16;
      case HuxChromeTabsSize.large:
        return 20;
    }
  }

  double _getVerticalPadding() {
    switch (widget.size) {
      case HuxChromeTabsSize.small:
        return 6;
      case HuxChromeTabsSize.medium:
        return 8;
      case HuxChromeTabsSize.large:
        return 12;
    }
  }

  double _getIconSize() {
    switch (widget.size) {
      case HuxChromeTabsSize.small:
        return 14;
      case HuxChromeTabsSize.medium:
        return 16;
      case HuxChromeTabsSize.large:
        return 18;
    }
  }

  double _getFontSize() {
    switch (widget.size) {
      case HuxChromeTabsSize.small:
        return 12;
      case HuxChromeTabsSize.medium:
        return 14;
      case HuxChromeTabsSize.large:
        return 16;
    }
  }
}

/// Custom painter for Chrome-style tab with curved bottom edges
class _ChromeTabPainter extends CustomPainter {
  _ChromeTabPainter({
    required this.isActive,
    required this.backgroundColor,
    required this.borderColor,
  });

  final bool isActive;
  final Color backgroundColor;
  final Color borderColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (!isActive) return;

    const curveRadius = 8.0;

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final paint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;
    final path = Path();

    // Bottom-left quarter circle
    path.moveTo(0, size.height);
    path.quadraticBezierTo(
      curveRadius,
      size.height,
      curveRadius,
      size.height - curveRadius,
    );
    path.lineTo(curveRadius, curveRadius);

    // Top-left corner arc
    path.quadraticBezierTo(
      curveRadius,
      0,
      curveRadius * 2,
      0,
    );

    // Top edge
    path.lineTo(size.width - curveRadius * 2, 0);

    // Top-right corner arc
    path.quadraticBezierTo(
      size.width - curveRadius,
      0,
      size.width - curveRadius,
      curveRadius,
    );

    // Right edge downward
    path.lineTo(size.width - curveRadius, size.height - curveRadius);

    // Bottom-right quarter circle (concave upward)
    path.quadraticBezierTo(
      size.width - curveRadius,
      size.height,
      size.width,
      size.height,
    );

    canvas.drawPath(path, paint);
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(_ChromeTabPainter oldDelegate) {
    return oldDelegate.isActive != isActive ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.borderColor != borderColor;
  }
}
