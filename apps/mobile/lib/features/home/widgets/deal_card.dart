import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/models/promotion_model.dart';

class DealCard extends StatelessWidget {
  const DealCard({super.key, required this.deal, this.compact = false});

  final PromotionModel deal;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push('/product/${deal.productId}'),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: compact ? double.infinity : 220,
        margin: const EdgeInsets.only(right: 12, bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.cardWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: CachedNetworkImage(
                    imageUrl: deal.imageUrl ?? '',
                    height: compact ? 120 : 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => Container(
                      height: compact ? 120 : 180,
                      color: AppColors.divider,
                      child: const Icon(Icons.image_not_supported),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(deal.retailerName, style: AppTextStyles.labelSmall),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(deal.productName, maxLines: 2, overflow: TextOverflow.ellipsis, style: AppTextStyles.labelLarge),
                  if (deal.brand != null)
                    Text(deal.brand!, style: AppTextStyles.bodyMedium),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(Formatters.currency(deal.regularPrice), style: AppTextStyles.priceRegular),
                      const SizedBox(width: 8),
                      Text(Formatters.currency(deal.salePrice), style: AppTextStyles.priceSale),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      Chip(
                        label: Text('SAVE ${Formatters.discountPct(deal.discountPct)}'),
                        backgroundColor: AppColors.accentOrange.withValues(alpha: 0.12),
                        labelStyle: AppTextStyles.priceSavings,
                      ),
                      if (deal.promotionEndsAt != null)
                        Chip(
                          label: Text(Formatters.countdown(deal.promotionEndsAt)),
                          labelStyle: AppTextStyles.labelSmall,
                        ),
                    ],
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
