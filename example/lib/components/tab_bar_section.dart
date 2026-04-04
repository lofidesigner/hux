import 'package:example/components/section_with_documentation.dart';
import 'package:flutter/material.dart';
import 'package:hux/hux.dart';

class TabBarSection extends StatefulWidget {
  const TabBarSection({super.key});

  @override
  State<TabBarSection> createState() => _TabBarSectionState();
}

class _TabBarSectionState extends State<TabBarSection> {
  HuxChromeTabsSize _selectedSize = HuxChromeTabsSize.medium;
  late final _controller = HuxTabBarController(
    initialTabs: [
      HuxTabBarItem(
        label: 'Home',
        icon: LucideIcons.home,
        content: _buildContent('Home', 'Welcome to the home page'),
      ),
      HuxTabBarItem(
        label: 'Documents',
        icon: LucideIcons.fileText,
        content: _buildContent('Documents', 'Your documents are here'),
      ),
      HuxTabBarItem(
        label: 'Settings',
        icon: LucideIcons.settings,
        content: _buildContent('Settings', 'Configure your preferences'),
      ),
    ],
    initialIndex: 0,
  );
  int _tabCounter = 4;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildContent(String title, String description) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: HuxTokens.textPrimary(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              fontSize: 16,
              color: HuxTokens.textSecondary(context),
            ),
          ),
        ],
      ),
    );
  }

  void _onAddTab() {
    _controller.addTab(
      HuxTabBarItem(
        label: 'Tab $_tabCounter',
        icon: LucideIcons.file,
        content: _buildContent(
          'Tab $_tabCounter',
          'This is a dynamically added tab',
        ),
      ),
    );
    _tabCounter++;
  }

  @override
  Widget build(BuildContext context) {
    return SectionWithDocumentation(
      componentName: 'tab-bar',
      child: HuxCard(
        size: HuxCardSize.large,
        backgroundColor: HuxColors.white5,
        borderColor: HuxTokens.borderSecondary(context),
        title: 'Tab Bar',
        subtitle:
            'Chrome-style tabs with drag-to-reorder and curved transitions',
        action: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Size:',
              style: TextStyle(
                color: HuxTokens.textSecondary(context),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 140,
              child: HuxDropdown<HuxChromeTabsSize>(
                items: const [
                  HuxDropdownItem(
                    value: HuxChromeTabsSize.small,
                    child: Text('Small'),
                  ),
                  HuxDropdownItem(
                    value: HuxChromeTabsSize.medium,
                    child: Text('Medium'),
                  ),
                  HuxDropdownItem(
                    value: HuxChromeTabsSize.large,
                    child: Text('Large'),
                  ),
                ],
                value: _selectedSize,
                onChanged: (value) {
                  setState(() {
                    _selectedSize = value;
                  });
                },
                placeholder: 'Select size',
                variant: HuxButtonVariant.outline,
                size: HuxButtonSize.small,
              ),
            ),
          ],
        ),
        child: Column(
          children: [
            const SizedBox(height: 16),
            HuxTabBar(
              controller: _controller,
              size: _selectedSize,
              onAddTab: _onAddTab,
              // onTabChanged: (index) {
              //   context.showHuxSnackbar(
              //     message: 'Switched to: ${_controller.tabs[index].label}',
              //     variant: HuxSnackbarVariant.info,
              //     duration: const Duration(seconds: 1),
              //   );
              // },
              // onTabsReordered: (oldIndex, newIndex) {},
              // onTabClosed: (index) {},
            ),
            Container(
              decoration: BoxDecoration(
                color: HuxTokens.surfacePrimary(context),
                border: Border(
                    left: BorderSide(
                      color: HuxTokens.borderSecondary(context),
                      width: 1,
                    ),
                    right: BorderSide(
                      color: HuxTokens.borderSecondary(context),
                      width: 1,
                    ),
                    bottom: BorderSide(
                      color: HuxTokens.borderSecondary(context),
                      width: 1,
                    )),
              ),
              height: 200,
              alignment: Alignment.center,
              child: ListenableBuilder(
                listenable: _controller,
                builder: (context, child) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: _controller.getContent ?? const Text('No content'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
