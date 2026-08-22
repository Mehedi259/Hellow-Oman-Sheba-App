import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../auth/auth_provider.dart';
import '../classifieds/classifieds_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final jobsState = ref.watch(jobsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sheba App'),
        actions: [
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
