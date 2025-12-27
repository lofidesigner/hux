import 'package:flutter/material.dart';
import 'package:hux/hux.dart';
import 'section_with_documentation.dart';

class ContextMenuSection extends StatelessWidget {
  final void Function(String) onShowSnackBar;
  final String selectedTheme;

  const ContextMenuSection({
    super.key,
    required this.onShowSnackBar,
    required this.selectedTheme,
  });

  Color _currentPrimaryColor(BuildContext context) {
    return selectedTheme == 'default'
        ? HuxTokens.primary(context)
        : HuxColors.getPresetColor(selectedTheme);
  }

  @override
  Widget build(BuildContext context) {
    return SectionWithDocumentation(
      componentName: 'context-menu',
      child: HuxCard(
        size: HuxCardSize.large,
        backgroundColor: HuxColors.white5,
        borderColor: HuxTokens.borderSecondary(context),
        title: 'Context Menu',
        subtitle: 'Right-click interactive context menus',
        child: Column(
          children: [
            const SizedBox(height: 16),
            Text(
              'Right-click on any of the items below to see the context menu:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? HuxColors.white70
                        : HuxColors.black70,
                  ),
            ),
            const SizedBox(height: 20),

            // Context Menu Examples
            LayoutBuilder(
              builder: (context, constraints) {
                final screenWidth = MediaQuery.of(context).size.width;
                final isMobileScreen = screenWidth < 768;

                return isMobileScreen
                    ? Column(
                        children: [
                          _buildDocumentCard(context),
                          const SizedBox(height: 16),
                          _buildProjectCard(context),
                        ],
                      )
                    : Row(
                        children: [
                          Expanded(child: _buildDocumentCard(context)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildProjectCard(context)),
                        ],
                      );
              },
            ),

            const SizedBox(height: 20),

            // Button with Context Menu
            HuxContextMenu(
              menuItems: [
                HuxContextMenuItem(
                  text: 'Save',
                  icon: LucideIcons.save,
                  onTap: () => onShowSnackBar('Save action triggered'),
                ),
                HuxContextMenuItem(
                  text: 'Export',
                  icon: LucideIcons.download,
                  onTap: () => onShowSnackBar('Export action triggered'),
                ),
                const HuxContextMenuDivider(),
                HuxContextMenuItem(
                  text: 'Reset',
                  icon: LucideIcons.refreshCw,
                  onTap: () => onShowSnackBar('Reset action triggered'),
                  isDestructive: true,
                ),
              ],
              child: HuxButton(
                onPressed: () => onShowSnackBar('Button clicked normally'),
                primaryColor: _currentPrimaryColor(context),
                icon: LucideIcons.settings,
                child: const Text('Right-click for More Options'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentCard(BuildContext context) {
    return HuxContextMenu(
      menuItems: [
        HuxContextMenuItem(
          text: 'Copy',
          icon: LucideIcons.copy,
          onTap: () => onShowSnackBar('Copy action triggered'),
        ),
        HuxContextMenuItem(
          text: 'Paste',
          icon: LucideIcons.clipboard,
          onTap: () => onShowSnackBar('Paste action triggered'),
          isDisabled: true,
        ),
        const HuxContextMenuDivider(),
        HuxContextMenuItem(
          text: 'Share',
          icon: LucideIcons.share2,
          onTap: () => onShowSnackBar('Share action triggered'),
        ),
      ],
      child: HuxCard(
        title: 'Document',
        subtitle: 'Right-click for options',
        child: Container(
          height: 60,
          alignment: Alignment.center,
          child: Icon(
            LucideIcons.fileText,
            size: 32,
            color: Theme.of(context).brightness == Brightness.dark
                ? HuxColors.white50
                : HuxColors.black50,
          ),
        ),
      ),
    );
  }

  Widget _buildProjectCard(BuildContext context) {
    return HuxContextMenu(
      menuItems: [
        HuxContextMenuItem(
          text: 'Edit',
          icon: LucideIcons.edit2,
          onTap: () => onShowSnackBar('Edit action triggered'),
        ),
        HuxContextMenuItem(
          text: 'Duplicate',
          icon: LucideIcons.copy,
          onTap: () => onShowSnackBar('Duplicate action triggered'),
        ),
        const HuxContextMenuDivider(),
        HuxContextMenuItem(
          text: 'Delete',
          icon: LucideIcons.trash2,
          onTap: () => onShowSnackBar('Delete action triggered'),
          isDestructive: true,
        ),
      ],
      child: HuxCard(
        title: 'Project',
        subtitle: 'Right-click for actions',
        child: Container(
          height: 60,
          alignment: Alignment.center,
          child: Icon(
            LucideIcons.folder,
            size: 32,
            color: Theme.of(context).brightness == Brightness.dark
                ? HuxColors.white50
                : HuxColors.black50,
          ),
        ),
      ),
    );
  }
}
