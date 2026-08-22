import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/auth_provider.dart';
import '../../data/models/job.dart';
import '../../data/models/classifieds_models.dart';

// Mock favorites provider for demonstration since backend favorite endpoints aren't fully defined yet.
final favoriteJobsProvider = Provider<List<Job>>((ref) => []);
final favoritePropertiesProvider = Provider<List<Property>>((ref) => []);

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: authState.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text('Please log in to view your profile.'));
          }
          return DefaultTabController(
            length: 2,
            child: Column(
              children: [
                const SizedBox(height: 24),
                CircleAvatar(
                  radius: 50,
                  backgroundImage: user.profilePicture != null
                      ? NetworkImage(user.profilePicture!)
                      : null,
                  child: user.profilePicture == null ? const Icon(Icons.person, size: 50) : null,
                ),
                const SizedBox(height: 16),
                Text(
                  '${user.firstName ?? ''} ${user.lastName ?? ''}'.trim().isEmpty 
                      ? 'Sheba User' 
                      : '${user.firstName} ${user.lastName}',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Text(user.email, style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    ref.read(authStateProvider.notifier).logout();
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('Logout', style: TextStyle(color: Colors.white)),
                ),
                const SizedBox(height: 24),
                const TabBar(
                  tabs: [
                    Tab(text: 'Favorite Jobs'),
                    Tab(text: 'Favorite Properties'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _FavoriteJobsList(),
                      _FavoritePropertiesList(),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _FavoriteJobsList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoriteJobsProvider);
    if (favorites.isEmpty) return const Center(child: Text('No favorite jobs.'));
    return ListView.builder(
      itemCount: favorites.length,
      itemBuilder: (context, index) {
        final job = favorites[index];
        return ListTile(title: Text(job.title), subtitle: Text(job.company));
      },
    );
  }
}

class _FavoritePropertiesList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritePropertiesProvider);
    if (favorites.isEmpty) return const Center(child: Text('No favorite properties.'));
    return ListView.builder(
      itemCount: favorites.length,
      itemBuilder: (context, index) {
        final prop = favorites[index];
        return ListTile(title: Text(prop.title), subtitle: Text(prop.location));
      },
    );
  }
}
