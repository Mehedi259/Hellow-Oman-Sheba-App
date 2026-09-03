import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/post.dart';
import '../auth/auth_provider.dart';
import 'community_provider.dart';

class CommunityDetailScreen extends ConsumerStatefulWidget {
  final Post post;

  const CommunityDetailScreen({super.key, required this.post});

  @override
  ConsumerState<CommunityDetailScreen> createState() => _CommunityDetailScreenState();
}

class _CommunityDetailScreenState extends ConsumerState<CommunityDetailScreen> {
  final TextEditingController _commentController = TextEditingController();
  bool _isLoadingComments = true;
  bool _isPostingComment = false;
  List<Map<String, dynamic>> _comments = [];
  int _likesCount = 0;
  bool _isLiking = false;
  int? _replyingToCommentId;
  String? _replyingToName;

  @override
  void initState() {
    super.initState();
    _likesCount = widget.post.likes;
    _fetchComments();
  }

  Future<void> _toggleLike() async {
    if (_isLiking) return;
    setState(() {
      _isLiking = true;
    });
    try {
      final newLikes = await ref.read(communityRepositoryProvider).toggleLike(widget.post.id);
      if (mounted) {
        setState(() {
          _likesCount = newLikes;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLiking = false;
        });
      }
    }
  }


  Future<void> _toggleCommentLike(int commentId, int index, bool isReply, int? parentIndex) async {
    try {
      final newLikesData = await ref.read(communityRepositoryProvider).toggleCommentLike(commentId);
      if (mounted) {
        setState(() {
          // Find the comment and update it
          for (var i = 0; i < _comments.length; i++) {
            if (_comments[i]['id'] == commentId) {
              _comments[i]['likes'] = newLikesData['likes'];
              _comments[i]['is_liked_by_user'] = newLikesData['status'] == 'liked';
              break;
            }
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _fetchComments() async {
    try {
      final comments = await ref.read(communityRepositoryProvider).getComments(widget.post.id);
      if (mounted) {
        setState(() {
          _comments = comments;
          _isLoadingComments = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingComments = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load comments: $e')));
      }
    }
  }

  Future<void> _postComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _isPostingComment = true;
    });

    try {
      if (_editingCommentId != null) {
        await ref.read(communityRepositoryProvider).editComment(_editingCommentId!, text);
        _editingCommentId = null;
      } else {
        await ref.read(communityRepositoryProvider).addComment(widget.post.id, text, parentId: _replyingToCommentId);
        _replyingToCommentId = null;
        _replyingToName = null;
      }
      _commentController.clear();
      FocusScope.of(context).unfocus();
      await _fetchComments();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('সফলভাবে সংরক্ষিত হয়েছে!'), backgroundColor: Colors.green));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPostingComment = false;
        });
      }
    }
  }

  int? _editingCommentId;

  void _startEditingComment(Map<String, dynamic> comment) {
    setState(() {
      _editingCommentId = comment['id'];
      _commentController.text = comment['content'] ?? '';
    });
    FocusScope.of(context).requestFocus();
  }

