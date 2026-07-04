import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/models/promotion_model.dart';

class DealCardHorizontal extends StatelessWidget {
  const DealCardHorizontal({super.key, required this.deal});

  final PromotionModel deal;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push('/product/${deal.productId}'),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.cardWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: deal.imageUrl ?? '',
                width: 72,
                height: 72,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => const Icon(Icons.image_not_supported),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(deal.productName, maxLines: 2, overflow: TextOverflow.ellipsis, style: AppTextStyles.labelLarge),
                  Text(deal.retailerName, style: AppTextStyles.bodyMedium),
                  const SizedBox(height: 4),
                  Text(
                    '${Formatters.currency(deal.salePrice)} · SAVE ${Formatters.discountPct(deal.discountPct)}',
                    style: AppTextStyles.priceSale.copyWith(fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
