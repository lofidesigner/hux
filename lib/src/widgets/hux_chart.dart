import 'package:flutter/material.dart';
import 'package:cristalyse/cristalyse.dart';
import '../theme/hux_tokens.dart';

/// Chart types supported by HuxChart
enum HuxChartType {
  /// Line chart with connected data points
  line,

  /// Bar chart with rectangular bars
  bar,
}

/// Chart size variants
enum HuxChartSize {
  /// Small chart (200px height)
  small,

  /// Medium chart (300px height)
  medium,

  /// Large chart (400px height)
  large,
}

/// A customizable chart widget that wraps cristalyse with Hux UI styling
class HuxChart extends StatelessWidget {
  /// Creates a HuxChart widget.
  ///
  /// The [data], [type], [xField], and [yField] parameters are required.
  const HuxChart({
    super.key,
    required this.data,
    required this.type,
    required this.xField,
    required this.yField,
    this.size = HuxChartSize.medium,
    this.colorField,
    this.title,
    this.subtitle,
    Color? primaryColor,
    this.animated = true,
    this.animationDuration = const Duration(milliseconds: 800),
  }) : primaryColor = primaryColor ??
            const Color(
                0xFF3B82F6); // Will be overridden to use theme-aware color

  /// The data to display in the chart
  final List<Map<String, dynamic>> data;

  /// The type of chart to display
  final HuxChartType type;

  /// The size of the chart
  final HuxChartSize size;

  /// X-axis field name
  final String xField;

  /// Y-axis field name
  final String yField;

  /// Optional color field for grouping/coloring
  final String? colorField;

  /// Chart title
  final String? title;

  /// Chart subtitle
  final String? subtitle;

  /// Primary color for the chart
  final Color primaryColor;

  /// Whether to show animations
  final bool animated;

  /// Animation duration
  final Duration animationDuration;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _getChartHeight(),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(HuxTokens.radiusLg(context)),
        border: Border.all(
          color: HuxTokens.borderPrimary(context),
          width: HuxTokens.borderWidth(context),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null || subtitle != null) ...[
            _buildHeader(context),
            const SizedBox(height: 16),
          ],
          Expanded(
            child: _buildChart(context),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          Text(
            title!,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: HuxTokens.textPrimary(context),
                ),
          ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: HuxTokens.textSecondary(context),
                ),
          ),
        ],
      ],
    );
  }

  Widget _buildChart(BuildContext context) {
    try {
      // Use theme-aware primary color for charts
      final effectiveChartColor = primaryColor == const Color(0xFF3B82F6)
          ? HuxTokens.primary(context)
          : primaryColor;

      // Create theme using theme-aware tokens
      final customTheme = ChartTheme(
        backgroundColor: Colors.transparent, // No background color
        primaryColor: HuxTokens.primary(
            context), // This ensures primary color is theme-aware
        colorPalette: [
          HuxTokens.primary(
              context), // Main chart color - black in light, white in dark
          effectiveChartColor, // Custom or fallback color
          effectiveChartColor.withValues(alpha: 0.8),
        ],
        plotBackgroundColor: Colors.transparent, // No plot background color
        borderColor: Colors.transparent,
        gridColor: HuxTokens.chartGrid(context),
        axisColor: HuxTokens.chartAxis(context),
        gridWidth: 0.5,
        axisWidth: 1.0,
        pointSizeDefault: 4.0,
        pointSizeMin: 2.0,
        pointSizeMax: 8.0,
        axisTextStyle: TextStyle(
          fontSize: 12,
          color: HuxTokens.chartAxisText(context),
          fontWeight: FontWeight.w500,
        ),
        padding: const EdgeInsets.fromLTRB(40, 16, 16, 32),
      );

      // Build the base chart with custom theme
      var chart = CristalyseChart()
          .data(data)
          .mapping(
            x: xField,
            y: yField,
            color: colorField,
          )
          .theme(customTheme);

      // Add geometry based on chart type
      switch (type) {
        case HuxChartType.line:
          chart = chart
              .geomLine(
                strokeWidth: 3.0,
                alpha: 0.95,
              )
              .geomPoint(
                size: 8.0,
                alpha: 0.9,
              );
          break;
        case HuxChartType.bar:
          chart = chart.geomBar(width: 0.8);
          break;
      }

      // Add scales
      chart = chart.scaleXContinuous().scaleYContinuous();

      // Add animation if enabled
      if (animated) {
        chart = chart.animate(
          duration: animationDuration,
          curve: Curves.easeInOutCubic,
        );
      }

      return ClipRRect(
        borderRadius: BorderRadius.circular(HuxTokens.radiusMd(context)),
        child: chart.build(),
      );
    } catch (e) {
      // Fallback UI if chart fails to build
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bar_chart,
              size: 48,
              color: HuxTokens.iconSecondary(context),
            ),
            const SizedBox(height: 16),
            Text(
              'Chart Preview',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: HuxTokens.textTertiary(context),
                  ),
            ),
          ],
        ),
      );
    }
  }

  double _getChartHeight() {
    switch (size) {
      case HuxChartSize.small:
        return 200;
      case HuxChartSize.medium:
        return 300;
      case HuxChartSize.large:
        return 400;
    }
  }
}

/// Convenience constructors for common chart types
extension HuxChartConstructors on HuxChart {
  /// Creates a line chart
  static HuxChart line({
    Key? key,
    required List<Map<String, dynamic>> data,
    required String xField,
    required String yField,
    String? colorField,
    String? title,
    String? subtitle,
    Color? primaryColor,
    HuxChartSize size = HuxChartSize.medium,
    bool animated = true,
    Duration animationDuration = const Duration(milliseconds: 800),
  }) {
    return HuxChart(
      key: key,
      data: data,
      type: HuxChartType.line,
      xField: xField,
      yField: yField,
      colorField: colorField,
      title: title,
      subtitle: subtitle,
      primaryColor: primaryColor,
      size: size,
      animated: animated,
      animationDuration: animationDuration,
    );
  }

  /// Creates a bar chart
  static HuxChart bar({
    Key? key,
    required List<Map<String, dynamic>> data,
    required String xField,
    required String yField,
    String? colorField,
    String? title,
    String? subtitle,
    Color? primaryColor,
    HuxChartSize size = HuxChartSize.medium,
    bool animated = true,
    Duration animationDuration = const Duration(milliseconds: 800),
  }) {
    return HuxChart(
      key: key,
      data: data,
      type: HuxChartType.bar,
      xField: xField,
      yField: yField,
      colorField: colorField,
      title: title,
      subtitle: subtitle,
      primaryColor: primaryColor,
      size: size,
      animated: animated,
      animationDuration: animationDuration,
    );
  }
}
