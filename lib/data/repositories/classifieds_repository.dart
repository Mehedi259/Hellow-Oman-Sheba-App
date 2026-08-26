import 'package:dio/dio.dart';
import '../models/job.dart';
import '../models/job_seeker.dart';
import '../models/classifieds_models.dart';
import '../../core/api/api_client.dart';

class ClassifiedsRepository {
  final ApiClient apiClient;

  ClassifiedsRepository(this.apiClient);

  Future<Map<String, dynamic>> getJobSeekers({String? search, String? sort, int? page}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (sort != null) queryParams['ordering'] = sort;
      if (page != null) queryParams['page'] = page;

      final response = await apiClient.dio.get('/job-seekers/', queryParameters: queryParams);
      final data = response.data;
      
      final results = data['results'] as List? ?? [];
      final total = data['count'] ?? 0;
      final totalPages = data['total_pages'] ?? 1;

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
      final response = await apiClient.dio.get('/classifieds/jobs/');
      final data = response.data;
      final results = data is List ? data : (data['results'] as List? ?? []);
      return results.map((json) => Job.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Failed to load jobs');
    }
  }

  Future<List<Property>> getProperties() async {
    try {
      final response = await apiClient.dio.get('/classifieds/properties/');
      final data = response.data;
      final results = data is List ? data : (data['results'] as List? ?? []);
      return results.map((json) => Property.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Failed to load properties');
    }
  }

  Future<List<Vehicle>> getVehicles() async {
    try {
      final response = await apiClient.dio.get('/classifieds/vehicles/');
      final data = response.data;
      final results = data is List ? data : (data['results'] as List? ?? []);
      return results.map((json) => Vehicle.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Failed to load vehicles');
    }
  }

  Future<List<Service>> getServices({String? category}) async {
    try {
      final query = category != null ? "?category=$category" : "";
      final response = await apiClient.dio.get('/classifieds/services/$query');
      final data = response.data;
      final results = data is List ? data : (data['results'] as List? ?? []);
      return results.map((json) => Service.fromJson(json)).toList();
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
          'content_type': contentType,
          'content_id': contentId,
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
          'content_type': contentType,
          'content_id': contentId,
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
      final response = await apiClient.dio.get('/community/classifieds/');
      final data = response.data;
      final results = data is List ? data : (data['results'] as List? ?? []);
      return results.map((json) => MarketItem.fromJson(json)).toList();
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
}
