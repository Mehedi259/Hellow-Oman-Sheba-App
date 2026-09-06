import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart';
import '../models/job.dart';
import '../models/job_seeker.dart';
import '../models/classifieds_models.dart';
import '../../core/api/api_client.dart';

class ClassifiedsRepository {
  final ApiClient apiClient;

  ClassifiedsRepository(this.apiClient);

  Future<List<T>> _fetchAllPages<T>(String endpoint, T Function(Map<String, dynamic>) fromJson) async {
    List<T> allItems = [];
    String? nextUrl = endpoint;
    
    while (nextUrl != null) {
      final response = await apiClient.dio.get(nextUrl);
      final data = response.data;
      
      if (data is List) {
        allItems.addAll(data.map((json) => fromJson(json as Map<String, dynamic>)).toList());
        nextUrl = null;
      } else {
        final results = data['results'] as List? ?? [];
        allItems.addAll(results.map((json) => fromJson(json as Map<String, dynamic>)).toList());
        
        if (data['next'] != null) {
          nextUrl = data['next'] as String;
          // Strip base url if present
          if (nextUrl.startsWith(apiClient.dio.options.baseUrl)) {
            nextUrl = nextUrl.substring(apiClient.dio.options.baseUrl.length);
          }
        } else {
          nextUrl = null;
        }
      }
    }
    return allItems;
  }

