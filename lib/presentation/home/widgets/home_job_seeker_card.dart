import 'package:flutter/material.dart';
import '../../../data/models/job_seeker.dart';

class HomeJobSeekerCardWidget extends StatelessWidget {
  final JobSeeker jobSeeker;

  const HomeJobSeekerCardWidget({super.key, required this.jobSeeker});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade100, width: 1),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              shape: BoxShape.circle,
            ),
            child: jobSeeker.userAvatar != null && jobSeeker.userAvatar!.isNotEmpty
                ? ClipOval(
                    child: Image.network(
                      jobSeeker.userAvatar!.startsWith('http')
                          ? jobSeeker.userAvatar!
                          : 'http://188.245.212.240${jobSeeker.userAvatar}',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Icon(Icons.person_outline, color: Colors.blue.shade300, size: 32),
                    ),
                  )
                : Icon(Icons.person, color: Colors.blue.shade300, size: 32),
          ),
          const SizedBox(height: 12),
          // Title
          Text(
            jobSeeker.professionalTitle,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          // Name
          Text(
            jobSeeker.userFullName.isNotEmpty ? jobSeeker.userFullName : jobSeeker.userName,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          // Details
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.work_outline, size: 14, color: Colors.blue.shade400),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  'অভিজ্ঞতা: ${jobSeeker.yearsOfExperience} বছর',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          if (jobSeeker.educationLevel != null && jobSeeker.educationLevel!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.school_outlined, size: 14, color: Colors.blue.shade400),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    jobSeeker.educationLevel!,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
          const Spacer(),
          // Button
          SizedBox(
            width: double.infinity,
            height: 36,
            child: ElevatedButton(
              onPressed: () {
                // TODO: View candidate profile
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                elevation: 0,
              ),
              child: const Text('প্রোফাইল দেখুন', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            ),
          ),
        ],
      ),
    );
  }
}
