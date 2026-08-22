import 'package:flutter/material.dart';
import '../../data/models/post.dart';

class PostDetailScreen extends StatelessWidget {
  final Post post;
  const PostDetailScreen({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Post Detail')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(post.title, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.person, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(post.authorName, style: const TextStyle(color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 24),
            Text(post.content, style: const TextStyle(fontSize: 16, height: 1.5)),
            const SizedBox(height: 32),
            const Divider(),
            const Text('Comments', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const Center(child: Text('No comments yet.', style: TextStyle(color: Colors.grey))),
          ],
        ),
      ),
    );
  }
}
