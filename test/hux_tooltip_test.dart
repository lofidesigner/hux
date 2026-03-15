import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hux/hux.dart';

void main() {
  group('HuxTooltip', () {
    testWidgets('renders child widget correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HuxTooltip(
              message: 'Test tooltip',
              child: Icon(Icons.info),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.info), findsOneWidget);
    });

    testWidgets('shows tooltip on long press', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HuxTooltip(
              message: 'Test tooltip',
              child: Icon(Icons.info),
            ),
          ),
        ),
      );

      await tester.longPress(find.byIcon(Icons.info));
      await tester.pumpAndSettle();

      expect(find.text('Test tooltip'), findsOneWidget);
    });

    testWidgets('supports configured wait duration',
        (WidgetTester tester) async {
      const customDuration = Duration(milliseconds: 100);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HuxTooltip(
              message: 'Wait tooltip',
              waitDuration: customDuration,
              child: Icon(Icons.info),
            ),
          ),
        ),
      );

      final tooltipChild = find.byIcon(Icons.info);
      final mouseGesture =
          await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouseGesture.addPointer();
      await mouseGesture.moveTo(tester.getCenter(tooltipChild));

      await tester.pump(customDuration - const Duration(milliseconds: 1));
      expect(find.text('Wait tooltip'), findsNothing);

      await tester.pump(const Duration(milliseconds: 1));

      expect(find.text('Wait tooltip'), findsOneWidget);
    });

    testWidgets('shows tooltip when child receives keyboard focus',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HuxTooltip(
              message: 'Focus tooltip',
              child: TextButton(
                onPressed: () {},
                child: const Text('Focusable'),
              ),
            ),
          ),
        ),
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Focus tooltip'), findsOneWidget);
    });

    testWidgets('hides tooltip when focused element loses focus',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                HuxTooltip(
                  message: 'Blur tooltip',
                  child: TextButton(
                    onPressed: () {},
                    child: const Text('First'),
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('Second'),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      expect(find.text('Blur tooltip'), findsOneWidget);

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      expect(find.text('Blur tooltip'), findsNothing);
    });

    testWidgets('applies custom background color', (WidgetTester tester) async {
      const customColor = Colors.deepPurple;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HuxTooltip(
              message: 'Test tooltip',
              backgroundColor: customColor,
              child: Icon(Icons.info),
            ),
          ),
        ),
      );

      await tester.longPress(find.byIcon(Icons.info));
      await tester.pumpAndSettle();

      final tooltip = find.byType(Material);
      expect(tooltip, findsOneWidget);
    });

    testWidgets('applies custom text color', (WidgetTester tester) async {
      const customColor = Colors.white;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HuxTooltip(
              message: 'Test tooltip',
              textColor: customColor,
              child: Icon(Icons.info),
            ),
          ),
        ),
      );

      await tester.longPress(find.byIcon(Icons.info));
      await tester.pumpAndSettle();

      expect(find.text('Test tooltip'), findsOneWidget);
    });

    testWidgets('respects custom wait duration', (WidgetTester tester) async {
      const customDuration = Duration(milliseconds: 1000);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HuxTooltip(
              message: 'Test tooltip',
              waitDuration: customDuration,
              child: Icon(Icons.info),
            ),
          ),
        ),
      );

      await tester.longPress(find.byIcon(Icons.info));

      // Wait for the tooltip to appear
      await tester.pumpAndSettle();

      // Tooltip should be visible
      expect(find.text('Test tooltip'), findsOneWidget);
    });
  });

  group('HuxTooltip with Icon', () {
    testWidgets('renders child widget correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HuxTooltip(
              message: 'Test tooltip',
              icon: Icons.info_outline,
              child: Icon(Icons.help),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.help), findsOneWidget);
    });

    testWidgets('shows tooltip with icon on long press',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HuxTooltip(
              message: 'Test tooltip',
              icon: Icons.info_outline,
              child: Icon(Icons.help),
            ),
          ),
        ),
      );

      await tester.longPress(find.byIcon(Icons.help));
      await tester.pumpAndSettle();

      // The tooltip should show the icon + message
      expect(find.byIcon(Icons.info_outline), findsOneWidget);
      expect(find.textContaining('Test tooltip'), findsOneWidget);
    });

    testWidgets('applies custom icon color', (WidgetTester tester) async {
      const customColor = Colors.red;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HuxTooltip(
              message: 'Test tooltip',
              icon: Icons.info_outline,
              iconColor: customColor,
              child: Icon(Icons.help),
            ),
          ),
        ),
      );

      await tester.longPress(find.byIcon(Icons.help));
      await tester.pumpAndSettle();

      // The tooltip should show the icon + message
      expect(find.byIcon(Icons.info_outline), findsOneWidget);
      expect(find.textContaining('Test tooltip'), findsOneWidget);
    });

    testWidgets('respects custom icon size', (WidgetTester tester) async {
      const customSize = 24.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HuxTooltip(
              message: 'Test tooltip',
              icon: Icons.info_outline,
              iconSize: customSize,
              child: Icon(Icons.help),
            ),
          ),
        ),
      );

      await tester.longPress(find.byIcon(Icons.help));
      await tester.pumpAndSettle();

      // The tooltip should show the icon + message
      expect(find.byIcon(Icons.info_outline), findsOneWidget);
      expect(find.textContaining('Test tooltip'), findsOneWidget);
    });
  });

  group('HuxTooltip Theme Integration', () {
    testWidgets('adapts to light theme', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: HuxTheme.lightTheme,
          home: Scaffold(
            body: HuxTooltip(
              message: 'Test tooltip',
              child: Icon(Icons.info),
            ),
          ),
        ),
      );

      await tester.longPress(find.byIcon(Icons.info));
      await tester.pumpAndSettle();

      expect(find.text('Test tooltip'), findsOneWidget);
    });

    testWidgets('adapts to dark theme', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: HuxTheme.darkTheme,
          home: Scaffold(
            body: HuxTooltip(
              message: 'Test tooltip',
              child: Icon(Icons.info),
            ),
          ),
        ),
      );

      await tester.longPress(find.byIcon(Icons.info));
      await tester.pumpAndSettle();

      expect(find.text('Test tooltip'), findsOneWidget);
    });
  });
}
