class ProductModel {
  final int id;
  final String name;
  final String slug;
  final String? description;
  final double price;
  final double? discountPrice;
  final int stock;
  final double rating;
  final int reviewsCount;
  final String? imageUrl;
  final String? categoryName;
  final int? categoryId;
  final bool isFeatured;
  final bool freeShipping;
  final String? tag; // 'Bestseller', 'New', '-10%', etc.

  ProductModel({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    required this.price,
    this.discountPrice,
    required this.stock,
    required this.rating,
    required this.reviewsCount,
    this.imageUrl,
    this.categoryName,
    this.categoryId,
    this.isFeatured = false,
    this.freeShipping = true,
    this.tag,
  });

  int? get discountPercent {
    if (discountPrice != null && discountPrice! < price && price > 0) {
      return (((price - discountPrice!) / price) * 100).round();
    }
    return null;
  }

  double get effectivePrice => (discountPrice != null && discountPrice! > 0) ? discountPrice! : price;

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    String? img;
    if (json['primary_image'] != null && json['primary_image']['image_url'] != null) {
      img = json['primary_image']['image_url'];
    } else if (json['images'] is List && (json['images'] as List).isNotEmpty) {
      img = json['images'][0]['image_url'];
    } else if (json['image_url'] != null) {
      img = json['image_url'];
    }

    final double p = double.tryParse(json['price']?.toString() ?? '0.0') ?? 0.0;
    final double? dp = json['discount_price'] != null ? double.tryParse(json['discount_price'].toString()) : null;
    final bool feat = json['is_featured'] == true || json['is_featured'] == 1;

    String? computedTag;
    if (feat) {
      computedTag = 'Bestseller';
    } else if (dp != null && dp < p) {
      final pct = (((p - dp) / p) * 100).round();
      computedTag = '-$pct%';
    } else {
      computedTag = 'New';
    }

    return ProductModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      description: json['description'],
      price: p,
      discountPrice: dp,
      stock: json['stock'] is int ? json['stock'] : int.tryParse(json['stock']?.toString() ?? '0') ?? 0,
      rating: double.tryParse(json['rating']?.toString() ?? '4.8') ?? 4.8,
      reviewsCount: json['reviews_count'] is int ? json['reviews_count'] : int.tryParse(json['reviews_count']?.toString() ?? '120') ?? 120,
      imageUrl: img,
      categoryName: json['category'] != null ? json['category']['name'] : null,
      categoryId: json['category_id'] is int ? json['category_id'] : int.tryParse(json['category_id']?.toString() ?? '0'),
      isFeatured: feat,
      freeShipping: true,
      tag: computedTag,
    );
  }
}
