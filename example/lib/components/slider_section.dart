import 'package:flutter/material.dart';
import 'package:hux/hux.dart';
import 'section_with_documentation.dart';

class SliderSection extends StatefulWidget {
  const SliderSection({super.key});

  @override
  State<SliderSection> createState() => _SliderSectionState();
}

class _SliderSectionState extends State<SliderSection> {
  double _sliderValue = 50.0;

  @override
  Widget build(BuildContext context) {
    return SectionWithDocumentation(
      componentName: 'slider',
      child: HuxCard(
        size: HuxCardSize.large,
        backgroundColor: HuxColors.white5,
        borderColor: HuxTokens.borderSecondary(context),
        title: 'Slider',
        subtitle: 'Interactive slider control for selecting numeric values',
        child: Column(
          children: [
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: HuxSlider(
                value: _sliderValue,
                onChanged: (value) {
                  setState(() {
                    _sliderValue = value;
                  });
                },
                min: 0,
                max: 100,
                label: 'Volume',
                showValue: true,
              ),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}
