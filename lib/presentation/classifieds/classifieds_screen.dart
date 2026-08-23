import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'classifieds_provider.dart';
import 'classifieds_detail_screens.dart';
import 'widgets/job_card.dart';
import 'widgets/market_card.dart';

class ClassifiedsScreen extends StatelessWidget {
  final String? initialTab;
  const ClassifiedsScreen({super.key, this.initialTab});

  int _getInitialIndex() {
    switch (initialTab) {
      case 'market':
        return 0;
      case 'jobs':
        return 1;
      case 'properties':
        return 2;
      case 'vehicles':
        return 3;
      case 'services':
        return 4;
      default:
        return 0; // Default to Market
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: _getInitialIndex(),
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Classifieds'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Market'),
              Tab(text: 'Jobs'),
              Tab(text: 'Properties'),
              Tab(text: 'Vehicles'),
              Tab(text: 'Services'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            MarketView(),
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
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              elevation: 2,
              shadowColor: Colors.grey.shade100,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ServiceDetailScreen(service: item)),
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.teal.shade50,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.handyman_outlined, color: Colors.teal.shade600, size: 24),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    item.category,
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(height: 1),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.phone_outlined, size: 16, color: Colors.grey.shade600),
                              const SizedBox(width: 8),
                              Text(
                                item.contactInfo,
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey.shade400),
                        ],
                      ),
                    ],
                  ),
                ),
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

class MarketView extends ConsumerWidget {
  const MarketView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(marketItemsProvider);
    return state.when(
      data: (items) {
        if (items.isEmpty) return const Center(child: Text('No market items found.'));
        return GridView.builder(
          padding: const EdgeInsets.all(16.0),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 0.72,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            return MarketCardWidget(item: items[index]);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}
