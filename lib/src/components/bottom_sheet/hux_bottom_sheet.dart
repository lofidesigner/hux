import 'package:flutter/material.dart';
import '../../theme/hux_tokens.dart';
import '../buttons/hux_button.dart';

/// Size variants for HuxBottomSheet.
enum HuxBottomSheetSize {
  /// Small sheet taking about 25% of screen height
  small,

  /// Medium sheet taking about 50% of screen height
  medium,

  /// Large sheet taking about 75% of screen height
  large,

  /// Full screen sheet
  fullscreen,
}

/// HuxBottomSheet is a mobile-first modal component that slides up from the bottom.
///
/// Bottom sheets are the standard way to present options, forms, and content
/// on mobile devices. They are thumb-friendly and support drag gestures.
///
/// Example:
/// ```dart
/// showHuxBottomSheet(
///   context: context,
///   title: 'Options',
///   child: Column(
///     children: [
///       ListTile(title: Text('Option 1')),
///       ListTile(title: Text('Option 2')),
///     ],
///   ),
/// );
/// ```
class HuxBottomSheet extends StatelessWidget {
  /// Creates a HuxBottomSheet widget.
  const HuxBottomSheet({
    super.key,
    this.title,
    this.subtitle,
    this.child,
    this.actions,
    this.size = HuxBottomSheetSize.medium,
    this.showDragHandle = true,
    this.showCloseButton = false,
    this.padding,
  });

  /// Optional title text displayed in the sheet header
  final String? title;

  /// Optional subtitle text displayed below the title
  final String? subtitle;

  /// The main content widget to display in the sheet body
  final Widget? child;

  /// Optional list of action buttons displayed at the bottom
  final List<Widget>? actions;

  /// Size variant of the bottom sheet
  final HuxBottomSheetSize size;

  /// Whether to show a drag handle at the top
  final bool showDragHandle;

  /// Whether to show a close button in the header
  final bool showCloseButton;

  /// Custom padding for the content area
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: _getMaxHeight(context),
      ),
      decoration: BoxDecoration(
        color: HuxTokens.surfaceElevated(context),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
        border: Border(
          top: BorderSide(
            color: HuxTokens.borderPrimary(context),
            width: 1,
          ),
          left: BorderSide(
            color: HuxTokens.borderPrimary(context),
            width: 1,
          ),
          right: BorderSide(
            color: HuxTokens.borderPrimary(context),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: HuxTokens.shadowColor(context).withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (showDragHandle) _buildDragHandle(context),
          if (title != null || subtitle != null || showCloseButton)
            _buildHeader(context),
          if (child != null) _buildContent(context),
          if (actions?.isNotEmpty ?? false) _buildActions(context),
        ],
      ),
    );
  }

  /// Builds the drag handle indicator
  Widget _buildDragHandle(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 12, bottom: 8),
        width: 36,
        height: 4,
        decoration: BoxDecoration(
          color: HuxTokens.borderPrimary(context),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  /// Builds the sheet header with title and subtitle
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        showDragHandle ? 8 : 24,
        showCloseButton ? 16 : 24,
        16,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (title != null)
                  Text(
                    title!,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: HuxTokens.textPrimary(context),
                    ),
                  ),
                if (subtitle != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 14,
                        color: HuxTokens.textSecondary(context),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (showCloseButton)
            HuxButton(
              onPressed: () => Navigator.of(context).pop(),
              variant: HuxButtonVariant.ghost,
              size: HuxButtonSize.small,
              width: HuxButtonWidth.hug,
              icon: Icons.close,
              child: const SizedBox.shrink(),
            ),
        ],
      ),
    );
  }

  /// Builds the sheet content area
  Widget _buildContent(BuildContext context) {
    return Flexible(
      child: SingleChildScrollView(
        padding: padding ?? const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: child ?? const SizedBox.shrink(),
      ),
    );
  }

  /// Builds the sheet actions area
  Widget _buildActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: HuxTokens.borderSecondary(context),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: _buildActionButtons(),
        ),
      ),
    );
  }

  /// Builds the action buttons with proper spacing
  List<Widget> _buildActionButtons() {
    final List<Widget> buttons = [];
    final actionsList = actions ?? [];

    for (int i = 0; i < actionsList.length; i++) {
      if (i > 0) {
        buttons.add(const SizedBox(width: 12));
      }
      buttons.add(actionsList[i]);
    }

    return buttons;
  }

  /// Gets the maximum height based on the sheet size
  double _getMaxHeight(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    switch (size) {
      case HuxBottomSheetSize.small:
        return screenHeight * 0.3;
      case HuxBottomSheetSize.medium:
        return screenHeight * 0.5;
      case HuxBottomSheetSize.large:
        return screenHeight * 0.85;
      case HuxBottomSheetSize.fullscreen:
        return screenHeight;
    }
  }
}

