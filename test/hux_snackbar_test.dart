import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hux/hux.dart';

void main() {
  group('HuxSnackbar', () {
    testWidgets('uses opaque container and readable text in light mode',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: HuxTheme.lightTheme,
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: TextButton(
                  onPressed: () {
                    context.showHuxSnackbar(message: 'Light mode snackbar');
                  },
                  child: const Text('Show'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();

      final containerFinder =
          find.byKey(const ValueKey('huxSnackbarContainer'));
      expect(containerFinder, findsOneWidget);
      final container = tester.widget<Container>(containerFinder);
      final decoration = container.decoration! as BoxDecoration;
      expect(decoration.color, isNotNull);
      expect(decoration.color!.a, greaterThan(0.7));

      final messageText = tester.widget<Text>(find.text('Light mode snackbar'));
      expect(messageText.style, isNotNull);
      expect(messageText.style!.color, isNotNull);
    });
  });
}
