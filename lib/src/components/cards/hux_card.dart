import 'package:flutter/material.dart';
import '../../theme/hux_tokens.dart';

/// Size variants for HuxCard
enum HuxCardSize {
  /// Default card size with standard padding and text
  default_,

  /// Large card size with increased padding and larger text
  large
}

/// HuxCard is a customizable card component that provides a consistent
/// container with optional header, title, subtitle, and actions.
///
/// The card automatically adapts to light and dark themes and provides
/// a clean, modern appearance with subtle borders and optional shadows.
///
/// Example:
/// ```dart
/// HuxCard(
///   title: 'User Profile',
///   subtitle: 'Manage your account settings',
///   action: IconButton(
///     icon: Icon(Icons.more_vert),
///     onPressed: () {},
///   ),
///   child: Column(
///     children: [
///       Text('Card content goes here'),
///       // ... more content
///     ],
///   ),
///   onTap: () => print('Card tapped'),
/// )
/// ```
class HuxCard extends StatelessWidget {
  /// Creates a HuxCard widget.
  ///
  /// The [child] parameter is required and contains the main content of the card.
  const HuxCard({
    super.key,
    required this.child,
    this.title,
    this.subtitle,
    this.action,
    this.size,
    this.padding,
    this.margin = EdgeInsets.zero,
    this.elevation = 0,
    this.borderRadius,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth,
    this.onTap,
  });

  /// The main content widget to display inside the card
  final Widget child;

  /// Optional title text displayed in the card header
  final String? title;

  /// Optional subtitle text displayed below the title
  final String? subtitle;

  /// Optional action widget displayed in the top-right corner of the header
  final Widget? action;

  /// Size variant of the card. If null, uses original defaults (16px padding, 12px borderRadius).
  /// Use [HuxCardSize.default_] for explicit standard size or [HuxCardSize.large] for enhanced styling.
  final HuxCardSize? size;

  /// Padding around the main content. If null, uses size-based defaults:
  /// - [HuxCardSize.default_]: 16px on all sides
  /// - [HuxCardSize.large]: 24px on all sides
  final EdgeInsetsGeometry? padding;

  /// Margin around the entire card. Defaults to zero
  final EdgeInsetsGeometry margin;

  /// Elevation of the card shadow. Defaults to 0 for a flat appearance
  final double elevation;

  /// Border radius of the card corners. If null, uses size-based defaults:
  /// - [HuxCardSize.default_]: 12px
  /// - [HuxCardSize.large]: 20px
  final double? borderRadius;

  /// Custom background color for the card. If null, uses [HuxTokens.surfaceElevated]
  final Color? backgroundColor;

  /// Custom border color for the card. If null, uses [HuxTokens.borderPrimary]
  final Color? borderColor;

  /// Border width for the card. If null, defaults to 1.0
  final double? borderWidth;

  /// Callback triggered when the card is tapped. If null, the card is not interactive
  final VoidCallback? onTap;

  /// Gets the padding value based on size variant
  EdgeInsetsGeometry _getPadding() {
    if (padding != null) return padding!;
    switch (size) {
      case null:
      case HuxCardSize.default_:
        return const EdgeInsets.all(16);
      case HuxCardSize.large:
        return const EdgeInsets.all(24);
    }
  }

  /// Gets the border radius value based on size variant
  double _getBorderRadius() {
    if (borderRadius != null) return borderRadius!;
    switch (size) {
      case null:
      case HuxCardSize.default_:
        return 12;
      case HuxCardSize.large:
        return 20;
    }
  }

  /// Gets the header padding value based on size variant
  EdgeInsetsGeometry _getHeaderPadding() {
    switch (size) {
      case null:
      case HuxCardSize.default_:
        return const EdgeInsets.fromLTRB(16, 16, 16, 0);
      case HuxCardSize.large:
        return const EdgeInsets.fromLTRB(24, 24, 24, 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final borderRadiusValue = _getBorderRadius();
    final paddingValue = _getPadding();

    return Container(
      margin: margin,
      child: Material(
        elevation: elevation,
        borderRadius: BorderRadius.circular(borderRadiusValue),
        color: backgroundColor ?? HuxTokens.surfaceElevated(context),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadiusValue),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadiusValue),
              border: Border.all(
                color: borderColor ?? HuxTokens.borderPrimary(context),
                width: borderWidth ?? 1.0,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (title != null || subtitle != null || action != null)
                  _buildHeader(context),
                Padding(
                  padding: paddingValue,
                  child: child,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final headerPadding = _getHeaderPadding();
    final isLarge = size == HuxCardSize.large;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Padding(
      padding: headerPadding,
      child: isMobile && action != null
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (title != null)
                            Text(
                              title!,
                              style: isLarge
                                  ? Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.w500,
                                        color: HuxTokens.textPrimary(context),
                                      )
                                  : Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w500,
                                        color: HuxTokens.textPrimary(context),
                                      ),
                            ),
                          if (subtitle != null) ...[
                            SizedBox(height: isLarge ? 6 : 4),
                            Text(
                              subtitle!,
                              style: isLarge
                                  ? Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: HuxTokens.textTertiary(context),
                                      )
                                  : Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: HuxTokens.textTertiary(context),
                                      ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                LayoutBuilder(
                  builder: (context, constraints) {
                    // If action is a Row, extract its children and wrap them
                    if (action is Row) {
                      final row = action as Row;
                      return Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        alignment: WrapAlignment.start,
                        children: row.children,
                      );
                    }
                    // Otherwise, just show the action as-is (it should handle its own wrapping)
                    return action!;
                  },
                ),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (title != null)
                        Text(
                          title!,
                          style: isLarge
                              ? Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.w500,
                                    color: HuxTokens.textPrimary(context),
                                  )
                              : Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w500,
                                    color: HuxTokens.textPrimary(context),
                                  ),
                        ),
                      if (subtitle != null) ...[
                        SizedBox(height: isLarge ? 6 : 4),
                        Text(
                          subtitle!,
                          style: isLarge
                              ? Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: HuxTokens.textTertiary(context),
                                  )
                              : Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: HuxTokens.textTertiary(context),
                                  ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (action != null)
                  Flexible(
                    fit: FlexFit.loose,
                    child: Align(
                      alignment: Alignment.topRight,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          // If action is a Row and might overflow, wrap it
                          if (action is Row) {
                            final row = action as Row;
                            return ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: constraints.maxWidth,
                              ),
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                alignment: WrapAlignment.end,
                                children: row.children,
                              ),
                            );
                          }
                          return action!;
                        },
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}
