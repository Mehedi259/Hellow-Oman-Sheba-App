import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class CategoryItem {
  final String nameBn;
  final String imagePath;
  final String descriptionBn;
  final String? route;
  final String? url;

  CategoryItem({
    required this.nameBn,
    required this.imagePath,
    required this.descriptionBn,
    this.route,
    this.url,
  });
}

// First 7 pinned / most important categories
final List<CategoryItem> pinnedCategories = [
  CategoryItem(nameBn: 'চাকরি', descriptionBn: 'চাকরি খুঁজুন এবং আবেদন করুন', imagePath: 'assets/images/categories/jobs.png', route: '/classifieds?tab=jobs'),
  CategoryItem(nameBn: 'বাসা ভাড়া', descriptionBn: 'ফ্ল্যাট, রুম এবং বেড স্পেস', imagePath: 'assets/images/categories/properties.png', route: '/classifieds?tab=properties'),
  CategoryItem(nameBn: 'গাড়ি', descriptionBn: 'গাড়ি কিনুন বা ভাড়া নিন', imagePath: 'assets/images/categories/vehicles.png', route: '/classifieds?tab=vehicles'),
  CategoryItem(nameBn: 'মার্কেট', descriptionBn: 'কিনুন এবং বিক্রি করুন', imagePath: 'assets/images/categories/classifieds.png', route: '/classifieds?tab=market'),
  CategoryItem(nameBn: 'প্রশ্ন ও উত্তর', descriptionBn: 'আলোচনা এবং সহযোগিতা', imagePath: 'assets/images/categories/community.png', route: '/community'),
  CategoryItem(nameBn: 'দূতাবাস', descriptionBn: 'দূতাবাস সেবা এবং সহায়তা', imagePath: 'assets/images/categories/embassy.png', route: '/embassy'),
  CategoryItem(nameBn: 'সংবাদ', descriptionBn: 'সর্বশেষ সংবাদ', imagePath: 'assets/images/categories/news.png', route: '/news'),
];

// The rest (shown when "সব ক্যাটাগরি" is expanded)
final List<CategoryItem> extraCategories = [
  CategoryItem(nameBn: 'বিশেষজ্ঞ ডাক্তার', descriptionBn: 'বিশেষজ্ঞ চিকিৎসক এবং পরামর্শ', imagePath: 'assets/images/categories/doctors.png', route: '/services/doctors'),
  CategoryItem(nameBn: 'হাসপাতাল', descriptionBn: 'হাসপাতাল এবং ক্লিনিক', imagePath: 'assets/images/categories/hospitals.png', route: '/services/hospitals'),
  CategoryItem(nameBn: 'অ্যাম্বুলেন্স', descriptionBn: 'জরুরী অ্যাম্বুলেন্স সেবা', imagePath: 'assets/images/categories/ambulance.png', route: '/services/ambulance'),
  CategoryItem(nameBn: 'আইনজীবী', descriptionBn: 'আইনি পরামর্শ এবং সহায়তা', imagePath: 'assets/images/categories/lawyers.png', route: '/services/lawyers'),
  CategoryItem(nameBn: 'ট্রাভেল এজেন্সি', descriptionBn: 'ফ্লাইট এবং ট্যুর বুকিং', imagePath: 'assets/images/categories/travel.png', route: '/services/travel-agency'),
  CategoryItem(nameBn: 'হোটেল', descriptionBn: 'হোটেল এবং আবাসন', imagePath: 'assets/images/categories/hotels.png', route: '/services/hotels'),
  CategoryItem(nameBn: 'মানি এক্সচেঞ্জ', descriptionBn: 'মানি ট্রান্সফার এবং এক্সচেঞ্জ', imagePath: 'assets/images/categories/money.png', route: '/services/money-exchange'),
  CategoryItem(nameBn: 'মক্তব সানাদ', descriptionBn: 'মক্তব সার্টিফিকেট সেবা', imagePath: 'assets/images/categories/maktab.png', route: '/services/maktab'),
  CategoryItem(nameBn: 'দর্শনীয় স্থান', descriptionBn: 'ওমানের পর্যটন স্থান', imagePath: 'assets/images/categories/tourist.png', route: '/services/tourist-places'),
  CategoryItem(nameBn: 'পুলিশ স্টেশন', descriptionBn: 'পুলিশ স্টেশন তথ্য', imagePath: 'assets/images/categories/police.png', route: '/services/police'),
  CategoryItem(nameBn: 'জরুরী নম্বর', descriptionBn: 'জরুরী যোগাযোগ নম্বর', imagePath: 'assets/images/categories/emergency.png', route: '/emergency'),
  CategoryItem(nameBn: 'হ্যালো প্রবাস', descriptionBn: 'আমাদের Facebook পেজ', imagePath: 'assets/images/categories/hellowoman.png', url: 'https://www.facebook.com/helloomansheba'),
  CategoryItem(nameBn: 'সালতানাত ওমান', descriptionBn: 'ওমান সালতানাত সম্পর্কে জানুন', imagePath: 'assets/images/categories/sultanate-oman.png', route: '/about-oman'),
];

