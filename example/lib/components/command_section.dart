import 'package:flutter/material.dart';
import 'package:hux/hux.dart';
import 'section_with_documentation.dart';

class CommandSection extends StatefulWidget {
  final VoidCallback? onThemeToggle;

  const CommandSection({super.key, this.onThemeToggle});

  @override
  State<CommandSection> createState() => _CommandSectionState();
}

class _CommandSectionState extends State<CommandSection> {
  late final List<HuxCommandItem> _commands;

  @override
  void initState() {
    super.initState();
    _commands = [
      HuxCommandItem(
        id: 'toggle-theme',
        label: 'Toggle Theme',
        description: 'Switch between light and dark mode',
        shortcut: '⌘⇧D',
        icon: LucideIcons.sun,
        category: 'View',
        onExecute: () {
          widget.onThemeToggle?.call();
          _showSnackBar('Theme toggled');
        },
      ),
      HuxCommandItem(
        id: 'quick-search',
        label: 'Quick Search',
        description: 'Search across all content',
        shortcut: '⌘⇧K',
        icon: LucideIcons.search,
        category: 'Navigation',
        onExecute: () => _showSnackBar('Quick search opened'),
      ),
      HuxCommandItem(
        id: 'new-project',
        label: 'New Project',
        description: 'Create a new project',
        shortcut: '⌘⇧N',
        icon: LucideIcons.folderPlus,
        category: 'Project',
        onExecute: () => _showSnackBar('New project created'),
      ),
      HuxCommandItem(
        id: 'settings',
        label: 'Settings',
        description: 'Open application settings',
        shortcut: '⌘,',
        icon: LucideIcons.settings,
        category: 'Preferences',
        onExecute: () => _showSnackBar('Settings opened'),
      ),
      HuxCommandItem(
        id: 'help',
        label: 'Help & Support',
        description: 'View help documentation',
        shortcut: '⌘H',
        icon: LucideIcons.helpCircle,
        category: 'Help',
        onExecute: () {
          _showSnackBar('Help documentation would open here');
        },
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
            commands: _commands,
            onCommandSelected: (command) {
              _showSnackBar('Command executed: ${command.label}');
            },
          );
        },
      ),
    ];
  }

  void _showSnackBar(String message) {
    context.showHuxSnackbar(
      message: message,
      variant: HuxSnackbarVariant.info,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SectionWithDocumentation(
      componentName: 'command',
      child: HuxCard(
        size: HuxCardSize.large,
        backgroundColor: HuxColors.white5,
        borderColor: HuxTokens.borderSecondary(context),
        title: 'Command Palette',
        subtitle: 'Quick access to commands via CMD+K or action button',
        child: Column(
          children: [
            const SizedBox(height: 16),
            Text(
              'Press CMD+K (or Ctrl+K) to open the command palette, or click the button below:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: HuxTokens.textSecondary(context),
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Center(
              child: HuxButton(
                onPressed: () => showHuxCommand(
                  context: context,
                  commands: _commands,
                  onCommandSelected: (command) {
                    _showSnackBar('Command executed: ${command.label}');
                  },
                ),
                icon: LucideIcons.command,
                child: const Text('Open Command Palette'),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
