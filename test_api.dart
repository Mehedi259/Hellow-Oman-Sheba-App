import 'package:dio/dio.dart';

void main() async {
  final dio = Dio(BaseOptions(baseUrl: 'http://188.245.212.240/api'));
  try {
    final response = await dio.get('/community/forum/posts/');
    final results = response.data['results'] as List? ?? response.data as List;
    for (var json in results) {
      try {
        final id = json['id'];
        final title = json['title'] ?? '';
        final content = json['content'] ?? '';
        final authorName = json['author_first_name'] ?? json['author_name'] ?? 'অজ্ঞাত';
        final categoryName = json['category'] != null ? (json['category']['nameBn'] ?? json['category']['name'] ?? 'সাধারণ আলোচনা') : 'সাধারণ আলোচনা';
        final likes = json['likes'] ?? 0;
        final commentsCount = json['comments_count'] ?? 0;
        final createdAt = DateTime.parse(json['created_at']);
      } catch (e) {
        print('Error on parsing item: $e');
        print(json);
      }
    }
    print('Parsed all successfully!');
  } catch (e) {
    print('Outer error: $e');
  }
}
