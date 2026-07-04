import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;

  final _slides = const [
    ('Find real savings', 'Track genuine discounts across 15 major Australian retailers.'),
    ('Watch what matters', 'Add products to your watchlist and get alerted when prices drop.'),
    ('Shop smarter', 'Compare prices, history, and promotions before you buy.'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () => context.go('/login'),
                child: const Text(AppStrings.onboardingSkip),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _slides.length,
                onPageChanged: (value) => setState(() => _index = value),
                itemBuilder: (_, index) {
                  final slide = _slides[index];
                  return Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 180,
                          height: 180,
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: const Icon(Icons.savings_outlined, size: 80, color: AppColors.primaryBlue),
                        ),
                        const SizedBox(height: 32),
                        Text(slide.$1, style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.center),
                        const SizedBox(height: 12),
                        Text(slide.$2, textAlign: TextAlign.center),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _slides.length,
                (index) => Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _index == index ? AppColors.primaryBlue : AppColors.divider,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_index < _slides.length - 1) {
                      _controller.nextPage(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOut,
                      );
                    } else {
                      context.go('/onboarding/stores');
                    }
                  },
                  child: Text(
                    _index < _slides.length - 1
                        ? AppStrings.onboardingNext
                        : AppStrings.onboardingGetStarted,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
