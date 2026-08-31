import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../data/models/job_seeker.dart';
import 'home_job_seeker_card.dart';

import 'section_header.dart';
import 'animated_see_more_button.dart';

class LatestWorkersWidget extends StatefulWidget {
  final List<JobSeeker> workers;

  const LatestWorkersWidget({super.key, required this.workers});

  @override
  State<LatestWorkersWidget> createState() => _LatestWorkersWidgetState();
}

class _LatestWorkersWidgetState extends State<LatestWorkersWidget> {
  bool isExpanded = false;

  String _toBengaliNumber(int number) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const bengali = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
    String numStr = number.toString();
    for (int i = 0; i < english.length; i++) {
      numStr = numStr.replaceAll(english[i], bengali[i]);
    }
    return numStr;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.workers.isEmpty) return const SizedBox();

    final displayCount = isExpanded ? widget.workers.length : (widget.workers.length > 4 ? 4 : widget.workers.length);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'কর্মী খুঁজুন',
          badgeText: '${_toBengaliNumber(widget.workers.length)} টি',
          subtitle: 'দক্ষ কর্মী খুঁজে নিন',
          icon: Icons.group_outlined,
          color: const Color(0xFFEC4899), // Pink
          onSeeAllPressed: () {
            context.push('/classifieds?tab=jobs');
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
              childAspectRatio: 0.70, // Adjust based on card height
            ),
            itemCount: displayCount,
            itemBuilder: (context, index) {
              final worker = widget.workers[index];
              return HomeJobSeekerCardWidget(jobSeeker: worker);
            },
          ),
        ),
        if (widget.workers.length > 4 && !isExpanded)
          AnimatedSeeMoreButton(
            onPressed: () {
              setState(() {
                isExpanded = true;
              });
            },
          ),
      ],
    );
  }
}
