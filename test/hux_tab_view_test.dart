import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hux/hux.dart';

void main() {
  group('HuxTabView', () {
    testWidgets('renders with initial tabs', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HuxTabView(
              initialTabs: [
                TabDocument(title: 'Tab 1', content: const Text('Content 1')),
                TabDocument(title: 'Tab 2', content: const Text('Content 2')),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Tab 1'), findsOneWidget);
      expect(find.text('Tab 2'), findsOneWidget);
      expect(find.text('Content 1'), findsOneWidget);
    });

    testWidgets('shows empty state when no tabs', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HuxTabView(
              initialTabs: const [],
            ),
          ),
        ),
      );

      expect(find.text('No tabs open'), findsOneWidget);
      expect(find.byIcon(LucideIcons.layoutTemplate), findsOneWidget);
    });

    testWidgets('shows new tab button when enabled',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HuxTabView(
              initialTabs: [
                TabDocument(title: 'Tab 1', content: const Text('Content')),
              ],
              showNewTabButton: true,
            ),
          ),
        ),
      );

      expect(find.byIcon(LucideIcons.plus), findsOneWidget);
    });

    testWidgets('calls onNewTabRequested when new tab button pressed',
        (WidgetTester tester) async {
      bool newTabRequested = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HuxTabView(
              initialTabs: [
                TabDocument(title: 'Tab 1', content: const Text('Content')),
              ],
              showNewTabButton: true,
              onNewTabRequested: () => newTabRequested = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(LucideIcons.plus));
      await tester.pump();

      expect(newTabRequested, isTrue);
    });

    testWidgets('switches tabs on tap', (WidgetTester tester) async {
      int changedIndex = -1;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HuxTabView(
              initialTabs: [
                TabDocument(title: 'Tab 1', content: const Text('Content 1')),
                TabDocument(title: 'Tab 2', content: const Text('Content 2')),
              ],
              onTabChanged: (index) => changedIndex = index,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Tab 2'));
      await tester.pump();

      expect(changedIndex, equals(1));
      expect(find.text('Content 2'), findsOneWidget);
    });

    testWidgets('shows close buttons by default', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HuxTabView(
              initialTabs: [
                TabDocument(title: 'Tab 1', content: const Text('Content')),
                TabDocument(title: 'Tab 2', content: const Text('Content')),
              ],
            ),
          ),
        ),
      );

      expect(find.byIcon(LucideIcons.x), findsNWidgets(2));
    });

    testWidgets('hides close buttons when canCloseTabs is false',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HuxTabView(
              initialTabs: [
                TabDocument(title: 'Tab 1', content: const Text('Content')),
              ],
              canCloseTabs: false,
            ),
          ),
        ),
      );

      expect(find.byIcon(LucideIcons.x), findsNothing);
    });

    testWidgets('hides close button for non-closable tabs',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HuxTabView(
              initialTabs: [
                TabDocument(
                  title: 'Fixed',
                  content: const Text('Content'),
                  isClosable: false,
                ),
                TabDocument(
                  title: 'Closable',
                  content: const Text('Content'),
                  isClosable: true,
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byIcon(LucideIcons.x), findsOneWidget);
    });

    testWidgets('closes tab when close button pressed',
        (WidgetTester tester) async {
      int closedIndex = -1;
      String? closedTitle;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HuxTabView(
              initialTabs: [
                TabDocument(title: 'Tab 1', content: const Text('Content 1')),
                TabDocument(title: 'Tab 2', content: const Text('Content 2')),
              ],
              onTabClosed: (index, doc) {
                closedIndex = index;
                closedTitle = doc.title;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(LucideIcons.x).first);
      await tester.pump();

      expect(closedIndex, equals(0));
      expect(closedTitle, equals('Tab 1'));
      expect(find.text('Tab 1'), findsNothing);
      expect(find.text('Tab 2'), findsOneWidget);
    });

    testWidgets('displays tab icons when provided',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HuxTabView(
              initialTabs: [
                TabDocument(
                  title: 'Document',
                  icon: LucideIcons.fileText,
                  content: const Text('Content'),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byIcon(LucideIcons.fileText), findsOneWidget);
    });

    testWidgets('respects initialIndex', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HuxTabView(
              initialTabs: [
                TabDocument(title: 'Tab 1', content: const Text('Content 1')),
                TabDocument(title: 'Tab 2', content: const Text('Content 2')),
                TabDocument(title: 'Tab 3', content: const Text('Content 3')),
              ],
              initialIndex: 2,
            ),
          ),
        ),
      );

      expect(find.text('Content 3'), findsOneWidget);
      expect(find.text('Content 1'), findsNothing);
    });

    testWidgets('clamps initialIndex to valid range',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HuxTabView(
              initialTabs: [
                TabDocument(title: 'Tab 1', content: const Text('Content 1')),
                TabDocument(title: 'Tab 2', content: const Text('Content 2')),
              ],
              initialIndex: 10, // Out of range
            ),
          ),
        ),
      );

      // Should clamp to last valid index (1)
      expect(find.text('Content 2'), findsOneWidget);
    });

    testWidgets('calls onTabAdded when tab is added',
        (WidgetTester tester) async {
      TabDocument? addedDoc;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HuxTabView(
              initialTabs: [
                TabDocument(title: 'Initial', content: const Text('Content')),
              ],
              showNewTabButton: true,
              onTabAdded: (doc) => addedDoc = doc,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(LucideIcons.plus));
      await tester.pump();

      expect(addedDoc, isNotNull);
      expect(addedDoc!.title, equals('Untitled 1'));
      expect(find.text('Untitled 1'), findsOneWidget);
    });

    testWidgets('updates tabs when identifier order changes with same length',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HuxTabView(
              initialTabs: [
                TabDocument(
                  identifier: 'first',
                  title: 'Tab 1',
                  content: const Text('Content 1'),
                ),
                TabDocument(
                  identifier: 'second',
                  title: 'Tab 2',
                  content: const Text('Content 2'),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Content 1'), findsOneWidget);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HuxTabView(
              initialTabs: [
                TabDocument(
                  identifier: 'second',
                  title: 'Tab 2',
                  content: const Text('Content 2'),
                ),
                TabDocument(
                  identifier: 'first',
                  title: 'Tab 1',
                  content: const Text('Content 1'),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Content 2'), findsOneWidget);
    });

    testWidgets('preserves tab content state by identifier on reorder',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HuxTabView(
              initialTabs: [
                TabDocument(
                  identifier: 'alpha',
                  title: 'Alpha',
                  content: const _TestCounterContent(label: 'Alpha'),
                ),
                TabDocument(
                  identifier: 'beta',
                  title: 'Beta',
                  content: const _TestCounterContent(label: 'Beta'),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.tap(find.byKey(const ValueKey('increment-Alpha')));
      await tester.pump();
      expect(find.text('Alpha: 1'), findsOneWidget);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HuxTabView(
              initialTabs: [
                TabDocument(
                  identifier: 'beta',
                  title: 'Beta',
                  content: const _TestCounterContent(label: 'Beta'),
                ),
                TabDocument(
                  identifier: 'alpha',
                  title: 'Alpha',
                  content: const _TestCounterContent(label: 'Alpha'),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Beta: 0'), findsOneWidget);
      expect(find.text('Alpha: 1', skipOffstage: false), findsOneWidget);
    });

    testWidgets('does not force content to expand when expandContent is false',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 240,
              child: HuxTabView(
                expandContent: false,
                initialTabs: [
                  TabDocument(title: 'Tab 1', content: const Text('Content')),
                ],
              ),
            ),
          ),
        ),
      );

      final column = tester.widget<Column>(find.byType(Column).first);
      expect(column.children.whereType<Expanded>(), isEmpty);
      expect(column.children.whereType<Flexible>(), hasLength(1));
      expect(find.text('Content'), findsOneWidget);
    });

    group('Sizes', () {
      testWidgets('renders small size correctly', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: HuxTabView(
                size: HuxTabViewSize.small,
                initialTabs: [
                  TabDocument(title: 'Tab', content: const Text('Content')),
                ],
              ),
            ),
          ),
        );

        // Verify it renders without error
        expect(find.text('Tab'), findsOneWidget);
      });

      testWidgets('renders large size correctly', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: HuxTabView(
                size: HuxTabViewSize.large,
                initialTabs: [
                  TabDocument(title: 'Tab', content: const Text('Content')),
                ],
              ),
            ),
          ),
        );

        // Verify it renders without error
        expect(find.text('Tab'), findsOneWidget);
      });
    });

    group('Variants', () {
      testWidgets('renders pill variant with rounded corners',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: HuxTabView(
                variant: HuxTabViewVariant.pill,
                initialTabs: [
                  TabDocument(title: 'Tab', content: const Text('Content')),
                ],
              ),
            ),
          ),
        );

        expect(find.text('Tab'), findsOneWidget);
      });

      testWidgets('renders chrome variant', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: HuxTabView(
                variant: HuxTabViewVariant.chrome,
                initialTabs: [
                  TabDocument(title: 'Tab', content: const Text('Content')),
                ],
              ),
            ),
          ),
        );

        expect(find.text('Tab'), findsOneWidget);
      });
    });

    testWidgets('shows empty state with new tab button',
        (WidgetTester tester) async {
      bool newTabRequested = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HuxTabView(
              initialTabs: const [],
              showNewTabButton: true,
              onNewTabRequested: () => newTabRequested = true,
            ),
          ),
        ),
      );

      expect(find.text('Open a new tab'), findsOneWidget);

      await tester.tap(find.text('Open a new tab'));
      await tester.pump();

      expect(newTabRequested, isTrue);
    });

    testWidgets('truncates long tab titles with ellipsis',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HuxTabView(
              tabMaxWidth: 100,
              initialTabs: [
                TabDocument(
                  title: 'Very Long Document Name Here',
                  content: const Text('Content'),
                ),
              ],
            ),
          ),
        ),
      );

      final textWidget =
          tester.widget<Text>(find.text('Very Long Document Name Here'));
      expect(textWidget.overflow, equals(TextOverflow.ellipsis));
      expect(textWidget.maxLines, equals(1));
    });
  });
}

class _TestCounterContent extends StatefulWidget {
  const _TestCounterContent({required this.label});

  final String label;

  @override
  State<_TestCounterContent> createState() => _TestCounterContentState();
}

class _TestCounterContentState extends State<_TestCounterContent> {
  int count = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('${widget.label}: $count'),
        TextButton(
          key: ValueKey('increment-${widget.label}'),
          onPressed: () {
            setState(() {
              count++;
            });
          },
          child: const Text('Increment'),
        ),
      ],
    );
  }
}
