import 'product_model.dart';
import 'promotion_model.dart';

class WatchlistModel {
  const WatchlistModel({
    required this.id,
    required this.userId,
    required this.productId,
    this.product,
    this.bestPromotion,
    this.targetPrice,
    this.notifyAnyDrop = true,
  });

  final String id;
  final String userId;
  final String productId;
  final ProductModel? product;
  final PromotionModel? bestPromotion;
  final double? targetPrice;
  final bool notifyAnyDrop;

  factory WatchlistModel.fromJson(Map<String, dynamic> json) {
    return WatchlistModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      productId: json['product_id'] as String,
      product: json['products'] != null
          ? ProductModel.fromJson(json['products'] as Map<String, dynamic>)
          : null,
      bestPromotion: json['best_promotion'] != null
          ? PromotionModel.fromJson(
              json['best_promotion'] as Map<String, dynamic>,
            )
          : null,
      targetPrice: json['target_price'] != null
          ? double.tryParse(json['target_price'].toString())
          : null,
      notifyAnyDrop: json['notify_any_drop'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'product_id': productId,
        'target_price': targetPrice,
        'notify_any_drop': notifyAnyDrop,
      };

  WatchlistModel copyWith({
    String? id,
    String? userId,
    String? productId,
    ProductModel? product,
    PromotionModel? bestPromotion,
    double? targetPrice,
    bool? notifyAnyDrop,
  }) {
    return WatchlistModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      productId: productId ?? this.productId,
      product: product ?? this.product,
      bestPromotion: bestPromotion ?? this.bestPromotion,
      targetPrice: targetPrice ?? this.targetPrice,
      notifyAnyDrop: notifyAnyDrop ?? this.notifyAnyDrop,
    );
  }
}
