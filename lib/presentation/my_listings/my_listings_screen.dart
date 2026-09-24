import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'providers/my_listings_provider.dart';
import '../../data/models/job.dart';
import '../../data/models/job_seeker.dart';
import '../../data/models/classifieds_models.dart';
import '../../data/models/post.dart';
import '../classifieds/classifieds_detail_screens.dart';
import '../classifieds/worker_detail_screen.dart';
import '../categories/service_list_screen.dart' show ServiceDetailScreen;
import '../community/community_detail_screen.dart';
import '../../core/api/api_client.dart';
import '../auth/auth_provider.dart';
import '../post/edit_post_screen.dart';
import '../chat/widgets/chat_initiator_button.dart';
import 'widgets/favorite_item_card.dart';
import '../../core/utils/router_utils.dart';

class MyListingsScreen extends ConsumerStatefulWidget {
  final int initialIndex;
  const MyListingsScreen({super.key, this.initialIndex = 0});

  @override
  ConsumerState<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends ConsumerState<MyListingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 4,
      vsync: this,
      initialIndex: (widget.initialIndex >= 0 && widget.initialIndex < 4)
          ? widget.initialIndex
          : 0,
    );
  }

  @override
  void didUpdateWidget(covariant MyListingsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialIndex != widget.initialIndex &&
        widget.initialIndex >= 0 &&
        widget.initialIndex < 4) {
      _tabController.animateTo(widget.initialIndex);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _navigateToItem(
    BuildContext context,
    String type,
    int id,
  ) async {
    final apiClient = ref.read(apiClientProvider);

    bool isDialogShowing = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: Color(0xFF0056D2)),
      ),
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
        nextScreen = PropertyDetailScreen(
          property: Property.fromJson(res.data),
        );
      } else if (type == 'vehicle') {
        final res = await apiClient.dio.get('/classifieds/vehicles/$id/');
        nextScreen = VehicleDetailScreen(vehicle: Vehicle.fromJson(res.data));
      } else if (type == 'service') {
        final res = await apiClient.dio.get('/classifieds/services/$id/');
        nextScreen = ServiceDetailScreen(service: Service.fromJson(res.data));
      } else if (type == 'job_seeker') {
        final res = await apiClient.dio.get('/classifieds/job-seekers/$id/');
        nextScreen = WorkerDetailScreen(
          jobSeeker: JobSeeker.fromJson(res.data),
        );
      } else if (type == 'post' ||
          type == 'forum_post' ||
          type == 'community') {
        final res = await apiClient.dio.get('/community/forum/posts/$id/');
        nextScreen = CommunityDetailScreen(post: Post.fromJson(res.data));
      } else if (type == 'market' || type == 'marketitem' || type == 'classified') {
        final res = await apiClient.dio.get('/community/classifieds/$id/');
        nextScreen = MarketItemDetailScreen(item: MarketItem.fromJson(res.data));
      } else {
        if (!context.mounted) return;
        if (isDialogShowing) Navigator.of(context, rootNavigator: true).pop();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('অজানা টাইপ: $type')));
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('বিস্তারিত তথ্য পাওয়া যায়নি।'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deletePost(String type, int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('নিশ্চিত করুন', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('আপনি কি সত্যিই এই পোস্টটি মুছে ফেলতে চান? এটি পুনরুদ্ধার করা যাবে না।'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('না, বাতিল', style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('হ্যাঁ, মুছুন'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    if (!context.mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: Color(0xFF0056D2)),
      ),
    );
    try {
      final apiClient = ref.read(apiClientProvider);
      String endpoint = '';
      if (type == 'job') {
        endpoint = '/classifieds/jobs/$id/';
      } else if (type == 'property') {
        endpoint = '/classifieds/properties/$id/';
      } else if (type == 'vehicle') {
        endpoint = '/classifieds/vehicles/$id/';
      } else if (type == 'service') {
        endpoint = '/classifieds/services/$id/';
      } else if (type == 'job_seeker') {
        endpoint = '/classifieds/job-seekers/$id/';
      } else if (type == 'market' || type == 'marketitem' || type == 'classified') {
        endpoint = '/community/classifieds/$id/';
      } else if (type == 'post' || type == 'forum_post') {
        endpoint = '/community/forum/posts/$id/';
      }

      if (endpoint.isNotEmpty) {
        await apiClient.dio.delete(endpoint);
      }
      if (context.mounted) Navigator.of(context, rootNavigator: true).pop();
      ref.invalidate(myPostsProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('পোস্টটি সফলভাবে মুছে ফেলা হয়েছে'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('মুছে ফেলা সম্ভব হয়নি।'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _removeFavorite(int id) async {
    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.removeFavorite(id);
      ref.invalidate(myFavoritesProvider);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('রিমুভ করা সম্ভব হয়নি।'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildTabLabel(String text, int? count) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(text),
        if (count != null && count > 0) ...[
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFF0056D2).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0056D2),
              ),
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final postsCount = ref.watch(myPostsProvider).value?.length;
    final questionsCount = ref.watch(myForumPostsProvider).value?.length;
    final favsCount = ref.watch(myFavoritesProvider).value?.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
        title: const Text(
          'লিস্টিং ও কার্যক্রম',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 20,
            color: Color(0xFF1E293B),
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: const Color(0xFF0056D2),
          unselectedLabelColor: const Color(0xFF94A3B8),
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
          indicatorColor: const Color(0xFF0056D2),
          indicatorWeight: 3,
          indicatorSize: TabBarIndicatorSize.label,
          tabAlignment: TabAlignment.center,
          tabs: [
            Tab(child: _buildTabLabel('আমার পোস্ট', postsCount)),
            const Tab(child: Text('আবেদনকারী')),
            Tab(child: _buildTabLabel('আমার প্রশ্ন', questionsCount)),
            Tab(child: _buildTabLabel('পছন্দের তালিকা', favsCount)),
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
        ],
      ),
    );
  }

  Widget _buildCard({required Widget child, required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: const Color(0xFF0056D2).withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100, width: 1.5),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          highlightColor: const Color(0xFF0056D2).withOpacity(0.05),
          splashColor: const Color(0xFF0056D2).withOpacity(0.1),
          child: Padding(padding: const EdgeInsets.all(20.0), child: child),
        ),
      ),
    );
  }

  String? _extractImageUrl(Map<String, dynamic> post) {
    if (post['images'] != null &&
        post['images'] is List &&
        (post['images'] as List).isNotEmpty) {
      final first = (post['images'] as List).first;
      if (first is Map) {
        return first['image']?.toString() ?? first['url']?.toString();
      }
      return first.toString();
    }
    if (post['image_url'] != null && post['image_url'].toString().isNotEmpty) {
      return post['image_url'].toString();
    }
    if (post['image'] != null && post['image'].toString().isNotEmpty) {
      return post['image'].toString();
    }
    if (post['photo'] != null && post['photo'].toString().isNotEmpty) {
      return post['photo'].toString();
    }
    if (post['primary_image'] != null &&
        post['primary_image'].toString().isNotEmpty) {
      return post['primary_image'].toString();
    }
    return null;
  }

  String _getAbsoluteUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    if (url.startsWith('http')) return url;
    return 'http://188.245.212.240$url';
  }

  String _timeAgo(dynamic dateVal) {
    if (dateVal == null) return '';
    try {
      final dt = DateTime.parse(dateVal.toString());
      final diff = DateTime.now().difference(dt);
      if (diff.inDays > 30) {
        return DateFormat('d MMM yyyy').format(dt);
      } else if (diff.inDays > 0) {
        return '${diff.inDays} দিন আগে';
      } else if (diff.inHours > 0) {
        return '${diff.inHours} ঘণ্টা আগে';
      } else if (diff.inMinutes > 0) {
        return '${diff.inMinutes} মিনিট আগে';
      } else {
        return 'কিছুক্ষণ আগে';
      }
    } catch (_) {
      return '';
    }
  }

  String _getCategoryDisplayName(String type) {
    switch (type.toLowerCase()) {
      case 'job':
        return 'চাকরি';
      case 'property':
        return 'বাসা/রুম';
      case 'vehicle':
        return 'গাড়ি/বাইক';
      case 'service':
        return 'সার্ভিস';
      case 'job_seeker':
        return 'কাজের লোক';
      case 'market':
      case 'marketitem':
      case 'classified':
        return 'মার্কেট/কেনাবেচা';
      case 'post':
      case 'forum_post':
      case 'community':
        return 'কমিউনিটি';
      default:
        return type.toUpperCase();
    }
  }

  Color _getCategoryColor(String type) {
    switch (type.toLowerCase()) {
      case 'job':
        return const Color(0xFF2563EB);
      case 'property':
        return const Color(0xFFD97706);
      case 'vehicle':
        return const Color(0xFF4F46E5);
      case 'service':
        return const Color(0xFF0D9488);
      case 'job_seeker':
        return const Color(0xFF9333EA);
      case 'market':
      case 'marketitem':
      case 'classified':
        return const Color(0xFF059669);
      default:
        return const Color(0xFF64748B);
    }
  }

  Color _getCategoryBgColor(String type) {
    switch (type.toLowerCase()) {
      case 'job':
        return const Color(0xFFEFF6FF);
      case 'property':
        return const Color(0xFFFFFBEB);
      case 'vehicle':
        return const Color(0xFFEEF2FF);
      case 'service':
        return const Color(0xFFF0FDFA);
      case 'job_seeker':
        return const Color(0xFFFAF5FF);
      case 'market':
      case 'marketitem':
      case 'classified':
        return const Color(0xFFECFDF5);
      default:
        return const Color(0xFFF1F5F9);
    }
  }

  int _getViewCount(Map<String, dynamic> post) {
    final v = post['views'] ?? post['view_count'] ?? post['total_views'] ?? post['views_count'];
    if (v is int) return v;
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  String? _getPostPrice(Map<String, dynamic> post) {
    final price = post['price'] ?? post['salary'] ?? post['rent'] ?? post['expected_salary'];
    if (price != null && price.toString().trim().isNotEmpty) {
      final currency = post['currency'] ?? 'OMR';
      return '$currency $price';
    }
    return null;
  }

  Widget _buildFallbackIconWidget(String type, Color color) {
    IconData iconData = Icons.article_outlined;
    final lower = type.toLowerCase();
    if (lower == 'property') {
      iconData = Icons.home_work_outlined;
    } else if (lower == 'vehicle') {
      iconData = Icons.directions_car_outlined;
    } else if (lower == 'service') {
      iconData = Icons.design_services_outlined;
    } else if (lower == 'job_seeker') {
      iconData = Icons.person_search_outlined;
    } else if (lower == 'job') {
      iconData = Icons.work_outline;
    } else if (lower == 'market' || lower == 'marketitem' || lower == 'classified') {
      iconData = Icons.storefront_outlined;
    }

    return Center(
      child: Icon(iconData, size: 28, color: color),
    );
  }

  Widget _buildThumbnail(String imageUrl, String type) {
    final color = _getCategoryColor(type);
    final bgColor = _getCategoryBgColor(type);

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 74,
        height: 74,
        color: bgColor,
        child: imageUrl.isNotEmpty
            ? Image.network(
                imageUrl,
                width: 74,
                height: 74,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _buildFallbackIconWidget(type, color),
              )
            : _buildFallbackIconWidget(type, color),
      ),
    );
  }

  Widget _buildPostsHeader(int count) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF0056D2).withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              color: Color(0xFF0056D2),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'মোট $countটি পোস্ট',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'আপনার লিস্টিং ম্যানেজ করুন',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              context.safePushRoute('/post/create').then((_) => ref.refresh(myPostsProvider));
            },
            icon: const Icon(Icons.add_rounded, size: 16, color: Colors.white),
            label: const Text(
              'নতুন পোস্ট',
              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0056D2),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard(BuildContext context, Map<String, dynamic> post) {
    final type = (post['post_type'] ?? 'post').toString();
    final id = post['id'];
    final rawImageUrl = _extractImageUrl(post);
    final imageUrl = _getAbsoluteUrl(rawImageUrl);

    final title = post['title'] ??
        post['title_bn'] ??
        post['professional_title'] ??
        post['professional_title_bn'] ??
        post['name'] ??
        'শিরোনামহীন পোস্ট';

    final categoryName = _getCategoryDisplayName(type);
    final categoryColor = _getCategoryColor(type);
    final categoryBg = _getCategoryBgColor(type);
    final views = _getViewCount(post);
    final timeAgo = _timeAgo(post['created_at']);
    final priceStr = _getPostPrice(post);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _navigateToItem(context, type, id),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 74x74 rounded thumbnail
                    _buildThumbnail(imageUrl, type),
                    const SizedBox(width: 12),
                    // Post Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Badges Row
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFECFDF5),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: const Color(0xFFA7F3D0),
                                  ),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.circle,
                                      size: 6,
                                      color: Color(0xFF059669),
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'সক্রিয়',
                                      style: TextStyle(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF059669),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: categoryBg,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: categoryColor.withOpacity(0.2),
                                  ),
                                ),
                                child: Text(
                                  categoryName,
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w600,
                                    color: categoryColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          // Post Title
                          Text(
                            title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1E293B),
                              fontSize: 15,
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (priceStr != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              priceStr,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0056D2),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                const SizedBox(height: 8),
                // Bottom Row: Stats & Action Buttons
                Row(
                  children: [
                    const Icon(
                      Icons.visibility_outlined,
                      size: 14,
                      color: Color(0xFF94A3B8),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$views ভিউ',
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (timeAgo.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      const Text(
                        '•',
                        style: TextStyle(
                          color: Color(0xFFCBD5E1),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        timeAgo,
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                    const Spacer(),
                    // Edit Button
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
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
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFBFDBFE)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.edit_outlined,
                                size: 13,
                                color: Color(0xFF0056D2),
                              ),
                              SizedBox(width: 4),
                              Text(
                                'এডিট',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF0056D2),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    // Delete Button
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _deletePost(type, id),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF2F2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFFECACA)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.delete_outline_rounded,
                                size: 13,
                                color: Color(0xFFEF4444),
                              ),
                              SizedBox(width: 4),
                              Text(
                                'মুছুন',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFEF4444),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
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
            return _EmptyStateView(
              icon: Icons.post_add_rounded,
              title: 'আপনার কোনো পোস্ট নেই',
              subtitle: 'চাকরি, বাসা-ভাড়া, কেনাবেচা বা সার্ভিসের জন্য নতুন পোস্ট তৈরি করুন',
              actionButton: ElevatedButton.icon(
                onPressed: () {
                  context.safePushRoute('/post/create').then((_) => ref.refresh(myPostsProvider));
                },
                icon: const Icon(Icons.add_circle_outline_rounded, size: 18, color: Colors.white),
                label: const Text(
                  'নতুন পোস্ট তৈরি করুন',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0056D2),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            );
          }
          return ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 100),
            itemCount: posts.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return _buildPostsHeader(posts.length);
              }
              final post = posts[index - 1];
              return _buildPostCard(
                context,
                post is Map<String, dynamic> ? post : Map<String, dynamic>.from(post as Map),
              );
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFF0056D2)),
        ),
        error: (e, st) =>
            const Center(child: Text('কোনো ত্রুটি হয়েছে। আবার চেষ্টা করুন।')),
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
            padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 100),
            itemCount: comments.length,
            itemBuilder: (context, index) {
              final comment = comments[index];
              final postId = comment['post'] ?? 0;
              final content = comment['content'] ?? '';
              final timeStr = comment['created_at'] != null
                  ? DateFormat(
                      'MMM d, yyyy',
                    ).format(DateTime.parse(comment['created_at']))
                  : '';

              return _buildCard(
                onTap: () => _navigateToItem(context, 'forum_post', postId),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.comment_rounded,
                        color: Colors.green,
                        size: 22,
                      ),
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
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1E293B),
                              fontSize: 15,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(
                                Icons.forum_outlined,
                                size: 14,
                                color: Color(0xFF94A3B8),
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                'ফোরাম পোস্ট দেখুন',
                                style: TextStyle(
                                  color: Color(0xFF0056D2),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                timeStr,
                                style: const TextStyle(
                                  color: Color(0xFF94A3B8),
                                  fontSize: 12,
                                ),
                              ),
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
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFF0056D2)),
        ),
        error: (e, st) =>
            const Center(child: Text('কোনো ত্রুটি হয়েছে। আবার চেষ্টা করুন।')),
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
            TextButton(
              onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
              child: const Text('বাতিল'),
            ),
            TextButton(
              onPressed: () async {
                final newTitle = titleController.text.trim();
                final newContent = contentController.text.trim();
                if (newTitle.isNotEmpty && newContent.isNotEmpty) {
                  Navigator.of(context, rootNavigator: true).pop();
                  try {
                    await ref
                        .read(apiClientProvider)
                        .dio
                        .patch(
                          '/community/forum/posts/${post.id}/',
                          data: {'title': newTitle, 'content': newContent},
                        );
                    ref.refresh(myForumPostsProvider);
                    if (mounted)
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('সফলভাবে আপডেট হয়েছে'),
                          backgroundColor: Colors.green,
                        ),
                      );
                  } catch (e) {
                    if (mounted)
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                  }
                }
              },
              child: const Text('সেভ করুন'),
            ),
          ],
        );
      },
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
            padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 100),
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
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.forum,
                        color: Colors.blue,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            post.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(0xFF1E293B),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            post.content,
                            style: const TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 13,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${post.likes} পছন্দ • ${post.commentsCount} মন্তব্য',
                                style: const TextStyle(
                                  color: Color(0xFF94A3B8),
                                  fontSize: 12,
                                ),
                              ),
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
                              content: const Text(
                                'আপনি কি এই প্রশ্নটি মুছে ফেলতে চান?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: const Text('না'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: const Text(
                                    'হ্যাঁ',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            try {
                              await ref
                                  .read(apiClientProvider)
                                  .dio
                                  .delete('/community/forum/posts/${post.id}/');
                              ref.refresh(myForumPostsProvider);
                              if (mounted)
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('মুছে ফেলা হয়েছে'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                            } catch (e) {
                              if (mounted)
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error: $e'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                            }
                          }
                        }
                      },
                      itemBuilder: (ctx) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 18),
                              SizedBox(width: 8),
                              Text('এডিট করুন'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red, size: 18),
                              SizedBox(width: 8),
                              Text(
                                'ডিলিট করুন',
                                style: TextStyle(color: Colors.red),
                              ),
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
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFF0056D2)),
        ),
        error: (e, st) =>
            const Center(child: Text('কোনো ত্রুটি হয়েছে। আবার চেষ্টা করুন।')),
      ),
    );
  }
}

