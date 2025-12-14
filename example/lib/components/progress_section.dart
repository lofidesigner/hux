import 'package:flutter/material.dart';
import 'package:hux/hux.dart';

class ProgressSection extends StatefulWidget {
  const ProgressSection({super.key});

  @override
  State<ProgressSection> createState() => _ProgressSectionState();
}

class _ProgressSectionState extends State<ProgressSection> {
  double _progressValue = 0.0;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _startProgress();
  }

  void _startProgress() {
    if (_isAnimating) return;
    setState(() {
      _isAnimating = true;
      _progressValue = 0.0;
    });

    _animateProgress();
  }

  void _animateProgress() {
    Future.delayed(const Duration(milliseconds: 50), () {
      if (!mounted) return;
      setState(() {
        _progressValue += 0.01;
        if (_progressValue >= 1.0) {
          _progressValue = 1.0;
          _isAnimating = false;
        } else {
          _animateProgress();
        }
      });
    });
  }

  void _resetProgress() {
    setState(() {
      _progressValue = 0.0;
      _isAnimating = false;
    });
    _startProgress();
  }

  @override
  Widget build(BuildContext context) {
    return HuxCard(
      size: HuxCardSize.large,
      backgroundColor: HuxColors.white5,
      borderColor: HuxTokens.borderSecondary(context),
      title: 'Progress',
      subtitle:
          'Linear progress indicators for task completion and status tracking',
      action: HuxButton(
        onPressed: _resetProgress,
        variant: HuxButtonVariant.ghost,
        size: HuxButtonSize.small,
        icon: LucideIcons.refreshCw,
        child: const SizedBox.shrink(),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = MediaQuery.of(context).size.width;
          final isMobileScreen = screenWidth < 768;
          final isTabletScreen = screenWidth >= 768 && screenWidth < 1024;
          final progressWidth = isMobileScreen
              ? constraints.maxWidth
              : isTabletScreen
                  ? constraints.maxWidth * 0.7
                  : 400.0;
          return Column(
            children: [
              const SizedBox(height: 16),
              Center(
                child: SizedBox(
                  width: progressWidth,
                  child: HuxProgress(
                    value: _progressValue,
                    label: 'Loading Progress',
                    showValue: true,
                    variant: HuxProgressVariant.primary,
                    size: HuxProgressSize.medium,
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }
}
