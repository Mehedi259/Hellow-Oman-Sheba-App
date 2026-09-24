import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../widgets/custom_cached_image.dart';
import '../../../data/models/job_seeker.dart';
import '../worker_detail_screen.dart';

class JobSeekerCardWidget extends StatelessWidget {
  final JobSeeker jobSeeker;

  const JobSeekerCardWidget({super.key, required this.jobSeeker});

  void _openProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WorkerDetailScreen(jobSeeker: jobSeeker),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _openProfile(context),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: Colors.blue.shade100, width: 2),
                ),
                child: jobSeeker.userAvatar != null && jobSeeker.userAvatar!.isNotEmpty
                  ? CustomCachedImage(
                      imageUrl: jobSeeker.userAvatar!.startsWith('http')
                          ? jobSeeker.userAvatar!
                          : 'http://188.245.212.240${jobSeeker.userAvatar}',
                      fit: BoxFit.cover,
                      borderRadius: 32,
                    )
                    : const Icon(Icons.person, color: Colors.grey, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      jobSeeker.professionalTitle,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      jobSeeker.userFullName.isNotEmpty ? jobSeeker.userFullName : jobSeeker.userName,
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            jobSeeker.summary,
            style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.work_outline, size: 16, color: Colors.blue),
                  const SizedBox(width: 4),
                  Text(
                    'অভিজ্ঞতা: ${jobSeeker.yearsOfExperience} বছর',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                ],
              ),
              if (jobSeeker.educationLevel != null && jobSeeker.educationLevel!.isNotEmpty)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.school_outlined, size: 16, color: Colors.blue),
                    const SizedBox(width: 4),
                    Text(
                      jobSeeker.educationLevel!,
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                    ),
                  ],
                ),
            ],
          ),
          if (jobSeeker.skills.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ...jobSeeker.skills.take(5).map((skill) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        skill,
                        style: TextStyle(color: Colors.blue.shade700, fontSize: 11),
                      ),
                    )),
                if (jobSeeker.skills.length > 5)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '+${jobSeeker.skills.length - 5}',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                    ),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              if (jobSeeker.expectedSalary != null)
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      text: 'প্রত্যাশিত বেতন: ',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 13, fontWeight: FontWeight.bold),
                      children: [
                        TextSpan(
                          text: '${jobSeeker.expectedSalary} ${jobSeeker.salaryCurrency}',
                          style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                )
              else
                const Spacer(),
              if (jobSeeker.userPhone != null && jobSeeker.userPhone!.isNotEmpty) ...[
                IconButton(
                  onPressed: () async {
                    final uri = Uri.parse('tel:${jobSeeker.userPhone}');
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri);
                    }
                  },
                  icon: const Icon(Icons.phone_in_talk_rounded, size: 20),
                  color: Colors.green.shade600,
                  tooltip: 'কল করুন',
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.green.shade50,
                    padding: const EdgeInsets.all(8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Colors.green.shade200),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              OutlinedButton(
                onPressed: () => _openProfile(context),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  side: BorderSide(color: Colors.grey.shade300),
                  foregroundColor: const Color(0xFF0056D2),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                ),
                child: const Text(
                  'প্রোফাইল দেখুন',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  ),
),
);
  }
}
