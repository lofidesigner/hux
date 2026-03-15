import 'package:flutter/material.dart';
import '../../theme/hux_tokens.dart';

/// HuxTooltip is a customizable tooltip component that provides additional context
/// when hovering over or long-pressing on widgets.
///
/// The tooltip automatically adapts to light/dark themes and provides various
/// positioning and styling options.
///
/// Examples:
/// ```dart
/// // Basic tooltip
/// HuxTooltip(
///   message: 'This is a helpful tooltip',
///   child: Icon(Icons.info),
/// )
///
/// // Tooltip with icon
/// HuxTooltip(
///   message: 'Information about this feature',
///   icon: Icons.info_outline,
///   child: Icon(Icons.help),
/// )
///
/// // Custom styled tooltip
/// HuxTooltip(
///   message: 'Custom styled tooltip',
///   backgroundColor: Colors.deepPurple,
///   textColor: Colors.white,
///   child: Text('Hover me'),
/// )
/// ```
class HuxTooltip extends StatefulWidget {
  /// Creates a HuxTooltip widget.
  ///
  /// Either [message] or [richMessage] must be provided.
  const HuxTooltip({
    super.key,
    this.message,
    required this.child,
    this.icon,
    this.iconColor,
    this.iconSize = 16.0,
    this.backgroundColor,
    this.textColor,
    this.preferBelow = true,
    this.excludeFromSemantics = false,
    this.verticalOffset = 10.0,
    this.waitDuration = const Duration(milliseconds: 500),
    this.showDuration = const Duration(milliseconds: 3000),
    this.decoration,
    this.textStyle,
    this.padding,
    this.margin,
    this.richMessage,
  }) : assert(message != null || richMessage != null,
            'Either message or richMessage must be provided');

  /// The text to display in the tooltip
  final String? message;

  /// The icon to display alongside the message (optional)
  final IconData? icon;

  /// Color of the icon (optional, defaults to theme text color)
  final Color? iconColor;

  /// Size of the icon (defaults to 16.0)
  final double iconSize;

  /// The widget below this tooltip in the tree
  final Widget child;

  /// Background color of the tooltip (optional, defaults to theme surface)
  final Color? backgroundColor;

  /// Text color of the tooltip (optional, defaults to theme text)
  final Color? textColor;

  /// Whether to prefer showing the tooltip below the child
  final bool preferBelow;

  /// Whether to exclude this tooltip from the semantics tree
  final bool excludeFromSemantics;

  /// The vertical offset from the child
  final double verticalOffset;

  /// How long to wait before showing the tooltip
  final Duration waitDuration;

  /// How long to show the tooltip
  final Duration showDuration;

  /// Custom decoration for the tooltip (optional)
  final Decoration? decoration;

  /// Custom text style for the tooltip (optional)
  final TextStyle? textStyle;

  /// Padding inside the tooltip (optional)
  final EdgeInsetsGeometry? padding;

  /// Margin around the tooltip (optional)
  final EdgeInsetsGeometry? margin;

  /// Rich text message for the tooltip (optional, overrides message if provided)
  final InlineSpan? richMessage;

  @override
  State<HuxTooltip> createState() => _HuxTooltipState();
}

class _HuxTooltipState extends State<HuxTooltip> {
  GlobalKey<TooltipState> _tooltipKey = GlobalKey<TooltipState>();

  void _showTooltipForThisInstance() {
    _tooltipKey.currentState?.ensureTooltipVisible();
  }

  void _dismissTooltipForThisInstance() {
    if (!mounted) {
      return;
    }
    // Rotating the tooltip key disposes the previous Tooltip state,
    // removing only this instance's overlay instead of dismissing globally.
    setState(() {
      _tooltipKey = GlobalKey<TooltipState>();
    });
  }

  @override
  Widget build(BuildContext context) {
    final effectiveBackgroundColor =
        widget.backgroundColor ?? HuxTokens.primary(context);
    final effectiveTextColor =
        widget.textColor ?? HuxTokens.textInvert(context);
    final effectivePadding = widget.padding ??
        const EdgeInsets.symmetric(horizontal: 10, vertical: 4);
    final effectiveMargin = widget.margin ?? const EdgeInsets.all(8);

    // If icon is provided, use richMessage to render icon + text
    final effectiveRichMessage = widget.richMessage ??
        (widget.icon != null
            ? TextSpan(
                children: [
                  WidgetSpan(
                    child: Icon(
                      widget.icon,
                      size: widget.iconSize,
                      color: widget.iconColor ?? effectiveTextColor,
                    ),
                    alignment: PlaceholderAlignment.middle,
                  ),
                  const WidgetSpan(child: SizedBox(width: 8)),
                  TextSpan(
                    text: widget.message,
                    style: widget.textStyle ??
                        TextStyle(
                          color: effectiveTextColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              )
            : null);

    return Tooltip(
      key: _tooltipKey,
      message: effectiveRichMessage != null ? null : widget.message,
      preferBelow: widget.preferBelow,
      excludeFromSemantics: widget.excludeFromSemantics,
      verticalOffset: widget.verticalOffset,
      waitDuration: widget.waitDuration,
      showDuration: widget.showDuration,
      decoration: widget.decoration ??
          BoxDecoration(
            color: effectiveBackgroundColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: HuxTokens.borderPrimary(context),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: HuxTokens.textPrimary(context).withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
      textStyle: effectiveRichMessage != null
          ? null
          : (widget.textStyle ??
              TextStyle(
                color: effectiveTextColor,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              )),
      padding: effectivePadding,
      margin: effectiveMargin,
      richMessage: effectiveRichMessage,
      child: Focus(
        canRequestFocus: false,
        onFocusChange: (hasFocus) {
          if (hasFocus) {
            _showTooltipForThisInstance();
          } else {
            _dismissTooltipForThisInstance();
          }
        },
        child: widget.child,
      ),
    );
  }
}
