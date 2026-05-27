import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hux/hux.dart';

void main() {
  group('HuxOtpInput', () {
    test('asserts when length is zero', () {
      expect(
        () => HuxOtpInput(length: 0),
        throwsA(
          isA<AssertionError>().having(
            (error) => error.message,
            'message',
            'length must be > 0',
          ),
        ),
      );
    });

    testWidgets('renders when length is positive', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HuxOtpInput(length: 4),
          ),
        ),
      );

      expect(find.byType(TextField), findsNWidgets(4));
    });
  });
}
