import 'package:flutter/material.dart';
import 'package:hux/hux.dart';
import 'section_with_documentation.dart';

class ToggleSwitchesSection extends StatefulWidget {
  const ToggleSwitchesSection({super.key});

  @override
  State<ToggleSwitchesSection> createState() => _ToggleSwitchesSectionState();
}

class _ToggleSwitchesSectionState extends State<ToggleSwitchesSection> {
  bool _switchValue = false;

  @override
  Widget build(BuildContext context) {
    return SectionWithDocumentation(
      componentName: 'switch',
      child: HuxCard(
        size: HuxCardSize.large,
        backgroundColor: HuxColors.white5,
        borderColor: HuxTokens.borderSecondary(context),
        title: 'Switch',
        subtitle: 'Interactive toggle switch control',
        child: Column(
          children: [
            const SizedBox(height: 32),
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  HuxSwitch(
                    value: _switchValue,
                    onChanged: (value) {
                      setState(() {
                        _switchValue = value;
                      });
                    },
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _switchValue ? 'Enabled' : 'Disabled',
                    style: TextStyle(
                      color: HuxTokens.textSecondary(context),
                    ),
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
