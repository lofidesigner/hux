import 'package:flutter/material.dart';
import 'package:hux/hux.dart';
import 'section_with_documentation.dart';

class TabViewSection extends StatefulWidget {
  const TabViewSection({super.key});

  @override
  State<TabViewSection> createState() => _TabViewSectionState();
}

class _TabViewSectionState extends State<TabViewSection> {
  late List<TabDocument> _tabs;
  int _untitledCount = 0;

  @override
  void initState() {
    super.initState();
    _tabs = [
      TabDocument(
        title: 'document.md',
        icon: LucideIcons.fileText,
        content: Builder(builder: (context) => _buildMarkdownPreview(context)),
      ),
      TabDocument(
        title: 'main.dart',
        icon: LucideIcons.code,
        content: _buildCodePreview(),
      ),
    ];
  }

  Widget _buildMarkdownPreview(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Getting Started',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: HuxTokens.textPrimary(context),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'This is a sample markdown document to demonstrate the tab view component. It supports rich content and scrolling.',
            style: TextStyle(
              fontSize: 14,
              color: HuxTokens.textSecondary(context),
              height: 1.6,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: HuxTokens.surfaceElevated(context),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: HuxTokens.borderSecondary(context)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Features',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: HuxTokens.textPrimary(context),
                  ),
                ),
                const SizedBox(height: 12),
                _buildFeatureItem('Dynamic tab management'),
                _buildFeatureItem('Closable tabs with hover effects'),
                _buildFeatureItem('New tab button with tooltip'),
                _buildFeatureItem('Keyboard shortcuts support'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(LucideIcons.check, size: 16, color: HuxTokens.primary(context)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                  fontSize: 13, color: HuxTokens.textSecondary(context)),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildCodePreview() {
    return Container(
      color: const Color(0xFF1E1E1E),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCodeLine(
                'import \'package:flutter/material.dart\';', 'import'),
            _buildCodeLine('import \'package:hux/hux.dart\';', 'import'),
            const SizedBox(height: 16),
            _buildCodeLine('class MyApp extends StatelessWidget {', 'class'),
            _buildCodeLine('  @override', 'meta'),
            _buildCodeLine('  Widget build(BuildContext context) {', 'method'),
            _buildCodeLine('    return MaterialApp(', 'widget'),
            _buildCodeLine('      title: \'Hux Demo\',', 'string'),
            _buildCodeLine('      theme: ThemeData(', 'method'),
            _buildCodeLine('        primarySwatch: Colors.blue,', 'prop'),
            _buildCodeLine('      ),', 'method'),
            _buildCodeLine('      home: HuxTabView(...),', 'widget'),
            _buildCodeLine('    );', 'widget'),
            _buildCodeLine('  }', 'method'),
            _buildCodeLine('}', 'class'),
          ],
        ),
      ),
    );
  }

  static Widget _buildCodeLine(String code, String type) {
    final colors = {
      'import': const Color(0xFFC586C0),
      'class': const Color(0xFF569CD6),
      'method': const Color(0xFFDCDCAA),
      'string': const Color(0xFFCE9178),
      'widget': const Color(0xFF4EC9B0),
      'meta': const Color(0xFF9CDCFE),
      'prop': const Color(0xFF9CDCFE),
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        code,
        style: TextStyle(
          fontFamily: 'monospace',
          fontSize: 13,
          color: colors[type] ?? const Color(0xFFD4D4D4),
        ),
      ),
    );
  }

  void _addNewTab() {
    setState(() {
      _untitledCount++;
      _tabs = [
        ..._tabs,
        TabDocument(
          title: 'Untitled $_untitledCount',
          icon: LucideIcons.file,
          content: Builder(builder: (context) => _buildEmptyState(context)),
        ),
      ];
    });
  }

  static Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.fileText,
            size: 48,
            color: HuxTokens.iconSecondary(context),
          ),
          const SizedBox(height: 16),
          Text(
            'Empty document',
            style: TextStyle(
              fontSize: 14,
              color: HuxTokens.textPrimary(context),
            ),
          ),
        ],
      ),
    );
  }

  void _closeTab(int index, TabDocument doc) {
    setState(() {
      // Create NEW list so TabView detects the change
      _tabs = [..._tabs]..removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SectionWithDocumentation(
      componentName: 'tab-view',
      child: HuxCard(
        size: HuxCardSize.large,
        backgroundColor: HuxColors.white5,
        borderColor: HuxTokens.borderSecondary(context),
        title: 'TabView',
        subtitle: 'Dynamic workspace management with closable tabs',
        child: SizedBox(
          height: 300,
          child: HuxTabView(
            initialTabs: _tabs,
            showNewTabButton: true,
            onNewTabRequested: _addNewTab,
            onTabClosed: _closeTab,
          ),
        ),
      ),
    );
  }
}
