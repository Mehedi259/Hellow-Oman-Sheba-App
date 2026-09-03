import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/auth_provider.dart';
import '../../../data/models/post.dart';

final myPostsProvider = FutureProvider<List<dynamic>>((ref) async {
  final repository = ref.read(authRepositoryProvider);
  return repository.getMyPosts();
});

final myFavoritesProvider = FutureProvider<List<dynamic>>((ref) async {
  final repository = ref.read(authRepositoryProvider);
  return repository.getFavorites();
});

final myCommentsProvider = FutureProvider<List<dynamic>>((ref) async {
  final repository = ref.read(authRepositoryProvider);
  return repository.getMyComments();
});

final myForumPostsProvider = FutureProvider<List<Post>>((ref) async {
  final authState = ref.watch(authStateProvider);
  final userId = authState.value?.id;
  if (userId == null) return [];
  
  final apiClient = ref.read(apiClientProvider);
  // Import CommunityRepository manually inside provider to avoid circular dependencies if any,
  // but it's better to just use apiClient directly or import CommunityRepository.
  final response = await apiClient.dio.get('/community/forum/posts/', queryParameters: {'author': userId});
  final results = response.data['results'] as List? ?? response.data as List;
  return results.map((json) => Post.fromJson(json)).toList();
});
