import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../home/system_provider.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final searchResults = ref.watch(searchResultsProvider);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Search jobs, properties, news...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white70),
          ),
          style: const TextStyle(color: Colors.white),
          autofocus: true,
          onSubmitted: (value) {
            ref.read(searchQueryProvider.notifier).state = value;
          },
        ),
      ),
      body: _searchController.text.isEmpty
          ? const Center(child: Text('Type to start searching...'))
          : searchResults.when(
              data: (results) {
                if (results.isEmpty) return const Center(child: Text('No results found.'));
                return ListView.builder(
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final res = results[index];
                    return ListTile(
                      title: Text(res.title),
                      subtitle: Text(res.description),
                      trailing: Text(res.type, style: const TextStyle(color: Colors.teal, fontSize: 12)),
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
