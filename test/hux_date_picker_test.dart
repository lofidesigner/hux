import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hux/hux.dart';

void main() {
  group('HuxDatePicker keyboard support', () {
    testWidgets('closes overlay on Escape', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HuxDatePicker(
              initialDate: DateTime(2024, 1, 15),
              firstDate: DateTime(2020, 1, 1),
              lastDate: DateTime(2030, 12, 31),
              placeholder: 'Pick date',
            ),
          ),
        ),
      );

      await tester.tap(find.byType(HuxButton));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('huxDatePickerPanel')), findsOneWidget);

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('huxDatePickerPanel')), findsNothing);
    });

    testWidgets('ArrowRight then Enter selects next day',
        (WidgetTester tester) async {
      DateTime? selected;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HuxDatePicker(
              initialDate: DateTime(2024, 1, 15),
              firstDate: DateTime(2020, 1, 1),
              lastDate: DateTime(2030, 12, 31),
              onDateChanged: (date) => selected = date,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(HuxButton));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('huxDatePickerPanel')), findsOneWidget);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      expect(selected, isNotNull);
      expect(selected!.year, 2024);
      expect(selected!.month, 1);
      expect(selected!.day, 16);
    });

    testWidgets('Tab reaches header and arrows navigate calendar',
        (WidgetTester tester) async {
      DateTime? selected;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HuxDatePicker(
              initialDate: DateTime(2024, 1, 15),
              firstDate: DateTime(2020, 1, 1),
              lastDate: DateTime(2030, 12, 31),
              onDateChanged: (date) => selected = date,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(HuxButton));
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      expect(selected, isNotNull);
      expect(selected!.day, 16);
    });

    testWidgets('Tab does not move focus outside panel',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HuxDatePicker(
              initialDate: DateTime(2024, 1, 15),
              firstDate: DateTime(2020, 1, 1),
              lastDate: DateTime(2030, 12, 31),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(HuxButton));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('huxDatePickerPanel')), findsOneWidget);

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();

      final panelFinder = find.byKey(const ValueKey('huxDatePickerPanel'));
      expect(panelFinder, findsOneWidget);

      final BuildContext panelContext = tester.element(panelFinder);
      final BuildContext? focusedContext =
          FocusManager.instance.primaryFocus?.context;
      expect(focusedContext, isNotNull);

      bool isFocusInsidePanel = identical(focusedContext, panelContext);
      if (!isFocusInsidePanel && focusedContext != null) {
        focusedContext.visitAncestorElements((ancestor) {
          if (identical(ancestor, panelContext)) {
            isFocusInsidePanel = true;
            return false;
          }
          return true;
        });
      }

      expect(isFocusInsidePanel, isTrue);
    });

    testWidgets('Tab from header returns to calendar section',
        (WidgetTester tester) async {
      DateTime? selected;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HuxDatePicker(
              initialDate: DateTime(2024, 1, 15),
              firstDate: DateTime(2020, 1, 1),
              lastDate: DateTime(2030, 12, 31),
              onDateChanged: (date) => selected = date,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(HuxButton));
      await tester.pumpAndSettle();

      // Tab into header, then tab back into calendar section.
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();

      // If focus returned to calendar section, arrow navigation should work.
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      expect(selected, isNotNull);
      expect(selected!.day, 16);
    });

    testWidgets('Tab can reach header navigation and Enter activates it',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HuxDatePicker(
              initialDate: DateTime(2024, 1, 15),
              firstDate: DateTime(2020, 1, 1),
              lastDate: DateTime(2030, 12, 31),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(HuxButton));
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      expect(find.text('Dec'), findsOneWidget);
    });

    testWidgets('ArrowLeft on first day wraps to previous month last day',
        (WidgetTester tester) async {
      DateTime? selected;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HuxDatePicker(
              initialDate: DateTime(2024, 1, 1),
              firstDate: DateTime(2020, 1, 1),
              lastDate: DateTime(2030, 12, 31),
              onDateChanged: (date) => selected = date,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(HuxButton));
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      expect(selected, isNotNull);
      expect(selected!.year, 2023);
      expect(selected!.month, 12);
      expect(selected!.day, 31);
    });

    testWidgets('ArrowRight on last day wraps to next month first day',
        (WidgetTester tester) async {
      DateTime? selected;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HuxDatePicker(
              initialDate: DateTime(2024, 1, 31),
              firstDate: DateTime(2020, 1, 1),
              lastDate: DateTime(2030, 12, 31),
              onDateChanged: (date) => selected = date,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(HuxButton));
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      expect(selected, isNotNull);
      expect(selected!.year, 2024);
      expect(selected!.month, 2);
      expect(selected!.day, 1);
    });

    testWidgets('ArrowUp from first row focuses month/year header',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HuxDatePicker(
              initialDate: DateTime(2024, 1, 1),
              firstDate: DateTime(2020, 1, 1),
              lastDate: DateTime(2030, 12, 31),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(HuxButton));
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      expect(find.text('Select Month'), findsOneWidget);
    });

    testWidgets('month picker supports arrow navigation and Enter selection',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HuxDatePicker(
              initialDate: DateTime(2024, 1, 15),
              firstDate: DateTime(2020, 1, 1),
              lastDate: DateTime(2030, 12, 31),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(HuxButton));
      await tester.pumpAndSettle();

      // Tab from calendar section to header start, then move to month button.
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(find.text('Select Month'), findsOneWidget);

      // Move focus to next month and select it with Enter.
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      expect(find.text('Feb'), findsOneWidget);
    });
  });
}
