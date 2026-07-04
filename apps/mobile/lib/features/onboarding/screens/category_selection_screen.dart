import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_strings.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/onboarding_provider.dart';

class CategorySelectionScreen extends ConsumerStatefulWidget {
  const CategorySelectionScreen({super.key});

  @override
  ConsumerState<CategorySelectionScreen> createState() => _CategorySelectionScreenState();
}

class _CategorySelectionScreenState extends ConsumerState<CategorySelectionScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(onboardingProvider.notifier).loadCategories());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingProvider);
    final user = ref.watch(userProvider).valueOrNull;
    final topLevel = state.categories.where((c) => c.parentId == null).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Choose your categories')),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: topLevel.length,
              itemBuilder: (_, index) {
                final category = topLevel[index];
                final selected = state.selectedCategoryIds.contains(category.id);
                return InkWell(
                  onTap: () => ref.read(onboardingProvider.notifier).toggleCategory(category.id),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected ? Theme.of(context).colorScheme.primary : Colors.grey.shade300,
                        width: selected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(_iconFor(category.iconName)),
                        const SizedBox(height: 8),
                        Text(category.name),
                      ],
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: state.selectedCategoryIds.isEmpty || user == null
              ? null
              : () async {
                  await ref.read(onboardingProvider.notifier).saveCategories(user.id);
                  if (context.mounted) context.go('/home');
                },
          child: const Text(AppStrings.continueLabel),
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
