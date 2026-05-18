import 'package:flutter/material.dart';
import '../../theme/hux_tokens.dart';
import '../../theme/hux_variant.dart';
import '../buttons/hux_button.dart';

/// Visual variants for HuxDialog.
enum HuxDialogVariant {
  /// Default dialog styling
  default_,

  /// Destructive dialog styling for dangerous actions
  destructive,

  /// Success dialog styling for positive confirmations
  success,

  /// Warning dialog styling for cautionary messages
  warning,
}

/// Size variants for HuxDialog.
enum HuxDialogSize {
  /// Small dialog for simple confirmations
  small,

  /// Medium dialog for standard content (default)
  medium,

  /// Large dialog for complex content
  large,

  /// Extra large dialog for extensive content
  extraLarge,
}

/// HuxDialog is a customizable dialog component that provides a consistent
/// modal experience with optional header, content, and action buttons.
///
/// The dialog automatically adapts to light and dark themes and provides
/// a clean, modern appearance with proper spacing and accessibility.
///
/// Example:
/// ```dart
/// HuxDialog(
///   title: 'Confirm Action',
///   content: Text('Are you sure you want to proceed?'),
///   actions: [
///     HuxButton(
///       onPressed: () => Navigator.of(context).pop(false),
///       child: Text('Cancel'),
///       variant: HuxButtonVariant.secondary,
///     ),
///     HuxButton(
///       onPressed: () => Navigator.of(context).pop(true),
///       child: Text('Confirm'),
///     ),
///   ],
/// )
/// ```
class HuxDialog extends StatelessWidget {
  /// Creates a HuxDialog widget.
  const HuxDialog({
    super.key,
    this.title,
    this.subtitle,
    this.content,
    this.actions,
    this.variant = HuxDialogVariant.default_,
    this.size = HuxDialogSize.medium,
    this.showCloseButton = true,
    this.barrierDismissible = true,
    this.clipBehavior = Clip.antiAlias,
    this.shape,
    this.constraints,
    this.alignment,
    this.insetPadding =
        const EdgeInsets.symmetric(horizontal: 40.0, vertical: 24.0),
  });

  /// Optional title text displayed in the dialog header
  final String? title;

  /// Optional subtitle text displayed below the title
  final String? subtitle;

  /// The main content widget to display in the dialog body
  final Widget? content;

  /// Optional list of action buttons displayed at the bottom
  final List<Widget>? actions;

  /// Visual variant of the dialog
  final HuxDialogVariant variant;

  /// Size variant of the dialog
  final HuxDialogSize size;

  /// Whether to show a close button in the header
  final bool showCloseButton;

  /// Whether the dialog can be dismissed by tapping outside
  final bool barrierDismissible;

  /// How to clip the dialog content
  final Clip clipBehavior;

  /// Custom shape for the dialog
  final ShapeBorder? shape;

  /// Constraints for the dialog size
  final BoxConstraints? constraints;

  /// Alignment of the dialog within the available space
  final AlignmentGeometry? alignment;

