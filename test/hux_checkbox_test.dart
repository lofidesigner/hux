import 'dart:ui' show CheckedState;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hux/hux.dart';

void main() {
  group('HuxCheckbox', () {
    testWidgets('renders correctly with default properties',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HuxCheckbox(
              value: false,
              onChanged: (value) {},
            ),
          ),
        ),
      );

      expect(find.byType(HuxCheckbox), findsOneWidget);
    });

    testWidgets('renders with label', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HuxCheckbox(
              value: false,
              onChanged: (value) {},
              label: 'Test Label',
            ),
          ),
        ),
      );

      expect(find.text('Test Label'), findsOneWidget);
      expect(find.byType(HuxCheckbox), findsOneWidget);
    });

    testWidgets('shows checked state when value is true',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HuxCheckbox(
              value: true,
              onChanged: (value) {},
            ),
          ),
        ),
      );

      // Should show check icon when checked
      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('shows unchecked state when value is false',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HuxCheckbox(
              value: false,
              onChanged: (value) {},
            ),
          ),
        ),
      );

      // Should not show check icon when unchecked
      expect(find.byIcon(Icons.check), findsNothing);
    });

    testWidgets('calls onChanged when tapped', (WidgetTester tester) async {
      bool? changedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HuxCheckbox(
              value: false,
              onChanged: (value) => changedValue = value,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(HuxCheckbox));
      await tester.pump();

      expect(changedValue, equals(true));
    });

    testWidgets('toggles value when tapped', (WidgetTester tester) async {
      bool? changedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HuxCheckbox(
              value: true,
              onChanged: (value) => changedValue = value,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(HuxCheckbox));
      await tester.pump();

      expect(changedValue, equals(false));
    });

    testWidgets('does not call onChanged when disabled',
        (WidgetTester tester) async {
      bool? changedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HuxCheckbox(
              value: false,
              onChanged: (value) => changedValue = value,
              isDisabled: true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(HuxCheckbox));
      await tester.pump();

      expect(changedValue, isNull);
    });

    testWidgets('does not call onChanged when onChanged is null',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HuxCheckbox(
              value: false,
              onChanged: null,
            ),
          ),
        ),
      );

      // Should not throw when tapped
      expect(() => tester.tap(find.byType(HuxCheckbox)), returnsNormally);
    });

    testWidgets('renders with different sizes', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                HuxCheckbox(
                  value: false,
                  onChanged: (value) {},
                  size: HuxCheckboxSize.medium,
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(HuxCheckbox), findsOneWidget);
    });

    testWidgets('exposes checkbox semantics', (WidgetTester tester) async {
      final semantics = tester.ensureSemantics();
      try {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: HuxCheckbox(
                value: true,
                onChanged: (value) {},
                label: 'Accept terms',
              ),
            ),
          ),
        );

        final node = tester.getSemantics(find.byType(HuxCheckbox));
        final data = node.getSemanticsData();
        expect(data.label, contains('Accept terms'));
        expect(data.flagsCollection.isChecked, isNot(CheckedState.none));
        expect(data.flagsCollection.isChecked, CheckedState.isTrue);
      } finally {
        semantics.dispose();
      }
    });

    testWidgets('toggles with keyboard activation',
        (WidgetTester tester) async {
      bool checked = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return HuxCheckbox(
                  value: checked,
                  onChanged: (value) =>
                      setState(() => checked = value ?? false),
                  label: 'Keyboard checkbox',
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

      expect(checked, isTrue);
    });

    testWidgets('shows visual focus ring when focused',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HuxCheckbox(
              value: false,
              onChanged: (_) {},
              label: 'Focusable checkbox',
            ),
          ),
        ),
      );

      final Finder ringFinder =
          find.byKey(const ValueKey('huxCheckboxFocusRing'));

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
