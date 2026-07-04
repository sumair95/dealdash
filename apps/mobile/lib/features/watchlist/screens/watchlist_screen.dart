import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../../../shared/widgets/error_widget.dart';
import '../providers/watchlist_provider.dart';
import '../widgets/watchlist_item_card.dart';

class WatchlistScreen extends ConsumerWidget {
  const WatchlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final watchlistAsync = ref.watch(watchlistProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Watchlist')),
      body: watchlistAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorWidgetView(
          message: e.toString(),
          onRetry: () => ref.invalidate(watchlistProvider),
        ),
        data: (items) {
          if (items.isEmpty) {
            return const EmptyStateWidget(
              title: AppStrings.watchlistEmpty,
              icon: Icons.favorite_border,
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(watchlistProvider),
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (_, index) {
                final item = items[index];
                return Dismissible(
                  key: ValueKey(item.id),
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) =>
                      ref.read(watchlistControllerProvider).remove(item.id),
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 24),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  child: WatchlistItemCard(item: item),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
