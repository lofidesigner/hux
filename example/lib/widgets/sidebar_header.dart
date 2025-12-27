import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:hux/hux.dart';

/// Sidebar header widget with logo, theme toggle, theme selector, and resource links
class SidebarHeader extends StatelessWidget {
  final ThemeMode themeMode;
  final VoidCallback onThemeToggle;
  final String selectedTheme;
  final ValueChanged<String> onThemeChanged;

  const SidebarHeader({
    super.key,
    required this.themeMode,
    required this.onThemeToggle,
    required this.selectedTheme,
    required this.onThemeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SvgPicture.asset(
                          Theme.of(context).brightness == Brightness.dark
                              ? 'assets/logo-dark.svg'
                              : 'assets/logo-light.svg',
                          height: 32,
                        ),
                      ],
                    ),
                  ),
                  HuxButton(
                    onPressed: onThemeToggle,
                    variant: HuxButtonVariant.outline,
                    size: HuxButtonSize.small,
                    width: HuxButtonWidth.fixed,
                    widthValue: 36,
                    icon: themeMode == ThemeMode.light
                        ? LucideIcons.moon
                        : LucideIcons.sun,
                    child: const SizedBox.shrink(),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Theme Selector
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Button Theme',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? HuxColors.white80
                          : HuxColors.black80,
                    ),
              ),
              const SizedBox(height: 8),
              HuxDropdown<String>(
                value: selectedTheme,
                items: HuxColors.availablePresetColors
                    .map<HuxDropdownItem<String>>((String colorName) {
                  final color = colorName == 'default'
                      ? HuxTokens.primary(context)
                      : HuxColors.getPresetColor(colorName);
                  return HuxDropdownItem<String>(
                    value: colorName,
                    child: Row(
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? HuxColors.white30
                                  : HuxColors.black30,
                              width: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          colorName[0].toUpperCase() + colorName.substring(1),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    onThemeChanged(newValue);
                  }
                },
                placeholder: 'Select theme',
                variant: HuxButtonVariant.outline,
                size: HuxButtonSize.small,
              ),
            ],
          ),
        ),

        // GitHub and Documentation Buttons
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Resources',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? HuxColors.white80
                          : HuxColors.black80,
                    ),
              ),
              const SizedBox(height: 8),
              HuxButton(
                onPressed: () async {
                  final uri = Uri.parse('https://github.com/lofidesigner/hux');
                  if (!await launchUrl(
                    uri,
                    mode: LaunchMode.externalApplication,
                    webOnlyWindowName: '_blank',
                  )) {
                    // Handle error if needed
                  }
                },
                variant: HuxButtonVariant.ghost,
                size: HuxButtonSize.small,
                width: HuxButtonWidth.expand,
                icon: LucideIcons.github,
                child: const Text('GitHub'),
              ),
              const SizedBox(height: 8),
              HuxButton(
                onPressed: () async {
                  final uri = Uri.parse('https://docs.thehuxdesign.com/');
                  if (!await launchUrl(
                    uri,
                    mode: LaunchMode.externalApplication,
                    webOnlyWindowName: '_blank',
                  )) {
                    // Handle error if needed
                  }
                },
                variant: HuxButtonVariant.ghost,
                size: HuxButtonSize.small,
                width: HuxButtonWidth.expand,
                icon: LucideIcons.bookOpen,
                child: const Text('Documentation'),
              ),
              const SizedBox(height: 8),
              HuxButton(
                onPressed: () async {
                  final uri = Uri.parse('https://pub.dev/packages/hux');
                  if (!await launchUrl(
                    uri,
                    mode: LaunchMode.externalApplication,
                    webOnlyWindowName: '_blank',
                  )) {
                    // Handle error if needed
                  }
                },
                variant: HuxButtonVariant.ghost,
                size: HuxButtonSize.small,
                width: HuxButtonWidth.expand,
                icon: LucideIcons.package,
                child: const Text('Package'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
