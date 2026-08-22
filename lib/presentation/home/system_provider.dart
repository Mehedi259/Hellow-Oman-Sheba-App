import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/system_models.dart';
import '../../data/repositories/system_repository.dart';
import '../auth/auth_provider.dart';

final systemRepositoryProvider = Provider((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return SystemRepository(apiClient);
});

final slidersProvider = FutureProvider<List<SliderItem>>((ref) async {
  final repository = ref.watch(systemRepositoryProvider);
  return repository.getSliders();
});

final searchQueryProvider = StateProvider<String>((ref) => '');

final searchResultsProvider = FutureProvider<List<SearchResult>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  if (query.isEmpty) return [];
  final repository = ref.watch(systemRepositoryProvider);
  return repository.globalSearch(query);
});
