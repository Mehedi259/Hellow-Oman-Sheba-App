import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../auth/auth_provider.dart';
import '../classifieds/classifieds_provider.dart';
import 'system_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final jobsState = ref.watch(jobsProvider);
    final slidersState = ref.watch(slidersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sheba App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.push('/search'),
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () => context.push('/notifications'),
          ),
          IconButton(
            icon: const Icon(Icons.warning, color: Colors.red),
            onPressed: () => context.push('/emergency'),
          ),
          authState.when(
            data: (user) {
              if (user != null) {
                return IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () {
                    ref.read(authStateProvider.notifier).logout();
                  },
                );
              }
              return IconButton(
                icon: const Icon(Icons.person),
                onPressed: () => context.push('/login'),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const SizedBox(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(jobsProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            slidersState.when(
              data: (sliders) {
                if (sliders.isEmpty) return const SizedBox();
                return SizedBox(
                  height: 200,
                  child: PageView.builder(
                    itemCount: sliders.length,
                    itemBuilder: (context, index) {
                      final slider = sliders[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          image: DecorationImage(
                            image: NetworkImage(slider.imageUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: LinearGradient(
                              colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                          ),
                          padding: const EdgeInsets.all(16),
                          alignment: Alignment.bottomLeft,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(slider.title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                              Text(slider.subtitle, style: const TextStyle(color: Colors.white70)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => const SizedBox(),
            ),
            Text(
              'Latest Jobs',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            jobsState.when(
              data: (jobs) {
                if (jobs.isEmpty) {
                  return const Text('No jobs found.');
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: jobs.length,
                  itemBuilder: (context, index) {
                    final job = jobs[index];
                    return Card(
                      child: ListTile(
                        title: Text(job.title),
                        subtitle: Text('${job.company} - ${job.location}'),
                        trailing: Text(job.salary),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Text('Error: $error'),
            ),
          ],
        ),
      ),
    );
  }
}
