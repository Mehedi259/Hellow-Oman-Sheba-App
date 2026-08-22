class Property {
  final int id;
  final String title;
  final String description;
  final String price;
  final String location;
  final String type;
  final String? imageUrl;
  final String contactInfo;
  final DateTime createdAt;

  Property({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.location,
    required this.type,
    required this.createdAt,
    this.imageUrl,
    this.contactInfo = 'Contact owner',
  });

  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(
      id: json['id'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      price: json['price']?.toString() ?? '',
      location: json['location'] ?? '',
      type: json['property_type'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
      imageUrl: json['image_url'],
      contactInfo: json['contact_info'] ?? 'Contact owner',
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
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      make: json['make'] ?? '',
      model: json['model'] ?? '',
      price: json['price']?.toString() ?? '',
      year: json['year'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
      imageUrl: json['image_url'],
      mileage: json['mileage'] ?? '0',
      contactInfo: json['contact_info'] ?? 'Contact seller',
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

  Service({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.contactInfo,
    required this.createdAt,
    this.imageUrl,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      contactInfo: json['contact_info'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
