class ProductModel {
  final int id;
  final String name;
  final String slug;
  final double price;
  final double? discountPrice;
  final int stock;
  final double rating;
  final int reviewsCount;
  final String? imageUrl;
  final String? categoryName;

  ProductModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.price,
    this.discountPrice,
    required this.stock,
    required this.rating,
    required this.reviewsCount,
    this.imageUrl,
    this.categoryName,
  });

  int? get discountPercent {
    if (discountPrice != null && discountPrice! < price && price > 0) {
      return (((price - discountPrice!) / price) * 100).round();
    }
    return null;
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    String? img;
    if (json['primary_image'] != null && json['primary_image']['image_url'] != null) {
      img = json['primary_image']['image_url'];
    } else if (json['images'] is List && (json['images'] as List).isNotEmpty) {
      img = json['images'][0]['image_url'];
    } else if (json['image_url'] != null) {
      img = json['image_url'];
    }

    return ProductModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      discountPrice: json['discount_price'] != null ? double.tryParse(json['discount_price'].toString()) : null,
      stock: json['stock'] is int ? json['stock'] : int.tryParse(json['stock'].toString()) ?? 0,
      rating: double.tryParse(json['rating']?.toString() ?? '4.8') ?? 4.8,
      reviewsCount: json['reviews_count'] is int ? json['reviews_count'] : int.tryParse(json['reviews_count']?.toString() ?? '120') ?? 120,
      imageUrl: img,
      categoryName: json['category'] != null ? json['category']['name'] : null,
    );
  }
}
