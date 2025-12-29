import 'package:flutter/material.dart';
import 'package:hux/hux.dart';
import 'section_with_documentation.dart';

class TooltipSection extends StatelessWidget {
  const TooltipSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SectionWithDocumentation(
      componentName: 'tooltip',
      child: HuxCard(
        size: HuxCardSize.large,
        backgroundColor: HuxColors.white5,
        borderColor: HuxTokens.borderSecondary(context),
        title: 'Tooltip',
        subtitle: 'Contextual help and information',
        child: Column(
          children: [
            const SizedBox(height: 32),
            Center(
              child: HuxTooltip(
                message: 'This is a tooltip message',
                preferBelow: false,
                verticalOffset: 16.0,
                child: HuxButton(
                  onPressed: () {},
                  variant: HuxButtonVariant.outline,
                  child: const Text('Hover'),
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
