import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hux/hux.dart';

/// HuxDateInput is a specialized text input component for date input
/// with automatic formatting, validation, and calendar picker integration.
///
/// Provides a clean, modern date input that follows Hux UI design principles
/// with support for custom date formats, validation, and easy date selection.
///
/// Example:
/// ```dart
/// HuxDateInput(
///   label: 'Birth Date',
///   hint: 'MM/DD/YYYY',
///   format: DateFormat('MM/dd/yyyy'),
///   onDateChanged: (date) => print('Selected date: $date'),
///   validator: (date) {
///     if (date == null) return 'Date is required';
///     if (date.isAfter(DateTime.now())) return 'Date cannot be in the future';
///     return null;
///   },
/// )
/// ```
class HuxDateInput extends StatefulWidget {
  /// Creates a HuxDateInput widget.
  const HuxDateInput({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.initialDate,
    this.firstDate,
    this.lastDate,
    this.format,
    this.placeholder,
    this.enabled = true,
    this.showCalendarIcon = true,
    this.allowManualInput = true,
    this.onDateChanged,
    this.onDateSubmitted,
    this.validator,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
    this.width,
  });

  /// Controller for the text field
  final TextEditingController? controller;

  /// Label text displayed above the text field
  final String? label;

  /// Hint text displayed inside the text field when empty
  final String? hint;

  /// Helper text displayed below the text field
  final String? helperText;

  /// Error text displayed below the text field, overrides helperText
  final String? errorText;

  /// The initially selected date
  final DateTime? initialDate;

  /// The earliest selectable date
  final DateTime? firstDate;

  /// The latest selectable date
  final DateTime? lastDate;

  /// Date format for display and parsing
  final DateFormat? format;

  /// Placeholder text when no date is selected
  final String? placeholder;

  /// Whether the text field is enabled for input
  final bool enabled;

  /// Whether to show the calendar icon button
  final bool showCalendarIcon;

  /// Whether to allow manual text input
  final bool allowManualInput;

  /// Called when the date value changes
  final ValueChanged<DateTime?>? onDateChanged;

  /// Called when the user submits the date field
  final ValueChanged<DateTime?>? onDateSubmitted;

  /// Validator function for form validation
  final String? Function(DateTime?)? validator;

  /// When to show validation errors
  final AutovalidateMode autovalidateMode;

  /// Width of the text field (optional, defaults to full width)
  final double? width;

  @override
  State<HuxDateInput> createState() => _HuxDateInputState();
}

