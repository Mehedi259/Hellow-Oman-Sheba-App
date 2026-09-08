import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'providers/my_listings_provider.dart';
import '../../data/models/job.dart';
import '../../data/models/classifieds_models.dart';
import '../../data/models/post.dart';
import '../classifieds/classifieds_detail_screens.dart';
import '../categories/service_list_screen.dart' show ServiceDetailScreen;
import '../community/community_detail_screen.dart';
import '../../core/api/api_client.dart';
import '../auth/auth_provider.dart';
import '../post/edit_post_screen.dart';
import '../classifieds/classifieds_provider.dart';
import '../classifieds/widgets/job_list_card.dart';
import '../classifieds/widgets/market_card.dart';
import '../chat/widgets/chat_initiator_button.dart';

class MyListingsScreen extends ConsumerStatefulWidget {
  const MyListingsScreen({super.key});

  @override
  ConsumerState<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends ConsumerState<MyListingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _navigateToItem(BuildContext context, String type, int id) async {
    final apiClient = ref.read(apiClientProvider);
    
    bool isDialogShowing = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator(color: Color(0xFF0056D2))),
    ).then((_) {
      isDialogShowing = false;
    });

    try {
      Widget? nextScreen;
      
      if (type == 'job') {
        final res = await apiClient.dio.get('/classifieds/jobs/$id/');
        nextScreen = JobDetailScreen(job: Job.fromJson(res.data));
      } else if (type == 'property') {
        final res = await apiClient.dio.get('/classifieds/properties/$id/');
        nextScreen = PropertyDetailScreen(property: Property.fromJson(res.data));
      } else if (type == 'vehicle') {
        final res = await apiClient.dio.get('/classifieds/vehicles/$id/');
        nextScreen = VehicleDetailScreen(vehicle: Vehicle.fromJson(res.data));
      } else if (type == 'service') {
        final res = await apiClient.dio.get('/classifieds/services/$id/');
        nextScreen = ServiceDetailScreen(service: Service.fromJson(res.data));
      } else if (type == 'post' || type == 'forum_post' || type == 'community') {
        final res = await apiClient.dio.get('/community/forum/posts/$id/');
        nextScreen = CommunityDetailScreen(post: Post.fromJson(res.data));
      } else {
        if (!context.mounted) return;
        if (isDialogShowing) Navigator.of(context, rootNavigator: true).pop();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('অজানা টাইপ: $type')));
        return;
      }
      
      if (!context.mounted) return;
      if (isDialogShowing) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      
      if (nextScreen != null) {
        Navigator.push(context, MaterialPageRoute(builder: (_) => nextScreen!));
      }
    } catch (e) {
      debugPrint('Navigation error: $e');
      if (!context.mounted) return;
      if (isDialogShowing) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('বিস্তারিত তথ্য পাওয়া যায়নি।'), backgroundColor: Colors.red));
    }
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

    if (!context.mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator(color: Color(0xFF0056D2))),
    );
    try {
      final apiClient = ref.read(apiClientProvider);
      String endpoint = '';
      if (type == 'job') endpoint = '/classifieds/jobs/$id/';
      else if (type == 'property') endpoint = '/classifieds/properties/$id/';
      else if (type == 'vehicle') endpoint = '/classifieds/vehicles/$id/';
      else if (type == 'service') endpoint = '/classifieds/services/$id/';
      else if (type == 'post' || type == 'forum_post') endpoint = '/community/forum/posts/$id/';
      
      if (endpoint.isNotEmpty) {
        await apiClient.dio.delete(endpoint);
      }
      if (context.mounted) Navigator.of(context, rootNavigator: true).pop();
      ref.invalidate(myPostsProvider);
    } catch(e) {
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('মুছে ফেলা সম্ভব হয়নি।'), backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _removeFavorite(int id) async {
    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.removeFavorite(id);
      ref.invalidate(myFavoritesProvider);
    } catch(e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('রিমুভ করা সম্ভব হয়নি।'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
        title: const Text(
          'লিস্টিং ও কার্যক্রম',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20, color: Color(0xFF1E293B)),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: const Color(0xFF0056D2),
          unselectedLabelColor: const Color(0xFF94A3B8),
          labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          indicatorColor: const Color(0xFF0056D2),
          indicatorWeight: 3,
          indicatorSize: TabBarIndicatorSize.label,
          tabAlignment: TabAlignment.center,
          tabs: const [
            Tab(text: 'আমার পোস্ট'),
            Tab(text: 'আবেদনকারী'),
            Tab(text: 'আমার প্রশ্ন'),
            Tab(text: 'পছন্দের তালিকা'),
            Tab(text: 'আমার কমেন্ট'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPostsTab(),
          const _JobApplicantsTab(),
          _buildMyQuestionsTab(),
          _buildFavoritesTab(),
          _buildCommentsTab(),
        ],
      ),
    );
  }

  Widget _buildCard({
    required Widget child,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: child,
          ),
        ),
      ),
    );
  }

  Widget _buildPostsTab() {
    final myPostsAsync = ref.watch(myPostsProvider);
    return RefreshIndicator(
      onRefresh: () async => ref.refresh(myPostsProvider),
      child: myPostsAsync.when(
        data: (posts) {
          if (posts.isEmpty) {
            return const _EmptyStateView(
              icon: Icons.post_add_rounded,
              title: 'আপনার কোনো পোস্ট নেই',
              subtitle: 'নতুন পোস্ট তৈরি করতে নিচের + বাটনে ক্লিক করুন',
            );
          }
          return ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              final type = post['post_type'] ?? 'post';
              final id = post['id'];
              
              String iconPath = '💼';
              if (type == 'property') iconPath = '🏠';
              if (type == 'vehicle') iconPath = '🚗';
              if (type == 'service') iconPath = '🛠️';
              
              return _buildCard(
                onTap: () => _navigateToItem(context, type, id),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48, height: 48,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0056D2).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(iconPath, style: const TextStyle(fontSize: 22)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            post['title'] ?? post['title_bn'] ?? 'Untitled',
                            style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF1E293B), fontSize: 16),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(color: const Color(0xFF0056D2).withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                                child: Text(type.toString().toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF0056D2))),
                              ),
                              const SizedBox(width: 8),
                              const Text('বিস্তারিত দেখুন →', style: TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert_rounded, color: Color(0xFF64748B)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      onSelected: (value) {
                        if (value == 'edit') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditPostScreen(
                                type: type,
                                editId: id,
                                initialData: post,
                              ),
                            ),
                          ).then((_) => ref.refresh(myPostsProvider));
                        } else if (value == 'delete') {
                          _deletePost(type, id);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit_rounded, color: Color(0xFF0056D2), size: 20),
                              SizedBox(width: 8),
                              Text('এডিট করুন'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                              SizedBox(width: 8),
                              Text('মুছে ফেলুন', style: TextStyle(color: Colors.redAccent)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF0056D2))),
        error: (e, st) => const Center(child: Text('কোনো ত্রুটি হয়েছে। আবার চেষ্টা করুন।')),
      ),
    );
  }

  Widget _buildFavoritesTab() {
    return const _FavoritesTab();
  }

  Widget _buildCommentsTab() {
    final myCommentsAsync = ref.watch(myCommentsProvider);
    return RefreshIndicator(
      onRefresh: () async => ref.refresh(myCommentsProvider),
      child: myCommentsAsync.when(
        data: (comments) {
          if (comments.isEmpty) {
            return const _EmptyStateView(
              icon: Icons.comment_outlined,
              title: 'কোনো কমেন্ট নেই',
              subtitle: 'কমিউনিটি পোস্টে আপনার করা কমেন্টগুলো এখানে দেখা যাবে',
            );
          }
          return ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: comments.length,
            itemBuilder: (context, index) {
              final comment = comments[index];
              final postId = comment['post'] ?? 0;
              final content = comment['content'] ?? '';
              final timeStr = comment['created_at'] != null ? DateFormat('MMM d, yyyy').format(DateTime.parse(comment['created_at'])) : '';
              
              return _buildCard(
                onTap: () => _navigateToItem(context, 'forum_post', postId),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.comment_rounded, color: Colors.green, size: 22),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            content,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1E293B), fontSize: 15, height: 1.4),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(Icons.forum_outlined, size: 14, color: Color(0xFF94A3B8)),
                              const SizedBox(width: 4),
                              const Text('ফোরাম পোস্ট দেখুন', style: TextStyle(color: Color(0xFF0056D2), fontSize: 12, fontWeight: FontWeight.w600)),
                              const Spacer(),
                              Text(timeStr, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF0056D2))),
        error: (e, st) => const Center(child: Text('কোনো ত্রুটি হয়েছে। আবার চেষ্টা করুন।')),
      ),
    );
  }

  void _showEditPostDialog(Post post) {
    final titleController = TextEditingController(text: post.title);
    final contentController = TextEditingController(text: post.content);
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('প্রশ্ন এডিট করুন'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'শিরোনাম'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: contentController,
                  decoration: const InputDecoration(labelText: 'বিস্তারিত'),
                  maxLines: 5,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context, rootNavigator: true).pop(), child: const Text('বাতিল')),
            TextButton(
              onPressed: () async {
                final newTitle = titleController.text.trim();
                final newContent = contentController.text.trim();
                if (newTitle.isNotEmpty && newContent.isNotEmpty) {
                  Navigator.of(context, rootNavigator: true).pop();
                  try {
                    await ref.read(apiClientProvider).dio.patch('/community/forum/posts/${post.id}/', data: {
                      'title': newTitle,
                      'content': newContent,
                    });
                    ref.refresh(myForumPostsProvider);
                    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('সফলভাবে আপডেট হয়েছে'), backgroundColor: Colors.green));
                  } catch (e) {
                    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
                  }
                }
              },
              child: const Text('সেভ করুন'),
            ),
          ],
        );
      }
    );
  }

  Widget _buildMyQuestionsTab() {
    final myQuestionsAsync = ref.watch(myForumPostsProvider);
    return RefreshIndicator(
      onRefresh: () async => ref.refresh(myForumPostsProvider),
      child: myQuestionsAsync.when(
        data: (posts) {
          if (posts.isEmpty) {
            return const _EmptyStateView(
              icon: Icons.question_answer_rounded,
              title: 'আপনার কোনো প্রশ্ন নেই',
              subtitle: 'কমিউনিটিতে আপনার প্রশ্নগুলো এখানে দেখাবে',
            );
          }
          return ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return _buildCard(
                onTap: () => _navigateToItem(context, 'forum_post', post.id),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.forum, color: Colors.blue, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(post.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E293B)), maxLines: 2, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 4),
                          Text(post.content, style: const TextStyle(color: Color(0xFF64748B), fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${post.likes} পছন্দ • ${post.commentsCount} মন্তব্য', style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, color: Colors.grey),
                      onSelected: (val) async {
                        if (val == 'edit') {
                          _showEditPostDialog(post);
                        } else if (val == 'delete') {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('নিশ্চিত করুন'),
                              content: const Text('আপনি কি এই প্রশ্নটি মুছে ফেলতে চান?'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('না')),
                                TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('হ্যাঁ', style: TextStyle(color: Colors.red))),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            try {
                              await ref.read(apiClientProvider).dio.delete('/community/forum/posts/${post.id}/');
                              ref.refresh(myForumPostsProvider);
                              if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('মুছে ফেলা হয়েছে'), backgroundColor: Colors.green));
                            } catch (e) {
                              if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
                            }
                          }
                        }
                      },
                      itemBuilder: (ctx) => [
                        const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 18), SizedBox(width: 8), Text('এডিট করুন')])),
                        const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, color: Colors.red, size: 18), SizedBox(width: 8), Text('ডিলিট করুন', style: TextStyle(color: Colors.red))])),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF0056D2))),
        error: (e, st) => const Center(child: Text('কোনো ত্রুটি হয়েছে। আবার চেষ্টা করুন।')),
      ),
    );
  }
}

