import 'package:flutter/material.dart';
import 'package:hux/hux.dart';
import 'section_with_documentation.dart';

class SnackbarsSection extends StatelessWidget {
  const SnackbarsSection({super.key});

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
        child: Column(
          children: [
            const SizedBox(height: 16),

            // Information Snackbar
            Center(
              child: HuxAlert(
                variant: HuxAlertVariant.info,
                title: 'Information',
                message: 'This is an informational message.',
                showIcon: true,
                onDismiss: () {
                  context.showHuxSnackbar(
                    message: 'Information alert dismissed',
                    variant: HuxSnackbarVariant.info,
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // Success Alert
            Center(
              child: HuxAlert(
                variant: HuxAlertVariant.success,
                title: 'Success',
                message: 'Your operation completed successfully!',
                showIcon: true,
                onDismiss: () {
                  context.showHuxSnackbar(
                    message: 'Success alert dismissed',
                    variant: HuxSnackbarVariant.success,
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // Destructive Alert
            Center(
              child: HuxAlert(
                variant: HuxAlertVariant.error,
                title: 'Destructive',
                message:
                    'This action cannot be undone. Please proceed with caution.',
                showIcon: true,
                onDismiss: () {
                  context.showHuxSnackbar(
                    message: 'Destructive alert dismissed',
                    variant: HuxSnackbarVariant.error,
                  );
                },
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
