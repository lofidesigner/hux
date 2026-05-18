import 'package:flutter/material.dart';
import '../theme/hux_tokens.dart';

/// Shows a Hux UI-themed time picker dialog.
///
/// This function displays a custom time picker with modern design patterns,
/// featuring hour/minute selection with Hux theming.
///
/// Example:
/// ```dart
/// final TimeOfDay? picked = await showHuxTimePickerDialog(
///   context: context,
///   initialTime: TimeOfDay.now(),
/// );
/// ```
///
/// Returns the selected time or null if cancelled.
Future<TimeOfDay?> showHuxTimePickerDialog({
  required BuildContext context,
  required TimeOfDay initialTime,
  GlobalKey? targetKey, // ADD THIS PARAMETER
}) {
  // Get button position if targetKey is provided
  Offset? buttonPosition;
  Size? buttonSize;

  if (targetKey != null && targetKey.currentContext != null) {
    final RenderBox renderBox =
        targetKey.currentContext!.findRenderObject() as RenderBox;
    buttonPosition = renderBox.localToGlobal(Offset.zero);
    buttonSize = renderBox.size;
  }

  return showDialog<TimeOfDay>(
    context: context,
    barrierColor: Colors.transparent,
    builder: (context) {
      if (buttonPosition != null && buttonSize != null) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(color: Colors.transparent),
              ),
            ),
            CustomSingleChildLayout(
              delegate: _TimePickerLayoutDelegate(
                targetPosition: buttonPosition,
                targetSize: buttonSize,
              ),
              child: Material(
                color: Colors.transparent,
                child: HuxTimePickerDialog(
                  initialTime: initialTime,
                ),
              ),
            ),
          ],
        );
      } else {
        return Center(
          child: HuxTimePickerDialog(
            initialTime: initialTime,
          ),
        );
      }
    },
  );
}

class _TimePickerLayoutDelegate extends SingleChildLayoutDelegate {
  _TimePickerLayoutDelegate({
    required this.targetPosition,
    required this.targetSize,
  });

  final Offset targetPosition;
  final Size targetSize;

  @override
  Size getSize(BoxConstraints constraints) => constraints.biggest;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return BoxConstraints.loose(constraints.biggest);
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    // ignore: prefer_final_locals
    double x = targetPosition.dx;
    // Use a reasonable estimate for picker height instead of childSize.height
    const estimatedPickerHeight = 160.0;
    // ignore: prefer_final_locals
    double y = targetPosition.dy -
        estimatedPickerHeight -
        4; // Bottom of picker 4px above button top

    if (x + childSize.width > size.width - 10) {
      x = size.width - childSize.width - 10;
    }
    if (x < 10) {
      x = 10;
    }

    final buttonCenter = targetPosition.dx + (targetSize.width / 2);
    final pickerCenter = childSize.width / 2;
    if (buttonCenter - pickerCenter > 10 &&
        buttonCenter + pickerCenter < size.width - 10) {
      x = buttonCenter - pickerCenter;
    }

    return Offset(x, y);
  }

  @override
  bool shouldRelayout(_TimePickerLayoutDelegate oldDelegate) {
    return targetPosition != oldDelegate.targetPosition ||
        targetSize != oldDelegate.targetSize;
  }
}

/// A custom Hux UI-themed time picker dialog widget.
///
/// This widget provides a modern time picker with hour/minute selection,
/// dropdown interfaces, and Hux theming support.
///
/// Example:
/// ```dart
/// HuxTimePickerDialog(
///   initialTime: TimeOfDay.now(),
/// )
/// ```
class HuxTimePickerDialog extends StatefulWidget {
  /// Creates a Hux time picker dialog.
  ///
  /// [initialTime] is the time initially selected.
  const HuxTimePickerDialog({
    super.key,
    required this.initialTime,
  });

  /// The initial time to display in the picker.
  final TimeOfDay initialTime;

  @override
  State<HuxTimePickerDialog> createState() => _HuxTimePickerDialogState();
}

class _HuxTimePickerDialogState extends State<HuxTimePickerDialog> {
  late TimeOfDay _selectedTime;
  bool _isSelectingHour = false;
  bool _isSelectingMinute = false;
  bool _isHourHovered = false;
  bool _isMinuteHovered = false;

  @override
  void initState() {
    super.initState();
    _selectedTime = widget.initialTime;
  }

  void _selectHour(int hour) {
    setState(() {
      _selectedTime = TimeOfDay(hour: hour, minute: _selectedTime.minute);
      _isSelectingHour = false;
    });
    // Close the dialog and return the selected time
    Navigator.of(context).pop(_selectedTime);
  }

  void _selectMinute(int minute) {
    setState(() {
      _selectedTime = TimeOfDay(hour: _selectedTime.hour, minute: minute);
      _isSelectingMinute = false;
    });
    // Close the dialog and return the selected time
    Navigator.of(context).pop(_selectedTime);
  }

