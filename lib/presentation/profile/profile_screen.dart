import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/auth_provider.dart';
import '../auth/widgets/google_login_button.dart';
import '../../data/models/user.dart';
import '../classifieds/classifieds_provider.dart';
import '../classifieds/widgets/job_list_card.dart';
import '../classifieds/widgets/market_card.dart';
import 'privacy_policy_screen.dart';
import 'terms_conditions_screen.dart';
import 'faq_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _getInitials(String? name, String email) {
    if (name != null && name.trim().isNotEmpty) {
      final parts = name.trim().split(' ');
      if (parts.length >= 2) {
        return (parts[0][0] + parts[1][0]).toUpperCase();
      }
      return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
    }
    return email.substring(0, 2).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: authState.when(
        data: (user) {
          if (user == null) {
            return _buildLoginPrompt();
          }

          final displayName = user.firstName != null && user.firstName!.isNotEmpty
              ? '${user.firstName} ${user.lastName ?? ''}'.trim()
              : 'ব্যবহারকারী';
          final initials = _getInitials(displayName, user.email);

          return NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                _buildProfileHeader(user, displayName, initials),
                _buildTabBar(),
              ];
            },
            body: TabBarView(
              controller: _tabController,
              children: [
                _ProfileInfoTab(user: user),
                const _MyPostsTab(),
                const _FavoritesTab(),
                const _ApplicationsTab(),
                const _SecurityTab(),
                const _SettingsTab(),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF7C3AED))),
        error: (err, st) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildLoginPrompt() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Color(0xFFF8FAFC), Color(0xFFEDE9FE)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120, height: 120,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF7C3AED), Color(0xFFDB2777)]),
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: const Color(0xFF7C3AED).withOpacity(0.25), blurRadius: 30, offset: const Offset(0, 12))],
                ),
                child: const Icon(Icons.person_rounded, size: 60, color: Colors.white),
              ),
              const SizedBox(height: 32),
              const Text(
                'স্বাগতম!',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Color(0xFF1E293B)),
              ),
              const SizedBox(height: 10),
              Text(
                'প্রোফাইল দেখতে ও সব ফিচার ব্যবহার করতে\nলগইন করুন',
                style: TextStyle(fontSize: 15, color: Colors.grey.shade600, height: 1.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 36),
              GoogleLoginButton(onSuccess: () {}),
            ],
          ),
        ),
      ),
    );
  }

  SliverAppBar _buildProfileHeader(User user, String displayName, String initials) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: const Color(0xFF7C3AED),
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF7C3AED), Color(0xFF6D28D9), Color(0xFFDB2777)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: [0.0, 0.5, 1.0],
            ),
          ),
          child: Stack(
            children: [
              // Decorative elements
              Positioned(top: -40, right: -40, child: Container(width: 160, height: 160, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.06)))),
              Positioned(bottom: 40, left: -30, child: Container(width: 100, height: 100, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.04)))),
              Positioned(top: 60, right: 80, child: Container(width: 50, height: 50, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.05)))),
              Positioned(bottom: 80, right: 30, child: Container(width: 30, height: 30, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.08)))),
              // Profile content
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                  child: SizedBox(
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Avatar
                        Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white.withOpacity(0.3), width: 3),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 8))],
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(colors: [Colors.white, Colors.white.withOpacity(0.95)]),
                              image: user.profilePicture != null && user.profilePicture!.isNotEmpty
                                  ? DecorationImage(
                                      image: NetworkImage(user.profilePicture!),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: user.profilePicture == null || user.profilePicture!.isEmpty
                                ? Center(
                                    child: Text(
                                      initials,
                                      style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w800, color: Color(0xFF7C3AED), letterSpacing: 1),
                                    ),
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Name
                        Text(
                          displayName,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.3),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),
                        // Email
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.email_rounded, size: 14, color: Colors.white.withOpacity(0.8)),
                              const SizedBox(width: 6),
                              Text(user.email, style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Location badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.location_on_rounded, size: 14, color: Colors.white.withOpacity(0.7)),
                              const SizedBox(width: 4),
                              Text('ওমান', style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.7), fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  SliverPersistentHeader _buildTabBar() {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _SliverAppBarDelegate(
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            indicatorColor: const Color(0xFF7C3AED),
            indicatorWeight: 3,
            indicatorSize: TabBarIndicatorSize.label,
            labelColor: const Color(0xFF7C3AED),
            unselectedLabelColor: const Color(0xFF94A3B8),
            labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
            tabAlignment: TabAlignment.start,
            tabs: const [
              Tab(icon: Icon(Icons.person_rounded, size: 20), text: 'প্রোফাইল'),
              Tab(icon: Icon(Icons.article_rounded, size: 20), text: 'আমার পোস্ট'),
              Tab(icon: Icon(Icons.favorite_rounded, size: 20), text: 'পছন্দ'),
              Tab(icon: Icon(Icons.work_rounded, size: 20), text: 'আবেদন'),
              Tab(icon: Icon(Icons.lock_rounded, size: 20), text: 'পাসওয়ার্ড'),
              Tab(icon: Icon(Icons.settings_rounded, size: 20), text: 'সেটিংস'),
            ],
          ),
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  _SliverAppBarDelegate(this.child);

  @override
  double get minExtent => 72;
  @override
  double get maxExtent => 72;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => false;
}

