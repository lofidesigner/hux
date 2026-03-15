import 'dart:ui' show Tristate;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hux/hux.dart';

void main() {
  group('HuxSwitch', () {
    testWidgets('renders correctly with default properties',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HuxSwitch(
              value: false,
              onChanged: (value) {},
            ),
          ),
        ),
      );

      expect(find.byType(HuxSwitch), findsOneWidget);
    });

    testWidgets('shows on state when value is true',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HuxSwitch(
              value: true,
              onChanged: (value) {},
            ),
          ),
        ),
      );

      expect(find.byType(HuxSwitch), findsOneWidget);
      // Switch should be in on position (aligned right)
      final switchWidget = tester.widget<HuxSwitch>(find.byType(HuxSwitch));
      expect(switchWidget.value, isTrue);
    });

    testWidgets('shows off state when value is false',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HuxSwitch(
              value: false,
              onChanged: (value) {},
            ),
          ),
        ),
      );

      expect(find.byType(HuxSwitch), findsOneWidget);
      // Switch should be in off position (aligned left)
      final switchWidget = tester.widget<HuxSwitch>(find.byType(HuxSwitch));
      expect(switchWidget.value, isFalse);
    });

    testWidgets('calls onChanged when tapped', (WidgetTester tester) async {
      bool? changedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HuxSwitch(
              value: false,
              onChanged: (value) => changedValue = value,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(HuxSwitch));
      await tester.pump();

      expect(changedValue, equals(true));
    });

    testWidgets('toggles value when tapped', (WidgetTester tester) async {
      bool? changedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HuxSwitch(
              value: true,
              onChanged: (value) => changedValue = value,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(HuxSwitch));
      await tester.pump();

      expect(changedValue, equals(false));
    });

    testWidgets('does not call onChanged when disabled',
        (WidgetTester tester) async {
      bool? changedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HuxSwitch(
              value: false,
              onChanged: (value) => changedValue = value,
              isDisabled: true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(HuxSwitch));
      await tester.pump();

      expect(changedValue, isNull);
    });

    testWidgets('does not call onChanged when onChanged is null',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HuxSwitch(
              value: false,
              onChanged: null,
            ),
          ),
        ),
      );

      // Should not throw when tapped
      expect(() => tester.tap(find.byType(HuxSwitch)), returnsNormally);
    });

    testWidgets('renders with different sizes', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                HuxSwitch(
                  value: false,
                  onChanged: (value) {},
                  size: HuxSwitchSize.medium,
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(HuxSwitch), findsOneWidget);
    });

    testWidgets('exposes switch semantics', (WidgetTester tester) async {
      final semantics = tester.ensureSemantics();
      try {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: HuxSwitch(
                value: true,
                onChanged: (value) {},
              ),
            ),
          ),
        );

        final node = tester.getSemantics(find.byType(HuxSwitch));
        final data = node.getSemanticsData();
        expect(data.flagsCollection.isToggled, isNot(Tristate.none));
        expect(data.flagsCollection.isToggled, Tristate.isTrue);
      } finally {
        semantics.dispose();
      }
    });

    testWidgets('toggles with keyboard activation',
        (WidgetTester tester) async {
      bool enabled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return HuxSwitch(
                  value: enabled,
                  onChanged: (value) => setState(() => enabled = value),
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

      expect(enabled, isTrue);
    });

    testWidgets('shows visual focus ring when focused',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HuxSwitch(
              value: false,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      final Finder ringFinder =
          find.byKey(const ValueKey('huxSwitchFocusRing'));

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
