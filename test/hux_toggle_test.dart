import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hux/hux.dart';

void main() {
  group('HuxToggle', () {
    testWidgets('shows visual focus ring when focused',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HuxToggle(
              value: false,
              onChanged: (_) {},
              icon: Icons.format_bold,
              label: 'Bold',
            ),
          ),
        ),
      );

      final Finder ringFinder = find.byKey(const ValueKey('huxToggleFocusRing'));

      final AnimatedContainer beforeFocus =
          tester.widget<AnimatedContainer>(ringFinder);
      final BoxDecoration beforeDecoration =
          beforeFocus.decoration! as BoxDecoration;
      final Border beforeBorder = beforeDecoration.border! as Border;
      expect(beforeBorder.top.color, equals(Colors.transparent));

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();

      final AnimatedContainer afterFocus =
          tester.widget<AnimatedContainer>(ringFinder);
      final BoxDecoration afterDecoration =
          afterFocus.decoration! as BoxDecoration;
      final Border afterBorder = afterDecoration.border! as Border;
      expect(afterBorder.top.color, isNot(equals(Colors.transparent)));
    });
  });
}