// Full list (used by other widgets if needed)
final List<CategoryItem> categoriesList = [...pinnedCategories, ...extraCategories];

class CategoryGridWidget extends StatefulWidget {
  const CategoryGridWidget({super.key});

  @override
  State<CategoryGridWidget> createState() => _CategoryGridWidgetState();
}

class _CategoryGridWidgetState extends State<CategoryGridWidget> with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap(BuildContext context, CategoryItem category) async {
    if (category.url != null) {
      final uri = Uri.parse(category.url!);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    } else if (category.route != null) {
      context.push(category.route!);
    }
  }

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  Widget _buildCategoryTile(CategoryItem category) {
    return Builder(
      builder: (context) => InkWell(
        onTap: () => _handleTap(context, category),
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

  Widget _buildAllCategoriesTile() {
    return InkWell(
      onTap: _toggleExpand,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: _isExpanded ? const Color(0xFF0056D2).withOpacity(0.08) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _isExpanded ? const Color(0xFF0056D2).withOpacity(0.3) : Colors.grey.shade200,
          ),
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
                padding: const EdgeInsets.all(10.0),
                child: AnimatedRotation(
                  turns: _isExpanded ? 0.125 : 0, // rotate 45deg when expanded
                  duration: const Duration(milliseconds: 300),
                  child: Icon(
                    Icons.apps_rounded,
                    size: 36,
                    color: _isExpanded ? const Color(0xFF0056D2) : const Color(0xFF64748B),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 2.0, right: 2.0, bottom: 8.0),
              child: Text(
                _isExpanded ? 'বন্ধ করুন' : 'সব ক্যাটাগরি',
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: _isExpanded ? const Color(0xFF0056D2) : Colors.black87,
                  height: 1.1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            'আমাদের সেবাসমূহ',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),

        // First row: 7 pinned + 1 "সব ক্যাটাগরি"
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: GridView.count(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 4,
            childAspectRatio: 1.0,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            children: [
              ...pinnedCategories.map((cat) => _buildCategoryTile(cat)),
              _buildAllCategoriesTile(),
            ],
          ),
        ),

        // Animated expandable section with extra categories
        SizeTransition(
          sizeFactor: _animation,
          child: Column(
            children: [
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: GridView.count(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 4,
                  childAspectRatio: 1.0,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  children: extraCategories.map((cat) => _buildCategoryTile(cat)).toList(),
                ),
              ),
              // Collapse button at the bottom
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _toggleExpand,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.keyboard_arrow_up_rounded, color: Color(0xFF0056D2), size: 20),
                    const SizedBox(width: 4),
                    const Text(
                      'কম দেখুন',
                      style: TextStyle(
                        color: Color(0xFF0056D2),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
            ],
          ),
        ),
      ],
    );
  }
}
