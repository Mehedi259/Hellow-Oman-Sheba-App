import 'package:dio/dio.dart';
import '../models/post.dart';
import '../../core/api/api_client.dart';

class CommunityRepository {
  final ApiClient apiClient;

  CommunityRepository(this.apiClient);

  Future<List<Post>> getPosts() async {
    try {
      final response = await apiClient.dio.get('/community/forum/posts/');
      final results = response.data['results'] as List? ?? response.data as List;
      return results.map((json) => Post.fromJson(json)).toList();
    } catch (e) {
      if (e is DioException) {
        throw Exception(e.response?.data['detail'] ?? e.message ?? 'Failed to load posts');
      }
      throw Exception('Parsing error: $e');
    }
  }

  Future<void> createPost(String title, String content) async {
    try {
      await apiClient.dio.post('/community/posts/', data: {
        'title': title,
        'content': content,
      });
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Failed to create post');
    }
  }
}
