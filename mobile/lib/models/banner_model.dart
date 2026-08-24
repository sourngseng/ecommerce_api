class BannerModel {
  final int id;
  final String title;
  final String? subtitle;
  final String imageUrl;
  final String? linkUrl;
  final String? buttonText;
  final String position;

  BannerModel({
    required this.id,
    required this.title,
    this.subtitle,
    required this.imageUrl,
    this.linkUrl,
    this.buttonText,
    required this.position,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      title: json['title'] ?? '',
      subtitle: json['subtitle'],
      imageUrl: json['image_url'] ?? '',
      linkUrl: json['link_url'],
      buttonText: json['button_text'] ?? 'Shop Now',
      position: json['position'] ?? 'slider',
    );
  }
}
