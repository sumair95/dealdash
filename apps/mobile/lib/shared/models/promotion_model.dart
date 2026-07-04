class PromotionModel {
  const PromotionModel({
    required this.id,
    required this.productId,
    required this.productName,
    this.brand,
    this.imageUrl,
    required this.retailerId,
    required this.retailerName,
    this.retailerLogo,
    required this.regularPrice,
    required this.salePrice,
    required this.discountPct,
    this.promotionType,
    this.promotionEndsAt,
    this.productUrl,
  });

  final String id;
  final String productId;
  final String productName;
  final String? brand;
  final String? imageUrl;
  final String retailerId;
  final String retailerName;
  final String? retailerLogo;
  final double regularPrice;
  final double salePrice;
  final double discountPct;
  final String? promotionType;
  final DateTime? promotionEndsAt;
  final String? productUrl;

  factory PromotionModel.fromJson(Map<String, dynamic> json) {
    return PromotionModel(
      id: json['id'] as String? ?? json['product_id'] as String,
      productId: json['product_id'] as String,
      productName: json['product_name'] as String,
      brand: json['brand'] as String?,
      imageUrl: json['image_url'] as String?,
      retailerId: json['retailer_id'] as String,
      retailerName: json['retailer_name'] as String,
      retailerLogo: json['retailer_logo'] as String?,
      regularPrice: _toDouble(json['regular_price']),
      salePrice: _toDouble(json['sale_price']),
      discountPct: _toDouble(json['discount_pct']),
      promotionType: json['promotion_type'] as String?,
      promotionEndsAt: json['promotion_ends_at'] != null
          ? DateTime.tryParse(json['promotion_ends_at'] as String)
          : null,
      productUrl: json['product_url'] as String?,
    );
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'product_id': productId,
        'product_name': productName,
        'brand': brand,
        'image_url': imageUrl,
        'retailer_id': retailerId,
        'retailer_name': retailerName,
        'retailer_logo': retailerLogo,
        'regular_price': regularPrice,
        'sale_price': salePrice,
        'discount_pct': discountPct,
        'promotion_type': promotionType,
        'promotion_ends_at': promotionEndsAt?.toIso8601String(),
        'product_url': productUrl,
      };

  PromotionModel copyWith({
    String? id,
    String? productId,
    String? productName,
    String? brand,
    String? imageUrl,
    String? retailerId,
    String? retailerName,
    String? retailerLogo,
    double? regularPrice,
    double? salePrice,
    double? discountPct,
    String? promotionType,
    DateTime? promotionEndsAt,
    String? productUrl,
  }) {
    return PromotionModel(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      brand: brand ?? this.brand,
      imageUrl: imageUrl ?? this.imageUrl,
      retailerId: retailerId ?? this.retailerId,
      retailerName: retailerName ?? this.retailerName,
      retailerLogo: retailerLogo ?? this.retailerLogo,
      regularPrice: regularPrice ?? this.regularPrice,
      salePrice: salePrice ?? this.salePrice,
      discountPct: discountPct ?? this.discountPct,
      promotionType: promotionType ?? this.promotionType,
      promotionEndsAt: promotionEndsAt ?? this.promotionEndsAt,
      productUrl: productUrl ?? this.productUrl,
    );
  }
}
