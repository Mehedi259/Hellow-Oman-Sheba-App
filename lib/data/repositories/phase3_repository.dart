import 'package:dio/dio.dart';
import '../models/phase3_models.dart';
import '../../core/api/api_client.dart';

class Phase3Repository {
  final ApiClient apiClient;

  Phase3Repository(this.apiClient);

  Future<List<News>> getNews() async {
    try {
      final response = await apiClient.dio.get('/news/');
      final results = response.data['results'] as List? ?? response.data as List;
      return results.map((json) => News.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Failed to load news');
    }
  }

  Future<List<EmergencyContact>> getEmergencyContacts() async {
    try {
      final response = await apiClient.dio.get('/emergency/contacts/');
      final results = response.data['results'] as List? ?? response.data as List;
      return results.map((json) => EmergencyContact.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Failed to load emergency contacts');
    }
  }
}
