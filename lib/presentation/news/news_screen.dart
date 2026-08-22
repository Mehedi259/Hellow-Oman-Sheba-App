import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/phase3_models.dart';
import '../../data/repositories/phase3_repository.dart';
import '../auth/auth_provider.dart';

final phase3RepositoryProvider = Provider((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return Phase3Repository(apiClient);
});

final newsProvider = FutureProvider<List<News>>((ref) async {
  final repository = ref.watch(phase3RepositoryProvider);
  return repository.getNews();
});

class NewsScreen extends ConsumerWidget {
  const NewsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final newsState = ref.watch(newsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('News Feed')),
      body: newsState.when(
        data: (newsList) {
          if (newsList.isEmpty) return const Center(child: Text('No news available.'));
          return ListView.builder(
            itemCount: newsList.length,
            itemBuilder: (context, index) {
              final news = newsList[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (news.imageUrl != null)
                      Image.network(news.imageUrl!, height: 200, width: double.infinity, fit: BoxFit.cover),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(news.title, style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 8),
                          Text(news.content, maxLines: 3, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
