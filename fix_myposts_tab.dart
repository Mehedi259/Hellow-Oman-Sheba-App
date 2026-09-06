import 'dart:io';

void main() {
  final file = File('lib/presentation/profile/profile_screen.dart');
  String content = file.readAsStringSync();

  final oldCode = '''class _MyPostsTab extends ConsumerWidget {
  const _MyPostsTab();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder(
      future: ref.read(authRepositoryProvider).getMyPosts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Color(0xFF7C3AED)));
        final posts = snapshot.data as List? ?? [];
        if (posts.isEmpty) {
          return _buildEmptyState(Icons.article_rounded, 'আপনি এখনো কোনো পোস্ট করেননি', 'পোস্ট করলে এখানে দেখাবে');
        }
        return ListView.builder(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final post = posts[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 3))],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(color: const Color(0xFF3B82F6).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.article_rounded, color: Color(0xFF3B82F6), size: 22),
                ),
                title: Text(post['title'] ?? 'Untitled', style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF1E293B))),
                subtitle: Container(
                  margin: const EdgeInsets.only(top: 6),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: const Color(0xFF8B5CF6).withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                        child: Text(post['post_type']?.toString().toUpperCase() ?? 'POST', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF8B5CF6))),
                      ),
                    ],
                  ),
                ),
                trailing: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(color: const Color(0xFFEF4444).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.delete_rounded, color: Color(0xFFEF4444), size: 18),
                  ),
                  onPressed: () => ref.read(authRepositoryProvider).deleteMyPost(post['post_type'] ?? 'post', post['id']),
                ),
              ),
            );
          },
        );
      },
    );
  }
}''';

  final newCode = '''class _MyPostsTab extends ConsumerStatefulWidget {
  const _MyPostsTab();
  @override
  ConsumerState<_MyPostsTab> createState() => _MyPostsTabState();
}

class _MyPostsTabState extends ConsumerState<_MyPostsTab> {
  Future<List<dynamic>>? _postsFuture;

  @override
  void initState() {
    super.initState();
    _postsFuture = ref.read(authRepositoryProvider).getMyPosts();
  }

  Future<void> _deletePost(String type, int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('নিশ্চিত করুন'),
        content: const Text('আপনি কি এই পোস্টটি মুছে ফেলতে চান?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('না')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('হ্যাঁ'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await ref.read(authRepositoryProvider).deleteMyPost(type, id);
      if (mounted) {
        Navigator.pop(context); // close loading
        setState(() {
          _postsFuture = ref.read(authRepositoryProvider).getMyPosts();
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('সফলভাবে মুছে ফেলা হয়েছে'), backgroundColor: Colors.green));
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('মুছে ফেলা সম্ভব হয়নি।'), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _postsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Color(0xFF7C3AED)));
        final posts = snapshot.data as List? ?? [];
        if (posts.isEmpty) {
          return _buildEmptyState(Icons.article_rounded, 'আপনি এখনো কোনো পোস্ট করেননি', 'পোস্ট করলে এখানে দেখাবে');
        }
        return ListView.builder(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final post = posts[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 3))],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(color: const Color(0xFF3B82F6).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.article_rounded, color: Color(0xFF3B82F6), size: 22),
                ),
                title: Text(post['title'] ?? 'Untitled', style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF1E293B))),
                subtitle: Container(
                  margin: const EdgeInsets.only(top: 6),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: const Color(0xFF8B5CF6).withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                        child: Text(post['post_type']?.toString().toUpperCase() ?? 'POST', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF8B5CF6))),
                      ),
                    ],
                  ),
                ),
                trailing: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(color: const Color(0xFFEF4444).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.delete_rounded, color: Color(0xFFEF4444), size: 18),
                  ),
                  onPressed: () => _deletePost(post['post_type'] ?? 'post', post['id']),
                ),
              ),
            );
          },
        );
      },
    );
  }
}''';

  content = content.replaceAll(oldCode, newCode);
  file.writeAsStringSync(content);
  print('Done rewriting _MyPostsTab');
}
