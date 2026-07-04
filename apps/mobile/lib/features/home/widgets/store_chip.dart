import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class StoreChip extends StatelessWidget {
  const StoreChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label, style: AppTextStyles.labelSmall),
        selected: selected,
        onSelected: onTap == null ? null : (_) => onTap!(),
        selectedColor: AppColors.primaryBlue.withValues(alpha: 0.15),
        checkmarkColor: AppColors.primaryBlue,
      ),
    );
  }
}
