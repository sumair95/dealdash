class ProductModel {
  const ProductModel({
    required this.id,
    required this.name,
    this.brand,
    this.categoryId,
    this.barcode,
    this.imageUrl,
  });

  final String id;
  final String name;
  final String? brand;
  final String? categoryId;
  final String? barcode;
  final String? imageUrl;

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String,
      name: json['name'] as String,
      brand: json['brand'] as String?,
      categoryId: json['category_id'] as String?,
      barcode: json['barcode'] as String?,
      imageUrl: json['image_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'brand': brand,
        'category_id': categoryId,
        'barcode': barcode,
        'image_url': imageUrl,
      };

  ProductModel copyWith({
    String? id,
    String? name,
    String? brand,
    String? categoryId,
    String? barcode,
    String? imageUrl,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      categoryId: categoryId ?? this.categoryId,
      barcode: barcode ?? this.barcode,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
