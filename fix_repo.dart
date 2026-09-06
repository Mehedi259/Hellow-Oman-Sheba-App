import 'dart:io';

void main() {
  final file = File('lib/data/repositories/classifieds_repository.dart');
  var content = file.readAsStringSync();

  // 1. Fix getJobSeekers
  content = content.replaceAll(
    "final int totalPages = data is List ? 1 : (data['total_pages'] ?? 1);",
    "final int totalPages = data is List ? 1 : (data['total_pages'] ?? (total / 20).ceil());"
  );

  // 2. Helper to fetch all pages
  final helperCode = '''
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
''';

  // Add helper at the top of the class
  content = content.replaceFirst(
    'class ClassifiedsRepository {\n  final ApiClient apiClient;\n\n  ClassifiedsRepository(this.apiClient);\n',
    'class ClassifiedsRepository {\n  final ApiClient apiClient;\n\n  ClassifiedsRepository(this.apiClient);\n\n$helperCode'
  );

  // 3. Replace simple gets with _fetchAllPages
  content = content.replaceFirst(
    '''  Future<List<Job>> getJobs() async {
    try {
      final response = await apiClient.dio.get('/classifieds/jobs/');
      final data = response.data;
      final results = data is List ? data : (data['results'] as List? ?? []);
      return results.map((json) => Job.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Failed to load jobs');
    }
  }''',
    '''  Future<List<Job>> getJobs() async {
    try {
      return await _fetchAllPages('/classifieds/jobs/', Job.fromJson);
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Failed to load jobs');
    }
  }'''
  );

  content = content.replaceFirst(
    '''  Future<List<Property>> getProperties() async {
    try {
      final response = await apiClient.dio.get('/classifieds/properties/');
      final data = response.data;
      final results = data is List ? data : (data['results'] as List? ?? []);
      return results.map((json) => Property.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Failed to load properties');
    }
  }''',
    '''  Future<List<Property>> getProperties() async {
    try {
      return await _fetchAllPages('/classifieds/properties/', Property.fromJson);
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Failed to load properties');
    }
  }'''
  );

  content = content.replaceFirst(
    '''  Future<List<Vehicle>> getVehicles() async {
    try {
      final response = await apiClient.dio.get('/classifieds/vehicles/');
      final data = response.data;
      final results = data is List ? data : (data['results'] as List? ?? []);
      return results.map((json) => Vehicle.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Failed to load vehicles');
    }
  }''',
    '''  Future<List<Vehicle>> getVehicles() async {
    try {
      return await _fetchAllPages('/classifieds/vehicles/', Vehicle.fromJson);
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Failed to load vehicles');
    }
  }'''
  );

  content = content.replaceFirst(
    '''  Future<List<Service>> getServices({String? category}) async {
    try {
      final query = category != null ? "?category=\$category" : "";
      final response = await apiClient.dio.get('/classifieds/services/\$query');
      final data = response.data;
      final results = data is List ? data : (data['results'] as List? ?? []);
      return results.map((json) => Service.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Failed to load services');
    }
  }''',
    '''  Future<List<Service>> getServices({String? category}) async {
    try {
      final query = category != null ? "?category=\$category" : "";
      return await _fetchAllPages('/classifieds/services/\$query', Service.fromJson);
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Failed to load services');
    }
  }'''
  );

  content = content.replaceFirst(
    '''  Future<List<MarketItem>> getMarketItems() async {
    try {
      final response = await apiClient.dio.get('/community/classifieds/');
      final data = response.data;
      final results = data is List ? data : (data['results'] as List? ?? []);
      return results.map((json) => MarketItem.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Failed to load market items');
    }
  }''',
    '''  Future<List<MarketItem>> getMarketItems() async {
    try {
      return await _fetchAllPages('/community/classifieds/', MarketItem.fromJson);
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Failed to load market items');
    }
  }'''
  );

  file.writeAsStringSync(content);
  print('Done rewriting ClassifiedsRepository');
}
