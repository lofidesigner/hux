import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hux/hux.dart';

void main() {
  group('HuxBadge', () {
    testWidgets('renders correctly with default properties',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HuxBadge(
              label: 'Test',
            ),
          ),
        ),
      );

      expect(find.text('Test'), findsOneWidget);
      expect(find.byType(HuxBadge), findsOneWidget);
    });

    testWidgets('renders with different variants',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                HuxBadge(
                  label: 'Primary',
                  variant: HuxBadgeVariant.primary,
                ),
                HuxBadge(
                  label: 'Secondary',
                  variant: HuxBadgeVariant.secondary,
                ),
                HuxBadge(
                  label: 'Success',
                  variant: HuxBadgeVariant.success,
                ),
                HuxBadge(
                  label: 'Error',
                  variant: HuxBadgeVariant.error,
                ),
                HuxBadge(
                  label: 'Destructive',
                  variant: HuxBadgeVariant.destructive,
                ),
                HuxBadge(
                  label: 'Outline',
                  variant: HuxBadgeVariant.outline,
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Primary'), findsOneWidget);
      expect(find.text('Secondary'), findsOneWidget);
      expect(find.text('Success'), findsOneWidget);
      expect(find.text('Error'), findsOneWidget);
      expect(find.text('Destructive'), findsOneWidget);
      expect(find.text('Outline'), findsOneWidget);
      expect(find.byType(HuxBadge), findsNWidgets(6));
    });

    testWidgets('renders with different sizes', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                HuxBadge(
                  label: 'Small',
                  size: HuxBadgeSize.small,
                ),
                HuxBadge(
                  label: 'Medium',
                  size: HuxBadgeSize.medium,
                ),
                HuxBadge(
                  label: 'Large',
                  size: HuxBadgeSize.large,
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Small'), findsOneWidget);
      expect(find.text('Medium'), findsOneWidget);
      expect(find.text('Large'), findsOneWidget);
      expect(find.byType(HuxBadge), findsNWidgets(3));
    });

    testWidgets('renders with custom color', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HuxBadge(
              label: 'Custom',
              customColor: Colors.purple,
            ),
          ),
        ),
      );

      expect(find.text('Custom'), findsOneWidget);
      expect(find.byType(HuxBadge), findsOneWidget);
    });

    testWidgets('renders numeric badge', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HuxBadge(
              label: '42',
              variant: HuxBadgeVariant.primary,
            ),
          ),
        ),
      );

      expect(find.text('42'), findsOneWidget);
      expect(find.byType(HuxBadge), findsOneWidget);
    });

    testWidgets('renders with long text', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HuxBadge(
              label: 'Very Long Badge Text',
            ),
          ),
        ),
      );

      expect(find.text('Very Long Badge Text'), findsOneWidget);
      expect(find.byType(HuxBadge), findsOneWidget);
    });
  });
}

