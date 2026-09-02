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

  Future<List<Map<String, dynamic>>> getComments(int postId) async {
    try {
      final response = await apiClient.dio.get('/community/forum/posts/$postId/comments/');
      final results = response.data['results'] as List? ?? response.data as List;
      return results.cast<Map<String, dynamic>>();
    } catch (e) {
      if (e is DioException) {
        throw Exception(e.response?.data['detail'] ?? 'Failed to load comments');
      }
      throw Exception('Parsing error: $e');
    }
  }

  Future<void> addComment(int postId, String content) async {
    try {
      await apiClient.dio.post('/community/forum/posts/$postId/comments/', data: {
        'content': content,
      });
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Failed to add comment');
    }
  }

  Future<int> toggleLike(int postId) async {
    try {
      final response = await apiClient.dio.post('/community/forum/posts/$postId/like/');
      return response.data['likes'] as int;
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Failed to toggle like');
    }
  }
}
