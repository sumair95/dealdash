import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/services/supabase_service.dart';
import '../providers/onboarding_provider.dart';

class CategorySelectionScreen extends ConsumerStatefulWidget {
  const CategorySelectionScreen({super.key});

  @override
  ConsumerState<CategorySelectionScreen> createState() => _CategorySelectionScreenState();
}

class _CategorySelectionScreenState extends ConsumerState<CategorySelectionScreen> {
  var _saving = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(onboardingProvider.notifier).loadCategories());
  }

  Future<void> _continue() async {
    final selectedCount = ref.read(onboardingProvider).selectedCategoryIds.length;
    if (selectedCount == 0 || _saving) return;

    setState(() => _saving = true);
    try {
      final userId = ref.read(supabaseServiceProvider).currentAuthUser?.id;
      if (userId != null) {
        await ref.read(onboardingProvider.notifier).saveCategories(userId);
        if (mounted) context.go('/home');
        return;
      }
      if (mounted) context.go('/register');
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save categories: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingProvider);
    final topLevel = state.categories.where((c) => c.parentId == null).toList();
    final selectedCount = state.selectedCategoryIds.length;
    final canContinue = selectedCount > 0 && !_saving;

    return Scaffold(
      appBar: AppBar(title: const Text('Choose your categories')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Text(
              'Tell us what you shop for so we can surface the most relevant deals.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ),
          if (selectedCount > 0)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Text(
                '$selectedCount selected',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : topLevel.isEmpty
                    ? Center(
                        child: Text(
                          'No categories found. Check your connection and try again.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.1,
                        ),
                        itemCount: topLevel.length,
                        itemBuilder: (_, index) {
                          final category = topLevel[index];
                          final selected = state.selectedCategoryIds.contains(category.id);
                          return InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () =>
                                ref.read(onboardingProvider.notifier).toggleCategory(category.id),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              decoration: BoxDecoration(
                                color: selected
                                    ? AppColors.primaryBlue.withValues(alpha: 0.08)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: selected
                                      ? AppColors.primaryBlue
                                      : Colors.grey.shade300,
                                  width: selected ? 2 : 1,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    _iconFor(category.iconName),
                                    color: selected
                                        ? AppColors.primaryBlue
                                        : AppColors.textSecondary,
                                    size: 28,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    category.name,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight:
                                          selected ? FontWeight.w600 : FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (selectedCount == 0)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    'Select at least one category to continue',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: canContinue ? _continue : null,
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          selectedCount > 0
                              ? '${AppStrings.continueLabel} ($selectedCount)'
                              : AppStrings.continueLabel,
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconFor(String? iconName) {
    switch (iconName) {
      case 'local_grocery_store':
        return Icons.local_grocery_store;
      case 'devices':
        return Icons.devices;
      case 'grass':
        return Icons.grass;
      case 'handyman':
        return Icons.handyman;
      default:
        return Icons.category;
    }
  }
}
