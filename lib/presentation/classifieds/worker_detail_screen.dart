import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../data/models/job_seeker.dart';
import 'package:url_launcher/url_launcher.dart';

class WorkerDetailScreen extends StatelessWidget {
  final JobSeeker jobSeeker;

  const WorkerDetailScreen({super.key, required this.jobSeeker});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('প্রোফাইল বিস্তারিত', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              children: [
                // Header Profile Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(32),
                      bottomRight: Radius.circular(32),
                    ),
                  ),
                  child: Column(
                    children: [
                      Hero(
                        tag: 'worker_avatar_${jobSeeker.id}',
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFEC4899), width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFEC4899).withOpacity(0.2),
                                blurRadius: 16,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: jobSeeker.userAvatar != null
                                ? CachedNetworkImage(
                                    imageUrl: jobSeeker.userAvatar!.startsWith('http') 
                                      ? jobSeeker.userAvatar! 
                                      : 'http://188.245.212.240${jobSeeker.userAvatar}',
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                                    errorWidget: (context, url, error) => const Icon(Icons.person, size: 50, color: Colors.grey),
                                  )
                                : const Icon(Icons.person, size: 50, color: Colors.grey),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        jobSeeker.userFullName.isNotEmpty ? jobSeeker.userFullName : jobSeeker.userName,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        jobSeeker.professionalTitle,
                        style: const TextStyle(fontSize: 16, color: Color(0xFFEC4899), fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Info Cards
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: _InfoCard(
                          icon: Icons.work_history_rounded,
                          title: 'অভিজ্ঞতা',
                          value: '${jobSeeker.yearsOfExperience} বছর',
                          color: const Color(0xFF3B82F6),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _InfoCard(
                          icon: Icons.school_rounded,
                          title: 'শিক্ষাগত যোগ্যতা',
                          value: jobSeeker.educationLevel ?? 'দেওয়া নেই',
                          color: const Color(0xFF10B981),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Details Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('আমার সম্পর্কে', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        Text(
                          jobSeeker.summary.isNotEmpty ? jobSeeker.summary : 'কোনো তথ্য দেওয়া নেই।',
                          style: TextStyle(fontSize: 15, color: Colors.grey.shade700, height: 1.5),
                        ),
                        
                        if (jobSeeker.skills.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          const Text('দক্ষতা', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: jobSeeker.skills.map((skill) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEC4899).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: const Color(0xFFEC4899).withOpacity(0.2)),
                              ),
                              child: Text(
                                skill,
                                style: const TextStyle(color: Color(0xFFEC4899), fontSize: 13, fontWeight: FontWeight.w500),
                              ),
                            )).toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Sticky Bottom Contact Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5)),
                ],
              ),
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (jobSeeker.userPhone != null && jobSeeker.userPhone!.isNotEmpty) {
                        launchUrl(Uri.parse('tel:${jobSeeker.userPhone}'));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('কোনো ফোন নম্বর দেওয়া নেই!')),
                        );
                      }
                    },
                    icon: const Icon(Icons.phone),
                    label: const Text('যোগাযোগ করুন', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEC4899),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(title, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87), maxLines: 2, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}
