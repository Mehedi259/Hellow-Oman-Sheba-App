import 'package:dio/dio.dart';
import '../models/user.dart';
import '../../core/api/api_client.dart';

class AuthRepository {
  final ApiClient apiClient;

  AuthRepository(this.apiClient);

  Future<String?> loginWithGoogle(String idToken) async {
    try {
      final response = await apiClient.dio.post('/users/auth/google/', data: {
        'id_token': idToken,
      });
      return response.data['access']; // Returning access token as per website API response
    } on DioException catch (e) {
      throw Exception(e.response?.data['error'] ?? 'Google login failed');
    }
  }

  Future<User> getProfile() async {
    try {
      final response = await apiClient.dio.get('/users/profile/');
      return User.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Failed to load profile');
    }
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    try {
      await apiClient.dio.patch('/users/profile/', data: data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Update failed');
    }
  }

  Future<void> changePassword(String oldPassword, String newPassword) async {
    try {
      await apiClient.dio.post('/users/change-password/', data: {
        'old_password': oldPassword,
        'new_password': newPassword,
      });
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Change password failed');
    }
  }

  Future<List<dynamic>> getMyPosts() async {
    try {
      final response = await apiClient.dio.get('/users/my-posts/');
      return response.data['results'] as List? ?? response.data as List;
    } catch (e) {
      return [];
    }
  }

  Future<List<dynamic>> getJobApplications() async {
    try {
      final response = await apiClient.dio.get('/users/applications/');
      return response.data['results'] as List? ?? response.data as List;
    } catch (e) {
      return [];
    }
  }

  Future<void> deleteMyPost(String type, int id) async {
    try {
      await apiClient.dio.delete('/community/posts/$id/'); // Assumption based on generic delete
    } catch (e) {
      throw Exception('Delete failed');
    }
  }

  Future<void> markNotificationRead(int id) async {
    try {
      await apiClient.dio.put('/users/notifications/$id/', data: {'read': true});
    } catch (e) {
      // ignore
    }
  }
  Future<List<dynamic>> getNotifications() async {
    try {
      final response = await apiClient.dio.get('/users/notifications/');
      return response.data['results'] as List? ?? response.data as List;
    } catch (e) {
      return [];
    }
  }
  Future<List<dynamic>> getFavorites() async {
    try {
      final response = await apiClient.dio.get('/users/favorites/');
      return response.data['results'] as List? ?? response.data as List;
    } catch (e) {
      return [];
    }
  }

  Future<void> addFavorite(String contentType, int contentId) async {
    try {
      await apiClient.dio.post('/users/favorites/', data: {
        'favorite_type': contentType,
        'favorite_id': contentId,
      });
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Failed to add to favorites');
    }
  }

  Future<void> removeFavorite(int favoriteId) async {
    try {
      await apiClient.dio.delete('/users/favorites/$favoriteId/');
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Failed to remove from favorites');
    }
  }
}
