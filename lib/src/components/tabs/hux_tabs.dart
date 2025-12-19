import 'package:flutter/material.dart';
import '../../theme/hux_tokens.dart';

/// Visual variants for HuxTabs.
enum HuxTabVariant {
  /// Default tabs with underline indicator
  default_,

  /// Pill-style tabs with background indicator
  pill,

  /// Minimal tabs with no indicator
  minimal,
}

/// Size variants for HuxTabs.
enum HuxTabSize {
  /// Small tabs for compact layouts
  small,

  /// Medium tabs for standard layouts (default)
  medium,

  /// Large tabs for prominent navigation
  large,
}

/// HuxTabItem represents a single tab with its content and properties.
class HuxTabItem {
  /// Creates a HuxTabItem.
  const HuxTabItem({
    required this.label,
    required this.content,
    this.icon,
    this.badge,
    this.isDisabled = false,
  });

  /// The text label displayed on the tab
  final String label;

  /// The content widget displayed when this tab is active
  final Widget content;

  /// Optional icon displayed before the label
  final IconData? icon;

  /// Optional badge widget displayed after the label
  final Widget? badge;

  /// Whether this tab is disabled
  final bool isDisabled;
}

/// HuxTabs is a customizable tab component that provides a consistent
/// navigation experience with multiple variants and sizes.
///
/// The tabs automatically adapt to light and dark themes and provide
/// a clean, modern appearance with proper spacing and accessibility.
///
/// Example:
/// ```dart
/// HuxTabs(
///   tabs: [
///     HuxTabItem(
///       label: 'Overview',
///       content: Text('Overview content'),
///       icon: Icons.dashboard,
///     ),
///     HuxTabItem(
///       label: 'Settings',
///       content: Text('Settings content'),
///       icon: Icons.settings,
///     ),
///   ],
///   onTabChanged: (index) => print('Tab changed to $index'),
/// )
/// ```
class HuxTabs extends StatefulWidget {
  /// Creates a HuxTabs widget.
  const HuxTabs({
    super.key,
    required this.tabs,
    this.initialIndex = 0,
    this.variant = HuxTabVariant.default_,
    this.size = HuxTabSize.medium,
    this.onTabChanged,
    this.isScrollable = false,
    this.alignment = TabAlignment.start,
    this.expandContent = false,
  });

  /// List of tab items to display
  final List<HuxTabItem> tabs;

  /// Initial active tab index
  final int initialIndex;

  /// Visual variant of the tabs
  final HuxTabVariant variant;

  /// Size variant of the tabs
  final HuxTabSize size;

  /// Callback when the active tab changes
  final ValueChanged<int>? onTabChanged;

  /// Whether tabs should be scrollable horizontally
  final bool isScrollable;

  /// Alignment of tabs within the available space
  final TabAlignment alignment;

  /// Whether the content should expand to fill available vertical space
  /// 
  /// When true, wraps content in Flexible to fill available height.
  /// When false, content takes only the space it needs.
  /// Defaults to false for better compatibility with unbounded constraints.
  final bool expandContent;

  @override
  State<HuxTabs> createState() => _HuxTabsState();
}

