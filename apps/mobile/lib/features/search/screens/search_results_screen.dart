import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../../../shared/widgets/error_widget.dart';
import '../providers/search_provider.dart';
import '../widgets/filter_chips_row.dart';
import '../widgets/product_list_tile.dart';

class SearchResultsScreen extends ConsumerWidget {
  const SearchResultsScreen({super.key, required this.query});

  final String query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(searchProvider);

    return Column(
      children: [
        const FilterChipsRow(),
        Expanded(
          child: state.isLoading
              ? const Center(child: CircularProgressIndicator())
              : state.error != null
                  ? ErrorWidgetView(message: state.error!)
                  : state.results.isEmpty
                      ? EmptyStateWidget(
                          title: '${AppStrings.noDealsFound} for "$query"',
                          icon: Icons.search_off,
                        )
                      : ListView.builder(
                          itemCount: state.results.length,
                          itemBuilder: (_, index) =>
                              ProductListTile(product: state.results[index]),
                        ),
        ),
      ],
    );
  }
}
