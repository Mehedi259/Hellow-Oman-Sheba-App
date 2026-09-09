import 'package:dio/dio.dart';
import '../models/news_article.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const String _newsApiBase = 'https://helloomanbangla.com/api';

class NewsRepository {
  final Dio _dio;
  List<NewsArticle>? _cache;
  DateTime? _cacheTime;
  static const _cacheDuration = Duration(minutes: 10);

  NewsRepository()
      : _dio = Dio(BaseOptions(
          baseUrl: _newsApiBase,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 15),
        ));

  Future<List<NewsArticle>> getAllNews({bool forceRefresh = false}) async {
    // Return cached data if still fresh
    if (!forceRefresh && _cache != null && _cacheTime != null) {
      if (DateTime.now().difference(_cacheTime!) < _cacheDuration) {
        return _cache!;
      }
    }

    try {
      final response = await _dio.get('/posts', queryParameters: {'status': 'published'});
      final data = response.data;
      List<dynamic> articles;
      if (data is Map && data['success'] == true && data['data'] != null) {
        articles = data['data'] as List;
      } else if (data is List) {
        articles = data;
      } else {
        return _cache ?? [];
      }
      final result = articles.map((json) => NewsArticle.fromJson(json)).toList();
      _cache = result;
      _cacheTime = DateTime.now();
      return result;
    } on DioException catch (e) {
      // Return cached data on error if available
      if (_cache != null) return _cache!;
      throw Exception('নিউজ লোড করতে সমস্যা: ${e.message}');
    }
  }

  Future<NewsArticle?> getNewsBySlug(String slug) async {
    try {
      final response = await _dio.get('/posts/slug/$slug');
      final data = response.data;
      if (data is Map && data['success'] == true && data['data'] != null) {
        return NewsArticle.fromJson(data['data']);
      }
      return null;
    } on DioException catch (e) {
      throw Exception('নিউজ লোড করতে সমস্যা: ${e.message}');
    }
  }

  Future<List<NewsArticle>> getNewsByCategory(String category, {bool forceRefresh = false}) async {
    final all = await getAllNews(forceRefresh: forceRefresh);
    if (category == 'সর্বশেষ') return all;
    return all.where((n) => n.category == category).toList();
  }
}

// Riverpod providers
final newsRepositoryProvider = Provider<NewsRepository>((ref) => NewsRepository());

final allNewsProvider = FutureProvider<List<NewsArticle>>((ref) {
  return ref.watch(newsRepositoryProvider).getAllNews();
});

final newsByCategory = FutureProvider.family<List<NewsArticle>, String>((ref, category) {
  return ref.watch(newsRepositoryProvider).getNewsByCategory(category);
});
