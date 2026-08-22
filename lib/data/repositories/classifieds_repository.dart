import 'package:dio/dio.dart';
import '../models/job.dart';
import '../models/classifieds_models.dart';
import '../../core/api/api_client.dart';

class ClassifiedsRepository {
  final ApiClient apiClient;

  ClassifiedsRepository(this.apiClient);

  Future<List<Job>> getJobs() async {
    try {
      final response = await apiClient.dio.get('/classifieds/jobs/');
      final results = response.data['results'] as List? ?? response.data as List;
      return results.map((json) => Job.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Failed to load jobs');
    }
  }

  Future<List<Property>> getProperties() async {
    try {
      final response = await apiClient.dio.get('/classifieds/properties/');
      final results = response.data['results'] as List? ?? response.data as List;
      return results.map((json) => Property.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Failed to load properties');
    }
  }

  Future<List<Vehicle>> getVehicles() async {
    try {
      final response = await apiClient.dio.get('/classifieds/vehicles/');
      final results = response.data['results'] as List? ?? response.data as List;
      return results.map((json) => Vehicle.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Failed to load vehicles');
    }
  }

  Future<List<Service>> getServices() async {
    try {
      final response = await apiClient.dio.get('/classifieds/services/');
      final results = response.data['results'] as List? ?? response.data as List;
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
}
