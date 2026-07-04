import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/models/promotion_model.dart';

class RetailerRow extends StatelessWidget {
  const RetailerRow({
    super.key,
    required this.promotion,
    this.highlighted = false,
  });

  final PromotionModel promotion;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: highlighted ? AppColors.highlightGreen : AppColors.cardWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          if (promotion.retailerLogo != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: CachedNetworkImage(
                imageUrl: promotion.retailerLogo!,
                width: 36,
                height: 36,
                errorWidget: (_, __, ___) => const Icon(Icons.store),
              ),
            )
          else
            const Icon(Icons.store),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(promotion.retailerName, style: AppTextStyles.labelLarge),
                Text(
                  '${Formatters.currency(promotion.regularPrice)} → ${Formatters.currency(promotion.salePrice)}',
                ),
                Text('Save ${Formatters.discountPct(promotion.discountPct)}'),
              ],
            ),
          ),
          TextButton(
            onPressed: promotion.productUrl == null
                ? null
                : () => launchUrl(Uri.parse(promotion.productUrl!)),
            child: const Text('Go to Store'),
          ),
        ],
      ),
    );
  }
}
