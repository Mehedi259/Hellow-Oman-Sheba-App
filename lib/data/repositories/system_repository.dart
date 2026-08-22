import 'package:dio/dio.dart';
import '../models/system_models.dart';
import '../../core/api/api_client.dart';

class SystemRepository {
  final ApiClient apiClient;

  SystemRepository(this.apiClient);

  Future<List<SliderItem>> getSliders() async {
    try {
      final response = await apiClient.dio.get('/system/sliders/');
      final results = response.data['results'] as List? ?? response.data as List;
      return results.map((json) => SliderItem.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Failed to load sliders');
    }
  }

  Future<List<SearchResult>> globalSearch(String query) async {
    if (query.isEmpty) return [];
    try {
      final response = await apiClient.dio.get('/system/search/', queryParameters: {'q': query});
      final results = response.data['results'] as List? ?? response.data as List;
      return results.map((json) => SearchResult.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Search failed');
    }
  }
}
