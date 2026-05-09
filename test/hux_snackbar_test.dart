import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hux/hux.dart';

void main() {
  group('HuxSnackbar', () {
    tearDown(() {
      HuxSnackbarStackController.resetForTest();
    });

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

    testWidgets('renders actions and invokes callbacks', (tester) async {
      var undoTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: HuxTheme.lightTheme,
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: TextButton(
                  onPressed: () {
                    context.showHuxSnackbar(
                      message: 'Deleted',
                      actions: [
                        HuxSnackbarAction(
                          label: 'Undo',
                          onPressed: () {
                            undoTapped = true;
                          },
                        ),
                      ],
                    );
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

      expect(find.text('Undo'), findsOneWidget);
      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();

      expect(undoTapped, isTrue);
    });

    testWidgets('can stack multiple snackbars when enabled', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: HuxTheme.lightTheme,
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: TextButton(
                  onPressed: () {
                    HuxSnackbarStackController.of(context).show(
                      const HuxSnackbar(
                        message: 'First',
                        duration: Duration.zero,
                      ),
                    );
                    HuxSnackbarStackController.of(context).show(
                      const HuxSnackbar(
                        message: 'Second',
                        duration: Duration.zero,
                      ),
                    );
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

      // Both snackbars should be visible simultaneously.
      expect(find.text('First'), findsOneWidget);
      expect(find.text('Second'), findsOneWidget);
    });

    testWidgets('stacked overlay uses snackbar margin and keyboard inset',
        (tester) async {
      const margin = EdgeInsets.fromLTRB(10, 20, 30, 40);

      await tester.pumpWidget(
        MaterialApp(
          theme: HuxTheme.lightTheme,
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                viewInsets: const EdgeInsets.only(bottom: 50),
              ),
              child: child!,
            );
          },
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: TextButton(
                  onPressed: () {
                    HuxSnackbarStackController.of(context).show(
                      const HuxSnackbar(
                        message: 'Inset aware',
                        duration: Duration.zero,
                        margin: margin,
                      ),
                    );
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

      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Padding &&
              widget.padding ==
                  const EdgeInsets.only(
                    left: 10,
                    top: 20,
                    right: 30,
                    bottom: 90,
                  ),
        ),
        findsOneWidget,
      );

      expect(find.text('Inset aware'), findsOneWidget);
    });

    testWidgets('dismiss closes before calling onDismiss', (tester) async {
      final events = <String>[];

      await tester.pumpWidget(
        MaterialApp(
          theme: HuxTheme.lightTheme,
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      HuxSnackbar(
                        message: 'Dismiss order',
                        duration: const Duration(minutes: 1),
                        onCloseRequest: () => events.add('close'),
                        onDismiss: () => events.add('dismiss'),
                      ).build(context),
                    );
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
      await tester.tap(find.byIcon(LucideIcons.x));
      await tester.pump();

      expect(events, ['close', 'dismiss']);
    });

    testWidgets('dismiss control has accessible label and 48dp tap target',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: HuxTheme.lightTheme,
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      HuxSnackbar(
                        message: 'Accessible dismiss',
                        duration: const Duration(minutes: 1),
                        onDismiss: () {},
                      ).build(context),
                    );
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

      expect(find.byTooltip('Dismiss notification'), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Semantics &&
              widget.properties.label == 'Dismiss notification' &&
              (widget.properties.button ?? false),
        ),
        findsOneWidget,
      );

      final dismissTarget = tester.widget<SizedBox>(
        find.ancestor(
          of: find.byIcon(LucideIcons.x),
          matching: find.byWidgetPredicate(
            (widget) => widget is SizedBox && widget.width == 48 && widget.height == 48,
          ),
        ),
      );

      expect(dismissTarget.width, 48);
      expect(dismissTarget.height, 48);
    });

    testWidgets('legacy action closes once before user callback', (tester) async {
      final events = <String>[];

      await tester.pumpWidget(
        MaterialApp(
          theme: HuxTheme.lightTheme,
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      HuxSnackbar(
                        message: 'Legacy action order',
                        duration: const Duration(minutes: 1),
                        onCloseRequest: () => events.add('close'),
                        action: SnackBarAction(
                          label: 'Undo',
                          onPressed: () => events.add('action'),
                        ),
                      ).build(context),
                    );
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
      await tester.tap(find.text('Undo'));
      await tester.pump();

      expect(events, ['close', 'action']);
    });
  });
}