// ==================== PROFILE INFO TAB ====================
class _ProfileInfoTab extends ConsumerStatefulWidget {
  final User user;
  const _ProfileInfoTab({required this.user});

  @override
  ConsumerState<_ProfileInfoTab> createState() => _ProfileInfoTabState();
}

class _ProfileInfoTabState extends ConsumerState<_ProfileInfoTab> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.firstName);
    _phoneController = TextEditingController(text: widget.user.phone);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Personal info card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 4))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: const Color(0xFF7C3AED).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.person_rounded, color: Color(0xFF7C3AED), size: 22),
                    ),
                    const SizedBox(width: 12),
                    const Text('ব্যক্তিগত তথ্য', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1E293B))),
                  ],
                ),
                const SizedBox(height: 24),
                _buildPremiumField(_nameController, 'পূর্ণ নাম', Icons.badge_rounded),
                const SizedBox(height: 16),
                _buildPremiumField(_phoneController, 'ফোন নম্বর', Icons.phone_rounded),
                const SizedBox(height: 16),
                // Email display (non-editable)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.email_rounded, size: 20, color: Color(0xFF94A3B8)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('ইমেইল', style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 2),
                            Text(widget.user.email, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Color(0xFF475569))),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: const Color(0xFF10B981).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                        child: const Text('ভেরিফাইড', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF10B981))),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                // Save button
                Container(
                  width: double.infinity,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF7C3AED), Color(0xFF6D28D9)]),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [BoxShadow(color: const Color(0xFF7C3AED).withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () async {
                        try {
                          final repo = ref.read(authRepositoryProvider);
                          await repo.updateProfile({
                            'first_name': _nameController.text,
                            'phone': _phoneController.text,
                          });
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Row(children: [Icon(Icons.check_circle_rounded, color: Colors.white), SizedBox(width: 8), Text('প্রোফাইল আপডেট করা হয়েছে')]),
                                backgroundColor: const Color(0xFF10B981),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            );
                          }
                          ref.invalidate(authStateProvider);
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                          }
                        }
                      },
                      borderRadius: BorderRadius.circular(14),
                      child: const Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.save_rounded, color: Colors.white, size: 20),
                            SizedBox(width: 8),
                            Text('পরিবর্তন সংরক্ষণ করুন', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Logout button
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.2)),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  ref.read(authStateProvider.notifier).logout();
                },
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout_rounded, color: const Color(0xFFEF4444).withOpacity(0.8), size: 20),
                      const SizedBox(width: 8),
                      Text('লগআউট করুন', style: TextStyle(color: const Color(0xFFEF4444).withOpacity(0.8), fontWeight: FontWeight.w600, fontSize: 15)),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildPremiumField(TextEditingController controller, String label, IconData icon) {
    return TextField(
      controller: controller,
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Color(0xFF1E293B)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.w500),
        prefixIcon: Icon(icon, size: 20, color: const Color(0xFF94A3B8)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade200)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade200)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF7C3AED), width: 1.5)),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}

