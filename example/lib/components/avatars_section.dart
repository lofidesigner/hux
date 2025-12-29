import 'package:flutter/material.dart';
import 'package:hux/hux.dart';
import 'section_with_documentation.dart';

class AvatarsSection extends StatelessWidget {
  const AvatarsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SectionWithDocumentation(
      componentName: 'avatar',
      child: HuxCard(
        size: HuxCardSize.large,
        backgroundColor: HuxColors.white5,
        borderColor: HuxTokens.borderSecondary(context),
        title: 'Avatar',
        subtitle: 'User avatars and profile displays',
        child: const Column(
          children: [
            SizedBox(height: 32),

            // Avatars and avatar group inline
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  HuxAvatar(
                    name: 'John Doe',
                    size: HuxAvatarSize.small,
                  ),
                  SizedBox(width: 16),
                  HuxAvatar(
                    name: 'Lofi Designer',
                    assetImage: 'assets/lofidesigner.png', // Your custom image
                    size: HuxAvatarSize.small,
                  ),
                  SizedBox(width: 16),
                  HuxAvatar(
                    useGradient: true,
                    size: HuxAvatarSize.small,
                  ),
                  SizedBox(width: 48),
                  HuxAvatarGroup(
                    avatars: [
                      HuxAvatar(
                        useGradient: true,
                        gradientVariant: HuxAvatarGradient.bluePurple,
                      ),
                      HuxAvatar(
                        useGradient: true,
                        gradientVariant: HuxAvatarGradient.greenBlue,
                      ),
                      HuxAvatar(
                        useGradient: true,
                        gradientVariant: HuxAvatarGradient.orangeRed,
                      ),
                    ],
                    size: HuxAvatarSize.small,
                    overlap: true,
                  ),
                ],
              ),
            ),

            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
