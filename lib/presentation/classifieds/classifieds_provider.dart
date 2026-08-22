import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/job.dart';
import '../../data/models/classifieds_models.dart';
import '../../data/repositories/classifieds_repository.dart';
import '../auth/auth_provider.dart'; // To get apiClientProvider

final classifiedsRepositoryProvider = Provider((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ClassifiedsRepository(apiClient);
});

final jobsProvider = FutureProvider<List<Job>>((ref) async {
  final repository = ref.watch(classifiedsRepositoryProvider);
  return repository.getJobs();
});

final propertiesProvider = FutureProvider<List<Property>>((ref) async {
  final repository = ref.watch(classifiedsRepositoryProvider);
  return repository.getProperties();
});

final vehiclesProvider = FutureProvider<List<Vehicle>>((ref) async {
  final repository = ref.watch(classifiedsRepositoryProvider);
  return repository.getVehicles();
});

final servicesProvider = FutureProvider<List<Service>>((ref) async {
  final repository = ref.watch(classifiedsRepositoryProvider);
  return repository.getServices();
});
