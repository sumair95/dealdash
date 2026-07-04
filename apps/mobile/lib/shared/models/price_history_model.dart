class PriceHistoryModel {
  const PriceHistoryModel({
    required this.id,
    required this.retailerProductId,
    required this.regularPrice,
    required this.salePrice,
    required this.discountPct,
    this.promotionType,
    this.scrapedAt,
    this.retailerName,
  });

  final String id;
  final String retailerProductId;
  final double regularPrice;
  final double salePrice;
  final double discountPct;
  final String? promotionType;
  final DateTime? scrapedAt;
  final String? retailerName;

  factory PriceHistoryModel.fromJson(Map<String, dynamic> json) {
    return PriceHistoryModel(
      id: json['id'] as String,
      retailerProductId: json['retailer_product_id'] as String,
      regularPrice: _toDouble(json['regular_price']),
      salePrice: _toDouble(json['sale_price']),
      discountPct: _toDouble(json['discount_pct']),
      promotionType: json['promotion_type'] as String?,
      scrapedAt: json['scraped_at'] != null
          ? DateTime.tryParse(json['scraped_at'] as String)
          : null,
      retailerName: json['retailer_name'] as String?,
    );
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'retailer_product_id': retailerProductId,
        'regular_price': regularPrice,
        'sale_price': salePrice,
        'discount_pct': discountPct,
        'promotion_type': promotionType,
        'scraped_at': scrapedAt?.toIso8601String(),
        'retailer_name': retailerName,
      };

  PriceHistoryModel copyWith({
    String? id,
    String? retailerProductId,
    double? regularPrice,
    double? salePrice,
    double? discountPct,
    String? promotionType,
    DateTime? scrapedAt,
    String? retailerName,
  }) {
    return PriceHistoryModel(
      id: id ?? this.id,
      retailerProductId: retailerProductId ?? this.retailerProductId,
      regularPrice: regularPrice ?? this.regularPrice,
      salePrice: salePrice ?? this.salePrice,
      discountPct: discountPct ?? this.discountPct,
      promotionType: promotionType ?? this.promotionType,
      scrapedAt: scrapedAt ?? this.scrapedAt,
      retailerName: retailerName ?? this.retailerName,
    );
  }
}
