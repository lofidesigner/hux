import 'package:flutter/material.dart';
import 'package:hux/hux.dart';
import 'section_with_documentation.dart';

class RadioButtonsSection extends StatefulWidget {
  const RadioButtonsSection({super.key});

  @override
  State<RadioButtonsSection> createState() => _RadioButtonsSectionState();
}

class _RadioButtonsSectionState extends State<RadioButtonsSection> {
  String _selectedOption = 'option1';

  @override
  Widget build(BuildContext context) {
    return SectionWithDocumentation(
      componentName: 'radio',
      child: HuxCard(
        size: HuxCardSize.large,
        backgroundColor: HuxColors.white5,
        borderColor: HuxTokens.borderSecondary(context),
        title: 'Radio Buttons',
        subtitle: 'Interactive radio button controls',
        child: Column(
          children: [
            const SizedBox(height: 32),
            Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  HuxRadio<String>(
                    value: 'option1',
                    groupValue: _selectedOption,
                    onChanged: (value) {
                      setState(() {
                        _selectedOption = value ?? 'option1';
                      });
                    },
                    label: 'Option 1',
                  ),
                  const SizedBox(height: 16),
                  HuxRadio<String>(
                    value: 'option2',
                    groupValue: _selectedOption,
                    onChanged: (value) {
                      setState(() {
                        _selectedOption = value ?? 'option1';
                      });
                    },
                    label: 'Option 2',
                  ),
                  const SizedBox(height: 16),
                  HuxRadio<String>(
                    value: 'option3',
                    groupValue: _selectedOption,
                    onChanged: (value) {
                      setState(() {
                        _selectedOption = value ?? 'option1';
                      });
                    },
                    label: 'Option 3',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
