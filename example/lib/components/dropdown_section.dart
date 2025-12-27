import 'package:flutter/material.dart';
import 'package:hux/hux.dart';
import 'section_with_documentation.dart';

class DropdownSection extends StatefulWidget {
  final Color primaryColor;
  const DropdownSection({super.key, required this.primaryColor});

  @override
  State<DropdownSection> createState() => _DropdownSectionState();
}

class _DropdownSectionState extends State<DropdownSection> {
  String? _selectedOption;
  HuxButtonVariant _selectedVariant = HuxButtonVariant.outline;
  bool _useItemWidgetAsValue = false;

  final List<HuxDropdownItem<String>> _options = const [
    HuxDropdownItem(
      value: 'Option 1',
      child: Row(
        children: [
          Icon(LucideIcons.user, size: 16),
          SizedBox(width: 8),
          Text('Option 1'),
        ],
      ),
    ),
    HuxDropdownItem(
      value: 'Option 2',
      child: Row(
        children: [
          Icon(LucideIcons.settings, size: 16),
          SizedBox(width: 8),
          Text('Option 2'),
        ],
      ),
    ),
    HuxDropdownItem(
      value: 'Option 3',
      child: Row(
        children: [
          Icon(LucideIcons.bell, size: 16),
          SizedBox(width: 8),
          Text('Option 3'),
        ],
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SectionWithDocumentation(
      componentName: 'dropdown',
      child: HuxCard(
        size: HuxCardSize.large,
        backgroundColor: HuxColors.white5,
        borderColor: HuxTokens.borderSecondary(context),
        title: 'Dropdown',
        subtitle: 'Dropdown/select components with various styles',
        action: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Variant:',
                  style: TextStyle(
                    color: HuxTokens.textSecondary(context),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 160,
                  child: HuxDropdown<HuxButtonVariant>(
                    items: const [
                      HuxDropdownItem(
                        value: HuxButtonVariant.primary,
                        child: Text('Primary'),
                      ),
                      HuxDropdownItem(
                        value: HuxButtonVariant.secondary,
                        child: Text('Secondary'),
                      ),
                      HuxDropdownItem(
                        value: HuxButtonVariant.outline,
                        child: Text('Outline'),
                      ),
                      HuxDropdownItem(
                        value: HuxButtonVariant.ghost,
                        child: Text('Ghost'),
                      ),
                    ],
                    value: _selectedVariant,
                    onChanged: (value) {
                      setState(() {
                        _selectedVariant = value;
                      });
                    },
                    placeholder: 'Select variant',
                    variant: HuxButtonVariant.outline,
                    size: HuxButtonSize.small,
                    primaryColor: widget.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Item widget as value:',
                  style: TextStyle(
                    color: HuxTokens.textSecondary(context),
                  ),
                ),
                const SizedBox(width: 8),
                HuxSwitch(
                  value: _useItemWidgetAsValue,
                  onChanged: (value) {
                    setState(() {
                      _useItemWidgetAsValue = value;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
        child: Column(
          children: [
            const SizedBox(height: 32),
            Center(
              child: SizedBox(
                width: 200,
                child: HuxDropdown<String>(
                  items: _options,
                  value: _selectedOption,
                  onChanged: (value) {
                    setState(() {
                      _selectedOption = value;
                    });
                  },
                  placeholder: 'Select an option',
                  useItemWidgetAsValue: _useItemWidgetAsValue,
                  variant: _selectedVariant,
                  primaryColor: widget.primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
