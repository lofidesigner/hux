import 'package:flutter/material.dart';
import 'package:hux/hux.dart';
import 'section_with_documentation.dart';

class ButtonsSection extends StatefulWidget {
  final void Function(String) onShowSnackBar;
  final String selectedTheme;

  const ButtonsSection({
    super.key,
    required this.onShowSnackBar,
    required this.selectedTheme,
  });

  @override
  State<ButtonsSection> createState() => _ButtonsSectionState();
}

class _ButtonsSectionState extends State<ButtonsSection> {
  HuxButtonSize _selectedButtonSize = HuxButtonSize.medium;
  bool _showIconButtons = true;

  Color _currentPrimaryColor(BuildContext context) =>
      widget.selectedTheme == 'default'
          ? HuxTokens.primary(context)
          : HuxColors.getPresetColor(widget.selectedTheme);

  Widget _buildSizeButton(String label, HuxButtonSize size) {
    final isSelected = _selectedButtonSize == size;

    return HuxButton(
      onPressed: () {
        setState(() {
          _selectedButtonSize = size;
        });
      },
      variant: isSelected ? HuxButtonVariant.primary : HuxButtonVariant.outline,
      size: HuxButtonSize.small,
      width: HuxButtonWidth.fixed,
      widthValue: 40,
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SectionWithDocumentation(
      componentName: 'buttons',
      child: HuxCard(
        size: HuxCardSize.large,
        backgroundColor: HuxColors.white5,
        borderColor: HuxTokens.borderSecondary(context),
        title: 'Buttons',
        subtitle: 'Different button variants and sizes',
        action: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Size buttons group
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildSizeButton('S', HuxButtonSize.small),
                const SizedBox(width: 8),
                _buildSizeButton('M', HuxButtonSize.medium),
                const SizedBox(width: 8),
                _buildSizeButton('L', HuxButtonSize.large),
              ],
            ),
            const SizedBox(width: 16),
            // Show icons switch group
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Show icons:',
                  style: TextStyle(
                    color: HuxTokens.textSecondary(context),
                  ),
                ),
                const SizedBox(width: 8),
                HuxSwitch(
                  value: _showIconButtons,
                  onChanged: (value) {
                    setState(() {
                      _showIconButtons = value;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
        child: Column(
          children: [
            const SizedBox(height: 36),

            // Button Variants - Responsive Height Container
            LayoutBuilder(
              builder: (context, constraints) {
                final screenWidth = MediaQuery.of(context).size.width;
                final isMobile = screenWidth < 768;
                // Use flexible height on mobile, fixed on desktop
                final containerHeight = isMobile ? null : 48.0;

                return SizedBox(
                  height: containerHeight,
                  child: Center(
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        HuxButton(
                          onPressed: () =>
                              widget.onShowSnackBar('Primary pressed'),
                          primaryColor: _currentPrimaryColor(context),
                          size: _selectedButtonSize,
                          icon: _showIconButtons ? LucideIcons.upload : null,
                          child: const Text('Primary'),
                        ),
                        HuxButton(
                          onPressed: () =>
                              widget.onShowSnackBar('Secondary pressed'),
                          variant: HuxButtonVariant.secondary,
                          size: _selectedButtonSize,
                          icon: _showIconButtons ? LucideIcons.upload : null,
                          child: const Text('Secondary'),
                        ),
                        HuxButton(
                          onPressed: () =>
                              widget.onShowSnackBar('Outline pressed'),
                          variant: HuxButtonVariant.outline,
                          size: _selectedButtonSize,
                          icon: _showIconButtons ? LucideIcons.upload : null,
                          child: const Text('Outline'),
                        ),
                        HuxButton(
                          onPressed: () =>
                              widget.onShowSnackBar('Ghost pressed'),
                          variant: HuxButtonVariant.ghost,
                          size: _selectedButtonSize,
                          icon: _showIconButtons ? LucideIcons.upload : null,
                          child: const Text('Ghost'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
