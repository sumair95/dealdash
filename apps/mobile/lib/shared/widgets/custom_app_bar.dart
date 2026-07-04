import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showLogo = false,
  });

  final String title;
  final List<Widget>? actions;
  final bool showLogo;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.cardWhite,
      elevation: 0,
      title: Row(
        children: [
          if (showLogo) ...[
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.local_offer, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 8),
          ],
          Text(title, style: AppTextStyles.titleMedium),
        ],
      ),
      actions: actions,
    );
  }
}
