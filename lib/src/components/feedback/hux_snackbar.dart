import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/hux_tokens.dart';
import '../buttons/hux_button.dart';

/// Visual variants for HuxSnackbar.
enum HuxSnackbarVariant {
  /// Blue styling for informational messages.
  info,

  /// Green styling for success confirmations.
  success,

  /// Orange styling for warning messages.
  warning,

  /// Red styling for error messages.
  error,
}

/// A proper snackbar component that provides temporary notification messages.
///
/// Built using composition to avoid inheritance conflicts with SnackBar.
/// Follows Hux design system principles with consistent theming and accessibility.
class HuxSnackbar {
  /// Creates a snackbar with the specified properties.
  const HuxSnackbar({
    this.key,
    required this.message,
    this.variant = HuxSnackbarVariant.info,
    this.title,
    this.onDismiss,
    this.onCloseRequest,
    this.showIcon = true,
    this.duration = const Duration(seconds: 4),
    this.action,
    this.actions,
    this.behavior = SnackBarBehavior.floating,
    this.backgroundColor,
    this.textColor,
    this.actionTextColor,
    this.elevation = 6,
    this.margin = const EdgeInsets.only(left: 16, bottom: 16),
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    this.shape,
  });

  /// The key for the snackbar.
  final Key? key;

  /// The message text to display in the snackbar.
  final String message;

  /// The visual variant of the snackbar.
  final HuxSnackbarVariant variant;

  /// Optional title text displayed above the message.
  final String? title;

  /// Callback when the snackbar is dismissed.
  final VoidCallback? onDismiss;

  /// Internal callback used to request closing this snackbar.
  ///
  /// When provided, the snackbar will call this instead of interacting with
  /// [ScaffoldMessenger]. This enables stacked snackbars via overlays.
  final VoidCallback? onCloseRequest;

  /// Whether to show an icon in the snackbar.
  final bool showIcon;

  /// Duration the snackbar is displayed.
  final Duration duration;

  /// Optional action button.
  ///
  /// Deprecated by [actions]. Kept for backward compatibility.
  final SnackBarAction? action;

  /// Optional action buttons shown inside the snackbar.
  ///
  /// Use this for common patterns like "Undo", "Retry", "View", or "Close".
  final List<HuxSnackbarAction>? actions;

  /// Behavior of the snackbar.
  final SnackBarBehavior behavior;

  /// Custom background color override.
  final Color? backgroundColor;

  /// Custom text color override.
  final Color? textColor;

  /// Custom action text color override.
  final Color? actionTextColor;

  /// Elevation of the snackbar.
  final double elevation;

  /// Margin around the snackbar.
  final EdgeInsetsGeometry margin;

  /// Padding inside the snackbar.
  final EdgeInsetsGeometry padding;

  /// Shape of the snackbar.
  final ShapeBorder? shape;

  /// Builds the SnackBar widget.
  SnackBar build(BuildContext context) {
    return SnackBar(
      key: key,
      content: _buildContent(context),
      duration: duration,
      // Action UI is rendered inside [_buildContent] to match Hux styling.
      behavior: behavior,
      backgroundColor: Colors.transparent,
      elevation: 0,
      margin: margin,
      padding: EdgeInsets.zero,
      shape: shape,
    );
  }

