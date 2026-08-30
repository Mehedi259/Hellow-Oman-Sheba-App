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

    final displayCount = isExpanded ? widget.posts.length : (widget.posts.length > 4 ? 4 : widget.posts.length);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'কমিউনিটি আলোচনা',
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
        if (widget.posts.length > 4 && !isExpanded)
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

  // Category-based colors for visual differentiation
  Map<String, dynamic> _getCategoryStyle(String categoryName) {
    final name = categoryName.toLowerCase();
    if (name.contains('সাহায্য') || name.contains('help')) {
      return {
        'color': const Color(0xFFEA580C),
        'bgColor': const Color(0xFFFFF7ED),
        'gradient': [const Color(0xFFEA580C), const Color(0xFFF59E0B)],
      };
    } else if (name.contains('আলোচনা') || name.contains('general')) {
      return {
        'color': const Color(0xFF0EA5E9),
        'bgColor': const Color(0xFFF0F9FF),
        'gradient': [const Color(0xFF0EA5E9), const Color(0xFF6366F1)],
      };
    } else if (name.contains('চাকরি') || name.contains('job')) {
      return {
        'color': const Color(0xFF059669),
        'bgColor': const Color(0xFFECFDF5),
        'gradient': [const Color(0xFF059669), const Color(0xFF10B981)],
      };
    } else {
      return {
        'color': const Color(0xFF8B5CF6),
        'bgColor': const Color(0xFFF5F3FF),
        'gradient': [const Color(0xFF8B5CF6), const Color(0xFFA78BFA)],
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    final catStyle = _getCategoryStyle(post.categoryName);
    final Color catColor = catStyle['color'];
    final Color catBgColor = catStyle['bgColor'];
    final List<Color> catGradient = catStyle['gradient'];

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
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: catColor.withOpacity(0.08),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gradient accent bar
            Container(
              height: 4,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: catGradient),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: catBgColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        post.categoryName,
                        style: TextStyle(
                          color: catColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      post.title,
                      style: const TextStyle(
                        fontSize: 13,
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
                        fontSize: 11,
                        color: Color(0xFF94A3B8),
                        height: 1.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    // Author row
                    Row(
                      children: [
                        const Icon(Icons.person_rounded, size: 12, color: Color(0xFF94A3B8)),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            post.authorName,
                            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10, fontWeight: FontWeight.w500),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Stats row
                    Row(
                      children: [
                        const Icon(Icons.favorite_rounded, size: 12, color: Color(0xFFEC4899)),
                        const SizedBox(width: 3),
                        Text('${post.likes}', style: const TextStyle(color: Color(0xFF64748B), fontSize: 10)),
                        const SizedBox(width: 10),
                        const Icon(Icons.chat_bubble_rounded, size: 12, color: Color(0xFF0EA5E9)),
                        const SizedBox(width: 3),
                        Text('${post.commentsCount}', style: const TextStyle(color: Color(0xFF64748B), fontSize: 10)),
                        const Spacer(),
                        Text(
                          _formatTime(post.createdAt),
                          style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 9),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