/// Shows a HuxBottomSheet with the specified properties.
///
/// This is a convenience function that wraps the HuxBottomSheet widget
/// in a showModalBottomSheet call for easy usage.
///
/// Example:
/// ```dart
/// final result = await showHuxBottomSheet<bool>(
///   context: context,
///   title: 'Confirm Action',
///   child: Text('Are you sure?'),
///   actions: [
///     HuxButton(
///       onPressed: () => Navigator.of(context).pop(false),
///       variant: HuxButtonVariant.secondary,
///       child: Text('Cancel'),
///     ),
///     HuxButton(
///       onPressed: () => Navigator.of(context).pop(true),
///       child: Text('Confirm'),
///     ),
///   ],
/// );
/// ```
Future<T?> showHuxBottomSheet<T>({
  required BuildContext context,
  String? title,
  String? subtitle,
  Widget? child,
  List<Widget>? actions,
  HuxBottomSheetSize size = HuxBottomSheetSize.medium,
  bool showDragHandle = true,
  bool showCloseButton = false,
  bool isDismissible = true,
  bool enableDrag = true,
  bool isScrollControlled = true,
  bool useSafeArea = true,
  EdgeInsets? padding,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    isScrollControlled: isScrollControlled,
    useSafeArea: useSafeArea,
    backgroundColor: Colors.transparent,
    barrierColor: HuxTokens.overlay(context),
    builder: (context) => HuxBottomSheet(
      title: title,
      subtitle: subtitle,
      actions: actions,
      size: size,
      showDragHandle: showDragHandle,
      showCloseButton: showCloseButton,
      padding: padding,
      child: child,
    ),
  );
}

/// An action item for use with HuxActionSheet.
class HuxActionSheetItem {
  /// Creates an action sheet item.
  const HuxActionSheetItem({
    required this.label,
    required this.onTap,
    this.icon,
    this.isDestructive = false,
    this.isDisabled = false,
  });

  /// The text label for the action
  final String label;

  /// Callback when the action is tapped
  final VoidCallback onTap;

  /// Optional icon to display before the label
  final IconData? icon;

  /// Whether this is a destructive action (styled in red)
  final bool isDestructive;

  /// Whether this action is disabled
  final bool isDisabled;
}

/// Shows an iOS-style action sheet with a list of actions.
///
/// This is the mobile-first alternative to context menus, presenting
/// options from the bottom of the screen.
///
/// Example:
/// ```dart
/// showHuxActionSheet(
///   context: context,
///   title: 'Share Photo',
///   actions: [
///     HuxActionSheetItem(
///       label: 'Save to Gallery',
///       icon: Icons.save_alt,
///       onTap: () => savePhoto(),
///     ),
///     HuxActionSheetItem(
///       label: 'Share',
///       icon: Icons.share,
///       onTap: () => sharePhoto(),
///     ),
///     HuxActionSheetItem(
///       label: 'Delete',
///       icon: Icons.delete,
///       isDestructive: true,
///       onTap: () => deletePhoto(),
///     ),
///   ],
///   cancelLabel: 'Cancel',
/// );
/// ```
Future<void> showHuxActionSheet({
  required BuildContext context,
  required List<HuxActionSheetItem> actions,
  String? title,
  String? subtitle,
  String cancelLabel = 'Cancel',
  bool showCancel = true,
}) {
  return showHuxBottomSheet(
    context: context,
    title: title,
    subtitle: subtitle,
    size: HuxBottomSheetSize.small,
    showDragHandle: true,
    showCloseButton: false,
    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ...actions.map((action) => _ActionSheetTile(action: action)),
        if (showCancel) ...[
          const SizedBox(height: 8),
          DecoratedBox(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: HuxTokens.borderSecondary(context),
                  width: 1,
                ),
              ),
            ),
            child: _ActionSheetTile(
              action: HuxActionSheetItem(
                label: cancelLabel,
                onTap: () => Navigator.of(context).pop(),
              ),
              isCancelButton: true,
            ),
          ),
        ],
      ],
    ),
  );
}

/// Internal widget for rendering action sheet items
class _ActionSheetTile extends StatelessWidget {
  const _ActionSheetTile({
    required this.action,
    this.isCancelButton = false,
  });

  final HuxActionSheetItem action;
  final bool isCancelButton;

  @override
  Widget build(BuildContext context) {
    final Color textColor;
    if (action.isDisabled) {
      textColor = HuxTokens.textDisabled(context);
    } else if (action.isDestructive) {
      textColor = HuxTokens.destructive(context);
    } else {
      textColor = HuxTokens.textPrimary(context);
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: action.isDisabled
            ? null
            : () {
                Navigator.of(context).pop();
                action.onTap();
              },
        borderRadius: BorderRadius.circular(12),
        splashColor: HuxTokens.surfaceHover(context),
        highlightColor: HuxTokens.surfaceHover(context),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: isCancelButton ? 16 : 14,
          ),
          child: Row(
            children: [
              if (action.icon != null) ...[
                Icon(
                  action.icon,
                  size: 20,
                  color: textColor,
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Text(
                  action.label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight:
                        isCancelButton ? FontWeight.w600 : FontWeight.w500,
                    color: textColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
