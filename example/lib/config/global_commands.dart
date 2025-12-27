import 'package:flutter/material.dart';
import 'package:hux/hux.dart';
import '../components/bottom_sheet_section.dart';

/// Global commands configuration for the command palette
class GlobalCommands {
  static List<HuxCommandItem> getCommands(
    BuildContext context,
    VoidCallback toggleTheme,
    void Function() showSettingsBottomSheet,
    void Function() showActionSheet,
  ) {
    return [
      HuxCommandItem(
        id: 'toggle-theme',
        label: 'Toggle Theme',
        description: 'Switch between light and dark theme',
        shortcut: '⌘⇧D',
        icon: LucideIcons.sun,
        category: 'View',
        onExecute: toggleTheme,
      ),
      HuxCommandItem(
        id: 'open-command-palette',
        label: 'Open Command Palette',
        description: 'Open the command palette',
        shortcut: '⌘⇧K',
        icon: LucideIcons.command,
        category: 'Navigation',
        onExecute: () {
          showHuxCommand(
            context: context,
            commands: getCommands(
              context,
              toggleTheme,
              showSettingsBottomSheet,
              showActionSheet,
            ),
            onCommandSelected: (command) {
              context.showHuxSnackbar(
                message: 'Command executed: ${command.label}',
                variant: HuxSnackbarVariant.info,
              );
            },
          );
        },
      ),
      HuxCommandItem(
        id: 'help',
        label: 'Help',
        description: 'Open help documentation',
        shortcut: '⌘H',
        icon: LucideIcons.helpCircle,
        category: 'Help',
        onExecute: () {
          context.showHuxSnackbar(
            message: 'Help opened',
            variant: HuxSnackbarVariant.info,
          );
        },
      ),
      HuxCommandItem(
        id: 'show-bottom-sheet',
        label: 'Show Bottom Sheet',
        description: 'Open example settings bottom sheet',
        icon: LucideIcons.panelBottom,
        category: 'Components',
        onExecute: showSettingsBottomSheet,
      ),
      HuxCommandItem(
        id: 'show-action-sheet',
        label: 'Show Action Sheet',
        description: 'Open example share action sheet',
        icon: LucideIcons.share2,
        category: 'Components',
        onExecute: showActionSheet,
      ),
    ];
  }

  static void showSettingsBottomSheet(BuildContext context) {
    BottomSheetSection.showSettingsBottomSheet(context, (message) {
      context.showHuxSnackbar(
        message: message,
        variant: HuxSnackbarVariant.info,
      );
    });
  }

  static void showActionSheet(BuildContext context) {
    BottomSheetSection.showActionSheet(context, (message) {
      context.showHuxSnackbar(
        message: message,
        variant: HuxSnackbarVariant.info,
      );
    });
  }
}