  Widget _buildContent(BuildContext context) {
    return Align(
      alignment: Alignment.bottomLeft,
      child: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Container(
      width: 400,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.black.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: Theme.of(context).brightness == Brightness.dark ? 10 : 5,
            sigmaY: Theme.of(context).brightness == Brightness.dark ? 10 : 5,
          ),
          child: Container(
            key: const ValueKey('huxSnackbarContainer'),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _getContainerBackgroundColor(context),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _getBorderColor(context),
                width: 1, // Consistent with Hux border width
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (showIcon) ...[
                  Icon(
                    _getIcon(),
                    color: _getIconColor(context),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (title != null) ...[
                        Text(
                          title!,
                          style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight
                                        .w600, // Consistent with Hux typography
                                    color: textColor ?? _getTextColor(context),
                                  ) ??
                              TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: textColor ?? _getTextColor(context),
                              ),
                        ),
                        const SizedBox(height: 4),
                      ],
                      Text(
                        message,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: textColor ?? _getTextColor(context),
                                ) ??
                            TextStyle(
                              fontSize: 12,
                              color: textColor ?? _getTextColor(context),
                            ),
                      ),
                    ],
                  ),
                ),
                if (_hasActions) ...[
                  const SizedBox(width: 12),
                  Flexible(
                    child: _buildActions(context),
                  ),
                ],
                if (onDismiss != null) ...[
                  const SizedBox(width: 8),
                  Material(
                    color: Colors.transparent,
                    child: Tooltip(
                      message: 'Dismiss notification',
                      child: Semantics(
                        button: true,
                        label: 'Dismiss notification',
                        child: InkWell(
                          onTap: () {
                            final close = onCloseRequest ??
                                () => ScaffoldMessenger.of(context)
                                    .hideCurrentSnackBar();
                            close();
                            onDismiss?.call();
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: SizedBox(
                            width: 48,
                            height: 48,
                            child: Center(
                              child: Icon(
                                LucideIcons.x,
                                size: 16,
                                color: textColor ?? _getTextColor(context),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool get _hasActions => action != null || (actions?.isNotEmpty ?? false);

  Widget _buildActions(BuildContext context) {
    final effectiveActions = <HuxSnackbarAction>[
      if (action != null)
        HuxSnackbarAction(
          label: action!.label,
          textColor: actionTextColor ?? action!.textColor,
          onPressed: () {
            action!.onPressed();
          },
        ),
      ...?actions,
    ];

    if (effectiveActions.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (final a in effectiveActions)
          HuxButton(
            onPressed: () {
              final close = onCloseRequest ??
                  () => ScaffoldMessenger.of(context).hideCurrentSnackBar();
              close();
              a.onPressed();
            },
            variant: HuxButtonVariant.primary,
            size: HuxButtonSize.small,
            child: Text(a.label),
          ),
      ],
    );
  }

  Color _getBackgroundColor(BuildContext context) {
    switch (variant) {
      case HuxSnackbarVariant.info:
        return HuxTokens.surfaceElevated(context);
      case HuxSnackbarVariant.success:
        return HuxTokens.surfaceOverlay(context);
      case HuxSnackbarVariant.warning:
        return HuxTokens.surfaceOverlay(context);
      case HuxSnackbarVariant.error:
        return HuxTokens.surfaceOverlay(context);
    }
  }

  Color _getBorderColor(BuildContext context) {
    switch (variant) {
      case HuxSnackbarVariant.info:
        return HuxTokens.borderSecondary(context);
      case HuxSnackbarVariant.success:
        return HuxTokens.borderSecondary(context);
      case HuxSnackbarVariant.warning:
        return const Color(0xFFF59E0B); // Amber border
      case HuxSnackbarVariant.error:
        return HuxTokens.borderSecondary(context);
    }
  }

  Color _getIconColor(BuildContext context) {
    switch (variant) {
      case HuxSnackbarVariant.info:
        return HuxTokens.textSecondary(context);
      case HuxSnackbarVariant.success:
        return HuxTokens.textSuccess(context);
      case HuxSnackbarVariant.warning:
        return const Color(0xFFF59E0B); // Amber icon
      case HuxSnackbarVariant.error:
        return HuxTokens.textDestructive(context);
    }
  }

  Color _getTextColor(BuildContext context) {
    if (textColor != null) return textColor!;

    switch (variant) {
      case HuxSnackbarVariant.info:
        return HuxTokens.textPrimary(context);
      case HuxSnackbarVariant.success:
        return HuxTokens.textSuccess(context);
      case HuxSnackbarVariant.warning:
        return const Color(0xFFF59E0B);
      case HuxSnackbarVariant.error:
        return HuxTokens.textDestructive(context);
    }
  }

  Color _getContainerBackgroundColor(BuildContext context) {
    if (backgroundColor != null) return backgroundColor!;

    final baseColor = _getBackgroundColor(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return baseColor.withValues(alpha: isDark ? 0.72 : 0.78);
  }

  IconData _getIcon() {
    switch (variant) {
      case HuxSnackbarVariant.info:
        return LucideIcons.info;
      case HuxSnackbarVariant.success:
        return LucideIcons.checkCircle;
      case HuxSnackbarVariant.warning:
        return LucideIcons.alertTriangle;
      case HuxSnackbarVariant.error:
        return LucideIcons.alertCircle;
    }
  }
}

/// Configuration for an action shown inside [HuxSnackbar].
class HuxSnackbarAction {
  /// Creates an action button shown inside a [HuxSnackbar].
  const HuxSnackbarAction({
    required this.label,
    required this.onPressed,
    this.textColor,
  });

  /// Visible label for the action button (e.g. "Undo").
  final String label;

  /// Callback invoked when the action button is pressed.
  final VoidCallback onPressed;

  /// Optional override for the action label color.
  final Color? textColor;
}

/// Extension to easily show HuxSnackbar.
extension HuxSnackbarExtension on BuildContext {
  /// Shows a HuxSnackbar with the given parameters.
  void showHuxSnackbar({
    required String message,
    HuxSnackbarVariant variant = HuxSnackbarVariant.info,
    String? title,
    VoidCallback? onDismiss,
    bool showIcon = true,
    Duration duration = const Duration(seconds: 4),
    SnackBarAction? action,
    List<HuxSnackbarAction>? actions,
    SnackBarBehavior behavior = SnackBarBehavior.floating,
    Color? backgroundColor,
    Color? textColor,
    Color? actionTextColor,
    double elevation = 6,
    EdgeInsets margin = const EdgeInsets.all(16),
    EdgeInsets padding =
        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ShapeBorder? shape,
  }) {
    final snackbar = HuxSnackbar(
      message: message,
      variant: variant,
      title: title,
      onDismiss: onDismiss,
      showIcon: showIcon,
      duration: duration,
      action: action,
      actions: actions,
      behavior: behavior,
      backgroundColor: backgroundColor,
      textColor: textColor,
      actionTextColor: actionTextColor,
      elevation: elevation,
      margin: margin,
      padding: padding,
      shape: shape,
    );

    ScaffoldMessenger.of(this).showSnackBar(snackbar.build(this));
  }
}

/// Controller for stacked [HuxSnackbar] overlays.
///
/// Flutter's [ScaffoldMessenger] queues snackbars (one at a time). This
/// controller enables showing multiple snackbars simultaneously by rendering
/// them in an [Overlay].
class HuxSnackbarStackController {
  HuxSnackbarStackController._(this._context);

  final BuildContext _context;

  /// Returns a controller instance associated with [context].
  static HuxSnackbarStackController of(BuildContext context) =>
      HuxSnackbarStackController._(context);

  static final ValueNotifier<List<_HuxSnackbarStackItem>> _items =
      ValueNotifier<List<_HuxSnackbarStackItem>>([]);

  static OverlayEntry? _entry;
  static OverlayState? _overlayState;
  static bool _isInserted = false;

  /// Shows [snackbar] as part of the stacked overlay.
  void show(HuxSnackbar snackbar) {
    final overlay = Overlay.of(_context, rootOverlay: true);
    _entry ??= OverlayEntry(
      builder: (context) {
        return ValueListenableBuilder<List<_HuxSnackbarStackItem>>(
          valueListenable: _items,
          builder: (context, items, _) {
            if (items.isEmpty) return const SizedBox.shrink();

            final margin = items.last.snackbar.margin.resolve(
              Directionality.of(context),
            );
            final viewInsets = MediaQuery.viewInsetsOf(context);

            // Oldest at top, newest at bottom (grows upwards from bottom-left).
            return Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: margin.left,
                    top: margin.top,
                    right: margin.right,
                    bottom: margin.bottom + viewInsets.bottom,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var i = 0; i < items.length; i++) ...[
                        _StackedSnackbarItemView(item: items[i]),
                        if (i != items.length - 1) const SizedBox(height: 12),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    // Avoid inserting twice in the same frame (OverlayEntry.mounted won't flip
    // until the next build).
    if (_overlayState != overlay) {
      if (_isInserted && (_entry?.mounted ?? false)) {
        _entry?.remove();
      }
      _isInserted = false;
      _overlayState = overlay;
    }
    if (!_isInserted) {
      overlay.insert(_entry!);
      _isInserted = true;
    }

    final id = UniqueKey().toString();
    final isClosing = ValueNotifier<bool>(false);
    Timer? timer;
    if (snackbar.duration > Duration.zero) {
      timer = Timer(snackbar.duration, () => _beginRemove(id));
    }

    _items.value = [
      ..._items.value,
      _HuxSnackbarStackItem(
        id: id,
        snackbar: snackbar,
        timer: timer,
        isClosing: isClosing,
      ),
    ];
  }

  static void _beginRemove(String id) {
    final current = _items.value;
    final idx = current.indexWhere((e) => e.id == id);
    if (idx == -1) return;

    final item = current[idx];
    if (item.isClosing.value) return;

    item.timer?.cancel();
    item.isClosing.value = true;

    // Let the exit animation play, then remove.
    Timer(const Duration(milliseconds: 160), () => _removeById(id));
  }

  static void _removeById(String id) {
    final current = _items.value;
    final idx = current.indexWhere((e) => e.id == id);
    if (idx == -1) return;

    final item = current[idx];
    item.timer?.cancel();
    item.isClosing.dispose();

    final next = [...current]..removeAt(idx);
    _items.value = next;

    if (next.isEmpty) {
      _entry?.remove();
      _entry = null;
      _overlayState = null;
      _isInserted = false;
    }
  }

  /// Resets the controller state for testing purposes.
  @visibleForTesting
  static void resetForTest() {
    for (final item in _items.value) {
      item.timer?.cancel();
      item.isClosing.dispose();
    }
    _items.value = [];
    _entry?.remove();
    _entry = null;
    _overlayState = null;
    _isInserted = false;
  }
}

class _StackedSnackbarItemView extends StatefulWidget {
  const _StackedSnackbarItemView({required this.item});

  final _HuxSnackbarStackItem item;

  @override
  State<_StackedSnackbarItemView> createState() =>
      _StackedSnackbarItemViewState();
}

class _StackedSnackbarItemViewState extends State<_StackedSnackbarItemView> {
  @override
  void initState() {
    super.initState();
    widget.item.isClosing.addListener(_onClosingChanged);
  }

  @override
  void didUpdateWidget(covariant _StackedSnackbarItemView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.isClosing != widget.item.isClosing) {
      oldWidget.item.isClosing.removeListener(_onClosingChanged);
      widget.item.isClosing.addListener(_onClosingChanged);
    }
  }

  @override
  void dispose() {
    widget.item.isClosing.removeListener(_onClosingChanged);
    super.dispose();
  }

  void _onClosingChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // Recreate a snackbar instance with an internal close callback.
    final sb = widget.item.snackbar;
    final effective = HuxSnackbar(
      key: sb.key,
      message: sb.message,
      variant: sb.variant,
      title: sb.title,
      onDismiss: sb.onDismiss,
      onCloseRequest: () =>
          HuxSnackbarStackController._beginRemove(widget.item.id),
      showIcon: sb.showIcon,
      duration: sb.duration,
      action: sb.action,
      actions: sb.actions,
      behavior: sb.behavior,
      backgroundColor: sb.backgroundColor,
      textColor: sb.textColor,
      actionTextColor: sb.actionTextColor,
      elevation: sb.elevation,
      margin: sb.margin,
      padding: sb.padding,
      shape: sb.shape,
    );

    final closing = widget.item.isClosing.value;
    return AnimatedSlide(
      offset: closing ? const Offset(0, 0.08) : Offset.zero,
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeInOut,
      child: AnimatedOpacity(
        opacity: closing ? 0 : 1,
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeInOut,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          builder: (context, t, child) {
            return Opacity(
              opacity: t,
              child: Transform.translate(
                // Slide up from the bottom as it appears.
                offset: Offset(0, (1 - t) * 24),
                child: child,
              ),
            );
          },
          child: effective._buildBody(context),
        ),
      ),
    );
  }
}

class _HuxSnackbarStackItem {
  _HuxSnackbarStackItem({
    required this.id,
    required this.snackbar,
    required this.timer,
    required this.isClosing,
  });

  final String id;
  final HuxSnackbar snackbar;
  final Timer? timer;
  final ValueNotifier<bool> isClosing;
}
