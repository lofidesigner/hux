import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:hux/hux.dart';

/// Wrapper widget that adds a documentation button to component sections
class SectionWithDocumentation extends StatelessWidget {
  final Widget child;
  final String componentName;

  const SectionWithDocumentation({
    super.key,
    required this.child,
    required this.componentName,
  });

  Widget _buildDocumentationButton(BuildContext context) {
    return Align(
      alignment: Alignment.bottomLeft,
      child: HuxButton(
        onPressed: () async {
          final url = Uri.parse(
            'https://docs.thehuxdesign.com/components/$componentName',
          );
          if (await canLaunchUrl(url)) {
            await launchUrl(url, mode: LaunchMode.externalApplication);
          }
        },
        variant: HuxButtonVariant.ghost,
        size: HuxButtonSize.small,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: Theme.of(context).brightness == Brightness.dark
                  ? SvgPicture.asset(
                      'assets/doc.svg',
                      width: 18,
                      height: 18,
                      colorFilter: const ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcIn,
                      ),
                    )
                  : SvgPicture.asset(
                      'assets/doc.svg',
                      width: 18,
                      height: 18,
                      colorFilter: ColorFilter.mode(
                        HuxTokens.buttonSecondaryText(context),
                        BlendMode.srcIn,
                      ),
                    ),
            ),
            const SizedBox(width: 8),
            const Text('Documentation'),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // If child is a HuxCard, modify its child to include the button
    if (child is HuxCard) {
      final card = child as HuxCard;
      return HuxCard(
        key: card.key,
        title: card.title,
        subtitle: card.subtitle,
        action: card.action,
        size: card.size,
        padding: card.padding,
        margin: card.margin,
        elevation: card.elevation,
        borderRadius: card.borderRadius,
        backgroundColor: card.backgroundColor,
        borderColor: card.borderColor,
        borderWidth: card.borderWidth,
        onTap: card.onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            card.child,
            const SizedBox(height: 16),
            _buildDocumentationButton(context),
          ],
        ),
      );
    }

    // For other widgets, wrap in a Stack
    return Stack(
      clipBehavior: Clip.hardEdge,
      children: [
        child,
        Positioned(
          bottom: 0,
          left: 0,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: _buildDocumentationButton(context),
          ),
        ),
      ],
    );
  }
}
