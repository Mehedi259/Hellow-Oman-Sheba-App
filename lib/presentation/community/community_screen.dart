import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'community_provider.dart';
import 'post_detail_screen.dart';

class CommunityScreen extends ConsumerWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsState = ref.watch(postsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Community'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CreatePostScreen()),
              );
            },
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(postsProvider);
        },
        child: postsState.when(
          data: (posts) {
            if (posts.isEmpty) return const Center(child: Text('No posts yet.'));
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: posts.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final post = posts[index];
                
                String formatTime(DateTime time) {
                  final difference = DateTime.now().difference(time);
                  if (difference.inDays > 0) return '${difference.inDays} দিন আগে';
                  if (difference.inHours > 0) return '${difference.inHours} ঘন্টা আগে';
                  if (difference.inMinutes > 0) return '${difference.inMinutes} মিনিট আগে';
                  return 'মাত্রই';
                }

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PostDetailScreen(post: post)),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade100,
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.pink.shade50,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                post.categoryName,
                                style: TextStyle(
                                  color: Colors.pink.shade700,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                Icon(Icons.access_time, size: 14, color: Colors.grey.shade500),
                                const SizedBox(width: 4),
                                Text(
                                  formatTime(post.createdAt),
                                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          post.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          post.content,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                            height: 1.4,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 16),
                        const Divider(height: 1),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 12,
                                  backgroundColor: Colors.grey.shade200,
                                  child: Icon(Icons.person, size: 16, color: Colors.grey.shade600),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  post.authorName,
                                  style: TextStyle(
                                    color: Colors.grey.shade800,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.thumb_up_alt_outlined, size: 16, color: Colors.grey.shade500),
                                    const SizedBox(width: 4),
                                    Text('${post.likes}', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                                  ],
                                ),
                                const SizedBox(width: 16),
                                Row(
                                  children: [
                                    Icon(Icons.chat_bubble_outline, size: 16, color: Colors.grey.shade500),
                                    const SizedBox(width: 4),
                                    Text('${post.commentsCount}', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
          loading: () => ListView(children: const [SizedBox(height: 300), Center(child: CircularProgressIndicator())]),
          error: (e, _) => ListView(children: [SizedBox(height: 300), Center(child: Padding(padding: const EdgeInsets.all(16.0), child: Text('Error: $e', textAlign: TextAlign.center)))]),
        ),
      ),
    );
  }
}

class CreatePostScreen extends ConsumerStatefulWidget {
  const CreatePostScreen({super.key});

  @override
  ConsumerState<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends ConsumerState<CreatePostScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  bool _isLoading = false;

  Future<void> _submit() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(communityRepositoryProvider).createPost(
            _titleController.text,
            _contentController.text,
          );
      if (mounted) {
        ref.invalidate(postsProvider);
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Post')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(labelText: 'Content'),
              maxLines: 5,
            ),
            const SizedBox(height: 24),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _submit,
                    child: const Text('Post'),
                  ),
          ],
        ),
      ),
    );
  }
}
