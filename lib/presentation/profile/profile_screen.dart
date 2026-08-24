import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/auth_provider.dart';
import '../auth/widgets/google_login_button.dart';
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Dashboard')),
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
                      onSuccess: () {
                        // After success, authStateProvider automatically updates and rebuilds this widget.
                      },
                    ),
                  ],
                ),
              ),
            );
          }
          return Row(
            children: [
              NavigationRail(
                selectedIndex: _selectedIndex,
                onDestinationSelected: (int index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                labelType: NavigationRailLabelType.all,
                destinations: const [
                  NavigationRailDestination(icon: Icon(Icons.person), label: Text('Profile')),
                  NavigationRailDestination(icon: Icon(Icons.article), label: Text('My Posts')),
                  NavigationRailDestination(icon: Icon(Icons.favorite), label: Text('Favorites')),
                  NavigationRailDestination(icon: Icon(Icons.work), label: Text('Applications')),
                  NavigationRailDestination(icon: Icon(Icons.security), label: Text('Security')),
                ],
              ),
              const VerticalDivider(thickness: 1, width: 1),
              Expanded(
                child: _buildContent(user),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildContent(user) {
    switch (_selectedIndex) {
      case 0:
        return _ProfileInfoTab(user: user);
      case 1:
        return const _MyPostsTab();
      case 2:
        return const _FavoritesTab();
      case 3:
        return const _ApplicationsTab();
      case 4:
        return const _SecurityTab();
      default:
        return const Center(child: Text('Unknown tab'));
    }
  }
}

class _ProfileInfoTab extends ConsumerStatefulWidget {
  final user;
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
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Profile Information', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Name')),
        const SizedBox(height: 16),
        TextField(controller: _phoneController, decoration: const InputDecoration(labelText: 'Phone')),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () async {
            // Update profile
            try {
              final repo = ref.read(authRepositoryProvider);
              await repo.updateProfile({
                'first_name': _nameController.text,
                'phone': _phoneController.text,
              });
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile Updated')));
              ref.refresh(authStateProvider);
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
            }
          },
          child: const Text('Save Changes'),
        ),
        const SizedBox(height: 48),
        ElevatedButton(
          onPressed: () {
            ref.read(authStateProvider.notifier).logout();
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('Logout', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}

class _MyPostsTab extends ConsumerWidget {
  const _MyPostsTab();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Ideally this uses a FutureProvider, but we keep it simple for now
    return FutureBuilder(
      future: ref.read(authRepositoryProvider).getMyPosts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        final posts = snapshot.data as List? ?? [];
        if (posts.isEmpty) return const Center(child: Text('No posts found.'));
        return ListView.builder(
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final post = posts[index];
            return ListTile(
              title: Text(post['title'] ?? 'Untitled'),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  ref.read(authRepositoryProvider).deleteMyPost('post', post['id']);
                },
              ),
            );
          },
        );
      },
    );
  }
}

class _FavoritesTab extends StatelessWidget {
  const _FavoritesTab();
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Favorites list will appear here.'));
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
        if (apps.isEmpty) return const Center(child: Text('No applications found.'));
        return ListView.builder(
          itemCount: apps.length,
          itemBuilder: (context, index) {
            final app = apps[index];
            return ListTile(
              title: Text(app['job_title'] ?? 'Job'),
              subtitle: Text(app['status'] ?? 'PENDING'),
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
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Change Password', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        TextField(controller: _oldController, decoration: const InputDecoration(labelText: 'Old Password'), obscureText: true),
        const SizedBox(height: 16),
        TextField(controller: _newController, decoration: const InputDecoration(labelText: 'New Password'), obscureText: true),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () async {
            try {
              await ref.read(authRepositoryProvider).changePassword(_oldController.text, _newController.text);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password Changed Successfully')));
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
            }
          },
          child: const Text('Update Password'),
        ),
      ],
    );
  }
}
