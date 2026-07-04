import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_strings.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/onboarding_provider.dart';

class StoreSelectionScreen extends ConsumerStatefulWidget {
  const StoreSelectionScreen({super.key});

  @override
  ConsumerState<StoreSelectionScreen> createState() => _StoreSelectionScreenState();
}

class _StoreSelectionScreenState extends ConsumerState<StoreSelectionScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(onboardingProvider.notifier).loadRetailers());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingProvider);
    final user = ref.watch(userProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(title: const Text('Choose your stores')),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
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
                  onTap: () => ref.read(onboardingProvider.notifier).toggleRetailer(retailer.id),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected ? Theme.of(context).colorScheme.primary : Colors.grey.shade300,
                        width: selected ? 2 : 1,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Center(child: Text(retailer.name, textAlign: TextAlign.center)),
                        if (selected)
                          const Positioned(
                            top: 8,
                            right: 8,
                            child: Icon(Icons.check_circle, color: Colors.green),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: state.selectedRetailerIds.isEmpty || user == null
              ? null
              : () async {
                  await ref.read(onboardingProvider.notifier).saveRetailers(user.id);
                  if (context.mounted) context.go('/onboarding/categories');
                },
          child: const Text(AppStrings.continueLabel),
        ),
      ),
    );
  }
}
