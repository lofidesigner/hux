import 'package:flutter/material.dart';
import 'package:hux/hux.dart';
import 'section_with_documentation.dart';

class DatePickerSection extends StatefulWidget {
  const DatePickerSection({super.key});

  @override
  State<DatePickerSection> createState() => _DatePickerSectionState();
}

class _DatePickerSectionState extends State<DatePickerSection> {
  DateTime? _selectedDate;

  @override
  Widget build(BuildContext context) {
    return SectionWithDocumentation(
      componentName: 'date-picker',
      child: HuxCard(
        size: HuxCardSize.large,
        backgroundColor: HuxColors.white5,
        borderColor: HuxTokens.borderSecondary(context),
        title: 'Date Picker',
        subtitle: 'Themed picker for date selection',
        child: Column(
          children: [
            const SizedBox(height: 32),
            Center(
              child: HuxDatePicker(
                initialDate: _selectedDate,
                firstDate: DateTime(2000),
                lastDate: DateTime(2101),
                onDateChanged: (date) {
                  setState(() {
                    _selectedDate = date;
                  });
                },
                variant: HuxButtonVariant.outline,
                icon: LucideIcons.calendar,
                placeholder: 'Select Date',
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
