class CategoryModel {
  const CategoryModel({
    required this.id,
    required this.name,
    required this.slug,
    this.parentId,
    this.iconName,
  });

  final String id;
  final String name;
  final String slug;
  final String? parentId;
  final String? iconName;

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
      parentId: json['parent_id'] as String?,
      iconName: json['icon_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'slug': slug,
        'parent_id': parentId,
        'icon_name': iconName,
      };

  CategoryModel copyWith({
    String? id,
    String? name,
    String? slug,
    String? parentId,
    String? iconName,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      parentId: parentId ?? this.parentId,
      iconName: iconName ?? this.iconName,
    );
  }
}
