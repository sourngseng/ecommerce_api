class CategoryModel {
  final int id;
  final String name;
  final String slug;
  final String? image;
  final int? productsCount;

  CategoryModel({
    required this.id,
    required this.name,
    required this.slug,
    this.image,
    this.productsCount,
  });

  String? get imageUrl => image;

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      image: json['image'],
      productsCount: json['products_count'],
    );
  }
}