class _HuxDateInputState extends State<HuxDateInput> {
  late TextEditingController _controller;
  DateTime? _selectedDate;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _selectedDate = widget.initialDate;
    _updateControllerText();
    _controller.addListener(_onControllerChanged);
  }

  @override
  void didUpdateWidget(covariant HuxDateInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialDate != oldWidget.initialDate) {
      _selectedDate = widget.initialDate;
      _updateControllerText();
    }
    if (widget.controller != oldWidget.controller) {
      _controller = widget.controller ?? _controller;
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _updateControllerText() {
    if (_selectedDate != null) {
      final format = widget.format ?? _getDefaultFormat();
      _controller.text = format.format(_selectedDate!);
    } else {
      _controller.text = '';
    }
  }

  DateFormat _getDefaultFormat() {
    return DateFormat('MM/dd/yyyy');
  }

  void _handleDateSelection(DateTime date) {
    setState(() {
      _selectedDate = date;
      _errorText = null;
    });
    _updateControllerText();
    widget.onDateChanged?.call(date);
  }

  void _handleTextChanged(String value) {
    if (!widget.allowManualInput) return;

    if (value.isEmpty) {
      setState(() {
        _selectedDate = null;
        _errorText = null;
      });
      widget.onDateChanged?.call(null);
      return;
    }

    // Auto-format the input with '/' symbols
    final formattedValue = _autoFormatDateInput(value);

    // Update the controller with formatted text (without triggering onChanged again)
    if (formattedValue != value) {
      _controller.removeListener(_onControllerChanged);
      _controller.text = formattedValue;
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: formattedValue.length),
      );
      _controller.addListener(_onControllerChanged);
    }

    try {
      final format = widget.format ?? _getDefaultFormat();
      final parsedDate = format.parse(formattedValue);

      // Validate date range if specified
      if (widget.firstDate != null && parsedDate.isBefore(widget.firstDate!)) {
        setState(() {
          _errorText =
              'Date cannot be before ${_formatDateForError(widget.firstDate!)}';
        });
        return;
      }

      if (widget.lastDate != null && parsedDate.isAfter(widget.lastDate!)) {
        setState(() {
          _errorText =
              'Date cannot be after ${_formatDateForError(widget.lastDate!)}';
        });
        return;
      }

      setState(() {
        _selectedDate = parsedDate;
        _errorText = null;
      });
      widget.onDateChanged?.call(parsedDate);
    } catch (e) {
      setState(() {
        _errorText = 'Invalid date format';
      });
      widget.onDateChanged?.call(null);
    }
  }

  String _autoFormatDateInput(String input) {
    // Remove all non-digit characters
    final digits = input.replaceAll(RegExp(r'[^\d]'), '');

    if (digits.length <= 2) {
      return digits;
    } else if (digits.length <= 4) {
      return '${digits.substring(0, 2)}/${digits.substring(2)}';
    } else if (digits.length <= 8) {
      return '${digits.substring(0, 2)}/${digits.substring(2, 4)}/${digits.substring(4)}';
    } else {
      // Limit to 8 digits (MM/DD/YYYY)
      return '${digits.substring(0, 2)}/${digits.substring(2, 4)}/${digits.substring(4, 8)}';
    }
  }

  void _onControllerChanged() {
    // This prevents infinite loops when updating the controller
  }

  String _formatDateForError(DateTime date) {
    final format = widget.format ?? _getDefaultFormat();
    return format.format(date);
  }

  void _handleSubmitted(String value) {
    if (_selectedDate != null) {
      widget.onDateSubmitted?.call(_selectedDate);
    }
  }

  Widget _buildCalendarIcon(BuildContext context) {
    return SizedBox(
      width: 28,
      height: 24,
      child: HuxDatePicker(
        initialDate: _selectedDate,
        firstDate: widget.firstDate ?? DateTime(1900),
        lastDate: widget.lastDate ?? DateTime(2100),
        onDateChanged: _handleDateSelection,
        placeholder: 'Select Date',
        size: HuxButtonSize.small, // Use small size for compact icon
        variant: HuxButtonVariant.ghost, // No border, just icon
        icon: Icons.calendar_today,
        showText: false, // Icon-only version
      ),
    );
  }

  String? _validateDate(DateTime? date) {
    if (widget.validator != null) {
      return widget.validator!(date);
    }

    if (date == null && widget.placeholder == null) {
      return 'Date is required';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final effectiveErrorText = _errorText ?? widget.errorText;
    final effectiveHelperText = effectiveErrorText ?? widget.helperText;

    return HuxInput(
      controller: _controller,
      label: widget.label,
      width: widget.width,
      hint: widget.hint ?? widget.placeholder ?? 'MM/DD/YYYY',
      errorText: effectiveErrorText,
      helperText: effectiveErrorText == null ? effectiveHelperText : null,
      suffixIcon: widget.showCalendarIcon ? _buildCalendarIcon(context) : null,
      maxLines: 1,
      minLines: 1,
      enabled: widget.enabled && widget.allowManualInput,
      onChanged: _handleTextChanged,
      onSubmitted: _handleSubmitted,
      validator: (_) => _validateDate(_selectedDate),
      autoValidateMode: widget.autovalidateMode,
      inputFormatters: [
        if (widget.format != null)
          FilteringTextInputFormatter.allow(RegExp(r'[0-9/\-\.]')),
      ],
    );
  }
}

/// DateFormat class for date formatting and parsing
class DateFormat {
  /// Creates a DateFormat with the specified pattern
  const DateFormat(this.pattern);

  /// The date format pattern (e.g., 'MM/dd/yyyy')
  final String pattern;

  /// Formats a DateTime to a string using the pattern
  String format(DateTime date) {
    // Simple implementation for common patterns
    if (pattern == 'MM/dd/yyyy') {
      return '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}';
    } else if (pattern == 'dd/MM/yyyy') {
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } else if (pattern == 'yyyy-MM-dd') {
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    } else if (pattern == 'MM-dd-yyyy') {
      return '${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}-${date.year}';
    }

    // Default fallback
    return '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}';
  }

  /// Parses a string to a DateTime using the pattern
  DateTime parse(String input) {
    // Simple implementation for common patterns
    if (pattern == 'MM/dd/yyyy' || pattern == 'MM-dd-yyyy') {
      final parts = input.split(RegExp(r'[/\-]'));
      if (parts.length == 3) {
        final month = int.parse(parts[0]);
        final day = int.parse(parts[1]);
        final year = int.parse(parts[2]);
        return DateTime(year, month, day);
      }
    } else if (pattern == 'dd/MM/yyyy') {
      final parts = input.split(RegExp(r'[/\-]'));
      if (parts.length == 3) {
        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final year = int.parse(parts[2]);
        return DateTime(year, month, day);
      }
    } else if (pattern == 'yyyy-MM-dd') {
      final parts = input.split('-');
      if (parts.length == 3) {
        final year = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final day = int.parse(parts[2]);
        return DateTime(year, month, day);
      }
    }

    throw FormatException('Invalid date format: $input');
  }
}
