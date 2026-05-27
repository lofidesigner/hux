import 'package:flutter/material.dart';
import 'package:hux/hux.dart';
import 'section_with_documentation.dart';

class TabViewSection extends StatefulWidget {
  const TabViewSection({super.key});

  @override
  State<TabViewSection> createState() => _TabViewSectionState();
}

class _TabViewSectionState extends State<TabViewSection> {
  HuxTabViewVariant _selectedVariant = HuxTabViewVariant.pill;
  late HuxTabViewController _controller;

  HuxTabViewController _createController() {
    return HuxTabViewController(
      initialTabs: [
        TabDocument(
          title: 'document.md',
          icon: LucideIcons.fileText,
          identifier: 'doc',
          content: _DeferredMarkdownPreview(),
        ),
        TabDocument(
          title: 'main.dart',
          icon: LucideIcons.code,
          identifier: 'code',
          content: const _CodePreview(),
        ),
        TabDocument(
          title: 'README.md',
          icon: LucideIcons.bookOpen,
          identifier: 'readme',
          content: const _ReadmePreview(),
        ),
      ],
      initialIndex: 0,
    );
  }

  @override
  void initState() {
    super.initState();
    _controller = _createController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
        subtitle: 'Dynamic workspace with drag-to-reorder, 2 variants (default, chrome), controller support',
        action: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            HuxButton(
              onPressed: () {
                final oldController = _controller;
                setState(() {
                  _controller = _createController();
                });
                // Dispose old controller after frame to avoid widget tree issues
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  oldController.dispose();
                });
              },
              variant: HuxButtonVariant.ghost,
              size: HuxButtonSize.small,
              icon: LucideIcons.rotateCcw,
              child: const Text('Reset'),
            ),
            const SizedBox(width: 16),
            Text(
              'Variant:',
              style: TextStyle(
                color: HuxTokens.textSecondary(context),
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 140,
              child: HuxDropdown<HuxTabViewVariant>(
                items: const [
                  HuxDropdownItem(
                    value: HuxTabViewVariant.pill,
                    child: Text('Default'),
                  ),
                  HuxDropdownItem(
                    value: HuxTabViewVariant.chrome,
                    child: Text('Chrome'),
                  ),
                ],
                value: _selectedVariant,
                onChanged: (value) {
                  setState(() {
                    _selectedVariant = value;
                  });
                },
                placeholder: 'Select variant',
                variant: HuxButtonVariant.outline,
                size: HuxButtonSize.small,
              ),
            ),
          ],
        ),
        child: SizedBox(
          height: 300,
          child: HuxTabView(
            controller: _controller,
            variant: _selectedVariant,
            showNewTabButton: true,
            onTabClosed: (index, doc) {
              context.showHuxSnackbar(
                message: 'Closed: ${doc.title}',
                variant: HuxSnackbarVariant.info,
              );
            },
            onTabChanged: (index) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Switched to tab $index')),
              );
            },
          ),
        ),
      ),
    );
  }
}

// Widget classes that defer context access until build time

class _DeferredMarkdownPreview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
                _buildFeatureItem(context, 'Dynamic tab management'),
                _buildFeatureItem(context, 'Closable tabs with hover effects'),
                _buildFeatureItem(context, 'New tab button with tooltip'),
                _buildFeatureItem(context, 'Keyboard shortcuts support'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(BuildContext context, String text) {
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
}

class _CodePreview extends StatelessWidget {
  const _CodePreview();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1E1E1E),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCodeLine("import 'package:flutter/material.dart';", 'import'),
            _buildCodeLine("import 'package:hux/hux.dart';", 'import'),
            const SizedBox(height: 16),
            _buildCodeLine('class MyApp extends StatelessWidget {', 'class'),
            _buildCodeLine('  @override', 'meta'),
            _buildCodeLine('  Widget build(BuildContext context) {', 'method'),
            _buildCodeLine('    return MaterialApp(', 'widget'),
            _buildCodeLine("      title: 'Hux Demo',", 'string'),
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

  Widget _buildCodeLine(String code, String type) {
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
}

class _ReadmePreview extends StatelessWidget {
  const _ReadmePreview();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'README',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: HuxTokens.textPrimary(context),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Drag-to-reorder: Long press and drag tabs to reorder them. Mouse users can drag immediately, touch users need a brief hold.',
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
                _buildFeatureItem(context, 'Drag-to-reorder support'),
                _buildFeatureItem(context, 'Two visual variants (pill, chrome)'),
                _buildFeatureItem(context, 'External controller support'),
                _buildFeatureItem(context, 'Keyboard shortcuts (Ctrl+T, Ctrl+W)'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(BuildContext context, String text) {
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
}
