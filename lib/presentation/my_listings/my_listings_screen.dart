import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'providers/my_listings_provider.dart';
import '../../data/models/job.dart';
import '../../data/models/classifieds_models.dart';
import '../../data/models/post.dart';
import '../classifieds/classifieds_detail_screens.dart';
import '../community/community_detail_screen.dart';
import '../../core/api/api_client.dart';
import '../auth/auth_provider.dart';

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
    _tabController = TabController(length: 3, vsync: this);
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
      if (context.mounted) Navigator.pop(context);
      ref.invalidate(myPostsProvider);
    } catch(e) {
      if (context.mounted) {
        Navigator.pop(context);
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
            Tab(text: 'পছন্দের তালিকা'),
            Tab(text: 'আমার কমেন্ট'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPostsTab(),
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
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                      onPressed: () => _deletePost(type, id),
                      tooltip: 'মুছুন',
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
    final myFavoritesAsync = ref.watch(myFavoritesProvider);
    return RefreshIndicator(
      onRefresh: () async => ref.refresh(myFavoritesProvider),
      child: myFavoritesAsync.when(
        data: (favorites) {
          if (favorites.isEmpty) {
            return const _EmptyStateView(
              icon: Icons.favorite_border_rounded,
              title: 'পছন্দের তালিকা খালি',
              subtitle: 'কোনো পোস্টে লাইক দিলে সেটি এখানে দেখা যাবে',
            );
          }
          return ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final fav = favorites[index];
              final type = fav['favorite_type'] ?? 'unknown';
              final contentId = fav['favorite_id'] ?? 0;
              final details = fav['item_details'] ?? {};
              
              return _buildCard(
                onTap: () => _navigateToItem(context, type, contentId),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 48, height: 48,
                      decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.favorite_rounded, color: Colors.red, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            details['title'] ?? 'Favorite Item',
                            style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF1E293B), fontSize: 16),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Text('Type: ${type.toString().toUpperCase()}', style: const TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                              const Spacer(),
                              const Text('বিস্তারিত দেখুন →', style: TextStyle(color: Color(0xFF0056D2), fontSize: 12, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.favorite, color: Colors.red),
                      onPressed: () => _removeFavorite(fav['id']),
                      tooltip: 'রিমুভ',
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
