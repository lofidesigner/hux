import 'package:flutter/material.dart';
import 'package:hux/hux.dart';
import 'section_with_documentation.dart';

class PaginationSection extends StatefulWidget {
  const PaginationSection({super.key});

  @override
  State<PaginationSection> createState() => _PaginationSectionState();
}

class _PaginationSectionState extends State<PaginationSection> {
  int _currentPage = 1;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    // Reduce pages on mobile to prevent overflow
    final totalPages = isMobile ? 10 : 20;
    final maxPagesToShow = isMobile ? 3 : 5;

    // Clamp current page to valid range if totalPages changed
    final currentPage = _currentPage.clamp(1, totalPages);

    return SectionWithDocumentation(
      componentName: 'pagination',
      child: HuxCard(
        size: HuxCardSize.large,
        backgroundColor: HuxColors.white5,
        borderColor: HuxTokens.borderSecondary(context),
        title: 'Pagination',
        subtitle: 'Navigate through pages with intelligent ellipsis handling',
        child: Column(
          children: [
            const SizedBox(height: 16),
            HuxPagination(
              currentPage: currentPage,
              totalPages: totalPages,
              maxPagesToShow: maxPagesToShow,
              onPageChanged: (page) {
                setState(() {
                  _currentPage = page;
                });
              },
            ),
            const SizedBox(height: 16),
            Text(
              'Current Page: $currentPage',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: HuxTokens.textSecondary(context),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
