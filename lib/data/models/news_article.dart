import 'dart:convert';
import 'dart:typed_data';

class NewsArticle {
  final String id;
  final String slug;
  final String title;
  final String category;
  final String image;
  final String date;
  final String? excerpt;
  final String? content;
  final String? reporter;
  final String? publishedDate;

  bool get isBase64Image => image.startsWith('data:image');

  Uint8List? get base64Bytes {
    if (!isBase64Image) return null;
    try {
      final base64Str = image.split(',').last;
      return base64Decode(base64Str);
    } catch (_) {
      return null;
    }
  }

  NewsArticle({
    required this.id,
    required this.slug,
    required this.title,
    required this.category,
    required this.image,
    required this.date,
    this.excerpt,
    this.content,
    this.reporter,
    this.publishedDate,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    final publishedDate = json['published_date'] ?? json['created_at'] ?? '';
    return NewsArticle(
      id: (json['slug'] ?? json['id'] ?? '').toString(),
      slug: json['slug'] ?? json['id'].toString(),
      title: json['title'] ?? '',
      category: json['category'] is Map
          ? (json['category']['name'] ?? 'সর্বশেষ')
          : (json['category'] ?? 'সর্বশেষ'),
      image: json['image'] ?? '',
      date: _formatDate(publishedDate),
      excerpt: json['excerpt'] ??
          (json['content'] != null && json['content'].toString().length > 150
              ? json['content'].toString().substring(0, 150) + '...'
              : json['content'] ?? ''),
      content: json['content'] ?? '',
      reporter: json['reporter'] ?? '',
      publishedDate: publishedDate,
    );
  }

  static String _formatDate(String dateStr) {
    if (dateStr.isEmpty) return '';
    try {
      final d = DateTime.parse(dateStr).toLocal();
      final now = DateTime.now();
      final diff = now.difference(d);
      if (diff.inMinutes < 1) return 'এইমাত্র';
      if (diff.inMinutes < 60) return '${diff.inMinutes} মিনিট আগে';
      if (diff.inHours < 24) return '${diff.inHours} ঘণ্টা আগে';
      if (diff.inDays < 7) return '${diff.inDays} দিন আগে';
      const months = [
        'জানুয়ারি', 'ফেব্রুয়ারি', 'মার্চ', 'এপ্রিল', 'মে', 'জুন',
        'জুলাই', 'আগস্ট', 'সেপ্টেম্বর', 'অক্টোবর', 'নভেম্বর', 'ডিসেম্বর'
      ];
      return '${d.day} ${months[d.month - 1]} ${d.year}';
    } catch (_) {
      return dateStr;
    }
  }
}
