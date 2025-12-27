import 'package:flutter/material.dart';
import 'package:hux/hux.dart';
import 'section_with_documentation.dart';

class DialogSection extends StatelessWidget {
  const DialogSection({super.key, required this.onShowConfirmationDialog});

  final void Function(BuildContext context) onShowConfirmationDialog;

  @override
  Widget build(BuildContext context) {
    return SectionWithDocumentation(
      componentName: 'dialog',
      child: HuxCard(
        size: HuxCardSize.large,
        backgroundColor: HuxColors.white5,
        borderColor: HuxTokens.borderSecondary(context),
        title: 'Dialog',
        subtitle: 'Modal dialogs with Hux styling',
        child: Column(
          children: [
            const SizedBox(height: 32),
            Center(
              child: HuxButton(
                onPressed: () => onShowConfirmationDialog(context),
                variant: HuxButtonVariant.outline,
                child: const Text('Show Confirmation Dialog'),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
