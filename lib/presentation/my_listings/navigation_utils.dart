import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/auth_provider.dart';
import '../../core/api/api_client.dart';
import '../../data/models/job.dart';
import '../../data/models/classifieds_models.dart';
import '../../data/models/job_seeker.dart';
import '../../data/models/post.dart';
import '../classifieds/classifieds_detail_screens.dart';
import '../classifieds/worker_detail_screen.dart';
import '../categories/service_list_screen.dart' show ServiceDetailScreen;
import '../community/community_detail_screen.dart';

Future<void> navigateToFavoriteItem(BuildContext context, WidgetRef ref, String type, int id) async {
  final apiClient = ref.read(apiClientProvider);
  
  bool isDialogShowing = true;
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const Center(child: CircularProgressIndicator(color: Color(0xFF0056D2))),
  ).then((_) {
    isDialogShowing = false;
  });

  try {
    Widget? nextScreen;
    
    if (type == 'job') {
      final res = await apiClient.dio.get('/classifieds/jobs/$id/');
      nextScreen = JobDetailScreen(job: Job.fromJson(res.data));
    } else if (type == 'property') {
      final res = await apiClient.dio.get('/classifieds/properties/$id/');
      nextScreen = PropertyDetailScreen(property: Property.fromJson(res.data));
    } else if (type == 'vehicle') {
      final res = await apiClient.dio.get('/classifieds/vehicles/$id/');
      nextScreen = VehicleDetailScreen(vehicle: Vehicle.fromJson(res.data));
    } else if (type == 'service') {
      final res = await apiClient.dio.get('/classifieds/services/$id/');
      nextScreen = ServiceDetailScreen(service: Service.fromJson(res.data));
    } else if (type == 'job_seeker') {
      final res = await apiClient.dio.get('/classifieds/job-seekers/$id/');
      nextScreen = WorkerDetailScreen(jobSeeker: JobSeeker.fromJson(res.data));
    } else if (type == 'post' || type == 'forum_post' || type == 'community') {
      final res = await apiClient.dio.get('/community/forum/posts/$id/');
      nextScreen = CommunityDetailScreen(post: Post.fromJson(res.data));
    } else {
      if (!context.mounted) return;
      if (isDialogShowing) Navigator.of(context, rootNavigator: true).pop();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('অজানা টাইপ: $type')));
      return;
    }
    
    if (!context.mounted) return;
    if (isDialogShowing) {
      Navigator.of(context, rootNavigator: true).pop();
    }
    
    if (nextScreen != null) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => nextScreen!));
    }
  } catch (e) {
    debugPrint('Navigation error: $e');
    if (!context.mounted) return;
    if (isDialogShowing) {
      Navigator.of(context, rootNavigator: true).pop();
    }
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('বিস্তারিত তথ্য পাওয়া যায়নি।'), backgroundColor: Colors.red));
  }
}
