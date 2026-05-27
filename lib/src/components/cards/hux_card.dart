import 'package:flutter/foundation.dart';
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
    this.wrapSpacing,
    this.wrapRunSpacing,
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

  /// Horizontal spacing used when row actions wrap in constrained layouts.
  ///
  /// If null, wrapped actions keep the existing 8px spacing.
  final double? wrapSpacing;

  /// Vertical spacing used between wrapped action rows in constrained layouts.
  ///
  /// If null, wrapped actions keep the existing 8px run spacing.
  final double? wrapRunSpacing;

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
                    if (action is Row) {
                      final row = action as Row;
                      return _AdaptiveActionLayout(
                        row: row,
                        constraints: constraints,
                        wrapAlignment: WrapAlignment.start,
                        wrapSpacing: wrapSpacing,
                        wrapRunSpacing: wrapRunSpacing,
                      );
                    }
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
                          if (action is Row) {
                            final row = action as Row;
                            return _AdaptiveActionLayout(
                              row: row,
                              constraints: constraints,
                              wrapAlignment: WrapAlignment.end,
                              wrapSpacing: wrapSpacing,
                              wrapRunSpacing: wrapRunSpacing,
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

class _AdaptiveActionLayout extends StatefulWidget {
  const _AdaptiveActionLayout({
    required this.row,
    required this.constraints,
    required this.wrapAlignment,
    this.wrapSpacing,
    this.wrapRunSpacing,
  });

  final Row row;
  final BoxConstraints constraints;
  final WrapAlignment wrapAlignment;
  final double? wrapSpacing;
  final double? wrapRunSpacing;

  @override
  State<_AdaptiveActionLayout> createState() => _AdaptiveActionLayoutState();
}

class _AdaptiveActionLayoutState extends State<_AdaptiveActionLayout> {
  final GlobalKey _measureKey = GlobalKey();
  double? _intrinsicWidth;

  @override
  void didUpdateWidget(covariant _AdaptiveActionLayout oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.row != widget.row ||
        !listEquals(oldWidget.row.children, widget.row.children)) {
      _intrinsicWidth = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_intrinsicWidth == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final box = _measureKey.currentContext?.findRenderObject() as RenderBox?;
        final width = box?.size.width;
        if (width != null && width > 0 && width != _intrinsicWidth) {
          setState(() {
            _intrinsicWidth = width;
          });
        }
      });

      return Stack(
        children: [
          ClipRect(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              reverse: widget.wrapAlignment == WrapAlignment.end,
              physics: const NeverScrollableScrollPhysics(),
              child: widget.row,
            ),
          ),
          Offstage(
            offstage: true,
            child: UnconstrainedBox(
              alignment: Alignment.topLeft,
              constrainedAxis: Axis.vertical,
              child: IntrinsicWidth(
                key: _measureKey,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: widget.row.children,
                ),
              ),
            ),
          ),
        ],
      );
    }

    final maxWidth = widget.constraints.maxWidth;
    if (!maxWidth.isFinite || _intrinsicWidth! <= maxWidth) {
      return widget.row;
    }

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Wrap(
        spacing: widget.wrapSpacing ?? 8,
        runSpacing: widget.wrapRunSpacing ?? 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        alignment: widget.wrapAlignment,
        children: widget.row.children,
      ),
    );
  }
}
