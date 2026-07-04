import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/models/price_history_model.dart';

class PriceHistoryChart extends StatelessWidget {
  const PriceHistoryChart({super.key, required this.history});

  final List<PriceHistoryModel> history;

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return const Text('Price history will appear once promotions are scraped.');
    }

    final sorted = [...history]
      ..sort((a, b) => (a.scrapedAt ?? DateTime.now()).compareTo(b.scrapedAt ?? DateTime.now()));
    final spots = <FlSpot>[];
    for (var i = 0; i < sorted.length; i++) {
      spots.add(FlSpot(i.toDouble(), sorted[i].salePrice));
    }
    final lowest = sorted.reduce((a, b) => a.salePrice < b.salePrice ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Price history', style: AppTextStyles.titleMedium),
        const SizedBox(height: 12),
        SizedBox(
          height: 220,
          child: LineChart(
            LineChartData(
              gridData: const FlGridData(show: true),
              titlesData: const FlTitlesData(show: true),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  dotData: const FlDotData(show: false),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Lowest ever: ${Formatters.currency(lowest.salePrice)} (${lowest.retailerName ?? 'Retailer'}, ${Formatters.dateShort(lowest.scrapedAt ?? DateTime.now())})',
          style: AppTextStyles.bodyMedium,
        ),
      ],
    );
  }
}
