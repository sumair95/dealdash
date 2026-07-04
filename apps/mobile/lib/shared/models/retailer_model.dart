class RetailerModel {
  const RetailerModel({
    required this.id,
    required this.name,
    required this.slug,
    this.logoUrl,
    this.websiteUrl,
    this.isActive = true,
  });

  final String id;
  final String name;
  final String slug;
  final String? logoUrl;
  final String? websiteUrl;
  final bool isActive;

  factory RetailerModel.fromJson(Map<String, dynamic> json) {
    return RetailerModel(
      id: json['id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
      logoUrl: json['logo_url'] as String?,
      websiteUrl: json['website_url'] as String?,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'slug': slug,
        'logo_url': logoUrl,
        'website_url': websiteUrl,
        'is_active': isActive,
      };

  RetailerModel copyWith({
    String? id,
    String? name,
    String? slug,
    String? logoUrl,
    String? websiteUrl,
    bool? isActive,
  }) {
    return RetailerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      logoUrl: logoUrl ?? this.logoUrl,
      websiteUrl: websiteUrl ?? this.websiteUrl,
      isActive: isActive ?? this.isActive,
    );
  }
}
