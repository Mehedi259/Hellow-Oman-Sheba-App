import 'package:flutter/material.dart';
import '../../data/models/phase3_models.dart';

class NewsDetailScreen extends StatelessWidget {
  final News news;
  const NewsDetailScreen({super.key, required this.news});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('News Detail')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (news.imageUrl != null)
              Image.network(news.imageUrl!, height: 250, width: double.infinity, fit: BoxFit.cover),
            const SizedBox(height: 16),
            Text(news.title, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text('Published on ${news.publishedAt}', style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),
            Text(news.content, style: const TextStyle(fontSize: 16, height: 1.5)),
          ],
        ),
      ),
    );
  }
}
