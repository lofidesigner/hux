import 'package:flutter/material.dart';
import '../../theme/hux_tokens.dart';

/// HuxKBD is a component for displaying keyboard shortcuts or keys.
///
/// It renders a small, styled box resembling a keyboard key.
///
/// Example:
/// ```dart
/// HuxKBD(shortcut: '⌘K')
/// ```
class HuxKBD extends StatelessWidget {
  /// Creates a [HuxKBD] widget.
  const HuxKBD({
    super.key,
    required this.shortcut,
  });

  /// The text to display inside the key (e.g., "⌘K", "Enter", "Esc")
  final String shortcut;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: HuxTokens.surfaceSecondary(context),
        borderRadius: BorderRadius.circular(HuxTokens.radiusSm(context)),
      ),
      child: Text(
        shortcut,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: HuxTokens.textTertiary(context),
              fontFamily: 'monospace',
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
      ),
    );
  }
}
