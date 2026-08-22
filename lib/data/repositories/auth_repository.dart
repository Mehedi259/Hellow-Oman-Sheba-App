import 'package:dio/dio.dart';
import '../models/user.dart';
import '../../core/api/api_client.dart';

class AuthRepository {
  final ApiClient apiClient;

  AuthRepository(this.apiClient);

  Future<String?> login(String email, String password) async {
    try {
      final response = await apiClient.dio.post('/users/login/', data: {
        'email': email,
        'password': password,
      });
      return response.data['token']; // Adjust based on actual Django response
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Login failed');
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
}
