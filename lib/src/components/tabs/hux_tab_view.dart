import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../theme/hux_tokens.dart';
import '../buttons/hux_button.dart';
import '../tooltip/hux_tooltip.dart';

class _CloseCurrentTabIntent extends Intent {
  const _CloseCurrentTabIntent();
}

class _OpenNewTabIntent extends Intent {
  const _OpenNewTabIntent();
}

class _SwitchToNextTabIntent extends Intent {
  const _SwitchToNextTabIntent();
}

class _SwitchToPreviousTabIntent extends Intent {
  const _SwitchToPreviousTabIntent();
}

/// Visual variants for HuxTabView.
enum HuxTabViewVariant {
  /// Pill-style tabs with rounded corners and subtle background (default)
  pill,

  /// Chrome-style tabs with curved edges (from merged HuxTabBar)
  chrome,
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

/// Controller for managing HuxTabView state externally.
///
/// Use this controller to programmatically manage tabs when you need
/// external control over the tab state.
class HuxTabViewController extends ChangeNotifier {
  /// Creates a HuxTabViewController.
  HuxTabViewController({
    List<TabDocument> initialTabs = const [],
    int initialIndex = 0,
  })  : _tabs = List.from(initialTabs),
        _activeIndex = initialIndex.clamp(
          0,
          initialTabs.isEmpty ? 0 : initialTabs.length - 1,
        );

  final List<TabDocument> _tabs;
  int _activeIndex;

  /// Returns the index of the currently active tab.
  int get activeIndex => _activeIndex;

  /// Returns the content widget of the currently active tab.
  /// Returns null if there are no tabs.
  Widget? get activeContent =>
      _activeIndex >= 0 && _activeIndex < _tabs.length
          ? _tabs[_activeIndex].content
          : null;

  /// Returns the number of tabs.
  int get tabCount => _tabs.length;

  /// Returns a copy of the current tabs list.
  List<TabDocument> get tabs => List.unmodifiable(_tabs);

  /// Returns the tab at the given index.
  TabDocument getTab(int index) {
    assert(index >= 0 && index < _tabs.length, 'Invalid tab index');
    return _tabs[index];
  }

  /// Adds a new tab.
  ///
  /// [autoActivate] - Whether to automatically activate the new tab.
  void addTab(TabDocument tab, {bool autoActivate = true}) {
    _tabs.add(tab);
    if (autoActivate) _activeIndex = _tabs.length - 1;
    notifyListeners();
  }

  /// Removes a tab at the specified index.
  void removeTab(int index) {
    if (index < 0 || index >= _tabs.length) return;
    _tabs.removeAt(index);
    if (_activeIndex >= _tabs.length && _tabs.isNotEmpty) {
      _activeIndex = _tabs.length - 1;
    } else if (_activeIndex > index && _activeIndex > 0) {
      _activeIndex--;
    }
    if (_tabs.isEmpty) _activeIndex = 0;
    notifyListeners();
  }

  /// Sets the active tab by index.
  void setActiveIndex(int index) {
    if (index >= 0 && index < _tabs.length) {
      _activeIndex = index;
      notifyListeners();
    }
  }

