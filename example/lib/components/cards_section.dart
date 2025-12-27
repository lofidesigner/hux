import 'package:flutter/material.dart';
import 'package:hux/hux.dart';
import 'section_with_documentation.dart';

class CardsSection extends StatelessWidget {
  const CardsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SectionWithDocumentation(
      componentName: 'cards',
      child: HuxCard(
        size: HuxCardSize.large,
        backgroundColor: HuxColors.white5,
        borderColor: HuxTokens.borderSecondary(context),
        title: 'Cards',
        subtitle: 'Container components for content organization',
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = MediaQuery.of(context).size.width;
            final isMobileScreen = screenWidth < 768;

            return Column(
              children: [
                const SizedBox(height: 16),
                isMobileScreen
                    ? const Column(
                        children: [
                          HuxCard(
                            title: 'Simple Card',
                            child: Text(
                                'This is a simple card with just a title and content.'),
                          ),
                          SizedBox(height: 16),
                          HuxCard(
                            title: 'Card with Subtitle',
                            subtitle: 'This card has both title and subtitle',
                            child: Text(
                                'Cards can have optional subtitles for additional context.'),
                          ),
                        ],
                      )
                    : const Row(
                        children: [
                          Expanded(
                            child: HuxCard(
                              title: 'Simple Card',
                              child: Text(
                                  'This is a simple card with just a title and content.'),
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: HuxCard(
                              title: 'Card with Subtitle',
                              subtitle: 'This card has both title and subtitle',
                              child: Text(
                                  'Cards can have optional subtitles for additional context.'),
                            ),
                          ),
                        ],
                      ),
              ],
            );
          },
        ),
      ),
    );
  }
}