  void _toggleHourSelection() {
    setState(() {
      _isSelectingHour = !_isSelectingHour;
      _isSelectingMinute = false;
    });
  }

  void _toggleMinuteSelection() {
    setState(() {
      _isSelectingMinute = !_isSelectingMinute;
      _isSelectingHour = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: HuxTokens.surfaceElevated(context),
        borderRadius: BorderRadius.circular(HuxTokens.radiusLg(context)),
        border: Border.all(
          color: HuxTokens.buttonSecondaryBorder(context),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: HuxTokens.shadowColor(context),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Hour selector
              MouseRegion(
                onEnter: (_) => setState(() => _isHourHovered = true),
                onExit: (_) => setState(() => _isHourHovered = false),
                child: GestureDetector(
                  onTap: _toggleHourSelection,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _isSelectingHour
                          ? HuxTokens.primary(context)
                          : _isHourHovered
                              ? HuxTokens.surfaceHover(context)
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(HuxTokens.radiusSm(context)),
                    ),
                    child: Text(
                      _selectedTime.hour.toString().padLeft(2, '0'),
                      style: TextStyle(
                        color: _isSelectingHour
                            ? HuxTokens.surfacePrimary(context)
                            : HuxTokens.textPrimary(context),
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              Text(
                ':',
                style: TextStyle(
                  color: HuxTokens.textPrimary(context),
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
              // Minute selector
              MouseRegion(
                onEnter: (_) => setState(() => _isMinuteHovered = true),
                onExit: (_) => setState(() => _isMinuteHovered = false),
                child: GestureDetector(
                  onTap: _toggleMinuteSelection,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _isSelectingMinute
                          ? HuxTokens.primary(context)
                          : _isMinuteHovered
                              ? HuxTokens.surfaceHover(context)
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(HuxTokens.radiusSm(context)),
                    ),
                    child: Text(
                      _selectedTime.minute.toString().padLeft(2, '0'),
                      style: TextStyle(
                        color: _isSelectingMinute
                            ? HuxTokens.surfacePrimary(context)
                            : HuxTokens.textPrimary(context),
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Hour dropdown
          if (_isSelectingHour) ...[
            const SizedBox(height: 16),
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: HuxTokens.surfaceSecondary(context),
                borderRadius: BorderRadius.circular(HuxTokens.radiusMd(context)),
                border: Border.all(
                  color: HuxTokens.buttonSecondaryBorder(context),
                  width: 1,
                ),
              ),
              child: ListView.builder(
                itemCount: 24,
                itemBuilder: (context, index) {
                  final hour = index;
                  final isSelected = hour == _selectedTime.hour;
                  return _HourItem(
                    hour: hour,
                    isSelected: isSelected,
                    onTap: () => _selectHour(hour),
                  );
                },
              ),
            ),
          ],

          // Minute dropdown
          if (_isSelectingMinute) ...[
            const SizedBox(height: 16),
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: HuxTokens.surfaceSecondary(context),
                borderRadius: BorderRadius.circular(HuxTokens.radiusMd(context)),
                border: Border.all(
                  color: HuxTokens.buttonSecondaryBorder(context),
                  width: 1,
                ),
              ),
              child: ListView.builder(
                itemCount: 60,
                itemBuilder: (context, index) {
                  final minute = index;
                  final isSelected = minute == _selectedTime.minute;
                  return _MinuteItem(
                    minute: minute,
                    isSelected: isSelected,
                    onTap: () => _selectMinute(minute),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _HourItem extends StatefulWidget {
  const _HourItem({
    required this.hour,
    required this.isSelected,
    required this.onTap,
  });

  final int hour;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  State<_HourItem> createState() => _HourItemState();
}

class _HourItemState extends State<_HourItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? HuxTokens.primary(context)
                : _isHovered
                    ? HuxTokens.surfaceHover(context)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(HuxTokens.radiusSm(context)),
          ),
          child: Text(
            widget.hour.toString().padLeft(2, '0'),
            style: TextStyle(
              color: widget.isSelected
                  ? HuxTokens.surfacePrimary(context)
                  : HuxTokens.textPrimary(context),
              fontSize: 16,
              fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class _MinuteItem extends StatefulWidget {
  const _MinuteItem({
    required this.minute,
    required this.isSelected,
    required this.onTap,
  });

  final int minute;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  State<_MinuteItem> createState() => _MinuteItemState();
}

class _MinuteItemState extends State<_MinuteItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? HuxTokens.primary(context)
                : _isHovered
                    ? HuxTokens.surfaceHover(context)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(HuxTokens.radiusSm(context)),
          ),
          child: Text(
            widget.minute.toString().padLeft(2, '0'),
            style: TextStyle(
              color: widget.isSelected
                  ? HuxTokens.surfacePrimary(context)
                  : HuxTokens.textPrimary(context),
              fontSize: 16,
              fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