  /// Padding around the dialog content
  final EdgeInsets? insetPadding;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      clipBehavior: clipBehavior,
      shape: shape ?? _getDefaultShape(context),
      insetPadding: insetPadding,
      child: ConstrainedBox(
        constraints: _getDefaultConstraints(),
        child: _buildDialogContent(context),
      ),
    );
  }

  /// Builds the main dialog content with proper styling
  Widget _buildDialogContent(BuildContext context) {
    return Stack(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: HuxTokens.surfaceElevated(context),
            borderRadius: BorderRadius.circular(_getBorderRadius(context)),
            border: Border.all(
              color: HuxTokens.borderPrimary(context),
              width: HuxTokens.borderWidth(context),
            ),
            boxShadow: HuxTokens.shadowElevated(context),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title != null || subtitle != null) _buildHeader(context),
              if (content != null) _buildContent(context),
              if (actions?.isNotEmpty ?? false) _buildActions(context),
            ],
          ),
        ),
        if (showCloseButton)
          Positioned(
            top: 16,
            right: 16,
            child: HuxButton(
              onPressed: () => Navigator.of(context).pop(),
              variant: HuxButtonVariant.ghost,
              size: HuxButtonSize.small,
              width: HuxButtonWidth.hug,
              icon: Icons.close,
              child: const SizedBox.shrink(),
            ),
          ),
      ],
    );
  }

  /// Builds the dialog header with title and subtitle
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null)
            Text(
              title!,
              style: TextStyle(
                fontSize: _getTitleFontSize(),
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
    );
  }

  /// Builds the dialog content area
  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: content ?? const SizedBox.shrink(),
    );
  }

  /// Builds the dialog actions area
  Widget _buildActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: _buildActionButtons(context),
      ),
    );
  }

  /// Builds the action buttons with proper spacing
  List<Widget> _buildActionButtons(BuildContext context) {
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

  /// Gets the default shape for the dialog
  ShapeBorder _getDefaultShape(BuildContext context) {
    return RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(_getBorderRadius(context)),
    );
  }

  /// Gets the default constraints based on the dialog size
  BoxConstraints _getDefaultConstraints() {
    switch (size) {
      case HuxDialogSize.small:
        return const BoxConstraints(
          maxWidth: 400,
          minWidth: 300,
        );
      case HuxDialogSize.medium:
        return const BoxConstraints(
          maxWidth: 500,
          minWidth: 350,
        );
      case HuxDialogSize.large:
        return const BoxConstraints(
          maxWidth: 700,
          minWidth: 500,
        );
      case HuxDialogSize.extraLarge:
        return const BoxConstraints(
          maxWidth: 900,
          minWidth: 700,
        );
    }
  }

  /// Gets the border radius based on the dialog size
  double _getBorderRadius(BuildContext context) {
    if (HuxScope.of(context) == HuxVariant.brutalist) return 0;
    switch (size) {
      case HuxDialogSize.small:
        return 12;
      case HuxDialogSize.medium:
        return 16;
      case HuxDialogSize.large:
        return 20;
      case HuxDialogSize.extraLarge:
        return 24;
    }
  }

  /// Gets the title font size based on the dialog size
  double _getTitleFontSize() {
    switch (size) {
      case HuxDialogSize.small:
        return 18;
      case HuxDialogSize.medium:
        return 20;
      case HuxDialogSize.large:
        return 22;
      case HuxDialogSize.extraLarge:
        return 24;
    }
  }
}

/// Shows a HuxDialog with the specified properties.
///
/// This is a convenience function that wraps the HuxDialog widget
/// in a showDialog call for easy usage.
///
/// Example:
/// ```dart
/// final bool? result = await showHuxDialog<bool>(
///   context: context,
///   title: 'Confirm Action',
///   content: Text('Are you sure?'),
///   actions: [
///     HuxButton(
///       onPressed: () => Navigator.of(context).pop(false),
///       child: Text('Cancel'),
///       variant: HuxButtonVariant.secondary,
///     ),
///     HuxButton(
///       onPressed: () => Navigator.of(context).pop(true),
///       child: Text('Confirm'),
///     ),
///   ],
/// );
/// ```
Future<T?> showHuxDialog<T>({
  required BuildContext context,
  String? title,
  String? subtitle,
  Widget? content,
  List<Widget>? actions,
  HuxDialogVariant variant = HuxDialogVariant.default_,
  HuxDialogSize size = HuxDialogSize.medium,
  bool showCloseButton = true,
  bool barrierDismissible = true,
  Clip clipBehavior = Clip.antiAlias,
  ShapeBorder? shape,
  BoxConstraints? constraints,
  AlignmentGeometry? alignment,
  EdgeInsets? insetPadding,
}) {
  return showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierColor: HuxTokens.overlay(context),
    builder: (context) => HuxDialog(
      title: title,
      subtitle: subtitle,
      content: content,
      actions: actions,
      variant: variant,
      size: size,
      showCloseButton: showCloseButton,
      barrierDismissible: barrierDismissible,
      clipBehavior: clipBehavior,
      shape: shape,
      constraints: constraints,
      alignment: alignment,
      insetPadding: insetPadding ??
          const EdgeInsets.symmetric(horizontal: 40.0, vertical: 24.0),
    ),
  );
}
