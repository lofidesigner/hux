import 'package:flutter/material.dart';
import 'package:hux/hux.dart';
import 'section_with_documentation.dart';

class TabsSection extends StatefulWidget {
  const TabsSection({super.key});

  @override
  State<TabsSection> createState() => _TabsSectionState();
}

class _TabsSectionState extends State<TabsSection> {
  HuxTabVariant _selectedVariant = HuxTabVariant.default_;

  @override
  Widget build(BuildContext context) {
    return SectionWithDocumentation(
      componentName: 'tabs',
      child: HuxCard(
        size: HuxCardSize.large,
        backgroundColor: HuxColors.white5,
        borderColor: HuxTokens.borderSecondary(context),
        title: 'Tabs',
        subtitle: 'Organize content into multiple panels with tab navigation',
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
              child: HuxDropdown<HuxTabVariant>(
                items: const [
                  HuxDropdownItem(
                    value: HuxTabVariant.default_,
                    child: Text('Default'),
                  ),
                  HuxDropdownItem(
                    value: HuxTabVariant.pill,
                    child: Text('Pill'),
                  ),
                  HuxDropdownItem(
                    value: HuxTabVariant.minimal,
                    child: Text('Minimal'),
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
            const SizedBox(height: 16),
            HuxTabs(
              variant: _selectedVariant,
              tabs: const [
                HuxTabItem(
                  label: 'Overview',
                  icon: LucideIcons.layout,
                  content: Center(child: Text('Overview content goes here')),
                ),
                HuxTabItem(
                  label: 'Settings',
                  icon: LucideIcons.settings,
                  content: Center(child: Text('Settings content goes here')),
                ),
                HuxTabItem(
                  label: 'Profile',
                  icon: LucideIcons.user,
                  badge: HuxBadge(
                      label: '3',
                      variant: HuxBadgeVariant.primary,
                      size: HuxBadgeSize.small),
                  content: Center(child: Text('Profile content goes here')),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