class _HuxTabsState extends State<HuxTabs> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _activeIndex = 0;

  @override
  void initState() {
    super.initState();
    _activeIndex = widget.initialIndex;
    _tabController = TabController(
      length: widget.tabs.length,
      vsync: this,
      initialIndex: widget.initialIndex,
    );
    _tabController.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _activeIndex = _tabController.index;
      });
      widget.onTabChanged?.call(_activeIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = _buildTabContent(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildTabBar(context),
        const SizedBox(height: 16),
        if (widget.expandContent)
          Flexible(fit: FlexFit.loose, child: content)
        else
          content,
      ],
    );
  }

  Widget _buildTabBar(BuildContext context) {
    final tabBar = TabBar(
      controller: _tabController,
      isScrollable: widget.isScrollable || widget.variant != HuxTabVariant.pill,
      tabAlignment:
          (widget.isScrollable || widget.variant != HuxTabVariant.pill)
              ? widget.alignment
              : null,
      indicator: _buildTabIndicator(context),
      indicatorSize: _getIndicatorSize(),
      labelColor: HuxTokens.tabActiveText(context),
      unselectedLabelColor: HuxTokens.tabInactiveText(context),
      labelStyle: _getLabelStyle(context, true),
      unselectedLabelStyle: _getLabelStyle(context, false),
      dividerColor: Colors.transparent,
      overlayColor: WidgetStateProperty.all(Colors.transparent),
      splashFactory: NoSplash.splashFactory,
      tabs: widget.tabs.map((tab) => _buildTab(context, tab)).toList(),
    );

    if (widget.variant == HuxTabVariant.pill) {
      return DecoratedBox(
        decoration: BoxDecoration(
          color: HuxTokens.surfaceSecondary(context),
          borderRadius: BorderRadius.circular(_getBorderRadius()),
          border: Border.all(
            color: HuxTokens.tabBorder(context),
            width: 1,
          ),
        ),
        child: tabBar,
      );
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        border: widget.variant == HuxTabVariant.minimal
            ? null
            : Border(
                bottom: BorderSide(
                  color: HuxTokens.tabBorder(context),
                  width: 1,
                ),
              ),
      ),
      child: tabBar,
    );
  }

  Widget _buildTab(BuildContext context, HuxTabItem tab) {
    final isActive = _activeIndex == widget.tabs.indexOf(tab);
    final tabIndex = widget.tabs.indexOf(tab);

    return Tab(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: widget.variant == HuxTabVariant.pill
              ? null
              : BorderRadius.circular(_getBorderRadius()),
          hoverColor: widget.variant == HuxTabVariant.pill
              ? Colors.transparent
              : HuxTokens.tabHoverBackground(context),
          highlightColor:
              widget.variant == HuxTabVariant.pill ? Colors.transparent : null,
          splashFactory: NoSplash.splashFactory,
          onTap: () {
            _tabController.animateTo(tabIndex);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            constraints: widget.variant == HuxTabVariant.pill
                ? null
                : const BoxConstraints(minWidth: 0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
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
                Text(tab.label),
                if (tab.badge != null) ...[
                  const SizedBox(width: 8),
                  tab.badge!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Decoration? _buildTabIndicator(BuildContext context) {
    switch (widget.variant) {
      case HuxTabVariant.default_:
        return UnderlineTabIndicator(
          borderSide: BorderSide(
            color: HuxTokens.tabIndicator(context),
            width: 2,
          ),
        );
      case HuxTabVariant.pill:
        return BoxDecoration(
          color: HuxTokens.tabActiveBackground(context),
          borderRadius: BorderRadius.circular(_getBorderRadius()),
        );
      case HuxTabVariant.minimal:
        return null;
    }
  }

  Widget _buildTabContent(BuildContext context) {
    return IndexedStack(
      index: _activeIndex,
      sizing: StackFit.loose,
      children: widget.tabs.map((tab) => tab.content).toList(),
    );
  }

  TabBarIndicatorSize _getIndicatorSize() {
    if (widget.variant == HuxTabVariant.pill) {
      return TabBarIndicatorSize.tab;
    }

    switch (widget.size) {
      case HuxTabSize.small:
        return TabBarIndicatorSize.tab;
      case HuxTabSize.medium:
      case HuxTabSize.large:
        return TabBarIndicatorSize.label;
    }
  }

  TextStyle _getLabelStyle(BuildContext context, bool isActive) {
    final baseStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
        );

    switch (widget.size) {
      case HuxTabSize.small:
        return baseStyle?.copyWith(fontSize: 12) ??
            const TextStyle(fontSize: 12);
      case HuxTabSize.medium:
        return baseStyle?.copyWith(fontSize: 14) ??
            const TextStyle(fontSize: 14);
      case HuxTabSize.large:
        return baseStyle?.copyWith(fontSize: 16) ??
            const TextStyle(fontSize: 16);
    }
  }

  double _getIconSize() {
    switch (widget.size) {
      case HuxTabSize.small:
        return 16;
      case HuxTabSize.medium:
        return 18;
      case HuxTabSize.large:
        return 20;
    }
  }

  double _getBorderRadius() {
    switch (widget.size) {
      case HuxTabSize.small:
        return 6;
      case HuxTabSize.medium:
        return 8;
      case HuxTabSize.large:
        return 10;
    }
  }
}