// ==================== MY POSTS TAB ====================
class _MyPostsTab extends ConsumerWidget {
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
          return _buildEmptyState(Icons.favorite_rounded, 'পছন্দের তালিকায় কোনো আইটেম নেই', 'পছন্দে যোগ করলে এখানে দেখাবে');
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

// ==================== APPLICATIONS TAB ====================
class _ApplicationsTab extends ConsumerWidget {
  const _ApplicationsTab();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder(
      future: ref.read(authRepositoryProvider).getJobApplications(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Color(0xFF7C3AED)));
        final apps = snapshot.data as List? ?? [];
        if (apps.isEmpty) {
          return _buildEmptyState(Icons.work_rounded, 'আপনি কোনো কোম্পানিতে আবেদন করেননি', 'চাকরিতে আবেদন করলে এখানে দেখাবে');
        }
        return ListView.builder(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          itemCount: apps.length,
          itemBuilder: (context, index) {
            final app = apps[index];
            final status = app['status'] ?? 'PENDING';
            final Color statusColor = status == 'APPROVED' ? const Color(0xFF10B981) : status == 'REJECTED' ? const Color(0xFFEF4444) : const Color(0xFFF59E0B);

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
                      decoration: BoxDecoration(color: const Color(0xFF3B82F6).withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
                      child: const Icon(Icons.business_center_rounded, color: Color(0xFF3B82F6), size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(app['job_title'] ?? 'Job', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Color(0xFF1E293B))),
                          const SizedBox(height: 4),
                          Text(app['company_name'] ?? 'Company', style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                      child: Text(status, style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.w700)),
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

// ==================== SECURITY TAB ====================
class _SecurityTab extends ConsumerStatefulWidget {
  const _SecurityTab();
  @override
  ConsumerState<_SecurityTab> createState() => _SecurityTabState();
}

class _SecurityTabState extends ConsumerState<_SecurityTab> {
  final _oldController = TextEditingController();
  final _newController = TextEditingController();
  bool _oldObscure = true;
  bool _newObscure = true;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: const Color(0xFFF59E0B).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.lock_rounded, color: Color(0xFFF59E0B), size: 22),
                ),
                const SizedBox(width: 12),
                const Text('পাসওয়ার্ড পরিবর্তন', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1E293B))),
              ],
            ),
            const SizedBox(height: 24),
            _buildPasswordField(_oldController, 'পুরানো পাসওয়ার্ড', _oldObscure, () => setState(() => _oldObscure = !_oldObscure)),
            const SizedBox(height: 16),
            _buildPasswordField(_newController, 'নতুন পাসওয়ার্ড', _newObscure, () => setState(() => _newObscure = !_newObscure)),
            const SizedBox(height: 28),
            Container(
              width: double.infinity,
              height: 52,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFD97706)]),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: const Color(0xFFF59E0B).withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () async {
                    try {
                      await ref.read(authRepositoryProvider).changePassword(_oldController.text, _newController.text);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Row(children: [Icon(Icons.check_circle_rounded, color: Colors.white), SizedBox(width: 8), Text('পাসওয়ার্ড সফলভাবে পরিবর্তন করা হয়েছে')]),
                            backgroundColor: const Color(0xFF10B981),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                      }
                    }
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: const Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shield_rounded, color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Text('আপডেট করুন', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField(TextEditingController controller, String label, bool obscure, VoidCallback toggle) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Color(0xFF1E293B)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.w500),
        prefixIcon: const Icon(Icons.key_rounded, size: 20, color: Color(0xFF94A3B8)),
        suffixIcon: IconButton(icon: Icon(obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded, size: 20, color: const Color(0xFF94A3B8)), onPressed: toggle),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade200)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade200)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFF59E0B), width: 1.5)),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
      ),
    );
  }
}

// ==================== SETTINGS TAB ====================
class _SettingsTab extends StatelessWidget {
  const _SettingsTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      children: [
        // Settings items
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 4))],
          ),
          child: Column(
            children: [
              _buildSettingsItem(
                icon: Icons.privacy_tip_rounded,
                iconColor: const Color(0xFF3B82F6),
                title: 'গোপনীয়তা নীতি',
                subtitle: 'Privacy Policy',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen())),
              ),
              Divider(height: 1, color: Colors.grey.shade100, indent: 70),
              _buildSettingsItem(
                icon: Icons.description_rounded,
                iconColor: const Color(0xFF10B981),
                title: 'শর্তাবলী',
                subtitle: 'Terms & Conditions',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TermsConditionsScreen())),
              ),
              Divider(height: 1, color: Colors.grey.shade100, indent: 70),
              _buildSettingsItem(
                icon: Icons.help_rounded,
                iconColor: const Color(0xFFF59E0B),
                title: 'সাধারণ জিজ্ঞাসা',
                subtitle: 'FAQ',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FaqScreen())),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
        // Developer credit
        Center(
          child: GestureDetector(
            onTap: () async {
              final Uri url = Uri.parse('https://helloomantech.com/');
              if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                debugPrint('Could not launch $url');
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(color: const Color(0xFF7C3AED).withOpacity(0.05), borderRadius: BorderRadius.circular(30)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.code_rounded, size: 16, color: const Color(0xFF7C3AED).withOpacity(0.6)),
                  const SizedBox(width: 8),
                  Text('Developed by Hello Oman Tech', style: TextStyle(color: const Color(0xFF7C3AED).withOpacity(0.7), fontWeight: FontWeight.w600, fontSize: 13)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildSettingsItem({required IconData icon, required Color iconColor, required String title, required String subtitle, required VoidCallback onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 42, height: 42,
                decoration: BoxDecoration(color: iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Color(0xFF1E293B))),
                    const SizedBox(height: 2),
                    Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade400)),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey.shade300),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== HELPER ====================
Widget _buildEmptyState(IconData icon, String title, String subtitle) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 80, height: 80,
          decoration: BoxDecoration(color: const Color(0xFF7C3AED).withOpacity(0.08), shape: BoxShape.circle),
          child: Icon(icon, size: 40, color: const Color(0xFF7C3AED).withOpacity(0.4)),
        ),
        const SizedBox(height: 20),
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF475569)), textAlign: TextAlign.center),
        const SizedBox(height: 6),
        Text(subtitle, style: TextStyle(fontSize: 13, color: Colors.grey.shade400), textAlign: TextAlign.center),
      ],
    ),
  );
}
