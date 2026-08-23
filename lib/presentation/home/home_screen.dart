import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../auth/auth_provider.dart';
import '../classifieds/classifieds_provider.dart';
import 'system_provider.dart';
import 'widgets/hero_slider.dart';
import 'widgets/category_grid.dart';
import 'widgets/latest_jobs.dart';
import 'widgets/market_widget.dart';
import 'widgets/community_widget.dart';
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
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue[700],
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text('H', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 8),
            const Text(
              'হ্যালো ওমান সেবা',
              style: TextStyle(
                color: Color(0xFF0F172A),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(jobsProvider);
          ref.invalidate(marketItemsProvider);
          ref.invalidate(postsProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            slidersState.when(
              data: (sliders) => HeroSliderWidget(sliders: sliders),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Slider Error: $e')),
            ),
            const CategoryGridWidget(),
            const SizedBox(height: 16),
            jobsState.when(
              data: (jobs) => LatestJobsWidget(jobs: jobs.take(6).toList()),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Text('Jobs Error: $error'),
            ),
            const SizedBox(height: 16),
            ref.watch(marketItemsProvider).when(
              data: (items) => MarketWidget(items: items),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Text('Market Error: $error'),
            ),
            const SizedBox(height: 16),
            ref.watch(postsProvider).when(
              data: (posts) => CommunityWidget(posts: posts),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Text('Community Error: $error'),
            ),
          ],
        ),
      ),
    );
  }
}
