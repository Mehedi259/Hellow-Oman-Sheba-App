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

  Future<List<Post>> getPostsByAuthor(int authorId) async {
    try {
      final response = await apiClient.dio.get('/community/forum/posts/', queryParameters: {'author': authorId});
      final results = response.data['results'] as List? ?? response.data as List;
      return results.map((json) => Post.fromJson(json)).toList();
    } catch (e) {
      if (e is DioException) {
        throw Exception(e.response?.data['detail'] ?? e.message ?? 'Failed to load posts by author');
      }
      throw Exception('Parsing error: $e');
    }
  }

  Future<void> createPost(String title, String content) async {
    try {
      await apiClient.dio.post('/community/forum/posts/', data: {
        'title': title,
        'content': content,
        'category': 1, // Default category
      });
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Failed to create post');
    }
  }

  Future<void> editPost(int postId, String title, String content) async {
    try {
      await apiClient.dio.patch('/community/forum/posts/$postId/', data: {
        'title': title,
        'content': content,
      });
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Failed to edit post');
    }
  }

  Future<void> deletePost(int postId) async {
    try {
      await apiClient.dio.delete('/community/forum/posts/$postId/');
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Failed to delete post');
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

  Future<void> addComment(int postId, String content, {int? parentId}) async {
    try {
      final data = <String, dynamic>{
        'content': content,
      };
      if (parentId != null) {
        data['parent'] = parentId;
      }
      await apiClient.dio.post('/community/forum/posts/$postId/comments/', data: data);
    } on DioException catch (e) {
      final responseData = e.response?.data;
      final errorMessage = (responseData is Map) 
          ? (responseData['detail'] ?? 'Failed to add comment') 
          : 'Failed to add comment: Server returned ${e.response?.statusCode}';
      throw Exception(errorMessage);
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

  Future<void> editComment(int commentId, String content) async {
    try {
      await apiClient.dio.patch('/community/forum/comments/$commentId/', data: {
        'content': content,
      });
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Failed to edit comment');
    }
  }

  Future<void> deleteComment(int commentId) async {
    try {
      await apiClient.dio.delete('/community/forum/comments/$commentId/');
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Failed to delete comment');
    }
  }

  Future<Map<String, dynamic>> toggleCommentLike(int commentId) async {
    try {
      final response = await apiClient.dio.post('/community/forum/comments/$commentId/like/');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      final responseData = e.response?.data;
      final errorMessage = (responseData is Map) 
          ? (responseData['detail'] ?? 'Failed to toggle comment like') 
          : 'Failed to toggle comment like: Server returned ${e.response?.statusCode}';
      throw Exception(errorMessage);
    }
  }
}
