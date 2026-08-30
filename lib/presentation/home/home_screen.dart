import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../auth/auth_provider.dart';
import '../classifieds/classifieds_provider.dart';
import 'system_provider.dart';
import 'widgets/hero_slider.dart';
import 'widgets/category_grid.dart';
import 'widgets/latest_jobs.dart';
import 'widgets/latest_workers.dart';
import 'widgets/market_widget.dart';
import 'widgets/community_widget.dart';
import 'widgets/properties_widget.dart';
import 'widgets/vehicles_widget.dart';
import 'widgets/call_to_action_widget.dart';
import '../community/community_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final jobsState = ref.watch(jobsProvider);
    final slidersState = ref.watch(slidersProvider);

    return Scaffold(
      appBar: AppBar(
        title: Image.asset('assets/images/main-logo.png', height: 40),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87), // For the hamburger icon
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
                      leading: const Icon(Icons.search),
                      title: const Text('সার্চ'),
                      onTap: () {
                        Navigator.pop(context);
                        // TODO: Implement search
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.favorite_border),
                      title: const Text('পছন্দের তালিকা'),
                      onTap: () {
                        Navigator.pop(context);
                        // TODO: Implement favorites
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.notifications_none),
                      title: const Text('নোটিফিকেশন'),
                      onTap: () {
                        Navigator.pop(context);
                        // TODO: Implement notifications
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
                      // TODO: Implement Post
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
          ref.invalidate(jobsProvider);
          ref.invalidate(homeJobSeekersProvider);
          ref.invalidate(propertiesProvider);
          ref.invalidate(vehiclesProvider);
          ref.invalidate(marketItemsProvider);
          ref.invalidate(postsProvider);
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
            const SizedBox(height: 4),
            jobsState.when(
              data: (jobs) => Padding(padding: const EdgeInsets.symmetric(horizontal: 16.0), child: LatestJobsWidget(jobs: jobs)),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Text('Jobs Error: $error'),
            ),
            const SizedBox(height: 4),
            ref.watch(homeJobSeekersProvider).when(
              data: (workers) => Padding(padding: const EdgeInsets.symmetric(horizontal: 16.0), child: LatestWorkersWidget(workers: workers)),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Text('Workers Error: $error'),
            ),
            const SizedBox(height: 4),
            ref.watch(propertiesProvider).when(
              data: (properties) => PropertiesWidget(properties: properties),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Text('Properties Error: $error'),
            ),
            const SizedBox(height: 4),
            ref.watch(vehiclesProvider).when(
              data: (vehicles) => VehiclesWidget(vehicles: vehicles),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Text('Vehicles Error: $error'),
            ),
            const SizedBox(height: 4),
            ref.watch(marketItemsProvider).when(
              data: (items) => Padding(padding: const EdgeInsets.symmetric(horizontal: 16.0), child: MarketWidget(items: items)),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Text('Market Error: $error'),
            ),
            const SizedBox(height: 4),
            ref.watch(postsProvider).when(
              data: (posts) => Padding(padding: const EdgeInsets.symmetric(horizontal: 16.0), child: CommunityWidget(posts: posts)),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Text('Community Error: $error'),
            ),
            const SizedBox(height: 8),
            const CallToActionWidget(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
