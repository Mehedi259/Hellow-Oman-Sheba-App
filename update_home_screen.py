with open('lib/presentation/home/home_screen.dart', 'r') as f:
    content = f.read()

# Add imports if missing
if "import 'widgets/latest_workers.dart';" not in content:
    content = content.replace("import 'widgets/latest_jobs.dart';", "import 'widgets/latest_jobs.dart';\nimport 'widgets/latest_workers.dart';")

# Find where jobsState is consumed in the body
jobs_widget = """jobsState.when(
              data: (jobs) => Padding(padding: const EdgeInsets.symmetric(horizontal: 16.0), child: LatestJobsWidget(jobs: jobs.take(6).toList())),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Text('Jobs Error: $error'),
            ),"""

workers_widget = """jobsState.when(
              data: (jobs) => Padding(padding: const EdgeInsets.symmetric(horizontal: 16.0), child: LatestJobsWidget(jobs: jobs.take(4).toList())),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Text('Jobs Error: $error'),
            ),
            const SizedBox(height: 16),
            ref.watch(homeJobSeekersProvider).when(
              data: (workers) => Padding(padding: const EdgeInsets.symmetric(horizontal: 16.0), child: LatestWorkersWidget(workers: workers.take(4).toList())),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Text('Workers Error: $error'),
            ),"""

content = content.replace(jobs_widget, workers_widget)

# Update RefreshIndicator to also invalidate homeJobSeekersProvider
if "ref.invalidate(homeJobSeekersProvider);" not in content:
    content = content.replace("ref.invalidate(jobsProvider);", "ref.invalidate(jobsProvider);\n          ref.invalidate(homeJobSeekersProvider);")

with open('lib/presentation/home/home_screen.dart', 'w') as f:
    f.write(content)