  Future<Map<String, dynamic>> getJobSeekers({String? search, String? sort, int? page}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (sort != null) queryParams['ordering'] = sort;
      if (page != null) queryParams['page'] = page;

      final response = await apiClient.dio.get('/classifieds/job-seekers/', queryParameters: queryParams);
      var data = response.data;
      if (data is String) {
        try {
          data = jsonDecode(data);
        } catch (e) {
          // If it fails to decode, we will let it fall through or handle it
        }
      }
      
      final List results = data is List ? data : (data['results'] as List? ?? []);
      final int total = data is List ? data.length : (data['count'] ?? 0);
      final int totalPages = data is List ? 1 : (data['total_pages'] ?? (total / 20).ceil());

      return {
        'items': results.map((json) => JobSeeker.fromJson(json)).toList(),
        'total': total,
        'totalPages': totalPages,
      };
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Failed to load job seekers');
    }
  }

  Future<List<Job>> getJobs() async {
    try {
      return await _fetchAllPages('/classifieds/jobs/', Job.fromJson);
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Failed to load jobs');
    }
  }

  Future<List<Property>> getProperties() async {
    try {
      return await _fetchAllPages('/classifieds/properties/', Property.fromJson);
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Failed to load properties');
    }
  }

  Future<List<Vehicle>> getVehicles() async {
    try {
      return await _fetchAllPages('/classifieds/vehicles/', Vehicle.fromJson);
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Failed to load vehicles');
    }
  }

  Future<List<Service>> getServices({String? category}) async {
    try {
      final query = category != null ? "?category=$category" : "";
      return await _fetchAllPages('/classifieds/services/$query', Service.fromJson);
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Failed to load services');
    }
  }

  Future<void> applyForJob(int jobId) async {
    try {
      await apiClient.dio.post('/classifieds/jobs/$jobId/apply/');
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Failed to apply for job');
    }
  }

  Future<List<Review>> getReviews(String contentType, int contentId) async {
    try {
      final response = await apiClient.dio.get(
        '/classifieds/reviews/',
        queryParameters: {
          'reviewable_type': contentType,
          'reviewable_id': contentId,
        },
      );
      final data = response.data;
      final results = data is List ? data : (data['results'] as List? ?? []);
      return results.map((json) => Review.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Failed to load reviews');
    }
  }

  Future<Review> postReview(String contentType, int contentId, int rating, String comment) async {
    try {
      final response = await apiClient.dio.post(
        '/classifieds/reviews/',
        data: {
          'reviewable_type': contentType,
          'reviewable_id': contentId,
          'rating': rating,
          'comment': comment,
        },
      );
      return Review.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Failed to post review');
    }
  }
  Future<List<MarketItem>> getMarketItems() async {
    try {
      return await _fetchAllPages('/community/classifieds/', MarketItem.fromJson);
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Failed to load market items');
    }
  }
  Future<void> createJob(Map<String, dynamic> data) async {
    try {
      await apiClient.dio.post('/classifieds/jobs/', data: data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Failed to create job post');
    }
  }

  Future<Map<String, dynamic>> createProperty(Map<String, dynamic> data) async {
    try {
      final response = await apiClient.dio.post('/classifieds/properties/', data: data);
      return response.data is Map<String, dynamic> ? response.data : {'id': response.data['id']};
    } on DioException catch (e) {
      throw Exception(e.response?.data?.toString() ?? 'Failed to create property post');
    }
  }

  Future<void> createVehicle(Map<String, dynamic> data, {List<File>? images}) async {
    try {
      final response = await apiClient.dio.post('/classifieds/vehicles/', data: data);
      final id = response.data['id'];
      if (images != null && images.isNotEmpty && id != null) {
        for (int i = 0; i < images.length; i++) {
          await uploadClassifiedImage(images[i].path, 'vehicle', id, i == 0);
        }
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Failed to create vehicle post');
    }
  }

  Future<void> createService(Map<String, dynamic> data, {List<File>? images}) async {
    try {
      final response = await apiClient.dio.post('/classifieds/services/', data: data);
      final id = response.data['id'];
      if (images != null && images.isNotEmpty && id != null) {
        for (int i = 0; i < images.length; i++) {
          await uploadClassifiedImage(images[i].path, 'service', id, i == 0);
        }
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Failed to create service post');
    }
  }

  Future<void> createMarketItem(Map<String, dynamic> data, {List<File>? images}) async {
    try {
      final response = await apiClient.dio.post('/community/classifieds/', data: data);
      final id = response.data['id'];
      if (images != null && images.isNotEmpty && id != null) {
        for (int i = 0; i < images.length; i++) {
          await uploadClassifiedImage(images[i].path, 'others', id, i == 0);
        }
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Failed to create market post');
    }
  }

  Future<Map<String, dynamic>> createJobSeekerProfile(Map<String, dynamic> data) async {
    try {
      final response = await apiClient.dio.post('/classifieds/job-seekers/', data: data);
      return response.data is Map<String, dynamic> ? response.data : {'id': response.data['id']};
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Failed to create job seeker profile');
    }
  }

  Future<Map<String, dynamic>> updateProperty(int id, Map<String, dynamic> data) async {
    try {
      final response = await apiClient.dio.patch('/classifieds/properties/$id/', data: data);
      return response.data is Map<String, dynamic> ? response.data : {};
    } on DioException catch (e) {
      throw Exception(e.response?.data?.toString() ?? 'Failed to update property');
    }
  }

  Future<Map<String, dynamic>> updateVehicle(int id, Map<String, dynamic> data) async {
    try {
      final response = await apiClient.dio.patch('/classifieds/vehicles/$id/', data: data);
      return response.data is Map<String, dynamic> ? response.data : {};
    } on DioException catch (e) {
      throw Exception(e.response?.data?.toString() ?? 'Failed to update vehicle');
    }
  }

  Future<Map<String, dynamic>> updateJob(int id, Map<String, dynamic> data) async {
    try {
      final response = await apiClient.dio.patch('/classifieds/jobs/$id/', data: data);
      return response.data is Map<String, dynamic> ? response.data : {};
    } on DioException catch (e) {
      throw Exception(e.response?.data?.toString() ?? 'Failed to update job');
    }
  }

  Future<Map<String, dynamic>> updateService(int id, Map<String, dynamic> data) async {
    try {
      final response = await apiClient.dio.patch('/classifieds/services/$id/', data: data);
      return response.data is Map<String, dynamic> ? response.data : {};
    } on DioException catch (e) {
      throw Exception(e.response?.data?.toString() ?? 'Failed to update service');
    }
  }

  Future<Map<String, dynamic>> updateMarketItem(int id, Map<String, dynamic> data) async {
    try {
      final response = await apiClient.dio.patch('/community/classifieds/$id/', data: data);
      return response.data is Map<String, dynamic> ? response.data : {};
    } on DioException catch (e) {
      throw Exception(e.response?.data?.toString() ?? 'Failed to update market post');
    }
  }

  /// Fetches the current user's job seeker profile from the list.
  /// Returns null if no profile exists for this user.
  Future<Map<String, dynamic>?> getMyJobSeekerProfile() async {
    try {
      final response = await apiClient.dio.get('/classifieds/job-seekers/');
      final data = response.data;
      final results = data is List ? data : (data['results'] as List? ?? []);
      
      // The API returns profiles ordered by newest first.
      // We need to find the one belonging to the current user.
      // Get the current user's username first.
      final profileResponse = await apiClient.dio.get('/users/profile/');
      final username = profileResponse.data['username'];
      
      for (final profile in results) {
        if (profile['user_name'] == username) {
          return profile as Map<String, dynamic>;
        }
      }
      
      // Check all pages if not found on first page
      String? nextUrl = data is Map ? data['next'] : null;
      while (nextUrl != null) {
        if (nextUrl.startsWith('http')) {
          final uri = Uri.parse(nextUrl);
          nextUrl = '${uri.path}?${uri.query}';
        }
        final nextResponse = await apiClient.dio.get(nextUrl);
        final nextData = nextResponse.data;
        final nextResults = nextData['results'] as List? ?? [];
        for (final profile in nextResults) {
          if (profile['user_name'] == username) {
            return profile as Map<String, dynamic>;
          }
        }
        nextUrl = nextData['next'];
      }
      
      return null;
    } on DioException {
      return null;
    }
  }

  /// Update an existing job seeker profile
  Future<Map<String, dynamic>> updateJobSeekerProfile(int id, Map<String, dynamic> data) async {
    try {
      final response = await apiClient.dio.patch('/classifieds/job-seekers/$id/', data: data);
      return response.data is Map<String, dynamic> ? response.data : {};
    } on DioException catch (e) {
      throw Exception(e.response?.data?.toString() ?? 'Failed to update profile');
    }
  }

  Future<void> uploadClassifiedImage(String filePath, String category, int id, bool isPrimary) async {
    try {
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(filePath),
        'content_type': category,
        'content_id': id,
        'is_primary': isPrimary.toString(),
      });
      await apiClient.dio.post('/classifieds/images/', data: formData);
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Failed to upload image');
    }
  }
}
