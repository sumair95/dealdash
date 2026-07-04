import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/services/supabase_service.dart';
import '../providers/search_provider.dart';
import '../screens/search_results_screen.dart';
import '../widgets/barcode_scanner_button.dart';

class SearchScreen extends ConsumerWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(searchProvider, (previous, next) {
      if (next.showPaywall && previous?.showPaywall != true) {
        context.push('/subscription/paywall');
      }
    });

    final state = ref.watch(searchProvider);
    final categoriesAsync = ref.watch(_categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: AppStrings.searchHint,
            border: InputBorder.none,
          ),
          onChanged: ref.read(searchProvider.notifier).setQuery,
          onSubmitted: ref.read(searchProvider.notifier).setQuery,
        ),
        actions: [
          BarcodeScannerButton(
            onScanned: (barcode) => ref.read(searchProvider.notifier).setQuery(barcode),
          ),
        ],
      ),
      body: state.query.isNotEmpty
          ? SearchResultsScreen(query: state.query)
          : ListView(
              children: [
                const ListTile(title: Text('Recent searches')),
                ...state.recentSearches.map(
                  (query) => ListTile(
                    leading: const Icon(Icons.history),
                    title: Text(query),
                    onTap: () => ref.read(searchProvider.notifier).setQuery(query),
                  ),
                ),
                const ListTile(title: Text('Popular categories')),
                categoriesAsync.when(
                  loading: () => const Center(child: Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator(),
                  )),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (categories) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: categories
                          .where((c) => c.parentId == null)
                          .map(
                            (category) => ActionChip(
                              label: Text(category.name),
                              onPressed: () {
                                ref.read(searchProvider.notifier).setFilters(
                                      state.filters.copyWith(categoryId: category.id),
                                    );
                                ref.read(searchProvider.notifier).setQuery(category.name);
                              },
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

final _categoriesProvider = FutureProvider((ref) {
  return ref.read(supabaseServiceProvider).getCategories();
});
