import 'package:flutter/material.dart';

import '../../../core/constants/app_text_styles.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.action});

  final String title;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Expanded(child: Text(title, style: AppTextStyles.titleLarge)),
          if (action != null) action!,
        ],
      ),
    );
  }
}
