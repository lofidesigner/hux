import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:hux/src/components/buttons/hux_button.dart';
import 'package:hux/src/theme/hux_tokens.dart';
import 'package:hux/src/utils/hux_wcag.dart';
import 'package:flutter/material.dart';

/// A pagination component to navigate through pages.
///
/// Originally contributed by @Kingsley-EZE
/// Enhanced with Hux compliance, accessibility improvements, and documentation.
///
/// Displays page numbers and next/previous buttons, with logic to
/// handle a large number of pages by showing ellipses.
///
/// Example:
/// ```dart
/// HuxPagination(
///   currentPage: 5,
///   totalPages: 10,
///   onPageChanged: (page) {
///     print('Selected page: $page');
///   },
/// )
///
class HuxPagination extends StatelessWidget {
  /// Creates a [HuxPagination] widget.
  /// The [currentPage], [totalPages] and [onPageChanged] are required
  /// parameters
  const HuxPagination({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
    this.maxPagesToShow = 5,
  })  : assert(totalPages >= 1, 'totalPages must be ≥ 1'),
        assert(currentPage >= 1 && currentPage <= totalPages,
            'currentPage must be within 1..totalPages'),
        assert(maxPagesToShow >= 1, 'maxPagesToShow must be ≥ 1');

  /// The currently active page. Must be between 1 and [totalPages].
  final int currentPage;

  /// The total number of pages.
  final int totalPages;

  /// Callback function that is called when a page is selected.
  final ValueChanged<int> onPageChanged;

  /// The maximum number of page buttons to display at once.
  final int maxPagesToShow;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        HuxButton(
          onPressed:
              currentPage > 1 ? () => onPageChanged(currentPage - 1) : null,
          variant: HuxButtonVariant.outline,
          isDisabled: currentPage == 1,
          size: HuxButtonSize.small,
          icon: LucideIcons.chevronLeft,
          child: const SizedBox(width: 0), // Icon-only button
        ),
        const SizedBox(width: 8),
        ..._buildPageNumbers(context),
        const SizedBox(width: 8),
        HuxButton(
          onPressed: currentPage < totalPages
              ? () => onPageChanged(currentPage + 1)
              : null,
          variant: HuxButtonVariant.outline,
          isDisabled: currentPage == totalPages,
          size: HuxButtonSize.small,
          icon: LucideIcons.chevronRight,
          child: const SizedBox(width: 0), // Icon-only button
        ),
      ],
    );
  }

  List<Widget> _buildPageNumbers(BuildContext context) {
    if (totalPages <= maxPagesToShow) {
      return List.generate(
        totalPages,
        (index) => _buildPageButton(context, index + 1),
      );
    }

    final int budget = maxPagesToShow;
    int window = budget;

    int start = currentPage - ((window - 1) ~/ 2);
    int end = start + window - 1;

    void clampWindow() {
      if (start < 1) {
        start = 1;
        end = start + window - 1;
      }
      if (end > totalPages) {
        end = totalPages;
        start = end - window + 1;
      }
    }

    clampWindow();

    final int extras = (start > 1 ? 1 : 0) + (end < totalPages ? 1 : 0);

    if (extras > 0 && window + extras > budget) {
      window = (budget - extras).clamp(1, totalPages);
      start = currentPage - ((window - 1) ~/ 2);
      end = start + window - 1;
      clampWindow();
    }

    final List<Widget> widgets = [];
    if (start > 1) {
      widgets.add(_buildPageButton(context, 1));
      if (start > 2) {
        widgets.add(_buildEllipsis(context));
      }
    }

    for (int i = start; i <= end; i++) {
      widgets.add(_buildPageButton(context, i));
    }

    if (end < totalPages) {
      if (end < totalPages - 1) {
        widgets.add(_buildEllipsis(context));
      }
      widgets.add(_buildPageButton(context, totalPages));
    }

    return widgets;
  }

  Widget _buildPageButton(BuildContext context, int page) {
    final bool isSelected = page == currentPage;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0),
      child: HuxButton(
        onPressed: () => onPageChanged(page),
        variant: isSelected ? HuxButtonVariant.primary : HuxButtonVariant.ghost,
        size: HuxButtonSize.small,
        width: HuxButtonWidth.hug,
        child: Text(
          '$page',
          style: TextStyle(
            color: isSelected
                ? HuxWCAG.getContrastingTextColor(
                    backgroundColor: HuxTokens.primary(context),
                    context: context,
                  )
                : HuxTokens.textPrimary(context),
          ),
        ),
      ),
    );
  }

  Widget _buildEllipsis(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Text(
        '...',
        style: TextStyle(
          color: HuxTokens.textSecondary(context),
        ),
      ),
    );
  }
}
