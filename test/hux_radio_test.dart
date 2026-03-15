import 'dart:ui' show CheckedState;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hux/hux.dart';

void main() {
  group('HuxRadio', () {
    testWidgets('renders correctly with default properties',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HuxRadio<String>(
              value: 'option1',
              groupValue: null,
              onChanged: (value) {},
            ),
          ),
        ),
      );

      expect(find.byType(HuxRadio<String>), findsOneWidget);
    });

    testWidgets('renders with label', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HuxRadio<String>(
              value: 'option1',
              groupValue: null,
              onChanged: (value) {},
              label: 'Test Label',
            ),
          ),
        ),
      );

      expect(find.text('Test Label'), findsOneWidget);
    });

    testWidgets('shows selected state when value matches groupValue',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HuxRadio<String>(
              value: 'option1',
              groupValue: 'option1',
              onChanged: (value) {},
            ),
          ),
        ),
      );

      // Should render inner circle marker when selected
      expect(find.byKey(const ValueKey('huxRadioInnerCircle')), findsOneWidget);
    });

    testWidgets('shows unselected state when value does not match groupValue',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HuxRadio<String>(
              value: 'option1',
              groupValue: 'option2',
              onChanged: (value) {},
            ),
          ),
        ),
      );

      // Should not render inner circle marker when not selected
      expect(find.byKey(const ValueKey('huxRadioInnerCircle')), findsNothing);
    });

    testWidgets('calls onChanged when tapped', (WidgetTester tester) async {
      String? selectedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HuxRadio<String>(
              value: 'option1',
              groupValue: null,
              onChanged: (value) => selectedValue = value,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(HuxRadio<String>));
      await tester.pump();

      expect(selectedValue, equals('option1'));
    });

    testWidgets('does not call onChanged when disabled',
        (WidgetTester tester) async {
      String? selectedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HuxRadio<String>(
              value: 'option1',
              groupValue: null,
              onChanged: (value) => selectedValue = value,
              isDisabled: true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(HuxRadio<String>));
      await tester.pump();

      expect(selectedValue, isNull);
    });

    testWidgets('does not call onChanged when onChanged is null',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HuxRadio<String>(
              value: 'option1',
              groupValue: null,
              onChanged: null,
            ),
          ),
        ),
      );

      // Should not throw when tapped
      expect(() => tester.tap(find.byType(HuxRadio<String>)), returnsNormally);
    });

    testWidgets('works with different generic types',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                HuxRadio<String>(
                  value: 'string_value',
                  groupValue: null,
                  onChanged: (value) {},
                ),
                HuxRadio<int>(
                  value: 42,
                  groupValue: null,
                  onChanged: (value) {},
                ),
                HuxRadio<bool>(
                  value: true,
                  groupValue: null,
                  onChanged: (value) {},
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(HuxRadio<String>), findsOneWidget);
      expect(find.byType(HuxRadio<int>), findsOneWidget);
      expect(find.byType(HuxRadio<bool>), findsOneWidget);
    });

    testWidgets('exposes radio semantics', (WidgetTester tester) async {
      final semantics = tester.ensureSemantics();
      try {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: HuxRadio<String>(
                value: 'option1',
                groupValue: 'option1',
                onChanged: (value) {},
                label: 'Option 1',
              ),
            ),
          ),
        );

        final node = tester.getSemantics(find.byType(HuxRadio<String>));
        final data = node.getSemanticsData();
        expect(data.label, contains('Option 1'));
        expect(data.flagsCollection.isChecked, isNot(CheckedState.none));
        expect(data.flagsCollection.isChecked, CheckedState.isTrue);
        expect(data.flagsCollection.isInMutuallyExclusiveGroup, isTrue);
      } finally {
        semantics.dispose();
      }
    });

    testWidgets('selects with keyboard activation',
        (WidgetTester tester) async {
      String? selected;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return HuxRadio<String>(
                  value: 'option1',
                  groupValue: selected,
                  onChanged: (value) => setState(() => selected = value),
                  label: 'Keyboard radio',
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

      expect(selected, equals('option1'));
    });

    testWidgets('shows visual focus ring when focused',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HuxRadio<String>(
              value: 'option1',
              groupValue: null,
              onChanged: (_) {},
              label: 'Focusable radio',
            ),
          ),
        ),
      );

      final Finder ringFinder = find.byKey(const ValueKey('huxRadioFocusRing'));

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
