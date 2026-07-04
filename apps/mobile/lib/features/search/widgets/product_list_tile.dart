import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_text_styles.dart';
import '../../../shared/models/product_model.dart';

class ProductListTile extends StatelessWidget {
  const ProductListTile({super.key, required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => context.push('/product/${product.id}'),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CachedNetworkImage(
          imageUrl: product.imageUrl ?? '',
          width: 56,
          height: 56,
          fit: BoxFit.cover,
          errorWidget: (_, __, ___) => const Icon(Icons.image_not_supported),
        ),
      ),
      title: Text(product.name, style: AppTextStyles.labelLarge),
      subtitle: Text(product.brand ?? ''),
      trailing: const Icon(Icons.chevron_right),
    );
  }
}
