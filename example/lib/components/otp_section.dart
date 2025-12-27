import 'package:flutter/material.dart';
import 'package:hux/hux.dart';
import 'section_with_documentation.dart';

class OtpSection extends StatelessWidget {
  const OtpSection({
    super.key,
    required this.onShowSnackBar,
  });

  final void Function(String) onShowSnackBar;

  @override
  Widget build(BuildContext context) {
    return SectionWithDocumentation(
      componentName: 'otp',
      child: HuxCard(
        size: HuxCardSize.large,
        backgroundColor: HuxColors.white5,
        borderColor: HuxTokens.borderSecondary(context),
        title: 'OTP Input',
        subtitle: 'One-Time Password input with automatic focus management',
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = MediaQuery.of(context).size.width;
            final isMobileScreen = screenWidth < 768;
            final isTabletScreen = screenWidth >= 768 && screenWidth < 1024;
            final inputWidth = isMobileScreen
                ? constraints.maxWidth
                : isTabletScreen
                    ? constraints.maxWidth * 0.7
                    : 400.0;
            return Column(
              children: [
                const SizedBox(height: 16),

                // Basic OTP Input
                Center(
                  child: SizedBox(
                    width: inputWidth,
                    child: HuxOtpInput(
                      length: 6,
                      autofocus: false,
                      onChanged: (value) {
                        // Handle OTP change
                      },
                      onCompleted: (value) {
                        onShowSnackBar('OTP completed: $value');
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            );
          },
        ),
      ),
    );
  }
}
