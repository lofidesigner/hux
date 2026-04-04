import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hux/hux.dart';

void main() {
  group('HuxCard', () {
    testWidgets('keeps row actions when they fit available width',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Center(
            child: SizedBox(
              width: 500,
              child: HuxCard(
                title: 'Title',
                action: Row(
                  key: const ValueKey('action-row'),
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(onPressed: () {}, child: const Text('Edit')),
                    const SizedBox(width: 8),
                    TextButton(onPressed: () {}, child: const Text('Share')),
                  ],
                ),
                child: const Text('Body'),
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.byKey(const ValueKey('action-row')), findsOneWidget);
      expect(find.byType(Wrap), findsNothing);
    });

    testWidgets('wraps row actions when they exceed available width',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Center(
            child: SizedBox(
              width: 220,
              child: HuxCard(
                title: 'Title',
                action: Row(
                  key: const ValueKey('action-row'),
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(
                      onPressed: () {},
                      child: const Text('Primary Action'),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () {},
                      child: const Text('Secondary Action'),
                    ),
                  ],
                ),
                child: const Text('Body'),
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.byKey(const ValueKey('action-row')), findsNothing);
      expect(find.byType(Wrap), findsOneWidget);
      expect(find.text('Primary Action'), findsOneWidget);
      expect(find.text('Secondary Action'), findsOneWidget);
    });
  });
}
