import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_text_styles.dart';
import '../../../shared/models/watchlist_model.dart';

class WatchlistItemCard extends StatelessWidget {
  const WatchlistItemCard({super.key, required this.item});

  final WatchlistModel item;

  @override
  Widget build(BuildContext context) {
    final product = item.product;
    final promotion = item.bestPromotion;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: CachedNetworkImage(
            imageUrl: product?.imageUrl ?? '',
            width: 56,
            height: 56,
            fit: BoxFit.cover,
            errorWidget: (_, __, ___) => const Icon(Icons.image_not_supported),
          ),
        ),
        title: Text(product?.name ?? 'Product', style: AppTextStyles.labelLarge),
        subtitle: Text(promotion?.retailerName ?? 'No active promotion'),
        trailing: Chip(
          label: Text(promotion != null ? 'On Sale' : 'Regular Price'),
          backgroundColor: promotion != null ? Colors.green.shade50 : Colors.grey.shade200,
        ),
      ),
    );
  }
}
