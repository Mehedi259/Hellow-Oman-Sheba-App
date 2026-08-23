import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/job.dart';
import '../../data/models/classifieds_models.dart';
import '../../data/repositories/classifieds_repository.dart';
import '../../core/api/api_client.dart';
import '../auth/auth_provider.dart';

final classifiedsRepositoryProvider = Provider((ref) {
  return ClassifiedsRepository(ref.watch(apiClientProvider));
});

class JobDetailScreen extends ConsumerWidget {
  final Job job;
  const JobDetailScreen({super.key, required this.job});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text(job.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (job.images.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    job.images[0].startsWith('http') ? job.images[0] : 'http://188.245.212.240${job.images[0]}',
                    height: 250,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Container(height: 250, color: Colors.grey[200], child: const Icon(Icons.broken_image, color: Colors.grey, size: 50)),
                  ),
                ),
              ),
            Text(job.title, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text('${job.company} - ${job.location}', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey)),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.attach_money, color: Colors.teal),
                Text(job.salary),
                const SizedBox(width: 16),
                const Icon(Icons.work, color: Colors.teal),
                Text(job.jobType),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Description', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(job.description),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  try {
                    await ref.read(classifiedsRepositoryProvider).applyForJob(job.id);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Successfully applied for job!')));
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                },
                child: const Text('Apply Now'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PropertyDetailScreen extends StatelessWidget {
  final Property property;
  const PropertyDetailScreen({super.key, required this.property});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(property.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (property.imageUrl != null)
              Image.network(
                property.imageUrl!.startsWith('http') ? property.imageUrl! : 'http://188.245.212.240${property.imageUrl}',
                height: 250,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Container(height: 250, color: Colors.grey[200], child: const Icon(Icons.broken_image, color: Colors.grey, size: 50)),
              ),
            const SizedBox(height: 16),
            Text(property.title, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text('\$${property.price}', style: const TextStyle(fontSize: 24, color: Colors.teal, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Text('${property.location} • ${property.type}'),
            const SizedBox(height: 24),
            const Text('Description', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(property.description),
            const SizedBox(height: 24),
            const Text('Contact Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(property.contactInfo),
          ],
        ),
      ),
    );
  }
}

class VehicleDetailScreen extends StatelessWidget {
  final Vehicle vehicle;
  const VehicleDetailScreen({super.key, required this.vehicle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(vehicle.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (vehicle.imageUrl != null)
              Image.network(
                vehicle.imageUrl!.startsWith('http') ? vehicle.imageUrl! : 'http://188.245.212.240${vehicle.imageUrl}',
                height: 250,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Container(height: 250, color: Colors.grey[200], child: const Icon(Icons.broken_image, color: Colors.grey, size: 50)),
              ),
            const SizedBox(height: 16),
            Text(vehicle.title, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text('\$${vehicle.price}', style: const TextStyle(fontSize: 24, color: Colors.teal, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Text('${vehicle.make} ${vehicle.model} • ${vehicle.year} • ${vehicle.mileage} km'),
            const SizedBox(height: 24),
            const Text('Description', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(vehicle.description),
            const SizedBox(height: 24),
            const Text('Contact Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(vehicle.contactInfo),
          ],
        ),
      ),
    );
  }
}

class ServiceDetailScreen extends StatelessWidget {
  final Service service;
  const ServiceDetailScreen({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(service.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (service.imageUrl != null)
              Image.network(
                service.imageUrl!.startsWith('http') ? service.imageUrl! : 'http://188.245.212.240${service.imageUrl}',
                height: 250,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Container(height: 250, color: Colors.grey[200], child: const Icon(Icons.broken_image, color: Colors.grey, size: 50)),
              ),
            const SizedBox(height: 16),
            Text(service.title, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(service.category, style: const TextStyle(fontSize: 18, color: Colors.teal)),
            const SizedBox(height: 24),
            const Text('Description', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(service.description),
            const SizedBox(height: 24),
            const Text('Contact Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(service.contactInfo),
          ],
        ),
      ),
    );
  }
}
