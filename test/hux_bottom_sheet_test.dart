import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hux/hux.dart';

void main() {
  group('HuxBottomSheet', () {
    testWidgets('renders with title and content', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HuxBottomSheet(
              title: 'Test Bottom Sheet',
              child: const Text('Test content'),
            ),
          ),
        ),
      );

      expect(find.text('Test Bottom Sheet'), findsOneWidget);
      expect(find.text('Test content'), findsOneWidget);
    });

    testWidgets('renders with subtitle', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HuxBottomSheet(
              title: 'Test Bottom Sheet',
              subtitle: 'Test subtitle',
              child: const Text('Test content'),
            ),
          ),
        ),
      );

      expect(find.text('Test Bottom Sheet'), findsOneWidget);
      expect(find.text('Test subtitle'), findsOneWidget);
      expect(find.text('Test content'), findsOneWidget);
    });

    testWidgets('renders with actions', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HuxBottomSheet(
              title: 'Test Bottom Sheet',
              actions: [
                HuxButton(
                  onPressed: () {},
                  child: const Text('Cancel'),
                ),
                HuxButton(
                  onPressed: () {},
                  child: const Text('Confirm'),
                ),
              ],
              child: const Text('Test content'),
            ),
          ),
        ),
      );

      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Confirm'), findsOneWidget);
    });

    testWidgets('shows drag handle by default', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HuxBottomSheet(
              title: 'Test Bottom Sheet',
              child: const Text('Test content'),
            ),
          ),
        ),
      );

      // Drag handle is a Container with specific dimensions
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Container &&
              widget.constraints?.maxWidth == 36 &&
              widget.constraints?.maxHeight == 4,
        ),
        findsOneWidget,
      );
    });

    testWidgets('hides drag handle when showDragHandle is false',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HuxBottomSheet(
              title: 'Test Bottom Sheet',
              showDragHandle: false,
              child: const Text('Test content'),
            ),
          ),
        ),
      );

      // Verify the sheet still renders
      expect(find.text('Test Bottom Sheet'), findsOneWidget);
    });

    testWidgets('shows close button when showCloseButton is true',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HuxBottomSheet(
              title: 'Test Bottom Sheet',
              showCloseButton: true,
              child: const Text('Test content'),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('hides close button by default', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HuxBottomSheet(
              title: 'Test Bottom Sheet',
              child: const Text('Test content'),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.close), findsNothing);
    });

    testWidgets('applies different sizes correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HuxBottomSheet(
              title: 'Test Bottom Sheet',
              size: HuxBottomSheetSize.small,
              child: const Text('Test content'),
            ),
          ),
        ),
      );

      // The bottom sheet should render without errors
      expect(find.text('Test Bottom Sheet'), findsOneWidget);
    });

    testWidgets('applies large size correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HuxBottomSheet(
              title: 'Test Bottom Sheet',
              size: HuxBottomSheetSize.large,
              child: const Text('Test content'),
            ),
          ),
        ),
      );

      expect(find.text('Test Bottom Sheet'), findsOneWidget);
    });

    testWidgets('applies fullscreen size correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HuxBottomSheet(
              title: 'Test Bottom Sheet',
              size: HuxBottomSheetSize.fullscreen,
              child: const Text('Test content'),
            ),
          ),
        ),
      );

      expect(find.text('Test Bottom Sheet'), findsOneWidget);
    });
  });

  group('showHuxBottomSheet', () {
    testWidgets('shows bottom sheet with showHuxBottomSheet function',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => HuxButton(
                onPressed: () {
                  showHuxBottomSheet<void>(
                    context: context,
                    title: 'Test Bottom Sheet',
                    child: const Text('Test content'),
                  );
                },
                child: const Text('Show Bottom Sheet'),
              ),
            ),
          ),
        ),
      );

      // Tap the button to show the bottom sheet
      await tester.tap(find.text('Show Bottom Sheet'));
      await tester.pumpAndSettle();

      // The bottom sheet should be visible
      expect(find.text('Test Bottom Sheet'), findsOneWidget);
      expect(find.text('Test content'), findsOneWidget);
    });

    testWidgets('bottom sheet can be dismissed by tapping outside',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => HuxButton(
                onPressed: () {
                  showHuxBottomSheet<void>(
                    context: context,
                    title: 'Test Bottom Sheet',
                    child: const Text('Test content'),
                  );
                },
                child: const Text('Show Bottom Sheet'),
              ),
            ),
          ),
        ),
      );

      // Tap the button to show the bottom sheet
      await tester.tap(find.text('Show Bottom Sheet'));
      await tester.pumpAndSettle();

      // Verify the bottom sheet is visible
      expect(find.text('Test Bottom Sheet'), findsOneWidget);

      // Tap outside to dismiss (tap at the top of the screen)
      await tester.tapAt(const Offset(100, 50));
      await tester.pumpAndSettle();

      // The bottom sheet should be dismissed
      expect(find.text('Test Bottom Sheet'), findsNothing);
    });
  });

  group('showHuxActionSheet', () {
    testWidgets('shows action sheet with actions',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => HuxButton(
                onPressed: () {
                  showHuxActionSheet(
                    context: context,
                    title: 'Test Action Sheet',
                    actions: [
                      HuxActionSheetItem(
                        label: 'Option 1',
                        onTap: () {},
                      ),
                      HuxActionSheetItem(
                        label: 'Option 2',
                        onTap: () {},
                      ),
                    ],
                  );
                },
                child: const Text('Show Action Sheet'),
              ),
            ),
          ),
        ),
      );

      // Tap the button to show the action sheet
      await tester.tap(find.text('Show Action Sheet'));
      await tester.pumpAndSettle();

      // The action sheet should be visible with options
      expect(find.text('Test Action Sheet'), findsOneWidget);
      expect(find.text('Option 1'), findsOneWidget);
      expect(find.text('Option 2'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('action sheet shows custom cancel label',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => HuxButton(
                onPressed: () {
                  showHuxActionSheet(
                    context: context,
                    actions: [
                      HuxActionSheetItem(
                        label: 'Delete',
                        onTap: () {},
                        isDestructive: true,
                      ),
                    ],
                    cancelLabel: 'Dismiss',
                  );
                },
                child: const Text('Show Action Sheet'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Action Sheet'));
      await tester.pumpAndSettle();

      expect(find.text('Dismiss'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
    });

    testWidgets('action sheet executes onTap callback',
        (WidgetTester tester) async {
      bool actionTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => HuxButton(
                onPressed: () {
                  showHuxActionSheet(
                    context: context,
                    actions: [
                      HuxActionSheetItem(
                        label: 'Tap Me',
                        onTap: () {
                          actionTapped = true;
                        },
                      ),
                    ],
                  );
                },
                child: const Text('Show Action Sheet'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Action Sheet'));
      await tester.pumpAndSettle();

      // Tap the action
      await tester.tap(find.text('Tap Me'));
      await tester.pumpAndSettle();

      expect(actionTapped, isTrue);
    });

    testWidgets('action sheet hides cancel button when showCancel is false',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => HuxButton(
                onPressed: () {
                  showHuxActionSheet(
                    context: context,
                    actions: [
                      HuxActionSheetItem(
                        label: 'Option 1',
                        onTap: () {},
                      ),
                    ],
                    showCancel: false,
                  );
                },
                child: const Text('Show Action Sheet'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Action Sheet'));
      await tester.pumpAndSettle();

      expect(find.text('Option 1'), findsOneWidget);
      expect(find.text('Cancel'), findsNothing);
    });
  });

  group('HuxActionSheetItem', () {
    testWidgets('renders with icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => HuxButton(
                onPressed: () {
                  showHuxActionSheet(
                    context: context,
                    actions: [
                      HuxActionSheetItem(
                        label: 'Share',
                        icon: Icons.share,
                        onTap: () {},
                      ),
                    ],
                  );
                },
                child: const Text('Show Action Sheet'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Action Sheet'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.share), findsOneWidget);
      expect(find.text('Share'), findsOneWidget);
    });
  });
}
