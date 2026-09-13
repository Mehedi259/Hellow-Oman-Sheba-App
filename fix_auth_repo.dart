import 'dart:io';

void main() {
  final file = File('/Users/mehedihasanmridul/app/Hellow-Oman-Sheba-App/lib/data/repositories/auth_repository.dart');
  var content = file.readAsStringSync();

  // Add deleteAccount
  if (!content.contains('deleteAccount')) {
    content = content.replaceFirst(
'''  Future<void> updateProfile(Map<String, dynamic> data) async {
    try {
      await apiClient.dio.patch('/users/profile/', data: data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Update failed');
    }
  }''',
'''  Future<void> updateProfile(dynamic data) async {
    try {
      await apiClient.dio.patch('/users/profile/', data: data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Update failed');
    }
  }

  Future<void> deleteAccount() async {
    try {
      await apiClient.dio.delete('/users/profile/');
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Delete account failed');
    }
  }'''
    );
  }

  file.writeAsStringSync(content);
}
