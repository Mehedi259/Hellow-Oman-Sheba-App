class MarketCategory {
  final int id;
  final String name;
  final String nameBn;
  final String slug;
  final String icon;

  MarketCategory({
    required this.id,
    required this.name,
    required this.nameBn,
    required this.slug,
    required this.icon,
  });

  factory MarketCategory.fromJson(Map<String, dynamic> json) {
    return MarketCategory(
      id: json['id'],
      name: json['name'] ?? '',
      nameBn: json['name_bn'] ?? '',
      slug: json['slug'] ?? '',
      icon: json['icon'] ?? '',
    );
  }
}

class MarketItem {
  final int id;
  final String title;
  final String titleBn;
  final String description;
  final String descriptionBn;
  final String price;
  final String currency;
  final bool priceNegotiable;
  final String condition;
  final String city;
  final String contactName;
  final String contactPhone;
  final DateTime createdAt;
  final List<String> images;
  final double rating;
  final int reviewCount;

  MarketItem({
    required this.id,
    required this.title,
    required this.titleBn,
    required this.description,
    required this.descriptionBn,
    required this.price,
    required this.currency,
    required this.priceNegotiable,
    required this.condition,
    required this.city,
    required this.contactName,
    required this.contactPhone,
    required this.createdAt,
    required this.images,
    required this.rating,
    required this.reviewCount,
  });

  factory MarketItem.fromJson(Map<String, dynamic> json) {
    List<String> imageUrls = [];
    if (json['images'] != null) {
      imageUrls = List<String>.from(json['images']);
    }
    return MarketItem(
      id: json['id'],
      title: json['title'] ?? '',
      titleBn: json['title_bn'] ?? '',
      description: json['description'] ?? '',
      descriptionBn: json['description_bn'] ?? '',
      price: json['price']?.toString() ?? '',
      currency: json['currency'] ?? 'OMR',
      priceNegotiable: json['price_negotiable'] ?? false,
      condition: json['condition'] ?? '',
      city: json['city'] ?? '',
      contactName: json['contact_name'] ?? '',
      contactPhone: json['contact_phone'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
      images: imageUrls,
      rating: (json['rating'] ?? 0.0).toDouble(),
      reviewCount: json['review_count'] ?? 0,
    );
  }
}
