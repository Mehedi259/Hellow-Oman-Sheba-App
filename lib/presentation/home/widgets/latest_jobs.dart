import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../data/models/job.dart';
import '../../classifieds/widgets/job_card.dart';

import 'section_header.dart';

class LatestJobsWidget extends StatefulWidget {
  final List<Job> jobs;

  const LatestJobsWidget({super.key, required this.jobs});

  @override
  State<LatestJobsWidget> createState() => _LatestJobsWidgetState();
}

class _LatestJobsWidgetState extends State<LatestJobsWidget> {
  bool isExpanded = false;

  String _timeAgo(DateTime createdAt) {
    final difference = DateTime.now().difference(createdAt);
    if (difference.inDays > 0) {
      return '${difference.inDays} দিন আগে';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ঘন্টা আগে';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} মিনিট আগে';
    } else {
      return 'এইমাত্র';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.jobs.isEmpty) return const SizedBox();

    final displayCount = isExpanded ? widget.jobs.length : (widget.jobs.length > 4 ? 4 : widget.jobs.length);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'চাকরি খুঁজুন',
          subtitle: 'আপনার স্বপ্নের চাকরি খুঁজুন',
          icon: Icons.work_outline_rounded,
          color: const Color(0xFF2563EB), // Blue
          onSeeAllPressed: () {
            context.push('/classifieds');
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: GridView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 0.58, // Adjust based on card height
            ),
            itemCount: displayCount,
            itemBuilder: (context, index) {
              final job = widget.jobs[index];
              return JobCardWidget(job: job);
            },
          ),
        ),
        if (widget.jobs.length > 4 && !isExpanded)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 12, right: 12),
            child: SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  setState(() {
                    isExpanded = true;
                  });
                },
                style: TextButton.styleFrom(
                  backgroundColor: Colors.blue.shade50,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('আরও দেখুন', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
      ],
    );
  }
}
