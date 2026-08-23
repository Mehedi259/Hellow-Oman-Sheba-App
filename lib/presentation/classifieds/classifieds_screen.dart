import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'classifieds_provider.dart';
import 'classifieds_detail_screens.dart';
import 'widgets/job_card.dart';

class ClassifiedsScreen extends StatelessWidget {
  const ClassifiedsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Classifieds'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Jobs'),
              Tab(text: 'Properties'),
              Tab(text: 'Vehicles'),
              Tab(text: 'Services'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            JobsView(),
            PropertiesView(),
            VehiclesView(),
            ServicesView(),
          ],
        ),
      ),
    );
  }
}

class JobsView extends ConsumerWidget {
  const JobsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobsState = ref.watch(jobsProvider);
    return jobsState.when(
      data: (jobs) {
        if (jobs.isEmpty) return const Center(child: Text('No jobs found.'));
        return GridView.builder(
          padding: const EdgeInsets.all(16.0),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 0.75,
          ),
          itemCount: jobs.length,
          itemBuilder: (context, index) {
            return JobCardWidget(job: jobs[index]);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}

class PropertiesView extends ConsumerWidget {
  const PropertiesView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(propertiesProvider);
    return state.when(
      data: (items) {
        if (items.isEmpty) return const Center(child: Text('No properties found.'));
        return ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                title: Text(item.title),
                subtitle: Text('${item.location} - ${item.type}'),
                trailing: Text('\$${item.price}'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PropertyDetailScreen(property: item)),
                  );
                },
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}

class VehiclesView extends ConsumerWidget {
  const VehiclesView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(vehiclesProvider);
    return state.when(
      data: (items) {
        if (items.isEmpty) return const Center(child: Text('No vehicles found.'));
        return ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                title: Text(item.title),
                subtitle: Text('${item.make} ${item.model} (${item.year})'),
                trailing: Text('\$${item.price}'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => VehicleDetailScreen(vehicle: item)),
                  );
                },
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}

class ServicesView extends ConsumerWidget {
  const ServicesView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(servicesProvider);
    return state.when(
      data: (items) {
        if (items.isEmpty) return const Center(child: Text('No services found.'));
        return ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                title: Text(item.title),
                subtitle: Text(item.category),
                trailing: Text(item.contactInfo),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ServiceDetailScreen(service: item)),
                  );
                },
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}
