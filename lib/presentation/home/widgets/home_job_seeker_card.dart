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
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFEC4899).withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Gradient header with avatar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFEC4899), Color(0xFFF97316)],
              ),
            ),
            child: Center(
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.4), width: 2),
                  color: Colors.white.withOpacity(0.2),
                ),
                child: jobSeeker.userAvatar != null && jobSeeker.userAvatar!.isNotEmpty
                    ? ClipOval(
                        child: Image.network(
                          jobSeeker.userAvatar!.startsWith('http')
                              ? jobSeeker.userAvatar!
                              : 'http://188.245.212.240${jobSeeker.userAvatar}',
                          fit: BoxFit.cover,
                          width: 56,
                          height: 56,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.person_rounded, color: Colors.white, size: 26),
                        ),
                      )
                    : Text(
                        _getInitials(jobSeeker.userFullName.isNotEmpty ? jobSeeker.userFullName : jobSeeker.userName),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ),
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: Column(
                children: [
                  Text(
                    jobSeeker.professionalTitle,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B),
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    jobSeeker.userFullName.isNotEmpty ? jobSeeker.userFullName : jobSeeker.userName,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF94A3B8),
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  _infoRow(Icons.work_history_rounded, 'অভিজ্ঞতা: ${jobSeeker.yearsOfExperience} বছর', const Color(0xFFEC4899)),
                  if (jobSeeker.educationLevel != null && jobSeeker.educationLevel!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    _infoRow(Icons.school_rounded, jobSeeker.educationLevel!, const Color(0xFF94A3B8)),
                  ],
                  const Spacer(),
                  // Button
                  SizedBox(
                    width: double.infinity,
                    height: 34,
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: View candidate profile
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEC4899),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                        padding: EdgeInsets.zero,
                      ),
                      child: const Text('প্রোফাইল দেখুন', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return 'N';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  Widget _infoRow(IconData icon, String text, Color iconColor) {
    return Row(
      children: [
        Icon(icon, size: 13, color: iconColor),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text,
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 11, height: 1.2),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
