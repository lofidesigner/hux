import 'package:flutter/material.dart';
import 'package:hux/hux.dart';
import 'section_with_documentation.dart';

class LoadingSection extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onToggleLoading;

  const LoadingSection({
    super.key,
    required this.isLoading,
    required this.onToggleLoading,
  });

  @override
  Widget build(BuildContext context) {
    return SectionWithDocumentation(
      componentName: 'loading',
      child: HuxCard(
        size: HuxCardSize.large,
        backgroundColor: HuxColors.white5,
        borderColor: HuxTokens.borderSecondary(context),
        title: 'Loading Indicators',
        subtitle: 'Different loading states and sizes',
        child: Column(
          children: [
            const SizedBox(height: 16),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    HuxLoading(size: HuxLoadingSize.small),
                    SizedBox(height: 8),
                    Text('Small'),
                  ],
                ),
                Column(
                  children: [
                    HuxLoading(size: HuxLoadingSize.medium),
                    SizedBox(height: 8),
                    Text('Medium'),
                  ],
                ),
                Column(
                  children: [
                    HuxLoading(size: HuxLoadingSize.large),
                    SizedBox(height: 8),
                    Text('Large'),
                  ],
                ),
                Column(
                  children: [
                    HuxLoading(size: HuxLoadingSize.extraLarge),
                    SizedBox(height: 8),
                    Text('XL'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            HuxButton(
              onPressed: onToggleLoading,
              variant: HuxButtonVariant.outline,
              child: Text(isLoading ? 'Stop Loading' : 'Show Loading Overlay'),
            ),
          ],
        ),
      ),
    );
  }
}