  /// Reorders tabs by moving a tab from [oldIndex] to [newIndex].
  void reorderTabs(int oldIndex, int newIndex) {
    if (oldIndex == newIndex) return;
    if (newIndex > oldIndex) newIndex -= 1;

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
}

/// A TabView component for dynamic workspace management.
///
/// Unlike HuxTabs which is for static section navigation, HuxTabView is
/// designed for browser-like or IDE-like tab interfaces where users can
/// open, close, switch, and reorder tabs.
///
/// Features:
/// - Open/close tabs dynamically
/// - Drag-to-reorder with mouse and touch support
/// - Close buttons on individual tabs
/// - Optional "New Tab" button
/// - Horizontal scrolling for many tabs
/// - Keyboard shortcuts (Ctrl/Cmd+T to open, Ctrl/Cmd+W to close, Ctrl/Cmd+Tab to switch)
/// - Optional external controller for programmatic control
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
    this.controller,
    this.initialTabs,
    this.initialIndex = 0,
    this.variant = HuxTabViewVariant.pill,
    this.size = HuxTabViewSize.medium,
    this.showNewTabButton = false,
    this.canCloseTabs = true,
    this.onTabChanged,
    this.onTabAdded,
    this.onTabClosed,
    this.onNewTabRequested,
    this.expandContent = true,
    this.tabMaxWidth,
    this.newTabTooltip = 'New Tab',
    this.closeTabTooltip = 'Close tab',
  });

  /// Optional external controller for managing tab state.
  /// If provided, initialTabs and initialIndex are ignored.
  final HuxTabViewController? controller;

  /// Initial list of tabs to display.
  /// Ignored if [controller] is provided.
  final List<TabDocument>? initialTabs;

  /// Initial active tab index.
  /// Ignored if [controller] is provided.
  final int initialIndex;

  /// Visual variant of the tabs
  /// Use [HuxTabViewVariant.pill] for rounded pill-style tabs
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
  // Internal state (used when no external controller provided)
  late List<TabDocument> _internalTabs;
  late int _internalActiveIndex;
  int _untitledCount = 0;

  final ScrollController _scrollController = ScrollController();
  final Set<int> _hoveringTabs = <int>{};

  /// Timer to detect mouse vs touch for drag behavior
  /// Touch requires delay to distinguish drag from scroll
  Timer _mouseTimer = Timer(Duration.zero, () {})..cancel();
  DateTime _lastHoverTime = DateTime.now();
  bool _isMouseActive = false;
  static const _mouseHoverThreshold = Duration(milliseconds: 100);

  /// Returns true if using external controller
  bool get _usesController => widget.controller != null;

  /// Returns the current tabs (from controller or internal state)
  List<TabDocument> get _tabs => _usesController ? widget.controller!.tabs : _internalTabs;

  /// Returns the current active index (from controller or internal state)
  int get _activeIndex => _usesController ? widget.controller!.activeIndex : _internalActiveIndex;

  @override
  void initState() {
    super.initState();
    _internalTabs = List.from(widget.initialTabs ?? []);
    _internalActiveIndex =
        widget.initialIndex.clamp(0, _internalTabs.isEmpty ? 0 : _internalTabs.length - 1);

    // Listen to controller changes
    widget.controller?.addListener(_onControllerChanged);
  }

  @override
  void didUpdateWidget(HuxTabView oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Handle controller change
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_onControllerChanged);
      widget.controller?.addListener(_onControllerChanged);
      setState(() {});
    }

    // Update internal state from props when not using controller and controller unchanged
    // (i.e., both old and new have no controller)
    if (!_usesController && oldWidget.controller == null && widget.controller == null) {
      final reorderResult = _computeReorderIfSameTabs(
        oldWidget.initialTabs,
        widget.initialTabs,
      );

      if (reorderResult != null && _hasSameTabs(oldWidget.initialTabs, widget.initialTabs)) {
        // Same tabs with same properties, just reordered - update order but preserve
        // TabDocument objects to maintain widget state
        setState(() {
          _internalTabs = reorderResult;
          _internalActiveIndex = _internalActiveIndex.clamp(
            0,
            _internalTabs.isEmpty ? 0 : _internalTabs.length - 1,
          );
          _hoveringTabs.removeWhere((index) => index >= _internalTabs.length);
        });
      } else if (!_hasSameTabs(oldWidget.initialTabs, widget.initialTabs)) {
        // Different tabs (identifier, title, icon, or isClosable changed) - replace entirely
        setState(() {
          _internalTabs = List.from(widget.initialTabs ?? []);
          _internalActiveIndex = _internalActiveIndex.clamp(
            0,
            _internalTabs.isEmpty ? 0 : _internalTabs.length - 1,
          );
          _hoveringTabs.removeWhere((index) => index >= _internalTabs.length);
        });
      }
    }
  }

  void _onControllerChanged() {
    setState(() {
      // Controller state changed, rebuild
      _hoveringTabs.removeWhere((index) => index >= _tabs.length);
    });
  }

  /// Returns reordered list if same tabs (by identifier) in different order.
  /// Returns null if tabs are different (not just reordered) or if any tab
  /// lacks a unique non-null identifier (making safe matching impossible).
  List<TabDocument>? _computeReorderIfSameTabs(
    List<TabDocument>? oldTabs,
    List<TabDocument>? newTabs,
  ) {
    final previous = oldTabs ?? const <TabDocument>[];
    final current = newTabs ?? const <TabDocument>[];

    if (previous.length != current.length) return null;

    // Identifier-based matching requires all tabs to have unique, non-null identifiers.
    // If any tab lacks one, null identifiers collapse in the map and produce wrong matches.
    if (previous.any((t) => t.identifier == null) ||
        current.any((t) => t.identifier == null)) {
      return null;
    }
    final previousIds = previous.map((t) => t.identifier).toSet();
    if (previousIds.length != previous.length) return null; // duplicate identifiers

    // Build map of previous tabs by identifier
    final previousById = <String, TabDocument>{};
    for (final tab in previous) {
      previousById[tab.identifier!] = tab;
    }

    // Check if all current tabs exist in previous (same identifiers)
    final result = <TabDocument>[];
    for (final tab in current) {
      final matchingTab = previousById[tab.identifier!];
      if (matchingTab == null) return null; // new tab not in previous
      result.add(matchingTab);
    }

    // Check if order actually changed
    var orderChanged = false;
    for (var i = 0; i < previous.length; i++) {
      if (previous[i].identifier != current[i].identifier) {
        orderChanged = true;
        break;
      }
    }

    return orderChanged ? result : null;
  }

  /// Checks if two tabs are equal by comparing all meaningful properties
  /// (identifier, title, icon, isClosable).
  bool _tabsAreEqual(TabDocument a, TabDocument b) {
    return a.identifier == b.identifier &&
        a.title == b.title &&
        a.icon == b.icon &&
        a.isClosable == b.isClosable;
  }

  /// Checks if two tab lists have the same tabs in the same order
  /// using deep equality comparison.
  bool _hasSameTabs(List<TabDocument>? oldTabs, List<TabDocument>? newTabs) {
    final previous = oldTabs ?? const <TabDocument>[];
    final current = newTabs ?? const <TabDocument>[];

    if (previous.length != current.length) return false;

    for (var index = 0; index < previous.length; index++) {
      if (!_tabsAreEqual(previous[index], current[index])) {
        return false;
      }
    }

    return true;
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_onControllerChanged);
    _mouseTimer.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  /// Reorders tabs by moving a tab from [oldIndex] to [newIndex].
  void _onReorder(int oldIndex, int newIndex) {
    if (_usesController) {
      // Delegate to controller
      widget.controller!.reorderTabs(oldIndex, newIndex);
    } else {
      // Handle internally
      if (oldIndex == newIndex) return;

      setState(() {
        if (newIndex > oldIndex) {
          newIndex -= 1;
        }

        final item = _internalTabs.removeAt(oldIndex);
        _internalTabs.insert(newIndex, item);

        // Update active index
        if (_internalActiveIndex == oldIndex) {
          _internalActiveIndex = newIndex;
        } else if (oldIndex < _internalActiveIndex && newIndex >= _internalActiveIndex) {
          _internalActiveIndex--;
        } else if (oldIndex > _internalActiveIndex && newIndex <= _internalActiveIndex) {
          _internalActiveIndex++;
        }

        // Update hovering indices
        final newHoveringTabs = _hoveringTabs.map((index) {
          if (index == oldIndex) return newIndex;
          if (oldIndex < index && index <= newIndex) return index - 1;
          if (newIndex <= index && index < oldIndex) return index + 1;
          return index;
        }).toSet();
        _hoveringTabs
          ..clear()
          ..addAll(newHoveringTabs);
      });
    }
  }

  void _closeTab(int index) {
    if (index < 0 || index >= _tabs.length) return;
    if (!widget.canCloseTabs) return;
    if (!_tabs[index].isClosable) return;

    final closedTab = _tabs[index];
    final previousActiveIndex = _activeIndex;
    final previousActiveDoc = _tabs.isNotEmpty ? _tabs[_activeIndex] : null;

    if (_usesController) {
      // Delegate to controller
      widget.controller!.removeTab(index);
      _hoveringTabs.removeWhere((hoveredIndex) => hoveredIndex == index);
    } else {
      // Handle internally
      setState(() {
        _internalTabs.removeAt(index);
        final remainingHoveringTabs = _hoveringTabs
            .where((hoveredIndex) => hoveredIndex != index)
            .map((hoveredIndex) => hoveredIndex > index ? hoveredIndex - 1 : hoveredIndex)
            .toSet();
        _hoveringTabs
          ..clear()
          ..addAll(remainingHoveringTabs);

        // Adjust active index
        if (_internalTabs.isEmpty) {
          _internalActiveIndex = 0;
        } else if (_internalActiveIndex >= _internalTabs.length) {
          _internalActiveIndex = _internalTabs.length - 1;
        } else if (_internalActiveIndex > index) {
          _internalActiveIndex--;
        }
      });
    }

    widget.onTabClosed?.call(index, closedTab);

    // Only fire onTabChanged if active tab actually changed
    if (_tabs.isNotEmpty) {
      final currentActiveDoc = _tabs[_activeIndex];
      if (previousActiveIndex != _activeIndex || previousActiveDoc != currentActiveDoc) {
        widget.onTabChanged?.call(_activeIndex);
      }
    }
  }

  void _switchToTab(int index) {
    if (index < 0 || index >= _tabs.length || index == _activeIndex) return;

    if (_usesController) {
      widget.controller!.setActiveIndex(index);
    } else {
      setState(() {
        _internalActiveIndex = index;
      });
    }
    widget.onTabChanged?.call(index);
    _scrollToActiveTab();
  }

  void _openNewTab() {
    final onNewTabRequested = widget.onNewTabRequested;
    if (onNewTabRequested != null) {
      onNewTabRequested();
      return;
    }

    _addNewTab();
  }

  void _closeCurrentTab() {
    if (_tabs.isEmpty) return;
    _closeTab(_activeIndex);
  }

  void _switchToNextTab() {
    if (_tabs.length < 2) return;
    _switchToTab((_activeIndex + 1) % _tabs.length);
  }

  void _switchToPreviousTab() {
    if (_tabs.length < 2) return;
    _switchToTab((_activeIndex - 1 + _tabs.length) % _tabs.length);
  }



  void _scrollToActiveTab() {
    if (!_scrollController.hasClients) return;

    // Calculate position to scroll to center the active tab
    final maxScroll = _scrollController.position.maxScrollExtent;
    final tabWidth = _getTabScrollExtent();
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
    final content = _tabs.isEmpty
        ? _buildEmptyState(context)
        : _buildTabContent(context);
    final shortcuts = <ShortcutActivator, Intent>{
      SingleActivator(LogicalKeyboardKey.keyT, control: true): const _OpenNewTabIntent(),
      SingleActivator(LogicalKeyboardKey.keyT, meta: true): const _OpenNewTabIntent(),
      SingleActivator(LogicalKeyboardKey.keyW, control: true): const _CloseCurrentTabIntent(),
      SingleActivator(LogicalKeyboardKey.keyW, meta: true): const _CloseCurrentTabIntent(),
      SingleActivator(LogicalKeyboardKey.tab, control: true): const _SwitchToNextTabIntent(),
      SingleActivator(LogicalKeyboardKey.tab, meta: true): const _SwitchToNextTabIntent(),
      SingleActivator(LogicalKeyboardKey.tab, control: true, shift: true): const _SwitchToPreviousTabIntent(),
      SingleActivator(LogicalKeyboardKey.tab, meta: true, shift: true): const _SwitchToPreviousTabIntent(),
    };

    return Shortcuts(
      shortcuts: shortcuts,
      child: Actions(
        actions: <Type, Action<Intent>>{
          _OpenNewTabIntent: CallbackAction<_OpenNewTabIntent>(
            onInvoke: (_) {
              _openNewTab();
              return null;
            },
          ),
          _CloseCurrentTabIntent: CallbackAction<_CloseCurrentTabIntent>(
            onInvoke: (_) {
              _closeCurrentTab();
              return null;
            },
          ),
          _SwitchToNextTabIntent: CallbackAction<_SwitchToNextTabIntent>(
            onInvoke: (_) {
              _switchToNextTab();
              return null;
            },
          ),
          _SwitchToPreviousTabIntent: CallbackAction<_SwitchToPreviousTabIntent>(
            onInvoke: (_) {
              _switchToPreviousTab();
              return null;
            },
          ),
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTabBar(context),
            const SizedBox(height: 16),
            widget.expandContent
                ? Expanded(child: content)
                : Flexible(fit: FlexFit.loose, child: content),
          ],
        ),
      ),
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
      child: Listener(
        onPointerHover: (_) {
          final now = DateTime.now();
          final timeSinceLastHover = now.difference(_lastHoverTime);
          _lastHoverTime = now;

          final shouldRecreateTimer = !_mouseTimer.isActive || timeSinceLastHover > _mouseHoverThreshold;
          final wasMouseInactive = !_isMouseActive;

          if (shouldRecreateTimer) {
            _mouseTimer.cancel();
            _mouseTimer = Timer(const Duration(milliseconds: 500), () {
              if (_isMouseActive) {
                setState(() => _isMouseActive = false);
              }
            });
          }

          if (!_isMouseActive) {
            _isMouseActive = true;
            if (wasMouseInactive) {
              setState(() {});
            }
          }
        },
        child: ReorderableListView.builder(
          scrollController: _scrollController,
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.only(
            left: 8,
            right: 8,
            top: 8,
            bottom: widget.variant == HuxTabViewVariant.pill ? 4 : 0,
          ),
          buildDefaultDragHandles: false,
          onReorder: _onReorder,
          onReorderStart: (index) {
            if (index >= 0 && index < _tabs.length) {
              _switchToTab(index);
            }
          },
          proxyDecorator: (child, index, animation) {
            return Material(
              color: Colors.transparent,
              child: child,
            );
          },
          itemCount: _tabs.length + (widget.showNewTabButton ? 1 : 0),
          itemBuilder: (context, index) {
            if (index < _tabs.length) {
              final tab = _tabs[index];
              final key = ValueKey(tab.identifier ?? 'tab-$index-${tab.title}');

              // Touch requires delay to distinguish drag from scroll
              final tabGap = widget.variant == HuxTabViewVariant.chrome
                  ? EdgeInsets.zero
                  : const EdgeInsets.symmetric(horizontal: 4);
              if (_mouseTimer.isActive) {
                return ReorderableDragStartListener(
                  key: key,
                  index: index,
                  child: Padding(
                    padding: tabGap,
                    child: _buildTab(context, index),
                  ),
                );
              } else {
                return ReorderableDelayedDragStartListener(
                  key: key,
                  index: index,
                  child: Padding(
                    padding: tabGap,
                    child: _buildTab(context, index),
                  ),
                );
              }
            }
            // Last item is the + button (non-draggable)
            return Container(
              key: const ValueKey('new-tab-button'),
              padding: const EdgeInsets.only(left: 8),
              child: _buildNewTabButton(context),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTab(BuildContext context, int index) {
    final tab = _tabs[index];
    final isActive = index == _activeIndex;
    final fixedWidth = _getRenderedTabWidth();
    final isHovering = _hoveringTabs.contains(index);

    final tabContent = Container(
      padding: _getTabPadding(isActive),
      decoration: widget.variant != HuxTabViewVariant.chrome
          ? _getTabDecoration(context, isActive, isHovered: isHovering)
          : null,
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
            if (widget.variant == HuxTabViewVariant.chrome) const SizedBox(width: 2),
          ],
        ],
      ),
    );

    return MouseRegion(
      onEnter: (_) {
        if (_hoveringTabs.contains(index)) return;
        setState(() {
          _hoveringTabs.add(index);
        });
      },
      onExit: (_) {
        if (!_hoveringTabs.contains(index)) return;
        setState(() {
          _hoveringTabs.remove(index);
        });
      },
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
            child: widget.variant == HuxTabViewVariant.chrome
                ? Stack(
                    children: [
                      CustomPaint(
                        painter: _ChromeTabPainter(
                          isActive: isActive,
                          backgroundColor: isActive
                              ? HuxTokens.surfaceElevated(context)
                              : isHovering
                                  ? HuxTokens.tabHoverBackground(context)
                                  : Colors.transparent,
                          borderColor: HuxTokens.tabBorder(context),
                        ),
                        child: const SizedBox(
                          height: double.infinity,
                          width: double.infinity,
                        ),
                      ),
                      tabContent,
                    ],
                  )
                : ClipRRect(
                    borderRadius: widget.variant == HuxTabViewVariant.pill
                        ? BorderRadius.circular(16)
                        : const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                          ),
                    child: tabContent,
                  ),
          ),
        ),
      ),
    );
  }

  void _addNewTab() {
    _untitledCount++;
    final newTab = TabDocument(
      title: 'Untitled $_untitledCount',
      icon: LucideIcons.file,
      content: const SizedBox.expand(),
    );

    if (_usesController) {
      widget.controller!.addTab(newTab);
    } else {
      setState(() {
        _internalTabs.add(newTab);
        _internalActiveIndex = _internalTabs.length - 1;
      });
    }

    widget.onTabAdded?.call(newTab);
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
          size: HuxButtonSize.medium,
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
            onPressed: _openNewTab,
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

    return Stack(
      fit: widget.expandContent ? StackFit.expand : StackFit.loose,
      children: _tabs.asMap().entries.map((entry) {
        final index = entry.key;
        final tab = entry.value;
        return Offstage(
          key: ValueKey('tab-content-${tab.identifier ?? index}'),
          offstage: index != _activeIndex,
          child: TickerMode(
            enabled: index == _activeIndex,
            child: tab.content,
          ),
        );
      }).toList(),
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
            HuxButton(
              onPressed: widget.onNewTabRequested,
              variant: HuxButtonVariant.secondary,
              size: HuxButtonSize.small,
              child: const Text('Open a new tab'),
            ),
          ],
        ],
      ),
    );
  }

  Decoration? _getTabDecoration(BuildContext context, bool isActive,
      {bool isHovered = false}) {
    if (widget.variant == HuxTabViewVariant.chrome) {
      return null; // Chrome uses _ChromeTabPainter in _buildTab
    }

    // Pill variant
    return BoxDecoration(
      color: isActive
          ? HuxTokens.surfaceElevated(context)
          : isHovered
              ? HuxTokens.tabHoverBackground(context)
              : Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: isActive ? HuxTokens.tabBorder(context) : Colors.transparent,
        width: 1,
      ),
    );
  }

  TextStyle _getTabTextStyle(BuildContext context, bool isActive) {
    final fontSize = switch (widget.size) {
      HuxTabViewSize.small => 12.0,
      HuxTabViewSize.medium => 14.0,
      HuxTabViewSize.large => 16.0,
    };

    return _buildTabTextStyle(
      context,
      fontSize: fontSize,
      isActive: isActive,
    );
  }

  TextStyle _buildTabTextStyle(
    BuildContext context, {
    required double fontSize,
    required bool isActive,
  }) {
    final baseStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w500,
        );
    final color = isActive
        ? HuxTokens.tabActiveText(context)
        : HuxTokens.tabInactiveText(context);

    return baseStyle?.copyWith(
          fontSize: fontSize,
          color: color,
        ) ??
        TextStyle(
          fontSize: fontSize,
          color: color,
        );
  }

  EdgeInsets _getTabPadding(bool isActive) {
    // Pill variant uses asymmetric padding with less on right for close button
    if (widget.variant == HuxTabViewVariant.pill) {
      switch (widget.size) {
        case HuxTabViewSize.small:
          return const EdgeInsets.only(left: 12, right: 4, top: 4, bottom: 4);
        case HuxTabViewSize.medium:
          return const EdgeInsets.only(left: 16, right: 6, top: 6, bottom: 6);
        case HuxTabViewSize.large:
          return const EdgeInsets.only(left: 20, right: 8, top: 8, bottom: 8);
      }
    }
    // Chrome variant uses increased horizontal padding for the curved shape
    if (widget.variant == HuxTabViewVariant.chrome) {
      switch (widget.size) {
        case HuxTabViewSize.small:
          return const EdgeInsets.only(left: 20, right: 14, top: 4, bottom: 4);
        case HuxTabViewSize.medium:
          return const EdgeInsets.only(left: 24, right: 18, top: 6, bottom: 6);
        case HuxTabViewSize.large:
          return const EdgeInsets.only(left: 28, right: 22, top: 8, bottom: 8);
      }
    }
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

  double _getRenderedTabWidth() => widget.tabMaxWidth ?? 260;

  double _getTabScrollExtent() {
    // Each tab item includes 4px horizontal padding on both sides in the list.
    return _getRenderedTabWidth() + 8;
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

/// Custom painter for Chrome-style tab with curved bottom edges.
/// Used by the [HuxTabViewVariant.chrome] variant.
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

    const curveRadius = 16.0;

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
