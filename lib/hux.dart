/// Hux UI - A modern Flutter UI package with beautiful, customizable components
///
/// Hux provides a comprehensive set of UI components designed for clean and
/// consistent user interfaces. Features include:
///
/// - Modern button components with multiple variants and WCAG AA contrast
/// - Flexible card components with semantic tokens
/// - Enhanced text input fields with validation support
/// - Multi-line textarea component with character count support
/// - Customizable slider component with smooth animations
/// - Customizable loading indicators with theme awareness
/// - Progress indicators for task completion and status tracking
/// - Beautiful data visualization charts with cristalyse integration
/// - Right-click context menus with smart positioning
/// - Pre-configured light and dark themes
/// - Design token system for consistent theming
/// - Optimized web experience with clean context menus
///
/// ## Usage
///
/// ```dart
/// import 'package:flutter/material.dart';
/// import 'package:hux/hux.dart';
///
/// class MyApp extends StatelessWidget {
///   @override
///   Widget build(BuildContext context) {
///     return MaterialApp(
///       theme: HuxTheme.lightTheme,
///       darkTheme: HuxTheme.darkTheme,
///       home: Scaffold(
///         body: Column(
///           children: [
///             HuxButton(
///               onPressed: () {},
///               child: Text('Primary Button'),
///             ),
///             HuxInput(label: 'Email'),
///             HuxCard(title: 'Card Title'),
///           ],
///         ),
///       ),
///     );
///   }
/// }
/// ```
library;

// Export all components
export 'src/components/buttons/hux_button.dart';
export 'src/components/cards/hux_card.dart';
export 'src/components/inputs/hux_input.dart';
export 'src/components/inputs/hux_textarea.dart';
export 'src/components/inputs/hux_date_input.dart';
export 'src/components/inputs/hux_checkbox.dart';
export 'src/components/inputs/hux_radio.dart';
export 'src/components/otp/hux_otp_input.dart';
export 'src/components/switch/hux_switch.dart';
export 'src/components/slider/hux_slider.dart';
export 'src/components/badge/hux_badge.dart';
export 'src/components/feedback/hux_alert.dart';
export 'src/components/feedback/hux_snackbar.dart';
export 'src/components/avatar/hux_avatar.dart';
export 'src/components/avatar/hux_avatar_group.dart';
export 'src/components/tabs/hux_tabs.dart';
export 'src/components/tooltip/hux_tooltip.dart';
export 'src/theme/hux_theme.dart';
export 'src/theme/hux_colors.dart';
export 'src/theme/hux_tokens.dart';
export 'src/utils/hux_wcag.dart';
export 'src/widgets/hux_loading.dart';
export 'src/widgets/hux_chart.dart';
export 'src/widgets/hux_context_menu/hux_context_menu.dart';
export 'src/widgets/hux_context_menu/hux_context_menu_item.dart';
export 'src/widgets/hux_context_menu/hux_context_menu_divider.dart';
export 'src/widgets/hux_date_picker.dart';
export 'src/widgets/hux_time_picker.dart';
export 'src/components/dialog/hux_dialog.dart';
export 'src/components/dropdown/hux_dropdown.dart';
export 'src/components/pagination/hux_pagination.dart';
export 'src/components/toggle/hux_toggle.dart';
export 'src/components/command/hux_command.dart';
export 'src/components/command/hux_command_item.dart';
export 'src/components/command/hux_command_shortcuts.dart';
export 'src/components/navigation/hux_sidebar.dart';
export 'src/components/navigation/hux_sidebar_item.dart';
export 'src/components/navigation/hux_breadcrumbs.dart';
export 'src/components/progress/hux_progress.dart';
export 'src/components/bottom_sheet/hux_bottom_sheet.dart';

// Export external dependencies
/// LucideIcons - Beautiful icon set for Flutter applications
///
/// Provides access to over 1000+ beautiful, customizable SVG icons.
/// Use LucideIcons.iconName to access any icon.
///
/// Example:
/// ```dart
/// Icon(LucideIcons.heart)
/// Icon(LucideIcons.user)
/// ```
export 'package:lucide_icons/lucide_icons.dart';