  Future<void> _deleteComment(int commentId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('নিশ্চিত করুন'),
        content: const Text('আপনি কি সত্যিই এই মন্তব্যটি মুছে ফেলতে চান?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('না')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('হ্যাঁ', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await ref.read(communityRepositoryProvider).deleteComment(commentId);
      await _fetchComments();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('মন্তব্য মুছে ফেলা হয়েছে।'), backgroundColor: Colors.green));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    }
  }

  String _formatTime(DateTime time) {
    final difference = DateTime.now().difference(time);
    if (difference.inDays > 0) return '${difference.inDays} দিন আগে';
    if (difference.inHours > 0) return '${difference.inHours} ঘন্টা আগে';
    if (difference.inMinutes > 0) return '${difference.inMinutes} মিনিট আগে';
    return 'মাত্রই';
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(authStateProvider).value;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('প্রশ্নোত্তর', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Post Body
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            widget.post.categoryName,
                            style: TextStyle(
                              color: Colors.blue.shade700,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          widget.post.title,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            widget.post.authorProfilePicture != null
                                ? CircleAvatar(
                                    radius: 20,
                                    backgroundImage: NetworkImage(widget.post.authorProfilePicture!),
                                  )
                                : CircleAvatar(
                                    radius: 20,
                                    backgroundColor: Colors.grey.shade100,
                                    child: Icon(Icons.person, color: Colors.grey.shade400),
                                  ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.post.authorName,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      Icon(Icons.access_time, size: 14, color: Colors.grey.shade500),
                                      const SizedBox(width: 4),
                                      Text(
                                        _formatTime(widget.post.createdAt),
                                        style: TextStyle(
                                          color: Colors.grey.shade500,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Text(
                          widget.post.content,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Divider(color: Colors.grey.shade200),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            InkWell(
                              onTap: _toggleLike,
                              borderRadius: BorderRadius.circular(8),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.thumb_up_alt_rounded, 
                                      color: _likesCount > widget.post.likes ? Colors.blue.shade500 : Colors.grey.shade500, 
                                      size: 20
                                    ),
                                    const SizedBox(width: 8),
                                    Text('$_likesCount পছন্দ', style: TextStyle(color: Colors.grey.shade600, fontSize: 14, fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                Icon(Icons.chat_bubble_outline, color: Colors.blue.shade500, size: 20),
                                const SizedBox(width: 8),
                                Text('${_comments.length} মন্তব্য', style: TextStyle(color: Colors.blue.shade600, fontSize: 14, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Comments Section
                  Container(
                    color: Colors.grey.shade50,
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'মন্তব্যসমূহ',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                        const SizedBox(height: 16),
                        if (_isLoadingComments)
                          const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()))
                        else if (_comments.isEmpty)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Text('এখনো কোনো মন্তব্য করা হয়নি।\nপ্রথম মন্তব্যটি আপনি করুন!', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade500)),
                            ),
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _comments.length,
                            separatorBuilder: (context, index) => const Divider(height: 32),
                            itemBuilder: (context, index) {
                              final comment = _comments[index];
                              final createdAt = comment['created_at'] != null ? DateTime.tryParse(comment['created_at']) : null;
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  comment['author_profile_picture'] != null
                                      ? CircleAvatar(
                                          radius: 16,
                                          backgroundImage: NetworkImage(comment['author_profile_picture']),
                                        )
                                      : CircleAvatar(
                                          radius: 16,
                                          backgroundColor: Colors.blue.shade100,
                                          child: Text(
                                            (comment['author_name'] ?? '?')[0].toUpperCase(),
                                            style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.bold, fontSize: 14),
                                          ),
                                        ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              comment['author_name'] ?? 'Unknown User',
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                            ),
                                            Row(
                                              children: [
                                                if (createdAt != null)
                                                  Text(
                                                    _formatTime(createdAt),
                                                    style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                                                  ),
                                                if (currentUser != null && comment['author'] == currentUser.id)
                                                  PopupMenuButton<String>(
                                                    padding: EdgeInsets.zero,
                                                    iconSize: 18,
                                                    icon: Icon(Icons.more_vert, color: Colors.grey.shade500),
                                                    onSelected: (value) {
                                                      if (value == 'edit') {
                                                        _startEditingComment(comment);
                                                      } else if (value == 'delete') {
                                                        _deleteComment(comment['id']);
                                                      }
                                                    },
                                                    itemBuilder: (context) => [
                                                      const PopupMenuItem(
                                                        value: 'edit',
                                                        child: Row(
                                                          children: [
                                                            Icon(Icons.edit, size: 16),
                                                            SizedBox(width: 8),
                                                            Text('এডিট করুন', style: TextStyle(fontSize: 14)),
                                                          ],
                                                        ),
                                                      ),
                                                      PopupMenuItem(
                                                        value: 'delete',
                                                        child: Row(
                                                          children: [
                                                            Icon(Icons.delete, size: 16, color: Colors.red),
                                                            SizedBox(width: 8),
                                                            Text('ডিলিট করুন', style: TextStyle(fontSize: 14, color: Colors.red)),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),

                                        Text(
                                          comment['content'] ?? '',
                                          style: TextStyle(color: Colors.grey.shade800, fontSize: 14, height: 1.4),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            GestureDetector(
                                              onTap: () => _toggleCommentLike(comment['id'], index, false, null),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    comment['is_liked_by_user'] == true ? Icons.thumb_up : Icons.thumb_up_alt_outlined,
                                                    size: 14,
                                                    color: comment['is_liked_by_user'] == true ? Colors.blue : Colors.grey.shade600,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    '${comment['likes'] ?? 0} লাইক',
                                                    style: TextStyle(
                                                      color: comment['is_liked_by_user'] == true ? Colors.blue : Colors.grey.shade600,
                                                      fontSize: 12,
                                                      fontWeight: comment['is_liked_by_user'] == true ? FontWeight.bold : FontWeight.normal,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  _replyingToCommentId = comment['parent'] ?? comment['id'];
                                                  _replyingToName = comment['author_name'] ?? 'Unknown User';
                                                  FocusScope.of(context).requestFocus(FocusNode()); // To trigger keyboard if needed
                                                });
                                              },
                                              child: Row(
                                                children: [
                                                  Icon(Icons.reply, size: 14, color: Colors.grey.shade600),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    'রিপ্লাই',
                                                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),

                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          

          // Replying Badge
          if (_replyingToName != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.grey.shade100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Replying to $_replyingToName...', style: TextStyle(color: Colors.grey.shade700, fontSize: 13, fontWeight: FontWeight.bold)),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _replyingToCommentId = null;
                        _replyingToName = null;
                      });
                    },
                    child: const Icon(Icons.close, size: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),
          // Sticky Bottom Input Bar

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5)),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: InputDecoration(
                        hintText: _editingCommentId != null ? 'মন্তব্য এডিট করুন...' : 'আপনার মন্তব্য লিখুন...',
                        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        suffixIcon: _editingCommentId != null 
                            ? IconButton(
                                icon: const Icon(Icons.close, size: 18),
                                onPressed: () {
                                  setState(() {
                                    _editingCommentId = null;
                                    _commentController.clear();
                                  });
                                  FocusScope.of(context).unfocus();
                                },
                              )
                            : null,
                      ),
                      maxLines: 1,
                    ),
                  ),
                  const SizedBox(width: 12),
                  _isPostingComment
                      ? const Padding(padding: EdgeInsets.all(12), child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)))
                      : CircleAvatar(
                          radius: 22,
                          backgroundColor: const Color(0xFF2563EB),
                          child: IconButton(
                            icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                            onPressed: _postComment,
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
}
