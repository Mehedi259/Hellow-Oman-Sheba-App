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

  Future<void> createProperty(Map<String, dynamic> data) async {
    try {
      await apiClient.dio.post('/classifieds/properties/', data: data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Failed to create property post');
    }
  }

  Future<void> createVehicle(Map<String, dynamic> data) async {
    try {
      await apiClient.dio.post('/classifieds/vehicles/', data: data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Failed to create vehicle post');
    }
  }

  Future<void> createService(Map<String, dynamic> data) async {
    try {
      await apiClient.dio.post('/classifieds/services/', data: data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Failed to create service post');
    }
  }

  Future<void> createMarketItem(Map<String, dynamic> data) async {
    try {
      await apiClient.dio.post('/community/classifieds/', data: data);
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

  Future<void> uploadClassifiedImage(String filePath, String category, int id, bool isPrimary) async {
    try {
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(filePath),
        'category': category,
        'is_primary': isPrimary.toString(),
        if (category == 'market' || category == 'marketitem') 'market_item': id
        else if (category == 'job') 'job': id
        else if (category == 'property') 'property': id
        else if (category == 'vehicle') 'vehicle': id
        else if (category == 'service') 'service': id
        else 'content_id': id,
      });
      await apiClient.dio.post('/classifieds/images/', data: formData);
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Failed to upload image');
    }
  }
}
