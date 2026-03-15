import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/hux_tokens.dart';
import '../components/buttons/hux_button.dart';

/// Inline dropdown date picker anchored to a trigger button.
///
/// Renders a Hux-styled button; on press, shows an overlayed calendar panel
/// positioned relative to the button (below by default, flips above if needed).
class HuxDatePicker extends StatefulWidget {
  /// Creates a Hux date picker dropdown anchored to the trigger button.
  const HuxDatePicker(
      {super.key,
      this.initialDate,
      required this.firstDate,
      required this.lastDate,
      this.onDateChanged,
      this.placeholder,
      this.variant = HuxButtonVariant.outline,
      this.size = HuxButtonSize.medium,
      this.icon,
      this.primaryColor,
      this.overlayColor,
      this.showText = true});

  /// The initially selected date. If null, the button shows [placeholder].
  final DateTime? initialDate;

  /// The earliest selectable date in the dropdown calendar.
  final DateTime firstDate;

  /// The latest selectable date in the dropdown calendar.
  final DateTime lastDate;

  /// Called when the user selects a date from the dropdown panel.
  final ValueChanged<DateTime>? onDateChanged;

  /// Button label to render when [initialDate] is null.
  final String? placeholder;

  /// Visual style of the trigger button.
  final HuxButtonVariant variant;

  /// Size of the trigger button.
  final HuxButtonSize size;

  /// Optional leading icon for the trigger button.
  final IconData? icon;

  /// Optional primary color override for the trigger button.
  final Color? primaryColor;

  /// Optional color for DatePicker Overlay
  final Color? overlayColor;

  /// Whether to show text label (default: true). Set to false for icon-only version.
  final bool showText;

  @override
  State<HuxDatePicker> createState() => _HuxDatePickerState();
}

class _HuxDatePickerState extends State<HuxDatePicker> {
  final GlobalKey _buttonKey = GlobalKey();
  OverlayEntry? _overlayEntry;
  late DateTime _currentDate;
  final LayerLink _layerLink = LayerLink();
  final FocusNode _panelFocusNode = FocusNode(debugLabel: 'huxDatePickerPanel');

  @override
  void initState() {
    super.initState();
    _currentDate = widget.initialDate ?? DateTime.now();
  }

  @override
  void didUpdateWidget(covariant HuxDatePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialDate != oldWidget.initialDate &&
        widget.initialDate != null) {
      _currentDate = widget.initialDate!;
    }
  }

  @override
  void dispose() {
    _removeOverlay();
    _panelFocusNode.dispose();
    super.dispose();
  }

  void _toggleOverlay() {
    if (_overlayEntry == null) {
      _showOverlay();
    } else {
      _removeOverlay();
    }
  }

  void _showOverlay() {
    final RenderBox buttonBox =
        _buttonKey.currentContext!.findRenderObject() as RenderBox;
    final Size buttonSize = buttonBox.size;
    final Size screenSize = MediaQuery.of(context).size;

    const double panelHeight = 318.0; // Slightly more to account for variation
    const double belowGap = 4.0; // Small gap below button
    const double aboveGap =
        4.0; // Smaller gap above button for closer positioning

    bool showAbove = false;
    Offset followerOffset = Offset(0, buttonSize.height + belowGap);
    final double buttonGlobalDy = buttonBox.localToGlobal(Offset.zero).dy;

    final double spaceBelow =
        screenSize.height - (buttonGlobalDy + buttonSize.height);
    if (spaceBelow < panelHeight + belowGap + 20) {
      // 20px buffer
      showAbove = true;
      followerOffset = Offset(0, -panelHeight - aboveGap);
    }

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _removeOverlay,
                child: const SizedBox.shrink(),
              ),
            ),
            CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: followerOffset,
              child: Material(
                color: widget.overlayColor,
                child: _HuxDatePickerPanel(
                  key: const ValueKey('huxDatePickerPanel'),
                  initialDate: _currentDate,
                  firstDate: widget.firstDate,
                  lastDate: widget.lastDate,
                  panelFocusNode: _panelFocusNode,
                  onSelected: (date) {
                    setState(() => _currentDate = date);
                    widget.onDateChanged?.call(date);
                    _removeOverlay();
                  },
                  onRequestClose: _removeOverlay,
                  isAbove: showAbove,
                ),
              ),
            ),
          ],
        );
      },
    );

    Overlay.of(context, rootOverlay: false).insert(_overlayEntry!);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _overlayEntry != null) {
        _panelFocusNode.requestFocus();
      }
    });
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  String _formatDate(BuildContext context, DateTime date) {
    return MaterialLocalizations.of(context).formatMediumDate(date);
  }

  @override
  Widget build(BuildContext context) {
    final String label = widget.initialDate == null
        ? (widget.placeholder ?? 'Select Date')
        : _formatDate(context, _currentDate);

    // Use ghost variant (no border, no background, no padding) for icon-only mode
    final buttonVariant =
        widget.showText ? widget.variant : HuxButtonVariant.ghost;

    return CompositedTransformTarget(
      link: _layerLink,
      child: HuxButton(
        key: _buttonKey,
        onPressed: _toggleOverlay,
        variant: buttonVariant,
        size: widget.size,
        primaryColor: widget.primaryColor,
        icon: widget.icon ?? Icons.calendar_today,
        child: widget.showText ? Text(label) : const SizedBox(width: 0),
      ),
    );
  }
}

