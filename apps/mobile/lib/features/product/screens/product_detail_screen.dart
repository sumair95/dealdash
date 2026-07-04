import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/constants/app_text_styles.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../../shared/widgets/loading_overlay.dart';
import '../../watchlist/providers/watchlist_provider.dart';
import '../providers/product_provider.dart';
import '../widgets/price_comparison_table.dart';
import '../widgets/price_history_chart.dart';

class ProductDetailScreen extends ConsumerWidget {
  const ProductDetailScreen({super.key, required this.productId});

  final String productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(productDetailProvider(productId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product'),
        actions: [
          IconButton(
            onPressed: state.product == null
                ? null
                : () => Share.share('Check out ${state.product!.name} on DealDash'),
            icon: const Icon(Icons.share),
          ),
        ],
      ),
      floatingActionButton: state.product == null
          ? null
          : FloatingActionButton.extended(
              onPressed: () => ref.read(watchlistControllerProvider).add(productId),
              icon: const Icon(Icons.favorite_border),
              label: const Text('Add to Watchlist'),
            ),
      body: state.isLoading
          ? const LoadingOverlay()
          : state.error != null
              ? ErrorWidgetView(message: state.error!, onRetry: () => ref.invalidate(productDetailProvider(productId)))
              : ListView(
                  children: [
                    CachedNetworkImage(
                      imageUrl: state.product?.imageUrl ?? '',
                      height: 250,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => const SizedBox(
                        height: 250,
                        child: Icon(Icons.image_not_supported, size: 48),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(state.product?.name ?? '', style: AppTextStyles.titleLarge),
                          if (state.product?.brand != null)
                            Text(state.product!.brand!, style: AppTextStyles.bodyMedium),
                          const SizedBox(height: 8),
                          Text('In ${state.promotions.length} stores on sale'),
                          const SizedBox(height: 16),
                          PriceComparisonTable(promotions: state.promotions),
                          const SizedBox(height: 24),
                          PriceHistoryChart(history: state.history),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}
