import 'dart:ui' show Tristate;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hux/hux.dart';

void main() {
  group('HuxToggle', () {
    testWidgets('toggles with keyboard Space when focused',
        (WidgetTester tester) async {
      bool isEnabled = false;
      int onChangedCallCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return HuxToggle(
                  value: isEnabled,
                  onChanged: (value) {
                    onChangedCallCount++;
                    setState(() => isEnabled = value);
                  },
                  icon: Icons.format_bold,
                  label: 'Bold',
                );
              },
            ),
          ),
        ),
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();

      expect(onChangedCallCount, equals(1));
      expect(isEnabled, isTrue);
      expect(tester.widget<HuxToggle>(find.byType(HuxToggle)).value, isTrue);
    });

    testWidgets('toggles with keyboard Enter when focused',
        (WidgetTester tester) async {
      bool isEnabled = false;
      int onChangedCallCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return HuxToggle(
                  value: isEnabled,
                  onChanged: (value) {
                    onChangedCallCount++;
                    setState(() => isEnabled = value);
                  },
                  icon: Icons.format_bold,
                  label: 'Bold',
                );
              },
            ),
          ),
        ),
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();

      expect(onChangedCallCount, equals(1));
      expect(isEnabled, isTrue);
      expect(tester.widget<HuxToggle>(find.byType(HuxToggle)).value, isTrue);
    });

    testWidgets('exposes toggled semantics and enabled state',
        (WidgetTester tester) async {
      final semantics = tester.ensureSemantics();
      try {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: HuxToggle(
                value: true,
                onChanged: (_) {},
                icon: Icons.format_bold,
                label: 'Bold',
              ),
            ),
          ),
        );

        final node = tester.getSemantics(find.byType(HuxToggle));
        final data = node.getSemanticsData();
        expect(data.flagsCollection.isToggled, isNot(Tristate.none));
        expect(data.flagsCollection.isToggled, Tristate.isTrue);
        expect(data.flagsCollection.isEnabled, Tristate.isTrue);
      } finally {
        semantics.dispose();
      }
    });

    testWidgets('exposes disabled semantics when onChanged is null',
        (WidgetTester tester) async {
      final semantics = tester.ensureSemantics();
      try {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: HuxToggle(
                value: false,
                onChanged: null,
                icon: Icons.format_bold,
                label: 'Bold',
              ),
            ),
          ),
        );

        final node = tester.getSemantics(find.byType(HuxToggle));
        final data = node.getSemanticsData();
        expect(data.flagsCollection.isEnabled, Tristate.isFalse);
      } finally {
        semantics.dispose();
      }
    });

    testWidgets(
        'does not toggle on keyboard activation when disabled and still shows focus ring',
        (WidgetTester tester) async {
      const bool isEnabled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HuxToggle(
              value: isEnabled,
              onChanged: null,
              icon: Icons.format_bold,
              label: 'Bold',
            ),
          ),
        ),
      );

      final Finder ringFinder =
          find.byKey(const ValueKey('huxToggleFocusRing'));

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
      expect(afterBorder.top.color, equals(Colors.transparent));

      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();

      expect(isEnabled, isFalse);
      expect(tester.widget<HuxToggle>(find.byType(HuxToggle)).value, isFalse);
    });

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

      final Finder ringFinder =
          find.byKey(const ValueKey('huxToggleFocusRing'));

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
