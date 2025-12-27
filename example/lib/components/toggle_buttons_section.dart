import 'package:flutter/material.dart';
import 'package:hux/hux.dart';
import 'section_with_documentation.dart';

class ToggleButtonsSection extends StatefulWidget {
  final String selectedTheme;
  const ToggleButtonsSection({
    super.key,
    required this.selectedTheme,
  });

  @override
  State<ToggleButtonsSection> createState() => _ToggleButtonsSectionState();
}

class _ToggleButtonsSectionState extends State<ToggleButtonsSection> {
  bool _isEditing = false;
  HuxButtonVariant _selectedVariant = HuxButtonVariant.primary;

  Color get _primaryColor {
    return widget.selectedTheme == 'default'
        ? HuxTokens.primary(context)
        : HuxColors.getPresetColor(widget.selectedTheme);
  }

  @override
  Widget build(BuildContext context) {
    return SectionWithDocumentation(
      componentName: 'toggle',
      child: HuxCard(
        size: HuxCardSize.large,
        backgroundColor: HuxColors.white5,
        borderColor: HuxTokens.borderSecondary(context),
        title: 'Toggle',
        subtitle: 'Two-state toggle buttons for formatting controls',
        action: Row(
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
              ),
            ),
          ],
        ),
        child: Column(
          children: [
            const SizedBox(height: 32),
            Center(
              child: Column(
                children: [
                  // Icon-only toggle
                  HuxToggle(
                    value: _isEditing,
                    onChanged: (value) {
                      setState(() {
                        _isEditing = value;
                      });
                    },
                    icon: LucideIcons.edit2,
                    variant: _selectedVariant,
                    primaryColor: _primaryColor,
                  ),
                  const SizedBox(height: 16),
                  // Icon with text toggle
                  HuxToggle(
                    value: _isEditing,
                    onChanged: (value) {
                      setState(() {
                        _isEditing = value;
                      });
                    },
                    icon: LucideIcons.edit2,
                    label: 'Edit',
                    variant: _selectedVariant,
                    primaryColor: _primaryColor,
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
