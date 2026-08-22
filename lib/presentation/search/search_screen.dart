import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
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
            // Perform search
            setState(() {});
          },
        ),
      ),
      body: _searchController.text.isEmpty
          ? const Center(child: Text('Type to start searching...'))
          : Center(child: Text('Search results for "${_searchController.text}" will appear here.')),
    );
  }
}
