class Property {
  final int id;
  final String title;
  final String description;
  final String price;
  final String location;
  final String type;
  final String? imageUrl;
  final List<String> images;
  final String contactInfo;
  final DateTime createdAt;
  final double rating;
  final int reviewCount;
  final int? ownerId;

  Property({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.location,
    required this.type,
    required this.createdAt,
    this.imageUrl,
    this.images = const [],
    this.contactInfo = 'Contact owner',
    this.rating = 0.0,
    this.reviewCount = 0,
    this.ownerId,
  });

  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(
      id: json['id'],
      ownerId: json['user'] ?? json['user_id'] ?? json['owner_id'],
      title: json['title_bn']?.toString() ?? json['title']?.toString() ?? '',
      description: json['description_bn']?.toString() ?? json['description']?.toString() ?? '',
      price: json['price']?.toString() ?? '',
      location: (json['area'] != null && json['area'].toString().isNotEmpty) 
          ? '${json['area']}, ${json['city'] ?? ''}' 
          : (json['city']?.toString() ?? json['location']?.toString() ?? ''),
      type: json['category']?.toString() ?? json['type']?.toString() ?? json['property_type']?.toString() ?? '',
      createdAt: DateTime.parse(json['created_at']),
      imageUrl: json['image_url']?.toString(),
      images: (json['images'] as List?)?.map((e) {
        if (e is String) return e;
        if (e is Map) return (e['image'] ?? e['url'] ?? '').toString();
        return '';
      }).where((e) => e.isNotEmpty).toList() ?? [],
      contactInfo: json['contact_phone']?.toString() ?? json['contact_info']?.toString() ?? 'Contact owner',
      rating: (json['rating'] ?? 0.0).toDouble(),
      reviewCount: json['review_count'] ?? 0,
    );
  }
}

class Vehicle {
  final int id;
  final String title;
  final String description;
  final String make;
  final String model;
  final String price;
  final int year;
  final String? imageUrl;
  final String mileage;
  final String contactInfo;
  final DateTime createdAt;
  final double rating;
  final int reviewCount;

  Vehicle({
    required this.id,
    required this.title,
    required this.description,
    required this.make,
    required this.model,
    required this.price,
    required this.year,
    required this.createdAt,
    this.imageUrl,
    this.mileage = '0',
    this.contactInfo = 'Contact seller',
    this.rating = 0.0,
    this.reviewCount = 0,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'],
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      make: json['make']?.toString() ?? '',
      model: json['model']?.toString() ?? '',
      price: json['price']?.toString() ?? '',
      year: json['year'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
      imageUrl: json['image_url']?.toString(),
      mileage: json['mileage']?.toString() ?? '0',
      contactInfo: json['contact_info']?.toString() ?? 'Contact seller',
      rating: (json['rating'] ?? 0.0).toDouble(),
      reviewCount: json['review_count'] ?? 0,
    );
  }
}

class Service {
  final int id;
  final String title;
  final String description;
  final String category;
  final String contactInfo;
  final String? imageUrl;
  final DateTime createdAt;
  final double rating;
  final int reviewCount;

  Service({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.contactInfo,
    required this.createdAt,
    this.imageUrl,
    this.rating = 0.0,
    this.reviewCount = 0,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'],
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      contactInfo: json['contact_info']?.toString() ?? '',
      createdAt: DateTime.parse(json['created_at']),
      imageUrl: json['image_url']?.toString(),
      rating: (json['rating'] ?? 0.0).toDouble(),
      reviewCount: json['review_count'] ?? 0,
    );
  }
}

class Review {
  final int id;
  final String contentId;
  final String contentType;
  final String userName;
  final int rating;
  final String comment;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.contentId,
    required this.contentType,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      contentId: json['content_id'].toString(),
      contentType: json['content_type'].toString(),
      userName: json['user_name']?.toString() ?? 'Unknown User',
      rating: json['rating'] ?? 0,
      comment: json['comment']?.toString() ?? '',
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class MarketItem {
  final int id;
  final String title;
  final String description;
  final String categoryName;
  final String price;
  final String currency;
  final String condition;
  final String city;
  final String area;
  final List<String> images;
  final DateTime createdAt;

  MarketItem({
    required this.id,
    required this.title,
    required this.description,
    required this.categoryName,
    required this.price,
    required this.currency,
    required this.condition,
    required this.city,
    required this.area,
    this.images = const [],
    required this.createdAt,
  });

  factory MarketItem.fromJson(Map<String, dynamic> json) {
    return MarketItem(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      title: json['title_bn']?.toString() ?? json['title']?.toString() ?? '',
      description: json['description_bn']?.toString() ?? json['description']?.toString() ?? '',
      categoryName: json['category_name']?.toString() ?? json['category']?.toString() ?? 'সাধারণ',
      price: json['price']?.toString() ?? '0',
      currency: json['currency']?.toString() ?? 'OMR',
      condition: (json['condition']?.toString().isEmpty ?? true) ? 'N/A' : json['condition'].toString(),
      city: json['city']?.toString() ?? '',
      area: json['area']?.toString() ?? '',
      images: (json['images'] as List?)?.map((e) {
        if (e is String) return e;
        if (e is Map) return (e['image'] ?? e['url'] ?? '').toString();
        return '';
      }).where((e) => e.isNotEmpty).toList() ?? [],
      createdAt: json['created_at'] != null 
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now() 
          : DateTime.now(),
    );
  }
}
