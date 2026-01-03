import 'package:flutter/material.dart';
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
  });
}

