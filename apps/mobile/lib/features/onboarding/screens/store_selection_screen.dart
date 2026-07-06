import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/services/supabase_service.dart';
import '../providers/onboarding_provider.dart';

class StoreSelectionScreen extends ConsumerStatefulWidget {
  const StoreSelectionScreen({super.key});

  @override
  ConsumerState<StoreSelectionScreen> createState() => _StoreSelectionScreenState();
}

class _StoreSelectionScreenState extends ConsumerState<StoreSelectionScreen> {
  var _saving = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(onboardingProvider.notifier).loadRetailers());
  }

  Future<void> _continue() async {
    final selectedCount = ref.read(onboardingProvider).selectedRetailerIds.length;
    if (selectedCount == 0 || _saving) return;

    setState(() => _saving = true);
    try {
      final userId = ref.read(supabaseServiceProvider).currentAuthUser?.id;
      if (userId != null) {
        await ref.read(onboardingProvider.notifier).saveRetailers(userId);
      }
      if (mounted) context.go('/onboarding/categories');
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save stores: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingProvider);
    final selectedCount = state.selectedRetailerIds.length;
    final canContinue = selectedCount > 0 && !_saving;

    return Scaffold(
      appBar: AppBar(title: const Text('Choose your stores')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Text(
              'Pick the retailers you shop at most. We will prioritise deals from these stores.',
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
                : state.retailers.isEmpty
                    ? Center(
                        child: Text(
                          'No stores found. Check your connection and try again.',
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
                          childAspectRatio: 1.2,
                        ),
                        itemCount: state.retailers.length,
                        itemBuilder: (_, index) {
                          final retailer = state.retailers[index];
                          final selected = state.selectedRetailerIds.contains(retailer.id);
                          return InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () =>
                                ref.read(onboardingProvider.notifier).toggleRetailer(retailer.id),
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
                                boxShadow: selected
                                    ? [
                                        BoxShadow(
                                          color: AppColors.primaryBlue.withValues(alpha: 0.12),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Stack(
                                children: [
                                  Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Text(
                                        retailer.name,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontWeight:
                                              selected ? FontWeight.w600 : FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (selected)
                                    const Positioned(
                                      top: 8,
                                      right: 8,
                                      child: Icon(Icons.check_circle, color: AppColors.primaryBlue),
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
                    'Select at least one store to continue',
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
}
