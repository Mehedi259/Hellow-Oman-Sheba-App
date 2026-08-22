class SliderItem {
  final int id;
  final String title;
  final String subtitle;
  final String imageUrl;
  final String? link;

  SliderItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    this.link,
  });

  factory SliderItem.fromJson(Map<String, dynamic> json) {
    return SliderItem(
      id: json['id'],
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      imageUrl: json['image_url'] ?? '',
      link: json['link'],
    );
  }
}

class SearchResult {
  final String id;
  final String title;
  final String type;
  final String description;

  SearchResult({
    required this.id,
    required this.title,
    required this.type,
    required this.description,
  });

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    return SearchResult(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      type: json['type'] ?? 'unknown',
      description: json['description'] ?? '',
    );
  }
}