class _EmptyStateView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _EmptyStateView({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: const Color(0xFF0056D2).withOpacity(0.05), shape: BoxShape.circle),
              child: Icon(icon, size: 64, color: const Color(0xFF0056D2).withOpacity(0.5)),
            ),
            const SizedBox(height: 24),
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(subtitle, style: const TextStyle(fontSize: 14, color: Color(0xFF64748B), height: 1.5), textAlign: TextAlign.center),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

// ==================== JOB APPLICANTS TAB ====================
class _JobApplicantsTab extends ConsumerWidget {
  const _JobApplicantsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder(
      future: ref.read(authRepositoryProvider).getJobApplicants(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Color(0xFF7C3AED)));
        final apps = snapshot.data as List? ?? [];
        if (apps.isEmpty) {
          return const _EmptyStateView(icon: Icons.people_alt_rounded, title: 'কোনো আবেদনকারী নেই', subtitle: 'আপনার পোস্ট করা জবগুলোতে কেউ আবেদন করলে এখানে তাদের তালিকা দেখা যাবে।');
        }
        return ListView.builder(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          itemCount: apps.length,
          itemBuilder: (context, index) {
            final app = apps[index];
            
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 3))],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 48, height: 48,
                      decoration: BoxDecoration(color: const Color(0xFF10B981).withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
                      clipBehavior: Clip.antiAlias,
                      child: app['applicant_avatar'] != null
                          ? Image.network(
                              app['applicant_avatar'].toString().startsWith('http') 
                                  ? app['applicant_avatar'] 
                                  : '${ApiClient.baseUrl}${app['applicant_avatar']}',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => const Icon(Icons.person_rounded, color: Color(0xFF10B981), size: 24),
                            )
                          : const Icon(Icons.person_rounded, color: Color(0xFF10B981), size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(app['applicant_name'] ?? 'Applicant', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Color(0xFF1E293B))),
                          const SizedBox(height: 2),
                          Text(app['job_title'] ?? 'Job', style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
                          const SizedBox(height: 4),
                          if (app['applicant_phone'] != null && app['applicant_phone'].toString().isNotEmpty)
                            Text(app['applicant_phone'], style: const TextStyle(fontSize: 12, color: Color(0xFF3B82F6))),
                        ],
                      ),
                    ),
                    // Message Button
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B82F6).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: app['applicant_id'] != null 
                        ? ChatInitiatorButton(
                            targetUserId: app['applicant_id'],
                            title: app['applicant_name'] ?? 'Candidate',
                            initialMessage: 'আপনার ${app['job_title'] ?? 'জবে'} আবেদন সম্পর্কে কথা বলতে চাই।',
                            relatedObjectType: 'job',
                            relatedObjectId: app['job_id'] ?? 0,
                            isIconButton: true,
                            icon: const Icon(Icons.message_rounded, size: 20, color: Color(0xFF3B82F6)),
                          )
                        : const SizedBox(),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// ==================== FAVORITES TAB ====================
