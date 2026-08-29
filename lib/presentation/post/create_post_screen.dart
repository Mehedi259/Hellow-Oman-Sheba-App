import 'package:flutter/material.dart';
import 'widgets/job_form.dart';
import 'widgets/property_form.dart';
import 'widgets/vehicle_form.dart';
import 'widgets/market_form.dart';
import 'widgets/service_form.dart';
import 'widgets/job_seeker_form.dart';
import '../community/community_screen.dart' show CreateCommunityPostScreen;

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> with SingleTickerProviderStateMixin {
  String? _selectedCategory;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  final List<Map<String, dynamic>> _categories = [
    {'id': 'job', 'name': 'চাকরি', 'subtitle': 'চাকরি দিন বা খুঁজুন', 'icon': Icons.work_rounded, 'gradient': [const Color(0xFF3B82F6), const Color(0xFF1D4ED8)]},
    {'id': 'property', 'name': 'প্রপার্টি', 'subtitle': 'বাসা/ফ্ল্যাট ভাড়া', 'icon': Icons.apartment_rounded, 'gradient': [const Color(0xFF10B981), const Color(0xFF059669)]},
    {'id': 'vehicle', 'name': 'গাড়ি', 'subtitle': 'গাড়ি কিনুন/বিক্রি', 'icon': Icons.directions_car_rounded, 'gradient': [const Color(0xFF8B5CF6), const Color(0xFF6D28D9)]},
    {'id': 'classified', 'name': 'মার্কেট', 'subtitle': 'পণ্য কিনুন/বিক্রি', 'icon': Icons.storefront_rounded, 'gradient': [const Color(0xFFF59E0B), const Color(0xFFD97706)]},
    {'id': 'service', 'name': 'সেবা', 'subtitle': 'সেবা প্রদানকারী', 'icon': Icons.handyman_rounded, 'gradient': [const Color(0xFF14B8A6), const Color(0xFF0D9488)]},
    {'id': 'discussion', 'name': 'আলোচনা', 'subtitle': 'কমিউনিটি পোস্ট', 'icon': Icons.forum_rounded, 'gradient': [const Color(0xFFEC4899), const Color(0xFFDB2777)]},
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: _selectedCategory == null ? _buildCategorySelection() : _buildFormShell(),
    );
  }

  Widget _buildCategorySelection() {
    return CustomScrollView(
      slivers: [
        // Premium gradient header
        SliverAppBar(
          expandedHeight: 200,
          pinned: true,
          backgroundColor: const Color(0xFF7C3AED),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF7C3AED), Color(0xFFDB2777)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(
                children: [
                  // Decorative circles
                  Positioned(top: -30, right: -30, child: Container(width: 120, height: 120, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.08)))),
                  Positioned(bottom: -20, left: -20, child: Container(width: 80, height: 80, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.06)))),
                  Positioned(top: 40, right: 60, child: Container(width: 40, height: 40, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.05)))),
                  // Content
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 80, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.add_circle_outline, size: 16, color: Colors.white),
                              SizedBox(width: 6),
                              Text('নতুন পোস্ট', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'কী পোস্ট করবেন?',
                          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.5),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'আপনার প্রয়োজন অনুযায়ী ক্যাটাগরি নির্বাচন করুন',
                          style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.8)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Category Grid
        SliverPadding(
          padding: const EdgeInsets.all(20),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 1.05,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final category = _categories[index];
                final gradientColors = category['gradient'] as List<Color>;
                return FadeTransition(
                  opacity: _fadeAnim,
                  child: _buildCategoryCard(category, gradientColors, index),
                );
              },
              childCount: _categories.length,
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 80)),
      ],
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> category, List<Color> gradientColors, int index) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (category['id'] == 'discussion') {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateCommunityPostScreen()));
          } else if (category['id'] == 'job') {
            _showJobTypeDialog();
          } else {
            setState(() => _selectedCategory = category['id']);
          }
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: gradientColors[0].withOpacity(0.12), blurRadius: 20, offset: const Offset(0, 8)),
              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2)),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: gradientColors, begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [BoxShadow(color: gradientColors[0].withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))],
                ),
                child: Icon(category['icon'], color: Colors.white, size: 28),
              ),
              const SizedBox(height: 14),
              Text(category['name'], style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: Color(0xFF1E293B))),
              const SizedBox(height: 4),
              Text(category['subtitle'], style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }

  void _showJobTypeDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 24), decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
              const Text('আপনি কী করতে চান?', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF1E293B))),
              const SizedBox(height: 8),
              Text('আপনার প্রয়োজন অনুযায়ী একটি বিকল্প বেছে নিন', style: TextStyle(fontSize: 14, color: Colors.grey.shade500)),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: _buildJobTypeCard(
                      icon: Icons.business_center_rounded,
                      label: 'চাকরি দিচ্ছি',
                      subtitle: 'কর্মী নিয়োগ দিন',
                      gradient: [const Color(0xFF3B82F6), const Color(0xFF1D4ED8)],
                      onTap: () {
                        Navigator.pop(context);
                        setState(() => _selectedCategory = 'job_post');
                      },
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _buildJobTypeCard(
                      icon: Icons.person_search_rounded,
                      label: 'চাকরি খুঁজছি',
                      subtitle: 'প্রোফাইল তৈরি করুন',
                      gradient: [const Color(0xFF8B5CF6), const Color(0xFF6D28D9)],
                      onTap: () {
                        Navigator.pop(context);
                        setState(() => _selectedCategory = 'job_seeker');
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildJobTypeCard({required IconData icon, required String label, required String subtitle, required List<Color> gradient, required VoidCallback onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [gradient[0].withOpacity(0.08), gradient[1].withOpacity(0.04)], begin: Alignment.topLeft, end: Alignment.bottomRight),
            border: Border.all(color: gradient[0].withOpacity(0.2), width: 1.5),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: gradient),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: gradient[0].withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))],
                ),
                child: Icon(icon, size: 28, color: Colors.white),
              ),
              const SizedBox(height: 14),
              Text(label, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: gradient[0])),
              const SizedBox(height: 4),
              Text(subtitle, style: TextStyle(fontSize: 11, color: gradient[0].withOpacity(0.6))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormShell() {
    final Map<String, dynamic> category;
    String formTitle;
    List<Color> formGradient;

    if (_selectedCategory == 'job_post') {
      category = _categories.firstWhere((c) => c['id'] == 'job');
      formTitle = 'চাকরির বিজ্ঞাপন';
      formGradient = [const Color(0xFF3B82F6), const Color(0xFF1D4ED8)];
    } else if (_selectedCategory == 'job_seeker') {
      category = _categories.firstWhere((c) => c['id'] == 'job');
      formTitle = 'চাকরিপ্রার্থী প্রোফাইল';
      formGradient = [const Color(0xFF8B5CF6), const Color(0xFF6D28D9)];
    } else {
      category = _categories.firstWhere((c) => c['id'] == _selectedCategory);
      formTitle = category['name'];
      formGradient = category['gradient'] as List<Color>;
    }

    Widget formContent;
    switch (_selectedCategory) {
      case 'job_post':
        formContent = JobForm(onSuccess: () => setState(() => _selectedCategory = null));
        break;
      case 'job_seeker':
        formContent = JobSeekerForm(onSuccess: () => setState(() => _selectedCategory = null));
        break;
      case 'property':
        formContent = PropertyForm(onSuccess: () => setState(() => _selectedCategory = null));
        break;
      case 'vehicle':
        formContent = VehicleForm(onSuccess: () => setState(() => _selectedCategory = null));
        break;
      case 'classified':
        formContent = MarketForm(onSuccess: () => setState(() => _selectedCategory = null));
        break;
      case 'service':
        formContent = ServiceForm(onSuccess: () => setState(() => _selectedCategory = null));
        break;
      default:
        formContent = Center(child: Text('Form for ${_selectedCategory} not implemented yet'));
    }

    return Column(
      children: [
        // Premium form header
        Container(
          width: double.infinity,
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: formGradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(4, 8, 16, 20),
            child: Row(
              children: [
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                  ),
                  onPressed: () => setState(() => _selectedCategory = null),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(formTitle, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
                      const SizedBox(height: 2),
                      Text('সকল তথ্য সঠিকভাবে পূরণ করুন', style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.8))),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(14)),
                  child: Icon(category['icon'], color: Colors.white, size: 24),
                ),
              ],
            ),
          ),
        ),
        // Form body
        Expanded(
          child: Container(
            color: const Color(0xFFF8FAFC),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: formContent,
            ),
          ),
        ),
      ],
    );
  }
}
