import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/auth_provider.dart';

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
