import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/constants/app_colors.dart';

class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({super.key, this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    if (child != null) {
      return Stack(
        children: [
          child!,
          const ColoredBox(
            color: Color(0x66000000),
            child: Center(child: CircularProgressIndicator()),
          ),
        ],
      );
    }
    return const Center(child: CircularProgressIndicator());
  }
}

class ShimmerBox extends StatelessWidget {
  const ShimmerBox({super.key, required this.height, this.width});

  final double height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.divider,
      highlightColor: AppColors.cardWhite,
      child: Container(
        width: width ?? double.infinity,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.divider,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
