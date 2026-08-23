import 'package:dio/dio.dart';
import '../models/market_models.dart';
import '../../core/api/api_client.dart';

class MarketRepository {
  final ApiClient apiClient;

  MarketRepository(this.apiClient);

  Future<List<MarketCategory>> getCategories() async {
    try {
      final response = await apiClient.dio.get('/community/classifieds/categories/');
      final results = response.data['results'] as List? ?? response.data as List;
      return results.map((json) => MarketCategory.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Failed to load market categories');
    }
  }

  Future<List<MarketItem>> getItems({String? category}) async {
    try {
      final queryParams = category != null ? {'category': category} : null;
      final response = await apiClient.dio.get('/community/classifieds/', queryParameters: queryParams);
      final results = response.data['results'] as List? ?? response.data as List;
      return results.map((json) => MarketItem.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Failed to load market items');
    }
  }
}