class _HuxDatePickerPanel extends StatefulWidget {
  const _HuxDatePickerPanel({
    super.key,
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    required this.onSelected,
    required this.panelFocusNode,
    required this.onRequestClose,
    this.isAbove = false,
  });

  /// Date used to initialize the panel selection and month view.
  final DateTime initialDate;

  /// Lower bound for selectable dates.
  final DateTime firstDate;

  /// Upper bound for selectable dates.
  final DateTime lastDate;

  /// Callback invoked when a date is chosen from the panel.
  final ValueChanged<DateTime> onSelected;
  final FocusNode panelFocusNode;
  final VoidCallback onRequestClose;

  /// Whether the panel is rendered above the trigger (for limited space below).
  final bool isAbove;

  @override
  State<_HuxDatePickerPanel> createState() => _HuxDatePickerPanelState();
}

class _CalendarTabIntent extends Intent {
  const _CalendarTabIntent({required this.forward});
  final bool forward;
}

class _HuxDatePickerPanelState extends State<_HuxDatePickerPanel> {
  static const int _monthColumns = 3;
  static const double _yearOptionItemHeight = 36.0;
  static const double _yearOptionItemPadding = 8.0;
  static const int _yearPickerVisibleCount = 4;
  static const double _yearPickerViewportOffset = 24.0;
  int get _firstYear => widget.firstDate.year;
  int get _lastYear => widget.lastDate.year;
  int get _yearCount => _lastYear - _firstYear + 1;
  DateTime get _firstSelectableDate => DateUtils.dateOnly(widget.firstDate);
  DateTime get _lastSelectableDate => DateUtils.dateOnly(widget.lastDate);
  DateTime get _firstSelectableMonth =>
      DateTime(_firstYear, widget.firstDate.month);
  DateTime get _lastSelectableMonth =>
      DateTime(_lastYear, widget.lastDate.month);
  late DateTime _selectedDate;
  late DateTime _currentMonth;
  late DateTime _focusedDate;
  bool _isShowingMonthPicker = false;
  bool _isShowingYearPicker = false;
  late ScrollController _yearScrollController;
  final FocusNode _prevMonthFocusNode = FocusNode(debugLabel: 'prevMonth');
  final FocusNode _monthFocusNode = FocusNode(debugLabel: 'monthButton');
  final FocusNode _yearFocusNode = FocusNode(debugLabel: 'yearButton');
  final FocusNode _nextMonthFocusNode = FocusNode(debugLabel: 'nextMonth');
  final Map<int, FocusNode> _monthOptionFocusNodes = <int, FocusNode>{};
  final Map<int, FocusNode> _yearOptionFocusNodes = <int, FocusNode>{};
  int? _focusedMonthOptionIndex;
  int? _focusedYearOptionIndex;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    final int clampedInitialYear =
        widget.initialDate.year.clamp(_firstYear, _lastYear).toInt();
    _currentMonth = _clampMonthToSelectableWindow(
      DateTime(clampedInitialYear, widget.initialDate.month),
    );
    _focusedDate = _selectedDate;
    _clampFocusedDateToCurrentMonth();
    _yearScrollController = ScrollController();
  }

  @override
  void dispose() {
    _yearScrollController.dispose();
    _prevMonthFocusNode.dispose();
    _monthFocusNode.dispose();
    _yearFocusNode.dispose();
    _nextMonthFocusNode.dispose();
    for (final FocusNode node in _monthOptionFocusNodes.values) {
      node.dispose();
    }
    for (final FocusNode node in _yearOptionFocusNodes.values) {
      node.dispose();
    }
    super.dispose();
  }

  void _handleSelect(DateTime date) {
    setState(() {
      _selectedDate = date;
      _focusedDate = date;
      _currentMonth = DateTime(date.year, date.month);
    });
    widget.onSelected(date);
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
      _clampCurrentMonthToSelectableWindow();
      _clampFocusedDateToCurrentMonth();
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
      _clampCurrentMonthToSelectableWindow();
      _clampFocusedDateToCurrentMonth();
    });
  }

  bool _isSelectableDate(DateTime date) {
    final DateTime dateOnly = DateUtils.dateOnly(date);
    return !dateOnly.isBefore(_firstSelectableDate) &&
        !dateOnly.isAfter(_lastSelectableDate);
  }

  void _moveFocusByDays(int deltaDays) {
    if (_isShowingMonthPicker || _isShowingYearPicker) return;
    final DateTime target = DateTime(
        _focusedDate.year, _focusedDate.month, _focusedDate.day + deltaDays);
    final DateTime targetDateOnly = DateUtils.dateOnly(target);
    final DateTime clamped = targetDateOnly.isBefore(_firstSelectableDate)
        ? _firstSelectableDate
        : (targetDateOnly.isAfter(_lastSelectableDate)
            ? _lastSelectableDate
            : targetDateOnly);

    if (!_isSelectableDate(clamped)) return;
    setState(() {
      _focusedDate = clamped;
      _currentMonth = DateTime(clamped.year, clamped.month);
    });
  }

  void _cycleTabFocus({required bool forward}) {
    final FocusNode? current = FocusManager.instance.primaryFocus;
    final bool onHeader = current == _prevMonthFocusNode ||
        current == _monthFocusNode ||
        current == _yearFocusNode ||
        current == _nextMonthFocusNode;
    final bool onCalendar = current == widget.panelFocusNode;
    final bool onMonthPicker =
        _monthOptionFocusNodes.values.contains(current) ||
            _focusedMonthOptionIndex != null;
    final bool onYearPicker = _yearOptionFocusNodes.values.contains(current) ||
        _focusedYearOptionIndex != null;

    if (_isShowingMonthPicker) {
      if (onHeader) {
        _focusMonthOption(_currentMonth.month - 1);
        return;
      }
      if (onMonthPicker) {
        (forward ? _prevMonthFocusNode : _nextMonthFocusNode).requestFocus();
        return;
      }
      _focusMonthOption(_currentMonth.month - 1);
      return;
    }

    if (_isShowingYearPicker) {
      if (onHeader) {
        _focusYearOption(_currentMonth.year - _firstYear);
        return;
      }
      if (onYearPicker) {
        (forward ? _prevMonthFocusNode : _nextMonthFocusNode).requestFocus();
        return;
      }
      _focusYearOption(_currentMonth.year - _firstYear);
      return;
    }

    if (onHeader) {
      widget.panelFocusNode.requestFocus();
      return;
    }

    if (onCalendar) {
      if (forward) {
        _prevMonthFocusNode.requestFocus();
      } else {
        _nextMonthFocusNode.requestFocus();
      }
      return;
    }

    widget.panelFocusNode.requestFocus();
  }

  void _focusMonthOption(int index) {
    final int clamped = index.clamp(0, 11);
    final int? target = _nearestSelectableMonthIndex(clamped);
    if (target == null) {
      return;
    }
    _focusedMonthOptionIndex = target;
    _monthOptionNode(target).requestFocus();
  }

  void _focusYearOption(int index) {
    final int clamped = index.clamp(0, _yearCount - 1);
    _focusedYearOptionIndex = clamped;
    _yearOptionNode(clamped).requestFocus();
    _scrollYearOptionIntoView(clamped);
  }

  FocusNode _monthOptionNode(int index) {
    return _monthOptionFocusNodes.putIfAbsent(
      index,
      () => FocusNode(debugLabel: 'monthOption-${index + 1}'),
    );
  }

  FocusNode _yearOptionNode(int index) {
    return _yearOptionFocusNodes.putIfAbsent(
      index,
      () => FocusNode(debugLabel: 'yearOption-${_firstYear + index}'),
    );
  }

  void _scrollYearOptionIntoView(int index) {
    if (!_yearScrollController.hasClients) {
      return;
    }
    const double totalItemHeight =
        _yearOptionItemHeight + _yearOptionItemPadding;
    const double viewportHeight =
        (_yearPickerVisibleCount * totalItemHeight) + _yearPickerViewportOffset;
    final double targetOffset =
        (index * totalItemHeight) - (viewportHeight / 2);
    final double maxOffset = _yearScrollController.position.maxScrollExtent;
    _yearScrollController.animateTo(
      targetOffset.clamp(0.0, maxOffset),
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
    );
  }

  void _moveHeaderFocus({required bool forward}) {
    final List<FocusNode> header = <FocusNode>[
      _prevMonthFocusNode,
      _monthFocusNode,
      _yearFocusNode,
      _nextMonthFocusNode,
    ];
    final FocusNode? current = FocusManager.instance.primaryFocus;
    int index = header.indexOf(current ?? _monthFocusNode);
    if (index == -1) {
      index = 0;
    }
    final int nextIndex =
        (index + (forward ? 1 : -1) + header.length) % header.length;
    header[nextIndex].requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return FocusTraversalGroup(
      policy: WidgetOrderTraversalPolicy(),
      child: Shortcuts(
        shortcuts: const <ShortcutActivator, Intent>{
          SingleActivator(LogicalKeyboardKey.escape): DismissIntent(),
          SingleActivator(LogicalKeyboardKey.arrowLeft):
              DirectionalFocusIntent(TraversalDirection.left),
          SingleActivator(LogicalKeyboardKey.arrowRight):
              DirectionalFocusIntent(TraversalDirection.right),
          SingleActivator(LogicalKeyboardKey.arrowUp):
              DirectionalFocusIntent(TraversalDirection.up),
          SingleActivator(LogicalKeyboardKey.arrowDown):
              DirectionalFocusIntent(TraversalDirection.down),
          SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
          SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
          SingleActivator(LogicalKeyboardKey.tab):
              _CalendarTabIntent(forward: true),
          SingleActivator(LogicalKeyboardKey.tab, shift: true):
              _CalendarTabIntent(forward: false),
        },
        child: Actions(
          actions: <Type, Action<Intent>>{
            DismissIntent: CallbackAction<DismissIntent>(
              onInvoke: (_) {
                widget.onRequestClose();
                return null;
              },
            ),
            DirectionalFocusIntent: CallbackAction<DirectionalFocusIntent>(
              onInvoke: (DirectionalFocusIntent intent) {
                final FocusNode? current = FocusManager.instance.primaryFocus;
                final bool onCalendar = current == widget.panelFocusNode;
                final bool onHeader = current == _prevMonthFocusNode ||
                    current == _monthFocusNode ||
                    current == _yearFocusNode ||
                    current == _nextMonthFocusNode;
                final int monthPickerIndex =
                    _focusedMonthOptionIndex ?? (_currentMonth.month - 1);
                final int yearPickerIndex = _focusedYearOptionIndex ??
                    (_currentMonth.year - _firstYear);

                if (_isShowingMonthPicker) {
                  if (onHeader) {
                    switch (intent.direction) {
                      case TraversalDirection.left:
                        _moveHeaderFocus(forward: false);
                        break;
                      case TraversalDirection.right:
                        _moveHeaderFocus(forward: true);
                        break;
                      case TraversalDirection.up:
                      case TraversalDirection.down:
                        _focusMonthOption(_currentMonth.month - 1);
                        break;
                    }
                    return null;
                  }
                  switch (intent.direction) {
                    case TraversalDirection.left:
                      _focusMonthOption(monthPickerIndex - 1);
                      break;
                    case TraversalDirection.right:
                      _focusMonthOption(monthPickerIndex + 1);
                      break;
                    case TraversalDirection.up:
                      if (monthPickerIndex < _monthColumns) {
                        _monthFocusNode.requestFocus();
                      } else {
                        _focusMonthOption(monthPickerIndex - _monthColumns);
                      }
                      break;
                    case TraversalDirection.down:
                      _focusMonthOption(monthPickerIndex + _monthColumns);
                      break;
                  }
                  return null;
                }

                if (_isShowingYearPicker) {
                  if (onHeader) {
                    switch (intent.direction) {
                      case TraversalDirection.left:
                        _moveHeaderFocus(forward: false);
                        break;
                      case TraversalDirection.right:
                        _moveHeaderFocus(forward: true);
                        break;
                      case TraversalDirection.up:
                      case TraversalDirection.down:
                        _focusYearOption(_currentMonth.year - _firstYear);
                        break;
                    }
                    return null;
                  }
                  switch (intent.direction) {
                    case TraversalDirection.up:
                      if (yearPickerIndex == 0) {
                        _yearFocusNode.requestFocus();
                      } else {
                        _focusYearOption(yearPickerIndex - 1);
                      }
                      break;
                    case TraversalDirection.down:
                      _focusYearOption(yearPickerIndex + 1);
                      break;
                    case TraversalDirection.left:
                      _focusYearOption(yearPickerIndex - 1);
                      break;
                    case TraversalDirection.right:
                      _focusYearOption(yearPickerIndex + 1);
                      break;
                  }
                  return null;
                }

                if (onHeader) {
                  switch (intent.direction) {
                    case TraversalDirection.left:
                      _moveHeaderFocus(forward: false);
                      break;
                    case TraversalDirection.right:
                      _moveHeaderFocus(forward: true);
                      break;
                    case TraversalDirection.down:
                      widget.panelFocusNode.requestFocus();
                      break;
                    case TraversalDirection.up:
                      widget.panelFocusNode.requestFocus();
                      break;
                  }
                  return null;
                }

                if (onCalendar) {
                  switch (intent.direction) {
                    case TraversalDirection.left:
                      _moveFocusByDays(-1);
                      break;
                    case TraversalDirection.right:
                      _moveFocusByDays(1);
                      break;
                    case TraversalDirection.up:
                      final DateTime previousWeekDate = DateTime(
                        _focusedDate.year,
                        _focusedDate.month,
                        _focusedDate.day - 7,
                      );
                      final bool wouldLeaveCurrentMonth =
                          previousWeekDate.year != _currentMonth.year ||
                              previousWeekDate.month != _currentMonth.month;
                      if (wouldLeaveCurrentMonth) {
                        _monthFocusNode.requestFocus();
                      } else {
                        _moveFocusByDays(-7);
                      }
                      break;
                    case TraversalDirection.down:
                      _moveFocusByDays(7);
                      break;
                  }
                }
                return null;
              },
            ),
            ActivateIntent: CallbackAction<ActivateIntent>(
              onInvoke: (_) {
                final FocusNode? current = FocusManager.instance.primaryFocus;
                if (current == _prevMonthFocusNode) {
                  _previousMonth();
                  return null;
                }
                if (current == _nextMonthFocusNode) {
                  _nextMonth();
                  return null;
                }
                if (current == _monthFocusNode) {
                  _toggleMonthPicker();
                  return null;
                }
                if (current == _yearFocusNode) {
                  _toggleYearPicker();
                  return null;
                }
                final int monthPickerIndex =
                    _focusedMonthOptionIndex ?? (_currentMonth.month - 1);
                if (_isShowingMonthPicker) {
                  _handleMonthSelection(monthPickerIndex + 1);
                  return null;
                }
                final int yearPickerIndex = _focusedYearOptionIndex ??
                    (_currentMonth.year - _firstYear);
                if (_isShowingYearPicker) {
                  _handleYearSelection(_firstYear + yearPickerIndex);
                  return null;
                }
                if (!_isShowingMonthPicker &&
                    !_isShowingYearPicker &&
                    _isSelectableDate(_focusedDate)) {
                  _handleSelect(_focusedDate);
                }
                return null;
              },
            ),
            _CalendarTabIntent: CallbackAction<_CalendarTabIntent>(
              onInvoke: (_CalendarTabIntent intent) {
                if (_isShowingMonthPicker || _isShowingYearPicker) {
                  return null;
                }
                _cycleTabFocus(forward: intent.forward);
                return null;
              },
            ),
          },
          child: Focus(
            focusNode: widget.panelFocusNode,
            onKeyEvent: (node, event) {
              if (event is KeyDownEvent &&
                  event.logicalKey == LogicalKeyboardKey.tab) {
                final bool isShiftPressed =
                    HardwareKeyboard.instance.isShiftPressed;
                _cycleTabFocus(forward: !isShiftPressed);
                return KeyEventResult.handled;
              }
              return KeyEventResult.ignored;
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: HuxTokens.surfaceElevated(context),
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: HuxTokens.buttonSecondaryBorder(context)),
                boxShadow: [
                  BoxShadow(
                    color: HuxTokens.shadowColor(context),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(width: 7 * 32 + 6, child: _buildHeader()),
                  const SizedBox(height: 16),
                  if (_isShowingMonthPicker)
                    SizedBox(width: 7 * 32 + 6, child: _buildMonthPicker())
                  else if (_isShowingYearPicker)
                    SizedBox(width: 7 * 32 + 6, child: _buildYearPicker())
                  else
                    SizedBox(width: 7 * 32 + 6, child: _buildCalendarGrid()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        _NavigationButton(
          icon: Icons.chevron_left,
          onPressed: _previousMonth,
          focusNode: _prevMonthFocusNode,
          semanticLabel: 'Previous month',
        ),
        const SizedBox(width: 12),
        Expanded(child: _buildMonthButton(focusNode: _monthFocusNode)),
        const SizedBox(width: 8),
        Expanded(child: _buildYearButton(focusNode: _yearFocusNode)),
        const SizedBox(width: 12),
        _NavigationButton(
          icon: Icons.chevron_right,
          onPressed: _nextMonth,
          focusNode: _nextMonthFocusNode,
          semanticLabel: 'Next month',
        ),
      ],
    );
  }

  Widget _buildMonthButton({required FocusNode focusNode}) {
    return _PickerOptionButton(
      focusNode: focusNode,
      onPressed: _toggleMonthPicker,
      variant: HuxButtonVariant.outline,
      size: HuxButtonSize.small,
      child: Text(
        _getMonthName(_currentMonth.month),
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildYearButton({required FocusNode focusNode}) {
    return _PickerOptionButton(
      focusNode: focusNode,
      onPressed: _toggleYearPicker,
      variant: HuxButtonVariant.outline,
      size: HuxButtonSize.small,
      child: Text(
        _currentMonth.year.toString(),
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
    );
  }

  void _toggleMonthPicker() {
    setState(() {
      _isShowingMonthPicker = !_isShowingMonthPicker;
      _isShowingYearPicker = false;
      _focusedYearOptionIndex = null;
    });
    if (_isShowingMonthPicker) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusMonthOption(_currentMonth.month - 1);
      });
    } else {
      _focusedMonthOptionIndex = null;
    }
  }

  void _toggleYearPicker() {
    setState(() {
      _isShowingYearPicker = !_isShowingYearPicker;
      _isShowingMonthPicker = false;
      _focusedMonthOptionIndex = null;
    });
    if (_isShowingYearPicker) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final int currentYearIndex =
            (_currentMonth.year - _firstYear).clamp(0, _yearCount - 1).toInt();
        const double totalItemHeight =
            _yearOptionItemHeight + _yearOptionItemPadding;
        final double scrollOffset = (currentYearIndex * totalItemHeight) - 100;
        _yearScrollController.jumpTo(scrollOffset.clamp(0.0, double.infinity));
        _focusYearOption(currentYearIndex);
      });
    } else {
      _focusedYearOptionIndex = null;
    }
  }

  void _handleMonthSelection(int month) {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, month);
      _clampCurrentMonthToSelectableWindow();
      _clampFocusedDateToCurrentMonth();
      _isShowingMonthPicker = false;
      _focusedMonthOptionIndex = null;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _monthFocusNode.requestFocus();
    });
  }

  void _handleYearSelection(int year) {
    setState(() {
      _currentMonth = DateTime(year, _currentMonth.month);
      _clampCurrentMonthToSelectableWindow();
      _clampFocusedDateToCurrentMonth();
      _isShowingYearPicker = false;
      _focusedYearOptionIndex = null;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _yearFocusNode.requestFocus();
    });
  }

  void _clampFocusedDateToCurrentMonth() {
    final int daysInMonth =
        DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
    final int clampedDay = _focusedDate.day.clamp(1, daysInMonth).toInt();
    DateTime clamped =
        DateTime(_currentMonth.year, _currentMonth.month, clampedDay);
    if (clamped.isBefore(_firstSelectableDate)) {
      clamped = _firstSelectableDate;
    } else if (clamped.isAfter(_lastSelectableDate)) {
      clamped = _lastSelectableDate;
    }
    _focusedDate = clamped;
  }

  void _clampCurrentMonthToSelectableWindow() {
    _currentMonth = _clampMonthToSelectableWindow(_currentMonth);
  }

  DateTime _clampMonthToSelectableWindow(DateTime month) {
    final DateTime normalized = DateTime(month.year, month.month);
    if (normalized.isBefore(_firstSelectableMonth)) {
      return _firstSelectableMonth;
    }
    if (normalized.isAfter(_lastSelectableMonth)) {
      return _lastSelectableMonth;
    }
    return normalized;
  }

  bool _isMonthSelectableInCurrentYear(int month) {
    final int year = _currentMonth.year;
    final DateTime monthStart = DateTime(year, month, 1);
    final DateTime monthEnd = DateTime(year, month + 1, 0);
    return !monthEnd.isBefore(_firstSelectableDate) &&
        !monthStart.isAfter(_lastSelectableDate);
  }

  int? _nearestSelectableMonthIndex(int index) {
    final List<int> selectableIndices = List<int>.generate(12, (i) => i)
        .where((i) => _isMonthSelectableInCurrentYear(i + 1))
        .toList();
    if (selectableIndices.isEmpty) {
      return null;
    }
    int nearest = selectableIndices.first;
    var nearestDistance = (nearest - index).abs();
    for (final candidate in selectableIndices.skip(1)) {
      final distance = (candidate - index).abs();
      if (distance < nearestDistance) {
        nearest = candidate;
        nearestDistance = distance;
      }
    }
    return nearest;
  }

  Widget _buildMonthPicker() {
    return Column(
      children: [
        Text(
          'Select Month',
          style: TextStyle(
            color: HuxTokens.textPrimary(context),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Column(
          children: [
            Row(children: [
              _buildMonthItem(1, 'Jan'),
              const SizedBox(width: 8),
              _buildMonthItem(2, 'Feb'),
              const SizedBox(width: 8),
              _buildMonthItem(3, 'Mar'),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              _buildMonthItem(4, 'Apr'),
              const SizedBox(width: 8),
              _buildMonthItem(5, 'May'),
              const SizedBox(width: 8),
              _buildMonthItem(6, 'Jun'),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              _buildMonthItem(7, 'Jul'),
              const SizedBox(width: 8),
              _buildMonthItem(8, 'Aug'),
              const SizedBox(width: 8),
              _buildMonthItem(9, 'Sep'),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              _buildMonthItem(10, 'Oct'),
              const SizedBox(width: 8),
              _buildMonthItem(11, 'Nov'),
              const SizedBox(width: 8),
              _buildMonthItem(12, 'Dec'),
            ]),
          ],
        ),
      ],
    );
  }

  Widget _buildMonthItem(int month, String label) {
    final bool isSelected = month == _currentMonth.month;
    final bool isSelectable = _isMonthSelectableInCurrentYear(month);
    const double itemWidth = (7 * 32 + 6 - (2 * 8)) / 3;
    return SizedBox(
      width: itemWidth,
      child: _PickerOptionButton(
        focusNode: _monthOptionNode(month - 1),
        canRequestFocus: isSelectable,
        onFocusChange: (focused) {
          if (focused) {
            _focusedMonthOptionIndex = month - 1;
          }
        },
        onKeyEvent: (node, event) {
          if (event is! KeyDownEvent) {
            return KeyEventResult.ignored;
          }
          final int index = month - 1;
          switch (event.logicalKey) {
            case LogicalKeyboardKey.arrowLeft:
              _focusMonthOption(index - 1);
              return KeyEventResult.handled;
            case LogicalKeyboardKey.arrowRight:
              _focusMonthOption(index + 1);
              return KeyEventResult.handled;
            case LogicalKeyboardKey.arrowUp:
              if (index < _monthColumns) {
                _monthFocusNode.requestFocus();
              } else {
                _focusMonthOption(index - _monthColumns);
              }
              return KeyEventResult.handled;
            case LogicalKeyboardKey.arrowDown:
              _focusMonthOption(index + _monthColumns);
              return KeyEventResult.handled;
            case LogicalKeyboardKey.enter:
            case LogicalKeyboardKey.space:
              if (!isSelectable) {
                return KeyEventResult.ignored;
              }
              _handleMonthSelection(month);
              return KeyEventResult.handled;
            default:
              return KeyEventResult.ignored;
          }
        },
        onPressed: isSelectable ? () => _handleMonthSelection(month) : null,
        variant:
            isSelected ? HuxButtonVariant.primary : HuxButtonVariant.outline,
        size: HuxButtonSize.small,
        child: Center(
          child: Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }

  Widget _buildYearPicker() {
    final List<int> years =
        List.generate(_yearCount, (index) => _firstYear + index);
    return Column(
      children: [
        Text(
          'Select Year',
          style: TextStyle(
            color: HuxTokens.textPrimary(context),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: (_yearPickerVisibleCount *
                  (_yearOptionItemHeight + _yearOptionItemPadding)) +
              _yearPickerViewportOffset,
          child: ScrollConfiguration(
            behavior:
                ScrollConfiguration.of(context).copyWith(scrollbars: false),
            child: ListView.builder(
              controller: _yearScrollController,
              physics: const ClampingScrollPhysics(),
              itemCount: years.length,
              itemBuilder: (context, index) {
                final int year = years[index];
                final bool isSelected = year == _currentMonth.year;
                return Padding(
                  padding:
                      const EdgeInsets.only(bottom: _yearOptionItemPadding),
                  child: _PickerOptionButton(
                    focusNode: _yearOptionNode(index),
                    onFocusChange: (focused) {
                      if (focused) {
                        _focusedYearOptionIndex = index;
                      }
                    },
                    onKeyEvent: (node, event) {
                      if (event is! KeyDownEvent) {
                        return KeyEventResult.ignored;
                      }
                      switch (event.logicalKey) {
                        case LogicalKeyboardKey.arrowUp:
                        case LogicalKeyboardKey.arrowLeft:
                          if (index == 0) {
                            _yearFocusNode.requestFocus();
                          } else {
                            _focusYearOption(index - 1);
                          }
                          return KeyEventResult.handled;
                        case LogicalKeyboardKey.arrowDown:
                        case LogicalKeyboardKey.arrowRight:
                          _focusYearOption(index + 1);
                          return KeyEventResult.handled;
                        case LogicalKeyboardKey.enter:
                        case LogicalKeyboardKey.space:
                          _handleYearSelection(year);
                          return KeyEventResult.handled;
                        default:
                          return KeyEventResult.ignored;
                      }
                    },
                    onPressed: () => _handleYearSelection(year),
                    variant: isSelected
                        ? HuxButtonVariant.primary
                        : HuxButtonVariant.outline,
                    size: HuxButtonSize.small,
                    child: SizedBox(
                      width: double.infinity,
                      child: Center(
                        child: Text(
                          year.toString(),
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarGrid() {
    return Column(
      children: [
        Row(
          children: ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su']
              .map((day) => SizedBox(
                    width: 32,
                    child: Center(
                      child: Text(
                        day,
                        style: TextStyle(
                          color: HuxTokens.textSecondary(context),
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 16),
        ..._buildCalendarRows(),
      ],
    );
  }

  List<Widget> _buildCalendarRows() {
    final int daysInMonth =
        DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
    final DateTime firstDayOfMonth =
        DateTime(_currentMonth.year, _currentMonth.month, 1);
    final int firstWeekday = firstDayOfMonth.weekday;
    final int daysFromPrevMonth = (firstWeekday - 1) % 7;
    final DateTime prevMonth =
        DateTime(_currentMonth.year, _currentMonth.month - 1);
    final int daysInPrevMonth =
        DateTime(prevMonth.year, prevMonth.month + 1, 0).day;

    final List<Widget> rows = [];
    final int totalDaysToShow = daysFromPrevMonth + daysInMonth;
    final int numberOfWeeks = (totalDaysToShow / 7).ceil();

    for (int weekIndex = 0; weekIndex < numberOfWeeks; weekIndex++) {
      bool hasCurrentMonthDay = false;
      for (int dayIndex = 0; dayIndex < 7; dayIndex++) {
        final int dayNumber = weekIndex * 7 + dayIndex - daysFromPrevMonth + 1;
        if (dayNumber > 0 && dayNumber <= daysInMonth) {
          hasCurrentMonthDay = true;
          break;
        }
      }
      if (hasCurrentMonthDay) {
        rows.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: List.generate(7, (dayIndex) {
                final int dayNumber =
                    weekIndex * 7 + dayIndex - daysFromPrevMonth + 1;
                final bool isPrevMonth = dayNumber <= 0;
                final bool isNextMonth = dayNumber > daysInMonth;
                if (isPrevMonth) {
                  final int prevMonthDay = daysInPrevMonth + dayNumber;
                  return SizedBox(
                    width: 32,
                    child: _buildDayCell(
                      day: prevMonthDay,
                      isCurrentMonth: false,
                      isSelected: false,
                      isFocused: false,
                      isToday: false,
                      isDisabled: true,
                    ),
                  );
                } else if (isNextMonth) {
                  final int nextMonthDay = dayNumber - daysInMonth;
                  return SizedBox(
                    width: 32,
                    child: _buildDayCell(
                      day: nextMonthDay,
                      isCurrentMonth: false,
                      isSelected: false,
                      isFocused: false,
                      isToday: false,
                      isDisabled: true,
                    ),
                  );
                } else {
                  final DateTime date = DateTime(
                      _currentMonth.year, _currentMonth.month, dayNumber);
                  final bool isSelected = date.year == _selectedDate.year &&
                      date.month == _selectedDate.month &&
                      date.day == _selectedDate.day;
                  final DateTime now = DateTime.now();
                  final bool isToday = date.year == now.year &&
                      date.month == now.month &&
                      date.day == now.day;
                  final bool isDisabled = !_isSelectableDate(date);

                  return SizedBox(
                    width: 32,
                    child: _buildDayCell(
                      day: dayNumber,
                      isCurrentMonth: true,
                      isSelected: isSelected,
                      isFocused: date.year == _focusedDate.year &&
                          date.month == _focusedDate.month &&
                          date.day == _focusedDate.day,
                      isToday: isToday,
                      isDisabled: isDisabled,
                      onTap: isDisabled ? null : () => _handleSelect(date),
                    ),
                  );
                }
              }),
            ),
          ),
        );
      }
    }

    return rows;
  }

  Widget _buildDayCell({
    required int day,
    required bool isCurrentMonth,
    required bool isSelected,
    required bool isFocused,
    required bool isToday,
    required bool isDisabled,
    VoidCallback? onTap,
  }) {
    return _DayCell(
      day: day,
      isCurrentMonth: isCurrentMonth,
      isSelected: isSelected,
      isFocused: isFocused,
      isToday: isToday,
      isDisabled: isDisabled,
      onTap: onTap,
    );
  }

  String _getMonthName(int month) {
    const List<String> months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }
}

/// Individual day cell with hover and pressed visual states.
class _DayCell extends StatefulWidget {
  const _DayCell({
    required this.day,
    required this.isCurrentMonth,
    required this.isSelected,
    required this.isFocused,
    required this.isToday,
    required this.isDisabled,
    this.onTap,
  });

  final int day;
  final bool isCurrentMonth;
  final bool isSelected;
  final bool isFocused;
  final bool isToday;
  final bool isDisabled;
  final VoidCallback? onTap;

  @override
  State<_DayCell> createState() => _DayCellState();
}

class _DayCellState extends State<_DayCell> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.isDisabled
          ? SystemMouseCursors.basic
          : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 32,
          height: 32,
          margin: const EdgeInsets.all(1),
          decoration: BoxDecoration(
            color: _getBackgroundColor(),
            borderRadius: BorderRadius.circular(8),
            border: _getBorder(),
          ),
          child: Center(
            child: Text(
              widget.day.toString(),
              style: TextStyle(
                color: _getTextColor(),
                fontSize: 14,
                fontWeight: widget.isSelected || widget.isToday
                    ? FontWeight.w600
                    : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    if (widget.isDisabled) return Colors.transparent;
    if (widget.isSelected) return HuxTokens.primary(context);
    if (_isPressed) {
      return HuxTokens.surfaceHover(context);
    }
    if (_isHovered && !widget.isSelected) {
      return HuxTokens.surfaceHover(context);
    }
    if (widget.isToday) {
      return HuxTokens.primary(context).withValues(alpha: 0.1);
    }
    return Colors.transparent;
  }

  Color _getTextColor() {
    if (widget.isDisabled) return HuxTokens.textDisabled(context);
    if (widget.isSelected) return HuxTokens.textInvert(context);
    if (widget.isToday) return HuxTokens.primary(context);
    if (widget.isCurrentMonth) return HuxTokens.textPrimary(context);
    return HuxTokens.textSecondary(context);
  }

  Border? _getBorder() {
    if (widget.isFocused && !widget.isSelected) {
      return Border.all(
        color: HuxTokens.primary(context).withValues(alpha: 0.7),
        width: 1.5,
      );
    }
    if (widget.isToday && !widget.isSelected) {
      return Border.all(color: HuxTokens.primary(context), width: 1);
    }
    return null;
  }
}

/// Small navigation button used in the calendar header.
class _NavigationButton extends StatefulWidget {
  const _NavigationButton({
    required this.icon,
    required this.onPressed,
    required this.semanticLabel,
    this.focusNode,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String semanticLabel;
  final FocusNode? focusNode;

  @override
  State<_NavigationButton> createState() => _NavigationButtonState();
}

class _NavigationButtonState extends State<_NavigationButton> {
  bool _isHovered = false;
  bool _isPressed = false;
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: widget.semanticLabel,
      child: Focus(
        focusNode: widget.focusNode,
        onFocusChange: (focused) {
          if (_isFocused != focused) {
            setState(() => _isFocused = focused);
          }
        },
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: GestureDetector(
            onTap: widget.onPressed,
            onTapDown: (_) => setState(() => _isPressed = true),
            onTapUp: (_) => setState(() => _isPressed = false),
            onTapCancel: () => setState(() => _isPressed = false),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: _getBackgroundColor(),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _isFocused
                      ? HuxTokens.primary(context).withValues(alpha: 0.6)
                      : Colors.transparent,
                  width: 2,
                  strokeAlign: BorderSide.strokeAlignOutside,
                ),
              ),
              child: Center(
                child: Icon(
                  widget.icon,
                  size: 18,
                  color: _getIconColor(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    if (_isPressed) return HuxTokens.surfaceHover(context);
    if (_isHovered) return HuxTokens.surfaceHover(context);
    return HuxTokens.surfacePrimary(context);
  }

  Color _getIconColor() {
    return HuxTokens.textPrimary(context);
  }
}

class _PickerOptionButton extends StatefulWidget {
  const _PickerOptionButton({
    this.focusNode,
    this.onFocusChange,
    this.onKeyEvent,
    this.canRequestFocus = true,
    required this.onPressed,
    required this.variant,
    required this.size,
    required this.child,
  });

  final FocusNode? focusNode;
  final ValueChanged<bool>? onFocusChange;
  final FocusOnKeyEventCallback? onKeyEvent;
  final bool canRequestFocus;
  final VoidCallback? onPressed;
  final HuxButtonVariant variant;
  final HuxButtonSize size;
  final Widget child;

  @override
  State<_PickerOptionButton> createState() => _PickerOptionButtonState();
}

class _PickerOptionButtonState extends State<_PickerOptionButton> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: widget.focusNode,
      canRequestFocus: widget.canRequestFocus,
      onFocusChange: (focused) {
        if (_isFocused != focused) {
          setState(() => _isFocused = focused);
        }
        widget.onFocusChange?.call(focused);
      },
      onKeyEvent: widget.onKeyEvent,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: _isFocused
                ? HuxTokens.primary(context).withValues(alpha: 0.6)
                : Colors.transparent,
            width: 2,
            strokeAlign: BorderSide.strokeAlignOutside,
          ),
        ),
        child: HuxButton(
          onPressed: widget.onPressed,
          variant: widget.variant,
          size: widget.size,
          child: widget.child,
        ),
      ),
    );
  }
}
