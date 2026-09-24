import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../auth/auth_provider.dart';
import '../../core/utils/router_utils.dart';
import '../../data/models/job.dart';
import '../../data/models/classifieds_models.dart';
import '../../data/models/job_seeker.dart';
import '../../data/models/post.dart';
import '../classifieds/classifieds_detail_screens.dart';
import '../classifieds/worker_detail_screen.dart';
import '../categories/service_list_screen.dart' show ServiceDetailScreen;
import '../community/community_detail_screen.dart';
import '../messages/chat_screen.dart';

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

Future<void> navigateToNotificationItem(
  BuildContext context,
  WidgetRef ref,
  Map<String, dynamic> notif,
) async {
  final apiClient = ref.read(apiClientProvider);

  final actionType = (notif['action_type']?.toString() ?? '').toLowerCase().trim();
  final type = (notif['type']?.toString() ?? '').toUpperCase().trim();
  final actionIdStr = (notif['action_id']?.toString() ?? '').trim();
  final actionId = int.tryParse(actionIdStr);
  final link = (notif['link']?.toString() ?? '').trim();

  // 1. External or deep link
  if (link.isNotEmpty) {
    if (link.startsWith('http://') || link.startsWith('https://')) {
      final uri = Uri.tryParse(link);
      if (uri != null && await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return;
      }
    } else if (link.startsWith('/')) {
      if (context.mounted) {
        context.safePushRoute(link);
      }
      return;
    }
  }

  // 2. Chat / Direct Message
  if (actionType == 'chat' || actionType == 'message' || type == 'MESSAGE') {
    if (actionId != null) {
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatScreen(
              title: notif['title'] ?? 'চ্যাট',
              conversationId: actionId,
            ),
          ),
        );
      }
    } else {
      if (context.mounted) {
        context.safePushRoute('/messages');
      }
    }
    return;
  }

  // 3. Fallback when actionId is null
  if (actionId == null) {
    if (actionType == 'new_job' || actionType == 'job' || type == 'JOB_ALERT') {
      if (context.mounted) context.safePushRoute('/classifieds?tab=jobs');
    } else if (actionType == 'job_application' || type == 'JOB_APPLICATION') {
      if (context.mounted) context.safePushRoute('/profile');
    } else if (actionType == 'forum_comment' ||
        actionType == 'forum_reply' ||
        actionType == 'post' ||
        actionType == 'community') {
      if (context.mounted) context.safePushRoute('/community');
    } else if (actionType == 'property') {
      if (context.mounted) context.safePushRoute('/classifieds?tab=properties');
    } else if (actionType == 'vehicle') {
      if (context.mounted) context.safePushRoute('/classifieds?tab=vehicles');
    } else if (actionType == 'service') {
      if (context.mounted) context.safePushRoute('/classifieds?tab=services');
    } else if (actionType == 'job_seeker' || actionType == 'seeker') {
      if (context.mounted) context.safePushRoute('/classifieds?tab=workers');
    } else if (actionType == 'news') {
      if (context.mounted) context.safePushRoute('/news');
    }
    return;
  }

  // 4. Detail item navigation with loading indicator
  if (!context.mounted) return;
  bool isDialogShowing = true;
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const Center(
      child: CircularProgressIndicator(color: Color(0xFF0056D2)),
    ),
  ).then((_) {
    isDialogShowing = false;
  });

  try {
    Widget? nextScreen;

    if (actionType == 'new_job' ||
        actionType == 'job' ||
        actionType == 'job_application' ||
        type == 'JOB_ALERT' ||
        type == 'JOB_APPLICATION') {
      final res = await apiClient.dio.get('/classifieds/jobs/$actionId/');
      nextScreen = JobDetailScreen(job: Job.fromJson(res.data));
    } else if (actionType == 'property') {
      final res = await apiClient.dio.get('/classifieds/properties/$actionId/');
      nextScreen = PropertyDetailScreen(property: Property.fromJson(res.data));
    } else if (actionType == 'vehicle') {
      final res = await apiClient.dio.get('/classifieds/vehicles/$actionId/');
      nextScreen = VehicleDetailScreen(vehicle: Vehicle.fromJson(res.data));
    } else if (actionType == 'service') {
      final res = await apiClient.dio.get('/classifieds/services/$actionId/');
      nextScreen = ServiceDetailScreen(service: Service.fromJson(res.data));
    } else if (actionType == 'job_seeker' || actionType == 'seeker') {
      final res = await apiClient.dio.get('/classifieds/job-seekers/$actionId/');
      nextScreen = WorkerDetailScreen(jobSeeker: JobSeeker.fromJson(res.data));
    } else if (actionType == 'forum_comment' ||
        actionType == 'forum_reply' ||
        actionType == 'post' ||
        actionType == 'forum_post' ||
        actionType == 'community') {
      final res = await apiClient.dio.get('/community/forum/posts/$actionId/');
      nextScreen = CommunityDetailScreen(post: Post.fromJson(res.data));
    } else if (type.contains('JOB')) {
      final res = await apiClient.dio.get('/classifieds/jobs/$actionId/');
      nextScreen = JobDetailScreen(job: Job.fromJson(res.data));
    }

    if (!context.mounted) return;
    if (isDialogShowing) {
      Navigator.of(context, rootNavigator: true).pop();
    }

    if (nextScreen != null) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => nextScreen!));
    }
  } catch (e) {
    debugPrint('Notification navigation error: $e');
    if (!context.mounted) return;
    if (isDialogShowing) {
      Navigator.of(context, rootNavigator: true).pop();
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('আইটেমটি আর পাওয়া যাচ্ছে না অথবা মুছে ফেলা হয়েছে।'),
        backgroundColor: Colors.red,
      ),
    );
  }
}

