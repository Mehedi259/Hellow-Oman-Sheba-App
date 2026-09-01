import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../data/models/post.dart';
import '../../community/community_detail_screen.dart';

import 'section_header.dart';
import 'animated_see_more_button.dart';

class CommunityWidget extends StatefulWidget {
  final List<Post> posts;

  const CommunityWidget({super.key, required this.posts});

  @override
  State<CommunityWidget> createState() => _CommunityWidgetState();
}

class _CommunityWidgetState extends State<CommunityWidget> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    if (widget.posts.isEmpty) return const SizedBox();

    final displayCount = isExpanded ? widget.posts.length : (widget.posts.length > 6 ? 6 : widget.posts.length);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'প্রশ্নোত্তর',
          subtitle: 'প্রবাসী জীবনের সমস্যা ও সমাধান',
          icon: Icons.forum_outlined,
          color: const Color(0xFFF59E0B), // Amber/Orange
          onSeeAllPressed: () {
            context.push('/community');
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
              childAspectRatio: 0.78,
            ),
            itemCount: displayCount,
            itemBuilder: (context, index) {
              final post = widget.posts[index];
              return CommunityCardWidget(post: post);
            },
          ),
        ),
        if (widget.posts.length > 6 && !isExpanded)
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

class CommunityCardWidget extends StatelessWidget {
  final Post post;
  const CommunityCardWidget({super.key, required this.post});

  String _formatTime(DateTime time) {
    final difference = DateTime.now().difference(time);
    if (difference.inDays > 0) return '${difference.inDays} দিন আগে';
    if (difference.inHours > 0) return '${difference.inHours} ঘন্টা আগে';
    if (difference.inMinutes > 0) return '${difference.inMinutes} মিনিট আগে';
    return 'মাত্রই';
  }

  @override
  Widget build(BuildContext context) {
    final Color logoBlue = const Color(0xFF0056D2);
    final Color logoBlueBg = const Color(0xFF0056D2).withOpacity(0.08);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CommunityDetailScreen(post: post),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: logoBlueBg,
                  borderRadius: BorderRadius.circular(20), // Pill shape
                ),
                child: Text(
                  post.categoryName,
                  style: TextStyle(
                    color: logoBlue,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                post.title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Text(
                post.content,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF94A3B8),
                  height: 1.3,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              // Author and Time row
              Row(
                children: [
                  const Icon(Icons.person_outline_rounded, size: 14, color: Color(0xFF64748B)),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      post.authorName.isNotEmpty ? post.authorName : 'অজ্ঞাত',
                      style: const TextStyle(color: Color(0xFF64748B), fontSize: 11, fontWeight: FontWeight.w500),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6),
                    child: Text('•', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
                  ),
                  const Icon(Icons.access_time_rounded, size: 14, color: Color(0xFF64748B)),
                  const SizedBox(width: 4),
                  Text(
                    _formatTime(post.createdAt),
                    style: const TextStyle(color: Color(0xFF64748B), fontSize: 11),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Divider(height: 1, color: Colors.grey.shade200),
              const SizedBox(height: 10),
              // Stats row
              Row(
                children: [
                  const Icon(Icons.thumb_up_alt_outlined, size: 15, color: Color(0xFF64748B)),
                  const SizedBox(width: 4),
                  Text('${post.likes}', style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                  const SizedBox(width: 16),
                  const Icon(Icons.chat_bubble_outline_rounded, size: 15, color: Color(0xFF64748B)),
                  const SizedBox(width: 4),
                  Text('${post.commentsCount} মন্তব্য', style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

