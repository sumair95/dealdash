import 'package:flutter/material.dart';

import '../../../core/constants/app_text_styles.dart';
import '../../../shared/models/promotion_model.dart';
import 'retailer_row.dart';

class PriceComparisonTable extends StatelessWidget {
  const PriceComparisonTable({super.key, required this.promotions});

  final List<PromotionModel> promotions;

  @override
  Widget build(BuildContext context) {
    if (promotions.isEmpty) {
      return const Text('No active promotions found.');
    }

    final bestPrice = promotions.map((p) => p.salePrice).reduce((a, b) => a < b ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Price comparison', style: AppTextStyles.titleMedium),
        const SizedBox(height: 12),
        ...promotions.map(
          (promotion) => RetailerRow(
            promotion: promotion,
            highlighted: promotion.salePrice == bestPrice,
          ),
        ),
      ],
    );
  }
}
