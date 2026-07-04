import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/supabase_service.dart';
import '../../home/widgets/store_chip.dart';
import '../providers/search_provider.dart';

class FilterChipsRow extends ConsumerWidget {
  const FilterChipsRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(searchProvider).filters;
    final retailersAsync = ref.watch(_retailersProvider);

    return SizedBox(
      height: 44,
      child: retailersAsync.when(
        loading: () => const Center(child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))),
        error: (_, __) => const SizedBox.shrink(),
        data: (retailers) => ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            StoreChip(
              label: 'All Stores',
              selected: filters.retailerId == null,
              onTap: () => ref.read(searchProvider.notifier).setFilters(
                    filters.copyWith(clearRetailerId: true),
                  ),
            ),
            ...retailers.map(
              (retailer) => StoreChip(
                label: retailer.name,
                selected: filters.retailerId == retailer.id,
                onTap: () => ref.read(searchProvider.notifier).setFilters(
                      filters.copyWith(retailerId: retailer.id),
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final _retailersProvider = FutureProvider((ref) {
  return ref.read(supabaseServiceProvider).getRetailers();
});