class _FavoritesTab extends ConsumerWidget {
  const _FavoritesTab();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobsAsync = ref.watch(jobsProvider);
    final marketAsync = ref.watch(marketItemsProvider);

    return FutureBuilder<List<dynamic>>(
      future: ref.read(authRepositoryProvider).getFavorites(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Color(0xFF7C3AED)));
        if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
        final items = snapshot.data ?? [];
        if (items.isEmpty) {
          return const _EmptyStateView(icon: Icons.favorite_rounded, title: 'পছন্দের তালিকায় কোনো আইটেম নেই', subtitle: 'পছন্দে যোগ করলে এখানে দেখাবে');
        }
        return ListView.builder(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            final String contentType = item['favorite_type'] ?? item['content_type'] ?? '';
            final String contentIdStr = (item['favorite_id'] ?? item['content_id'] ?? '').toString();
            final int favId = item['id'];

            Widget contentWidget;

            if (contentType == 'job' && jobsAsync.hasValue) {
              final job = jobsAsync.value!.where((j) => j.id.toString() == contentIdStr).firstOrNull;
              if (job != null) {
                contentWidget = JobListCardWidget(job: job);
              } else {
                contentWidget = _fallbackCard(context, ref, item, favId);
              }
            } else if ((contentType == 'market' || contentType == 'marketitem' || contentType == 'property' || contentType == 'vehicle' || contentType == 'service') && marketAsync.hasValue) {
              final marketItem = marketAsync.value!.where((m) => m.id.toString() == contentIdStr).firstOrNull;
              if (marketItem != null) {
                contentWidget = MarketCardWidget(item: marketItem);
              } else {
                contentWidget = _fallbackCard(context, ref, item, favId);
              }
            } else {
              contentWidget = _fallbackCard(context, ref, item, favId);
            }

            return Stack(
              children: [
                contentWidget,
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () async {
                      try {
                        await ref.read(authRepositoryProvider).removeFavorite(favId);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Removed from favorites')));
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444),
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: const Color(0xFFEF4444).withOpacity(0.3), blurRadius: 8)],
                      ),
                      child: const Icon(Icons.close_rounded, color: Colors.white, size: 16),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _fallbackCard(BuildContext context, WidgetRef ref, dynamic item, int favId) {
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
          decoration: BoxDecoration(color: const Color(0xFFEC4899).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
          child: const Icon(Icons.favorite_rounded, color: Color(0xFFEC4899), size: 22),
        ),
        title: Text(item['title'] ?? item['favorite_type'] ?? item['content_type'] ?? 'Favorite Item', style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('ID: ${item['favorite_id'] ?? item['content_id'] ?? ''}', style: TextStyle(color: Colors.grey.shade500)),
      ),
    );
  }
}
