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
      // Get user profile once to know user id
      final userResp = await apiClient.dio.get('/users/profile/');
      final userId = userResp.data['id'];

      // Fetch in parallel: official my-posts + market (filtered client-side by owner)
      final results = await Future.wait([
        _getMyPostsFromBackend(),
        _getMyMarketPosts(userId),
      ]);

      final allPosts = [...results[0], ...results[1]];
      // Sort newest first
      allPosts.sort((a, b) {
        final aDate = DateTime.tryParse(a['created_at']?.toString() ?? '') ?? DateTime(2000);
        final bDate = DateTime.tryParse(b['created_at']?.toString() ?? '') ?? DateTime(2000);
        return bDate.compareTo(aDate);
      });
      return allPosts;
    } catch (e) {
      return [];
    }
  }

  // Uses the official backend endpoint that already knows the logged-in user
  Future<List<dynamic>> _getMyPostsFromBackend() async {
    try {
      String? nextUrl = '/users/my-posts/';
      final List<dynamic> all = [];
      while (nextUrl != null) {
        final response = await apiClient.dio.get(nextUrl);
        final data = response.data;
        if (data is List) {
          all.addAll(data);
          break;
        } else {
          all.addAll(data['results'] as List? ?? []);
          final next = data['next']?.toString();
          if (next != null) {
            final uri = Uri.tryParse(next);
            nextUrl = uri != null ? '${uri.path}${uri.query.isNotEmpty ? '?${uri.query}' : ''}' : null;
          } else {
            nextUrl = null;
          }
        }
      }
      return all;
    } catch (e) {
      return [];
    }
  }

  // Fetch market posts (community/classifieds) filtered by owner id
  Future<List<Map<String, dynamic>>> _getMyMarketPosts(dynamic userId) async {
    try {
      final List<Map<String, dynamic>> myItems = [];
      String? nextUrl = '/community/classifieds/';
      while (nextUrl != null) {
        final response = await apiClient.dio.get(nextUrl);
        final data = response.data;
        final List rawList = data is List ? data : (data['results'] as List? ?? []);
        for (final item in rawList) {
          final map = item as Map<String, dynamic>;
          if (map['owner']?.toString() == userId.toString()) {
            myItems.add({...map, 'post_type': 'market'});
          }
        }
        // Only paginate if needed (if current page had results and there's a next page)
        final next = data is Map ? data['next']?.toString() : null;
        if (next != null) {
          final uri = Uri.tryParse(next);
          nextUrl = uri != null ? '${uri.path}${uri.query.isNotEmpty ? '?${uri.query}' : ''}' : null;
        } else {
          nextUrl = null;
        }
      }
      return myItems;
    } catch (e) {
      return [];
    }
  }

  Future<List<dynamic>> getMyComments() async {
    try {
      final response = await apiClient.dio.get('/users/my-comments/');
      if (response.data is List) return response.data as List;
      return (response.data['results'] as List?) ?? [];
    } catch (e) {
      return [];
    }
  }

  Future<List<dynamic>> getJobApplications() async {
    try {
      final response = await apiClient.dio.get('/users/applications/');
      if (response.data is List) return response.data as List;
      return (response.data['results'] as List?) ?? [];
    } catch (e) {
      return [];
    }
  }

  Future<List<dynamic>> getJobApplicants() async {
    try {
      final response = await apiClient.dio.get('/users/job-applicants/');
      if (response.data is List) return response.data as List;
      return (response.data['results'] as List?) ?? [];
    } catch (e) {
      return [];
    }
  }

  Future<void> deleteMyPost(String type, int id) async {
    try {
      String endpoint = '';
      if (type == 'job') endpoint = '/classifieds/jobs/$id/';
      else if (type == 'property') endpoint = '/classifieds/properties/$id/';
      else if (type == 'vehicle') endpoint = '/classifieds/vehicles/$id/';
      else if (type == 'service') endpoint = '/classifieds/services/$id/';
      else if (type == 'market') endpoint = '/community/classifieds/$id/';
      else endpoint = '/community/forum/posts/$id/';
      
      await apiClient.dio.delete(endpoint);
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
      if (response.data is List) return response.data as List;
      return (response.data['results'] as List?) ?? [];
    } catch (e) {
      return [];
    }
  }
  Future<List<dynamic>> getFavorites() async {
    try {
      final response = await apiClient.dio.get('/users/favorites/');
      if (response.data is List) return response.data as List;
      return (response.data['results'] as List?) ?? [];
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
