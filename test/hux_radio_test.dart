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
      expect(find.byType(Container), findsOneWidget);
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

      // Should show inner circle when selected
      final radioContainer = tester.widget<Container>(
        find.byType(Container).first,
      );

      // The container should have a child (the inner circle) when selected
      expect(radioContainer.child, isNotNull);
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

      // Should not show inner circle when not selected
      final radioContainer = tester.widget<Container>(
        find.byType(Container).first,
      );

      // The container should not have a child when not selected
      expect(radioContainer.child, isNull);
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

    testWidgets('selects with keyboard activation', (WidgetTester tester) async {
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
  });
}
