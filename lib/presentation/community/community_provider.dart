import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/post.dart';
import '../../data/repositories/community_repository.dart';
import '../auth/auth_provider.dart';

final communityRepositoryProvider = Provider((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return CommunityRepository(apiClient);
});

final postsProvider = FutureProvider<List<Post>>((ref) async {
  final repository = ref.watch(communityRepositoryProvider);
  return repository.getPosts();
});
