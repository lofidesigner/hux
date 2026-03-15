import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hux/hux.dart';

void main() {
  group('HuxButton', () {
    testWidgets('applies visible focused border state',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HuxButton(
              onPressed: () {},
              child: const Text('Focus me'),
            ),
          ),
        ),
      );

      final elevated =
          tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      final focusedShape = elevated.style?.shape?.resolve({
        WidgetState.focused,
      });

      expect(focusedShape, isA<RoundedRectangleBorder>());
      final focusedSide = (focusedShape! as RoundedRectangleBorder).side;
      expect(focusedSide.width, 2);
    });
  });
}
