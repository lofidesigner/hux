import 'package:flutter/material.dart';
import 'package:hux/hux.dart';
import 'section_with_documentation.dart';

class BottomSheetSection extends StatelessWidget {
  const BottomSheetSection({
    super.key,
    required this.onShowSnackBar,
  });

  final void Function(String) onShowSnackBar;

  @override
  Widget build(BuildContext context) {
    return SectionWithDocumentation(
      componentName: 'bottom-sheet',
      child: HuxCard(
        size: HuxCardSize.large,
        backgroundColor: HuxColors.white5,
        borderColor: HuxTokens.borderSecondary(context),
        title: 'Bottom Sheet',
        subtitle: 'Mobile-first modal component for options and content',
        child: Column(
          children: [
            const SizedBox(height: 32),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: [
                HuxButton(
                  onPressed: () =>
                      showSettingsBottomSheet(context, onShowSnackBar),
                  variant: HuxButtonVariant.outline,
                  child: const Text('Show Bottom Sheet'),
                ),
                HuxButton(
                  onPressed: () => showActionSheet(context, onShowSnackBar),
                  variant: HuxButtonVariant.outline,
                  child: const Text('Show Action Sheet'),
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  static void showSettingsBottomSheet(
    BuildContext context,
    void Function(String) onShowSnackBar,
  ) {
    bool notifications = true;
    bool darkMode = false;
    bool privacy = false;

    showHuxBottomSheet(
      context: context,
      title: 'Settings',
      subtitle: 'Customize your preferences',
      size: HuxBottomSheetSize.medium,
      child: StatefulBuilder(
        builder: (context, setModalState) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSettingsOptionStateful(
                context,
                'Notifications',
                'Receive push notifications',
                LucideIcons.bell,
                notifications,
                (v) => setModalState(() => notifications = v),
              ),
              _buildSettingsOptionStateful(
                context,
                'Dark Mode',
                'Use dark theme',
                LucideIcons.moon,
                darkMode,
                (v) => setModalState(() => darkMode = v),
              ),
              _buildSettingsOptionStateful(
                context,
                'Privacy',
                'Manage your privacy settings',
                LucideIcons.shield,
                privacy,
                (v) => setModalState(() => privacy = v),
              ),
            ],
          );
        },
      ),
      actions: [
        HuxButton(
          onPressed: () => Navigator.pop(context),
          variant: HuxButtonVariant.secondary,
          child: const Text('Cancel'),
        ),
        HuxButton(
          onPressed: () {
            Navigator.pop(context);
            onShowSnackBar('Settings saved!');
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  static void showActionSheet(
    BuildContext context,
    void Function(String) onShowSnackBar,
  ) {
    showHuxActionSheet(
      context: context,
      title: 'Share Photo',
      subtitle: 'Choose how to share this photo',
      actions: [
        HuxActionSheetItem(
          label: 'Save to Gallery',
          icon: LucideIcons.download,
          onTap: () {
            Navigator.pop(context);
            onShowSnackBar('Saved to gallery');
          },
        ),
        HuxActionSheetItem(
          label: 'Copy Link',
          icon: LucideIcons.link,
          onTap: () {
            Navigator.pop(context);
            onShowSnackBar('Link copied');
          },
        ),
        HuxActionSheetItem(
          label: 'Share',
          icon: LucideIcons.share2,
          onTap: () {
            Navigator.pop(context);
            onShowSnackBar('Shared!');
          },
        ),
        HuxActionSheetItem(
          label: 'Delete',
          icon: LucideIcons.trash2,
          isDestructive: true,
          onTap: () {
            Navigator.pop(context);
            onShowSnackBar('Deleted!');
          },
        ),
      ],
    );
  }

  static Widget _buildSettingsOptionStateful(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: HuxTokens.surfaceSecondary(context),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: HuxTokens.iconPrimary(context)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: HuxTokens.textPrimary(context),
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: HuxTokens.textSecondary(context),
                  ),
                ),
              ],
            ),
          ),
          HuxSwitch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
