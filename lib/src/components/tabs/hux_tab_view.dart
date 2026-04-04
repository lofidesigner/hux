import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/hux_tokens.dart';
import '../buttons/hux_button.dart';
import '../tooltip/hux_tooltip.dart';

/// Visual variants for HuxTabView.
enum HuxTabViewVariant {
  /// Default tabs with underline indicator and close buttons
  default_,

  /// Minimal tabs with text color changes and close buttons
  minimal,
}

/// Size variants for HuxTabView.
enum HuxTabViewSize {
  /// Small tabs for compact layouts
  small,

  /// Medium tabs for standard layouts (default)
  medium,

  /// Large tabs for prominent navigation
  large,
}

/// Represents a single tab in the TabView with its content and metadata.
class TabDocument {
  /// Creates a TabDocument.
  TabDocument({
    required this.title,
    required this.content,
    this.icon,
    this.isClosable = true,
    this.identifier,
  });

  /// The title displayed on the tab
  final String title;

  /// The content widget displayed when this tab is active
  final Widget content;

  /// Optional icon displayed before the title
  final IconData? icon;

  /// Whether this tab can be closed
  final bool isClosable;

  /// Optional unique identifier for the tab
  final String? identifier;
}

/// A TabView component for dynamic workspace management.
///
/// Unlike HuxTabs which is for static section navigation, HuxTabView is
/// designed for browser-like or IDE-like tab interfaces where users can
/// open, close, and switch between multiple documents or views.
///
/// Features:
/// - Open/close tabs dynamically
/// - Close buttons on individual tabs
/// - Optional "New Tab" button
/// - Horizontal scrolling for many tabs
/// - Keyboard shortcuts (Ctrl+W/Cmd+W to close, Ctrl+Tab/Cmd+Tab to switch)
///
/// Example:
/// ```dart
/// HuxTabView(
///   initialTabs: [
///     TabDocument(title: 'Home', content: HomePage()),
///   ],
///   onTabAdded: (doc) => print('Opened ${doc.title}'),
///   onTabClosed: (index, doc) => print('Closed ${doc.title}'),
/// )
/// ```
class HuxTabView extends StatefulWidget {
  /// Creates a HuxTabView widget.
  const HuxTabView({
    super.key,
    this.initialTabs,
    this.initialIndex = 0,
    this.variant = HuxTabViewVariant.default_,
    this.size = HuxTabViewSize.medium,
    this.showNewTabButton = false,
    this.canCloseTabs = true,
    this.onTabChanged,
    this.onTabAdded,
    this.onTabClosed,
    this.onNewTabRequested,
    this.expandContent = true,
    this.tabMaxWidth,
    this.newTabTooltip = 'New Tab (Ctrl+T)',
    this.closeTabTooltip = 'Close tab (Ctrl+W)',
  });

  /// Initial list of tabs to display
  final List<TabDocument>? initialTabs;

  /// Initial active tab index
  final int initialIndex;

  /// Visual variant of the tabs
  final HuxTabViewVariant variant;

  /// Size variant of the tabs
  final HuxTabViewSize size;

  /// Whether to show a "New Tab" button
  final bool showNewTabButton;

  /// Whether tabs can be closed
  final bool canCloseTabs;

  /// Callback when the active tab changes
  final ValueChanged<int>? onTabChanged;

  /// Callback when a tab is added
  final ValueChanged<TabDocument>? onTabAdded;

  /// Callback when a tab is closed
  final void Function(int index, TabDocument document)? onTabClosed;

  /// Callback when the new tab button is pressed
  final VoidCallback? onNewTabRequested;

  /// Whether content should expand to fill available space
  final bool expandContent;

  /// Maximum width for individual tabs
  final double? tabMaxWidth;

  /// Tooltip text for the new tab button
  final String newTabTooltip;

  /// Tooltip text for the close tab button
  final String closeTabTooltip;

  @override
  State<HuxTabView> createState() => _HuxTabViewState();
}

