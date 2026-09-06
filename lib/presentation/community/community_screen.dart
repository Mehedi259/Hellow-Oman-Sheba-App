import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'community_provider.dart';
import 'community_detail_screen.dart';

class CommunityScreen extends ConsumerWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsState = ref.watch(postsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Community'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CreateCommunityPostScreen()),
              );
            },
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(postsProvider);
        },
        child: postsState.when(
          data: (posts) {
            if (posts.isEmpty) return const Center(child: Text('No posts yet.'));
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: posts.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final post = posts[index];
                
                String formatTime(DateTime time) {
                  final difference = DateTime.now().difference(time);
                  if (difference.inDays > 0) return '${difference.inDays} দিন আগে';
                  if (difference.inHours > 0) return '${difference.inHours} ঘন্টা আগে';
                  if (difference.inMinutes > 0) return '${difference.inMinutes} মিনিট আগে';
                  return 'মাত্রই';
                }

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CommunityDetailScreen(post: post)),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade100,
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.pink.shade50,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                post.categoryName,
                                style: TextStyle(
                                  color: Colors.pink.shade700,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                Icon(Icons.access_time, size: 14, color: Colors.grey.shade500),
                                const SizedBox(width: 4),
                                Text(
                                  formatTime(post.createdAt),
                                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          post.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          post.content,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                            height: 1.4,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 16),
                        const Divider(height: 1),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                post.authorProfilePicture != null
                                    ? CircleAvatar(
                                        radius: 12,
                                        backgroundImage: NetworkImage(post.authorProfilePicture!),
                                      )
                                    : CircleAvatar(
                                        radius: 12,
                                        backgroundColor: Colors.grey.shade200,
                                        child: Icon(Icons.person, size: 16, color: Colors.grey.shade600),
                                      ),
                                const SizedBox(width: 8),
                                Text(
                                  post.authorName,
                                  style: TextStyle(
                                    color: Colors.grey.shade800,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.thumb_up_alt_outlined, size: 16, color: Colors.grey.shade500),
                                    const SizedBox(width: 4),
                                    Text('${post.likes}', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                                  ],
                                ),
                                const SizedBox(width: 16),
                                Row(
                                  children: [
                                    Icon(Icons.chat_bubble_outline, size: 16, color: Colors.grey.shade500),
                                    const SizedBox(width: 4),
                                    Text('${post.commentsCount}', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
          loading: () => ListView(children: const [SizedBox(height: 300), Center(child: CircularProgressIndicator())]),
          error: (e, _) => ListView(children: [SizedBox(height: 300), Center(child: Padding(padding: const EdgeInsets.all(16.0), child: Text('Error: $e', textAlign: TextAlign.center)))]),
        ),
      ),
    );
  }
}

class CreateCommunityPostScreen extends ConsumerStatefulWidget {
  const CreateCommunityPostScreen({super.key});

  @override
  ConsumerState<CreateCommunityPostScreen> createState() => _CreateCommunityPostScreenState();
}

class _CreateCommunityPostScreenState extends ConsumerState<CreateCommunityPostScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _tagsController = TextEditingController();
  
  bool _isLoading = false;
  File? _selectedImage;
  final picker = ImagePicker();
  
  String? _selectedCategory;
  List<Map<String, dynamic>> _categories = [];
  bool _isLoadingCategories = true;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }
  
  Future<void> _fetchCategories() async {
    try {
      final cats = await ref.read(communityRepositoryProvider).getCategories();
      if (mounted) {
        setState(() {
          _categories = cats;
          if (_categories.isNotEmpty) {
            _selectedCategory = _categories.first['id'].toString();
          }
          _isLoadingCategories = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingCategories = false);
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() => _selectedImage = File(image.path));
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  Future<void> _submit() async {
    if (_titleController.text.isEmpty || _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(children: [
            Icon(Icons.warning_amber_rounded, color: Colors.white), 
            SizedBox(width: 8), 
            Expanded(child: Text('শিরোনাম এবং ক্যাটাগরি অবশ্যই দিতে হবে')),
          ]),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ref.read(communityRepositoryProvider).createPost(
            _titleController.text,
            _selectedCategory!,
            _contentController.text,
            _tagsController.text,
            image: _selectedImage,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(children: [
              Icon(Icons.check_circle_outline_rounded, color: Colors.white), 
              SizedBox(width: 8), 
              Text('আলোচনা সফলভাবে পোস্ট হয়েছে!'),
            ]),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        ref.invalidate(postsProvider);
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('ত্রুটি: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))],
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
        title: const Text('নতুন আলোচনা শুরু করুন', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
        centerTitle: true,
      ),
      body: _isLoadingCategories 
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF3B82F6)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildTextField(
                    controller: _titleController,
                    label: 'আলোচনার শিরোনাম *',
                    hint: 'যেমন: ওমানে ড্রাইভিং লাইসেন্স নবায়ন সম্পর্কে জানতে চাই',
                  ),
                  const SizedBox(height: 20),
                  
                  const Text('ক্যাটাগরি *', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))],
                    ),
                    child: DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      items: _categories.map((c) => DropdownMenuItem(
                        value: c['id'].toString(), 
                        child: Text(c['name'] ?? 'Unknown', style: const TextStyle(fontSize: 15)),
                      )).toList(),
                      onChanged: (val) => setState(() => _selectedCategory = val),
                      decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
                      dropdownColor: Colors.white,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B)),
                      hint: const Text('ক্যাটাগরি নির্বাচন করুন'),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  _buildTextField(
                    controller: _contentController,
                    label: 'বিস্তারিত',
                    hint: 'আপনার প্রশ্ন বা আলোচনা বিস্তারিতভাবে লিখুন...',
                    maxLines: 5,
                  ),
                  const SizedBox(height: 20),
                  
                  _buildTextField(
                    controller: _tagsController,
                    label: 'ট্যাগ (ঐচ্ছিক)',
                    hint: 'কমা দিয়ে আলাদা করুন, যেমন: driving, oman, muscat',
                  ),
                  const SizedBox(height: 24),
                  
                  const Divider(),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('ছবি (ঐচ্ছিক)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1E293B))),
                      TextButton.icon(
                        onPressed: _pickImage,
                        icon: const Icon(Icons.cloud_upload_outlined, color: Color(0xFF3B82F6)),
                        label: const Text('ছবি আপলোড', style: TextStyle(color: Color(0xFF3B82F6))),
                        style: TextButton.styleFrom(backgroundColor: const Color(0xFF3B82F6).withOpacity(0.1)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  if (_selectedImage != null)
                    Stack(
                      children: [
                        Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            image: DecorationImage(image: FileImage(_selectedImage!), fit: BoxFit.cover),
                          ),
                        ),
                        Positioned(
                          top: 12, right: 12,
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedImage = null),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                              child: const Icon(Icons.close, color: Colors.white, size: 20),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                  const SizedBox(height: 32),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B82F6),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    onPressed: _isLoading ? null : _submit,
                    child: _isLoading
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('পোস্ট করুন', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }
}
