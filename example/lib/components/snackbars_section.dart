import 'package:flutter/material.dart';
import 'package:hux/hux.dart';
import 'section_with_documentation.dart';

class SnackbarsSection extends StatefulWidget {
  const SnackbarsSection({super.key});

  @override
  State<SnackbarsSection> createState() => _SnackbarsSectionState();
}

class _SnackbarsSectionState extends State<SnackbarsSection> {
  bool _showIcon = true;
  bool _showActions = false;

  List<HuxSnackbarAction>? _actionsForDemo() {
    if (!_showActions) return null;
    return [
      HuxSnackbarAction(
        label: 'Undo',
        onPressed: () {
          // Demo: no-op
        },
      ),
    ];
  }

  VoidCallback? _dismissForDemo() => _showActions ? null : () {};

  void _showDemoSnackbar({
    required HuxSnackbarVariant variant,
    required String title,
    required String message,
  }) {
    final sb = HuxSnackbar(
      title: title,
      message: message,
      variant: variant,
      showIcon: _showIcon,
      actions: _actionsForDemo(),
      onDismiss: _dismissForDemo(),
    );

    // Example app always stacks snackbars for easy visual testing.
    HuxSnackbarStackController.of(context).show(sb);
  }

  @override
  Widget build(BuildContext context) {
    return SectionWithDocumentation(
      componentName: 'snackbar',
      child: HuxCard(
        size: HuxCardSize.large,
        backgroundColor: HuxColors.white5,
        borderColor: HuxTokens.borderSecondary(context),
        title: 'Snackbar',
        subtitle: 'Temporary notification messages for user actions and status',
        action: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Show icon:',
                  style: TextStyle(color: HuxTokens.textSecondary(context)),
                ),
                const SizedBox(width: 8),
                HuxSwitch(
                  value: _showIcon,
                  onChanged: (value) {
                    setState(() {
                      _showIcon = value;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(width: 16),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Actions:',
                  style: TextStyle(color: HuxTokens.textSecondary(context)),
                ),
                const SizedBox(width: 8),
                HuxSwitch(
                  value: _showActions,
                  onChanged: (value) {
                    setState(() {
                      _showActions = value;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Center(
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  HuxButton(
                    onPressed: () {
                      _showDemoSnackbar(
                        variant: HuxSnackbarVariant.info,
                        title: 'Default',
                        message: 'This is the default snackbar style.',
                      );
                    },
                    child: const Text('Default'),
                  ),
                  HuxButton(
                    onPressed: () {
                      _showDemoSnackbar(
                        variant: HuxSnackbarVariant.success,
                        title: 'Success',
                        message: 'Your operation completed successfully!',
                      );
                    },
                    child: const Text('Success'),
                  ),
                  HuxButton(
                    onPressed: () {
                      _showDemoSnackbar(
                        variant: HuxSnackbarVariant.error,
                        title: 'Destructive',
                        message: 'Item deleted. You can undo this action.',
                      );
                    },
                    child: const Text('Destructive'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
