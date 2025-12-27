import 'package:flutter/material.dart';
import 'package:hux/hux.dart';
import 'section_with_documentation.dart';

class BadgesSection extends StatelessWidget {
  const BadgesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SectionWithDocumentation(
      componentName: 'badge',
      child: HuxCard(
        size: HuxCardSize.large,
        backgroundColor: HuxColors.white5,
        borderColor: HuxTokens.borderSecondary(context),
        title: 'Badge',
        subtitle: 'Status indicators and notification counters',
        child: const Column(
          children: [
            SizedBox(height: 32),
            Center(
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  HuxBadge(
                      label: 'Primary',
                      variant: HuxBadgeVariant.primary,
                      size: HuxBadgeSize.small),
                  HuxBadge(
                      label: 'Secondary',
                      variant: HuxBadgeVariant.secondary,
                      size: HuxBadgeSize.small),
                  HuxBadge(
                      label: 'Outline',
                      variant: HuxBadgeVariant.outline,
                      size: HuxBadgeSize.small),
                  HuxBadge(
                      label: 'Success',
                      variant: HuxBadgeVariant.success,
                      size: HuxBadgeSize.small),
                  HuxBadge(
                      label: 'Destructive',
                      variant: HuxBadgeVariant.destructive,
                      size: HuxBadgeSize.small),
                  HuxBadge(
                      label: '99+',
                      variant: HuxBadgeVariant.primary,
                      size: HuxBadgeSize.small),
                ],
              ),
            ),
            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
