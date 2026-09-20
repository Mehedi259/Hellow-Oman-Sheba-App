import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../auth/auth_provider.dart';
import '../classifieds/classifieds_provider.dart';
import 'system_provider.dart';
import 'widgets/hero_slider.dart';
import 'widgets/category_grid.dart';
import 'widgets/call_to_action_widget.dart';
import 'widgets/country_selector_widget.dart';
import 'widgets/home_tab_section_widget.dart';
import '../../data/repositories/auth_repository.dart';
import '../community/community_provider.dart';
import '../../data/repositories/news_repository.dart';

import '../../core/services/fcm_service.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize push notifications when app starts
    Future.microtask(() => FCMService.initialize(context));
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final slidersState = ref.watch(slidersProvider);

    return Scaffold(
      appBar: AppBar(
        title: Image.asset('assets/images/main-logo.png', height: 36),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          // Country selector — compact
          const CountrySelectorWidget(),
          // Notification bell with real unread count badge
          FutureBuilder<List<dynamic>>(
            future: ref.read(authRepositoryProvider).getNotifications(),
            builder: (context, snapshot) {
              final unreadCount = snapshot.hasData
                  ? snapshot.data!.where((n) => n['read'] != true).length
                  : 0;
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_none_rounded, color: Colors.black87, size: 26),
                    onPressed: () => context.push('/notifications'),
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: IgnorePointer(
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEF4444),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                          child: Center(
                            child: Text(
                              unreadCount > 9 ? '9+' : '$unreadCount',
                              style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, color: Colors.black87),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      endDrawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset('assets/images/main-logo.png', height: 40),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(),
              Expanded(
                child: ListView(
                  children: [
                    ListTile(
                      title: const Text('চাকরি'),
                      onTap: () {
                        Navigator.pop(context);
                        context.push('/classifieds?tab=jobs');
                      },
                    ),
                    ListTile(
                      title: const Text('বাসা ভাড়া'),
                      onTap: () {
                        Navigator.pop(context);
                        context.push('/classifieds?tab=properties');
                      },
                    ),
                    ListTile(
                      title: const Text('গাড়ি'),
                      onTap: () {
                        Navigator.pop(context);
                        context.push('/classifieds?tab=vehicles');
                      },
                    ),
                    ListTile(
                      title: const Text('সেবা'),
                      onTap: () {
                        Navigator.pop(context);
                        context.push('/classifieds?tab=services');
                      },
                    ),
                    ListTile(
                      title: const Text('কমিউনিটি'),
                      onTap: () {
                        Navigator.pop(context);
                        context.push('/community');
                      },
                    ),
                    ListTile(
                      title: const Text('মার্কেট'),
                      onTap: () {
                        Navigator.pop(context);
                        context.push('/classifieds?tab=market');
                      },
                    ),
                    const Divider(),

                    ListTile(
                      leading: const Icon(Icons.favorite_border),
                      title: const Text('পছন্দের তালিকা'),
                      onTap: () {
                        Navigator.pop(context);
                        context.go('/my-listings'); // Favorites is inside listings
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.notifications_none),
                      title: const Text('নোটিফিকেশন'),
                      onTap: () {
                        Navigator.pop(context);
                        context.push('/notifications');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.person_outline),
                      title: const Text('প্রোফাইল'),
                      onTap: () {
                        Navigator.pop(context);
                        context.push('/profile');
                      },
                    ),
                    ListTile(
                      title: const Text('লগআউট'),
                      onTap: () {
                        Navigator.pop(context);
                        ref.read(authStateProvider.notifier).logout();
                      },
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      final user = ref.read(authStateProvider).value;
                      if (user == null) {
                        context.push('/login');
                      } else {
                        context.push('/post/create');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('পোস্ট করুন', style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(slidersProvider);
          ref.invalidate(jobsProvider);
          ref.invalidate(homeJobSeekersProvider);
          ref.invalidate(propertiesProvider);
          ref.invalidate(vehiclesProvider);
          ref.invalidate(marketItemsProvider);
          ref.invalidate(postsProvider);
          ref.invalidate(allNewsProvider);
        },
        child: ListView(
          padding: const EdgeInsets.only(top: 8.0),
          children: [
            slidersState.when(
              data: (sliders) => HeroSliderWidget(sliders: sliders),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Slider Error: $e')),
            ),
            const CategoryGridWidget(),
            const SizedBox(height: 16),
            // All listing sections as tabs (চাকরি, কর্মী, বাসা, মার্কেট, সংবাদ, প্রশ্নোত্তর, গাড়ি)
            const HomeTabSectionWidget(),
            const SizedBox(height: 8),
            if (authState.value == null) const CallToActionWidget(),
            const SizedBox(height: 100), // Large padding for floating bottom nav clearance
          ],
        ),
      ),
    );
  }
}
