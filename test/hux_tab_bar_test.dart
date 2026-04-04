import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hux/hux.dart';

void main() {
  group('HuxTabBarController', () {
    test('initializes with correct values', () {
      final controller = HuxTabBarController(
        initialTabs: [
          const HuxTabBarItem(
            label: 'Tab 1',
            content: Text('Content 1'),
          ),
          const HuxTabBarItem(
            label: 'Tab 2',
            content: Text('Content 2'),
          ),
        ],
        initialIndex: 1,
      );

      expect(controller.tabCount, 2);
      expect(controller.activeIndex, 1);
      expect(controller.getContent, isA<Text>());
    });

    test('handles invalid initial index', () {
      final controller = HuxTabBarController(
        initialTabs: [
          const HuxTabBarItem(
            label: 'Tab 1',
            content: Text('Content 1'),
          ),
        ],
        initialIndex: 10,
      );

      expect(controller.activeIndex, 0);
    });

    test('adds tab correctly', () {
      final controller = HuxTabBarController(
        initialTabs: [
          const HuxTabBarItem(
            label: 'Tab 1',
            content: Text('Content 1'),
          ),
        ],
      );

      controller.addTab(
        const HuxTabBarItem(
          label: 'Tab 2',
          content: Text('Content 2'),
        ),
      );

      expect(controller.tabCount, 2);
      expect(controller.activeIndex, 1);
    });

    test('removes tab correctly', () {
      final controller = HuxTabBarController(
        initialTabs: [
          const HuxTabBarItem(
            label: 'Tab 1',
            content: Text('Content 1'),
          ),
          const HuxTabBarItem(
            label: 'Tab 2',
            content: Text('Content 2'),
          ),
        ],
        initialIndex: 1,
      );

      controller.removeTab(1);

      expect(controller.tabCount, 1);
      expect(controller.activeIndex, 0);
    });

    test('sets active index correctly', () {
      final controller = HuxTabBarController(
        initialTabs: [
          const HuxTabBarItem(
            label: 'Tab 1',
            content: Text('Content 1'),
          ),
          const HuxTabBarItem(
            label: 'Tab 2',
            content: Text('Content 2'),
          ),
        ],
      );

      controller.setActiveIndex(1);

      expect(controller.activeIndex, 1);
    });

    test('reorders tabs correctly', () {
      final controller = HuxTabBarController(
        initialTabs: [
          const HuxTabBarItem(
            label: 'Tab 1',
            content: Text('Content 1'),
          ),
          const HuxTabBarItem(
            label: 'Tab 2',
            content: Text('Content 2'),
          ),
          const HuxTabBarItem(
            label: 'Tab 3',
            content: Text('Content 3'),
          ),
        ],
        initialIndex: 0,
      );

      controller.reorderTabs(0, 2);

      expect(controller.getTab(1).label, 'Tab 1');
      expect(controller.activeIndex, 1);
    });
  });

  group('HuxTabBar Widget', () {
    testWidgets('renders tabs correctly', (WidgetTester tester) async {
      final controller = HuxTabBarController(
        initialTabs: [
          const HuxTabBarItem(
            label: 'Tab 1',
            content: Text('Content 1'),
          ),
          const HuxTabBarItem(
            label: 'Tab 2',
            content: Text('Content 2'),
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HuxTabBar(
              controller: controller,
            ),
          ),
        ),
      );

      expect(find.text('Tab 1'), findsOneWidget);
      expect(find.text('Tab 2'), findsOneWidget);
    });

    testWidgets('switches tabs on tap', (WidgetTester tester) async {
      final controller = HuxTabBarController(
        initialTabs: [
          const HuxTabBarItem(
            label: 'Tab 1',
            content: Text('Content 1'),
          ),
          const HuxTabBarItem(
            label: 'Tab 2',
            content: Text('Content 2'),
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HuxTabBar(
              controller: controller,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Tab 2'));
      await tester.pump();

      expect(controller.activeIndex, 1);
    });

    testWidgets('calls onAddTab when add button is pressed',
        (WidgetTester tester) async {
      final controller = HuxTabBarController(
        initialTabs: [
          const HuxTabBarItem(
            label: 'Tab 1',
            content: Text('Content 1'),
          ),
        ],
      );

      var addTabCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HuxTabBar(
              controller: controller,
              onAddTab: () {
                addTabCalled = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      expect(addTabCalled, true);
    });
  });
}