class _EmptyStateView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? actionButton;

  const _EmptyStateView({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionButton,
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
              decoration: BoxDecoration(
                color: const Color(0xFF0056D2).withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 64,
                color: const Color(0xFF0056D2).withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF64748B),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionButton != null) ...[
              const SizedBox(height: 20),
              actionButton!,
            ],
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
        if (snapshot.connectionState == ConnectionState.waiting)
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF7C3AED)),
          );
        final apps = snapshot.data as List? ?? [];
        if (apps.isEmpty) {
          return const _EmptyStateView(
            icon: Icons.people_alt_rounded,
            title: 'কোনো আবেদনকারী নেই',
            subtitle:
                'আপনার পোস্ট করা জবগুলোতে কেউ আবেদন করলে এখানে তাদের তালিকা দেখা যাবে।',
          );
        }
        return ListView.builder(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 100),
          itemCount: apps.length,
          itemBuilder: (context, index) {
            final app = apps[index];

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: app['applicant_avatar'] != null
                          ? Image.network(
                              app['applicant_avatar'].toString().startsWith(
                                    'http',
                                  )
                                  ? app['applicant_avatar']
                                  : '${ApiClient.baseUrl}${app['applicant_avatar']}',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(
                                    Icons.person_rounded,
                                    color: Color(0xFF10B981),
                                    size: 24,
                                  ),
                            )
                          : const Icon(
                              Icons.person_rounded,
                              color: Color(0xFF10B981),
                              size: 24,
                            ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            app['applicant_name'] ?? 'Applicant',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            app['job_title'] ?? 'Job',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (app['applicant_phone'] != null &&
                              app['applicant_phone'].toString().isNotEmpty)
                            Text(
                              app['applicant_phone'],
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF3B82F6),
                              ),
                            ),
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
                              initialMessage:
                                  'আপনার ${app['job_title'] ?? 'জবে'} আবেদন সম্পর্কে কথা বলতে চাই।',
                              relatedObjectType: 'job',
                              relatedObjectId: app['job_id'] ?? 0,
                              isIconButton: true,
                              icon: const Icon(
                                Icons.message_rounded,
                                size: 20,
                                color: Color(0xFF3B82F6),
                              ),
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
    final favoritesAsync = ref.watch(myFavoritesProvider);

    return favoritesAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: Color(0xFF0056D2)),
      ),
      error: (err, stack) => Center(child: Text('Error: $err')),
      data: (items) {
        if (items.isEmpty) {
          return const _EmptyStateView(
            icon: Icons.favorite_rounded,
            title: 'পছন্দের তালিকায় কোনো আইটেম নেই',
            subtitle: 'পছন্দে যোগ করলে এখানে দেখাবে',
          );
        }
        return RefreshIndicator(
          onRefresh: () async => ref.refresh(myFavoritesProvider),
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: 100,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final String contentType =
                  item['favorite_type'] ?? item['content_type'] ?? '';
              final String contentIdStr =
                  (item['favorite_id'] ?? item['content_id'] ?? '').toString();
              final int favId = item['id'];

              return FavoriteItemCard(
                item: item,
                favId: favId,
                contentType: contentType,
                contentIdStr: contentIdStr,
              );
            },
          ),
        );
      },
    );
  }
}