class _HuxTabViewState extends State<HuxTabView> with TickerProviderStateMixin {
  late List<TabDocument> _tabs;
  late int _activeIndex;
  int _untitledCount = 0;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabs = List.from(widget.initialTabs ?? []);
    _activeIndex =
        widget.initialIndex.clamp(0, _tabs.isEmpty ? 0 : _tabs.length - 1);
  }

  @override
  void didUpdateWidget(HuxTabView oldWidget) {
    super.didUpdateWidget(oldWidget);

    final oldLength = oldWidget.initialTabs?.length ?? 0;
    final newLength = widget.initialTabs?.length ?? 0;

    // Update if length changed (tabs added or removed)
    if (newLength != oldLength) {
      setState(() {
        _tabs = List.from(widget.initialTabs ?? []);
        // Clamp active index to valid range
        if (_activeIndex >= _tabs.length) {
          _activeIndex = _tabs.isEmpty ? 0 : _tabs.length - 1;
        }
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _closeTab(int index) {
    if (index < 0 || index >= _tabs.length) return;
    if (!_tabs[index].isClosable) return;

    final closedTab = _tabs[index];

    setState(() {
      _tabs.removeAt(index);

      // Adjust active index
      if (_tabs.isEmpty) {
        _activeIndex = 0;
      } else if (_activeIndex >= _tabs.length) {
        _activeIndex = _tabs.length - 1;
      } else if (_activeIndex > index) {
        _activeIndex--;
      }
    });

    widget.onTabClosed?.call(index, closedTab);
    if (_tabs.isNotEmpty) {
      widget.onTabChanged?.call(_activeIndex);
    }
  }

  void _switchToTab(int index) {
    if (index < 0 || index >= _tabs.length || index == _activeIndex) return;

    setState(() {
      _activeIndex = index;
    });
    widget.onTabChanged?.call(index);
    _scrollToActiveTab();
  }



  void _scrollToActiveTab() {
    if (!_scrollController.hasClients) return;

    // Calculate position to scroll to center the active tab
    final maxScroll = _scrollController.position.maxScrollExtent;
    final tabWidth = widget.tabMaxWidth ?? _getTabWidth();
    final targetOffset = (_activeIndex * tabWidth) -
        (_scrollController.position.viewportDimension / 2) +
        (tabWidth / 2);

    _scrollController.animateTo(
      targetOffset.clamp(0, maxScroll).toDouble(),
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTabBar(context),
        const SizedBox(height: 16),
        Expanded(
          child: _tabs.isEmpty
              ? _buildEmptyState(context)
              : _buildTabContent(context),
        ),
      ],
    );
  }

  Widget _buildTabBar(BuildContext context) {
    return Container(
      height: _getTabBarHeight(),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: HuxTokens.tabBorder(context),
            width: 1,
          ),
        ),
      ),
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 8, right: 8, top: 8),
        itemCount: _tabs.length + (widget.showNewTabButton ? 1 : 0),
        itemBuilder: (context, index) {
          if (index < _tabs.length) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: _buildTab(context, index),
            );
          }
          // Last item is the + button
          return Padding(
            padding: const EdgeInsets.only(left: 8),
            child: _buildNewTabButton(context),
          );
        },
      ),
    );
  }

  Widget _buildTab(BuildContext context, int index) {
    final tab = _tabs[index];
    final isActive = index == _activeIndex;
    final fixedWidth = widget.tabMaxWidth ?? 260;
    final isHovering = ValueNotifier<bool>(false);

    return ValueListenableBuilder<bool>(
      valueListenable: isHovering,
      builder: (context, hovering, _) {
        return MouseRegion(
          onEnter: (_) => isHovering.value = true,
          onExit: (_) => isHovering.value = false,
          child: Container(
            width: fixedWidth,
            margin: EdgeInsets.only(bottom: isActive ? 0 : 2),
            child: Material(
              color: Colors.transparent,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: InkWell(
                onTap: () => _switchToTab(index),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                hoverColor: Colors.transparent,
                highlightColor: Colors.transparent,
                splashColor: Colors.transparent,
                child: Container(
                  padding: _getTabPadding(isActive),
                  decoration:
                      _getTabDecoration(context, isActive, isHovered: hovering),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (tab.icon != null) ...[
                        Icon(
                          tab.icon,
                          size: _getIconSize(),
                          color: isActive
                              ? HuxTokens.tabActiveText(context)
                              : HuxTokens.tabInactiveText(context),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Expanded(
                        child: Text(
                          tab.title,
                          style: _getTabTextStyle(context, isActive),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      if (widget.canCloseTabs && tab.isClosable) ...[
                        const SizedBox(width: 4),
                        _buildCloseButton(context, index),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _addNewTab() {
    setState(() {
      _untitledCount++;
      _tabs = [
        ..._tabs,
        TabDocument(
          title: 'Untitled $_untitledCount',
          icon: LucideIcons.file,
          content: _buildEmptyState(context),
        ),
      ];
      _activeIndex = _tabs.length - 1;
    });

    widget.onTabAdded?.call(_tabs[_activeIndex]);
    widget.onTabChanged?.call(_activeIndex);
    _scrollToActiveTab();
  }

  Widget _buildCloseButton(BuildContext context, int index) {
    return HuxTooltip(
      message: widget.closeTabTooltip,
      child: SizedBox(
        width: 28,
        height: 28,
        child: HuxButton(
          onPressed: () => _closeTab(index),
          variant: HuxButtonVariant.ghost,
          size: HuxButtonSize.small,
          icon: LucideIcons.x,
          child: const SizedBox.shrink(),
        ),
      ),
    );
  }

  Widget _buildNewTabButton(BuildContext context) {
    return HuxTooltip(
      message: widget.newTabTooltip,
      child: SizedBox(
        width: 28,
        height: 28,
        child: Center(
          child: HuxButton(
            onPressed: widget.onNewTabRequested ?? _addNewTab,
            variant: HuxButtonVariant.ghost,
            size: HuxButtonSize.small,
            icon: LucideIcons.plus,
            child: const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent(BuildContext context) {
    if (_tabs.isEmpty) return const SizedBox.shrink();

    return IndexedStack(
      index: _activeIndex,
      sizing: StackFit.expand,
      children: _tabs.map((tab) => tab.content).toList(),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.layoutTemplate,
            size: 48,
            color: HuxTokens.iconSecondary(context),
          ),
          const SizedBox(height: 16),
          Text(
            'No tabs open',
            style: TextStyle(
              color: HuxTokens.textSecondary(context),
              fontSize: 16,
            ),
          ),
          if (widget.showNewTabButton && widget.onNewTabRequested != null) ...[
            const SizedBox(height: 16),
            TextButton(
              onPressed: widget.onNewTabRequested,
              child: const Text('Open a new tab'),
            ),
          ],
        ],
      ),
    );
  }

  Decoration? _getTabDecoration(BuildContext context, bool isActive,
      {bool isHovered = false}) {
    if (widget.variant == HuxTabViewVariant.minimal) return null;

    // Chrome-style tabs: active tab covers the divider line
    return BoxDecoration(
      color: isActive
          ? HuxTokens.surfaceElevated(context)
          : isHovered
              ? HuxTokens.tabHoverBackground(context)
              : Colors.transparent,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(12),
        topRight: Radius.circular(12),
      ),
      border: Border(
        bottom: BorderSide(
          color: isActive
              ? HuxTokens.surfaceElevated(context)
              : Colors.transparent,
          width: 2,
        ),
      ),
      boxShadow: isActive
          ? [
              BoxShadow(
                color: HuxTokens.shadowColor(context),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ]
          : null,
    );
  }

  TextStyle _getTabTextStyle(BuildContext context, bool isActive) {
    final baseStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w500,
        );

    switch (widget.size) {
      case HuxTabViewSize.small:
        return baseStyle?.copyWith(
              fontSize: 12,
              color: isActive
                  ? HuxTokens.tabActiveText(context)
                  : HuxTokens.tabInactiveText(context),
            ) ??
            TextStyle(
              fontSize: 12,
              color: isActive
                  ? HuxTokens.tabActiveText(context)
                  : HuxTokens.tabInactiveText(context),
            );
      case HuxTabViewSize.medium:
        return baseStyle?.copyWith(
              fontSize: 14,
              color: isActive
                  ? HuxTokens.tabActiveText(context)
                  : HuxTokens.tabInactiveText(context),
            ) ??
            TextStyle(
              fontSize: 14,
              color: isActive
                  ? HuxTokens.tabActiveText(context)
                  : HuxTokens.tabInactiveText(context),
            );
      case HuxTabViewSize.large:
        return baseStyle?.copyWith(
              fontSize: 16,
              color: isActive
                  ? HuxTokens.tabActiveText(context)
                  : HuxTokens.tabInactiveText(context),
            ) ??
            TextStyle(
              fontSize: 16,
              color: isActive
                  ? HuxTokens.tabActiveText(context)
                  : HuxTokens.tabInactiveText(context),
            );
    }
  }

  EdgeInsets _getTabPadding(bool isActive) {
    switch (widget.size) {
      case HuxTabViewSize.small:
        return isActive
            ? const EdgeInsets.only(left: 12, right: 6, top: 4, bottom: 6)
            : const EdgeInsets.only(left: 12, right: 6, top: 4, bottom: 4);
      case HuxTabViewSize.medium:
        return isActive
            ? const EdgeInsets.only(left: 16, right: 8, top: 6, bottom: 8)
            : const EdgeInsets.only(left: 16, right: 8, top: 6, bottom: 6);
      case HuxTabViewSize.large:
        return isActive
            ? const EdgeInsets.only(left: 20, right: 10, top: 8, bottom: 10)
            : const EdgeInsets.only(left: 20, right: 10, top: 8, bottom: 8);
    }
  }


  double _getTabBarHeight() {
    switch (widget.size) {
      case HuxTabViewSize.small:
        return 44;
      case HuxTabViewSize.medium:
        return 52;
      case HuxTabViewSize.large:
        return 60;
    }
  }

  double _getMinTabWidth() {
    switch (widget.size) {
      case HuxTabViewSize.small:
        return 80;
      case HuxTabViewSize.medium:
        return 100;
      case HuxTabViewSize.large:
        return 120;
    }
  }

  double _getTabWidth() {
    // Estimate average tab width for scrolling calculations
    return (widget.tabMaxWidth ?? _getMinTabWidth()) + 32;
  }

  double _getIconSize() {
    switch (widget.size) {
      case HuxTabViewSize.small:
        return 14;
      case HuxTabViewSize.medium:
        return 16;
      case HuxTabViewSize.large:
        return 18;
    }
  }
}
