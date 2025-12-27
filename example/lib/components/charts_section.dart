import 'package:flutter/material.dart';
import 'package:hux/hux.dart';
import 'section_with_documentation.dart';

class ChartsSection extends StatelessWidget {
  final String selectedTheme;

  const ChartsSection({
    super.key,
    required this.selectedTheme,
  });

  Color _currentPrimaryColor(BuildContext context) {
    return selectedTheme == 'default'
        ? HuxTokens.primary(context)
        : HuxColors.getPresetColor(selectedTheme);
  }

  List<Map<String, dynamic>> _getSampleLineData() {
    return [
      {'day': 1, 'calories': 520, 'type': 'Daily Goal'},
      {'day': 2, 'calories': 480, 'type': 'Daily Goal'},
      {'day': 3, 'calories': 440, 'type': 'Daily Goal'},
      {'day': 4, 'calories': 580, 'type': 'Daily Goal'},
      {'day': 5, 'calories': 520, 'type': 'Daily Goal'},
      {'day': 6, 'calories': 610, 'type': 'Daily Goal'},
      {'day': 7, 'calories': 490, 'type': 'Daily Goal'},
      {'day': 8, 'calories': 550, 'type': 'Daily Goal'},
      {'day': 9, 'calories': 580, 'type': 'Daily Goal'},
      {'day': 10, 'calories': 470, 'type': 'Daily Goal'},
      {'day': 11, 'calories': 620, 'type': 'Daily Goal'},
      {'day': 12, 'calories': 540, 'type': 'Daily Goal'},
      {'day': 13, 'calories': 510, 'type': 'Daily Goal'},
      {'day': 14, 'calories': 590, 'type': 'Daily Goal'},
    ];
  }

  List<Map<String, dynamic>> _getSampleBarData() {
    return [
      {'product': 'Mobile', 'revenue': 450},
      {'product': 'Tablet', 'revenue': 320},
      {'product': 'Laptop', 'revenue': 580},
      {'product': 'Desktop', 'revenue': 290},
      {'product': 'Watch', 'revenue': 180},
    ];
  }

  @override
  Widget build(BuildContext context) {
    return SectionWithDocumentation(
      componentName: 'charts',
      child: HuxCard(
        size: HuxCardSize.large,
        backgroundColor: HuxColors.white5,
        borderColor: HuxTokens.borderSecondary(context),
        title: 'Charts',
        subtitle: 'Data visualization with Cristalyse',
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = MediaQuery.of(context).size.width;
            final isMobileScreen = screenWidth < 768;

            return Column(
              children: [
                const SizedBox(height: 16),
                if (isMobileScreen)
                  Column(
                    children: [
                      HuxChart(
                        data: _getSampleLineData(),
                        type: HuxChartType.line,
                        xField: 'day',
                        yField: 'calories',
                        title: 'Daily Calories',
                        subtitle: 'Calorie tracking over time',
                        size: HuxChartSize.small,
                        primaryColor: _currentPrimaryColor(context),
                      ),
                      const SizedBox(height: 16),
                      HuxChart(
                        data: _getSampleBarData(),
                        type: HuxChartType.bar,
                        xField: 'product',
                        yField: 'revenue',
                        title: 'Product Revenue',
                        subtitle: 'Revenue by product',
                        size: HuxChartSize.small,
                        primaryColor: _currentPrimaryColor(context),
                      ),
                    ],
                  )
                else
                  Row(
                    children: [
                      Expanded(
                        child: HuxChart(
                          data: _getSampleLineData(),
                          type: HuxChartType.line,
                          xField: 'day',
                          yField: 'calories',
                          title: 'Daily Calories',
                          subtitle: 'Calorie tracking over time',
                          size: HuxChartSize.small,
                          primaryColor: _currentPrimaryColor(context),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: HuxChart(
                          data: _getSampleBarData(),
                          type: HuxChartType.bar,
                          xField: 'product',
                          yField: 'revenue',
                          title: 'Product Revenue',
                          subtitle: 'Revenue by product',
                          size: HuxChartSize.small,
                          primaryColor: _currentPrimaryColor(context),
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
