import 'package:flutter/material.dart';
import 'package:hux/hux.dart';
import 'section_with_documentation.dart';

class CheckboxesSection extends StatefulWidget {
  const CheckboxesSection({super.key});

  @override
  State<CheckboxesSection> createState() => _CheckboxesSectionState();
}

class _CheckboxesSectionState extends State<CheckboxesSection> {
  bool _checkboxValue = false;
  final bool _checkboxDisabled = true;

  @override
  Widget build(BuildContext context) {
    return SectionWithDocumentation(
      componentName: 'checkbox',
      child: HuxCard(
        size: HuxCardSize.large,
        backgroundColor: HuxColors.white5,
        borderColor: HuxTokens.borderSecondary(context),
        title: 'Checkbox',
        subtitle: 'Interactive checkbox controls',
        child: Column(
          children: [
            const SizedBox(height: 32),
            Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  HuxCheckbox(
                    value: _checkboxValue,
                    onChanged: (value) {
                      setState(() {
                        _checkboxValue = value ?? false;
                      });
                    },
                    label: 'I agree to the terms and conditions',
                  ),
                  const SizedBox(height: 16),
                  HuxCheckbox(
                    value: _checkboxDisabled,
                    onChanged: null,
                    label: 'Disabled checkbox',
                    isDisabled: true,
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
