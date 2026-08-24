import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/auth_provider.dart';
import '../auth/widgets/google_login_button.dart';
import '../../data/models/user.dart';
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
    _tabController = TabController(length: 5, vsync: this);
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
      backgroundColor: Colors.grey.shade100,
      body: authState.when(
        data: (user) {
          if (user == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.account_circle, size: 80, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text(
                      'প্রোফাইল দেখতে আপনাকে লগইন করতে হবে',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    GoogleLoginButton(
                      onSuccess: () {},
                    ),
                  ],
                ),
              ),
            );
          }

          final displayName = user.firstName != null && user.firstName!.isNotEmpty 
              ? '${user.firstName} ${user.lastName ?? ''}'.trim()
              : 'ব্যবহারকারী';
          final initials = _getInitials(displayName, user.email);

          return NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  expandedHeight: 220,
                  pinned: true,
                  backgroundColor: const Color(0xFF9333EA),
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF7C3AED), Color(0xFFDB2777)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4)),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    initials,
                                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF9333EA)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      displayName,
                                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      user.email,
                                      style: const TextStyle(fontSize: 14, color: Colors.white70),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Icon(Icons.location_on, size: 14, color: Colors.white70),
                                        const SizedBox(width: 4),
                                        const Text('ওমান', style: TextStyle(fontSize: 12, color: Colors.white70)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _SliverAppBarDelegate(
                    TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      indicatorColor: const Color(0xFF9333EA),
                      labelColor: const Color(0xFF9333EA),
                      unselectedLabelColor: Colors.grey,
                      tabs: const [
                        Tab(icon: Icon(Icons.person_outline), text: 'প্রোফাইল'),
                        Tab(icon: Icon(Icons.article_outlined), text: 'আমার পোস্ট'),
                        Tab(icon: Icon(Icons.favorite_outline), text: 'পছন্দ'),
                        Tab(icon: Icon(Icons.work_outline), text: 'আবেদন'),
                        Tab(icon: Icon(Icons.security_outlined), text: 'পাসওয়ার্ড'),
                      ],
                    ),
                  ),
                ),
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
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => Center(child: Text('Error: $err')),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}

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
      padding: const EdgeInsets.all(16),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.person, color: Color(0xFF9333EA)),
                  SizedBox(width: 8),
                  Text('ব্যক্তিগত তথ্য', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              const Divider(height: 32),
              TextField(
                controller: _nameController, 
                decoration: InputDecoration(
                  labelText: 'পূর্ণ নাম',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                )
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _phoneController, 
                decoration: InputDecoration(
                  labelText: 'ফোন নম্বর',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                )
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9333EA),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () async {
                    try {
                      final repo = ref.read(authRepositoryProvider);
                      await repo.updateProfile({
                        'first_name': _nameController.text,
                        'phone': _phoneController.text,
                      });
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('প্রোফাইল আপডেট করা হয়েছে')));
                      }
                      ref.invalidate(authStateProvider);
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                      }
                    }
                  },
                  child: const Text('পরিবর্তন সংরক্ষণ করুন', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: () {
                    ref.read(authStateProvider.notifier).logout();
                  },
                  icon: const Icon(Icons.logout, color: Colors.red),
                  label: const Text('লগআউট করুন', style: TextStyle(color: Colors.red)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MyPostsTab extends ConsumerWidget {
  const _MyPostsTab();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder(
      future: ref.read(authRepositoryProvider).getMyPosts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        final posts = snapshot.data as List? ?? [];
        if (posts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.article, size: 64, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                Text('আপনি এখনো কোনো পোস্ট করেননি', style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final post = posts[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                title: Text(post['title'] ?? 'Untitled', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(post['post_type']?.toString().toUpperCase() ?? 'POST'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () {
                    ref.read(authRepositoryProvider).deleteMyPost(post['post_type'] ?? 'post', post['id']);
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _FavoritesTab extends ConsumerWidget {
  const _FavoritesTab();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<List<dynamic>>(
      future: ref.read(authRepositoryProvider).getFavorites(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
        final items = snapshot.data ?? [];
        if (items.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.favorite, size: 64, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                Text('পছন্দের তালিকায় কোনো আইটেম নেই', style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: const Icon(Icons.favorite, color: Colors.pink),
                title: Text(item['title'] ?? item['content_type'] ?? 'Favorite Item'),
                subtitle: Text('ID: ${item['content_id'] ?? ''}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    try {
                      await ref.read(authRepositoryProvider).removeFavorite(item['id']);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Removed from favorites')));
                      // Note: In a real app we'd refresh the provider here.
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                    }
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _ApplicationsTab extends ConsumerWidget {
  const _ApplicationsTab();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder(
      future: ref.read(authRepositoryProvider).getJobApplications(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        final apps = snapshot.data as List? ?? [];
        if (apps.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.work, size: 64, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                Text('আপনি কোনো কোম্পানিতে আবেদন করেননি', style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: apps.length,
          itemBuilder: (context, index) {
            final app = apps[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                title: Text(app['job_title'] ?? 'Job', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(app['company_name'] ?? 'Company'),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    app['status'] ?? 'PENDING',
                    style: TextStyle(color: Colors.blue.shade700, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _SecurityTab extends ConsumerStatefulWidget {
  const _SecurityTab();
  @override
  ConsumerState<_SecurityTab> createState() => _SecurityTabState();
}

class _SecurityTabState extends ConsumerState<_SecurityTab> {
  final _oldController = TextEditingController();
  final _newController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.lock, color: Color(0xFF9333EA)),
                  SizedBox(width: 8),
                  Text('পাসওয়ার্ড পরিবর্তন', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              const Divider(height: 32),
              TextField(
                controller: _oldController, 
                decoration: InputDecoration(
                  labelText: 'পুরানো পাসওয়ার্ড',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _newController, 
                decoration: InputDecoration(
                  labelText: 'নতুন পাসওয়ার্ড',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                obscureText: true,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9333EA),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () async {
                    try {
                      await ref.read(authRepositoryProvider).changePassword(_oldController.text, _newController.text);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('পাসওয়ার্ড সফলভাবে পরিবর্তন করা হয়েছে')));
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                      }
                    }
                  },
                  child: const Text('আপডেট করুন', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
