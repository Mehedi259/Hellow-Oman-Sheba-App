import 'package:flutter/material.dart';
import 'widgets/job_form.dart';
import 'widgets/property_form.dart';
import 'widgets/vehicle_form.dart';
import 'widgets/market_form.dart';
import 'widgets/service_form.dart';
import 'widgets/job_seeker_form.dart';
import 'widgets/insurance_form.dart';
import 'widgets/business_form.dart';
import '../community/community_screen.dart' show CreateCommunityPostScreen;
import '../home/widgets/category_grid.dart' show categoriesList, CategoryItem;
import '../categories/service_list_screen.dart' show serviceCategoriesData;

class CreatePostScreen extends StatefulWidget {
  final String? initialCategory;
  const CreatePostScreen({super.key, this.initialCategory});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> with SingleTickerProviderStateMixin {
  String? _selectedCategory;
  String? _selectedServiceBackendName;
  CategoryItem? _selectedCategoryItem;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  List<CategoryItem> get _filteredCategories {
    return categoriesList.where((cat) {
      if (cat.route == '/news') return false;
      if (cat.route == '/emergency') return false;
      if (cat.route == '/about-oman') return false;
      if (cat.url != null) return false;
      return true;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
    if (_selectedCategory == 'job_seeker') {
      _selectedCategoryItem = CategoryItem(
        nameBn: 'চাকরিপ্রার্থী প্রোফাইল',
        imagePath: 'assets/images/categories/jobs.png',
        descriptionBn: '',
      );
    } else if (_selectedCategory == 'classified') {
      _selectedCategoryItem = CategoryItem(
        nameBn: 'মার্কেট',
        imagePath: 'assets/images/categories/classifieds.png',
        descriptionBn: '',
      );
    }
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
    final cats = _filteredCategories;
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
                  Positioned(top: -30, right: -30, child: Container(width: 120, height: 120, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.08)))),
                  Positioned(bottom: -20, left: -20, child: Container(width: 80, height: 80, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.06)))),
                  Positioned(top: 40, right: 60, child: Container(width: 40, height: 40, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.05)))),
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
        // Category Grid (4 items per row)
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.85,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return FadeTransition(
                  opacity: _fadeAnim,
                  child: _buildCategoryCard(cats[index]),
                );
              },
              childCount: cats.length,
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 80)),
      ],
    );
  }

  Widget _buildCategoryCard(CategoryItem category) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (category.route == null) return;
          
          if (category.route == '/community') {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateCommunityPostScreen()));
            return;
          }
          if (category.route == '/classifieds?tab=jobs') {
            _selectedCategoryItem = category;
            _showJobTypeDialog();
            return;
          }
          if (category.route == '/classifieds?tab=market') {
            setState(() {
              _selectedCategoryItem = category;
              _selectedCategory = 'classified';
            });
            return;
          }
          if (category.route == '/classifieds?tab=vehicles') {
            setState(() {
              _selectedCategoryItem = category;
              _selectedCategory = 'vehicle';
            });
            return;
          }
          if (category.route == '/classifieds?tab=properties') {
            setState(() {
              _selectedCategoryItem = category;
              _selectedCategory = 'property';
            });
            return;
          }
          if (category.route == '/services/insurance') {
            setState(() {
              _selectedCategoryItem = category;
              _selectedCategory = 'insurance';
            });
            return;
          }
          if (category.route == '/services/business') {
            setState(() {
              _selectedCategoryItem = category;
              _selectedCategory = 'business';
            });
            return;
          }
          if (category.route!.startsWith('/services/')) {
            String slug = category.route!.split('/').last;
            String? backendName = serviceCategoriesData[slug]?['backendName'];
            setState(() {
              _selectedCategoryItem = category;
              _selectedCategory = 'service';
              _selectedServiceBackendName = backendName ?? category.nameBn;
            });
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade100,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.asset(
                    category.imagePath,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.error_outline, color: Colors.grey),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 2.0, right: 2.0, bottom: 8.0),
                child: Text(
                  category.nameBn,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                    height: 1.1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showJobTypeDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
              const Text('আপনি কী করতে চান?', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF1E293B))),
              const SizedBox(height: 8),
              Text('আপনার প্রয়োজন অনুযায়ী একটি বিকল্প বেছে নিন', style: TextStyle(fontSize: 14, color: Colors.grey.shade500)),
              const SizedBox(height: 28),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
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
            ),
            ],
          ),
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
              Text(label, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: gradient[0])),
              const SizedBox(height: 4),
              Text(subtitle, textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: gradient[0].withOpacity(0.6))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormShell() {
    String formTitle = _selectedCategoryItem?.nameBn ?? '';
    List<Color> formGradient = [const Color(0xFF7C3AED), const Color(0xFFDB2777)]; // Default gradient
    
    if (_selectedCategory == 'job_post') {
      formTitle = 'চাকরির বিজ্ঞাপন';
      formGradient = [const Color(0xFF3B82F6), const Color(0xFF1D4ED8)];
    } else if (_selectedCategory == 'job_seeker') {
      formTitle = 'চাকরিপ্রার্থী প্রোফাইল';
      formGradient = [const Color(0xFF8B5CF6), const Color(0xFF6D28D9)];
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
        formContent = ServiceForm(
          onSuccess: () => setState(() => _selectedCategory = null),
          initialData: _selectedServiceBackendName != null ? {'category': _selectedServiceBackendName} : null,
        );
        break;
      case 'insurance':
        formContent = InsuranceForm(onSuccess: () => setState(() => _selectedCategory = null));
        break;
      case 'business':
        formContent = BusinessForm(onSuccess: () => setState(() => _selectedCategory = null));
        break;
      default:
        formContent = Center(child: Text('Form for $_selectedCategory not implemented yet'));
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
                  onPressed: () => setState(() {
                    _selectedCategory = null;
                    _selectedServiceBackendName = null;
                  }),
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
                if (_selectedCategoryItem != null)
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(14)),
                    child: Image.asset(_selectedCategoryItem!.imagePath, width: 24, height: 24),
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
