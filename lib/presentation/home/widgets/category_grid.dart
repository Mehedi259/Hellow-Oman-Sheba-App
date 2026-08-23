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

final List<CategoryItem> categoriesList = [
  CategoryItem(nameBn: 'চাকরি', descriptionBn: 'চাকরি খুঁজুন এবং আবেদন করুন', imagePath: 'assets/images/categories/jobs.png', route: '/classifieds?tab=jobs'),
  CategoryItem(nameBn: 'বাসা ভাড়া', descriptionBn: 'ফ্ল্যাট, রুম এবং বেড স্পেস', imagePath: 'assets/images/categories/properties.png', route: '/classifieds?tab=properties'),
  CategoryItem(nameBn: 'গাড়ি', descriptionBn: 'গাড়ি কিনুন বা ভাড়া নিন', imagePath: 'assets/images/categories/vehicles.png', route: '/classifieds?tab=vehicles'),
  CategoryItem(nameBn: 'মার্কেট', descriptionBn: 'কিনুন এবং বিক্রি করুন', imagePath: 'assets/images/categories/classifieds.png', route: '/classifieds?tab=market'),
  CategoryItem(nameBn: 'প্রশ্ন ও উত্তর', descriptionBn: 'আলোচনা এবং সহযোগিতা', imagePath: 'assets/images/categories/community.png', route: '/community'),
  CategoryItem(nameBn: 'বাংলাদেশ দূতাবাস', descriptionBn: 'দূতাবাস সেবা এবং সহায়তা', imagePath: 'assets/images/categories/embassy.png', route: '/categories'),
  CategoryItem(nameBn: 'বিশেষজ্ঞ ডাক্তার', descriptionBn: 'বিশেষজ্ঞ চিকিৎসক এবং পরামর্শ', imagePath: 'assets/images/categories/doctors.png', route: '/categories'),
  CategoryItem(nameBn: 'হাসপাতাল', descriptionBn: 'হাসপাতাল এবং ক্লিনিক', imagePath: 'assets/images/categories/hospitals.png', route: '/categories'),
  CategoryItem(nameBn: 'অ্যাম্বুলেন্স', descriptionBn: 'জরুরী অ্যাম্বুলেন্স সেবা', imagePath: 'assets/images/categories/ambulance.png', route: '/emergency'),
  CategoryItem(nameBn: 'আইনজীবী', descriptionBn: 'আইনি পরামর্শ এবং সহায়তা', imagePath: 'assets/images/categories/lawyers.png', route: '/categories'),
  CategoryItem(nameBn: 'ট্রাভেল এজেন্সি', descriptionBn: 'ফ্লাইট এবং ট্যুর বুকিং', imagePath: 'assets/images/categories/travel.png', route: '/categories'),
  CategoryItem(nameBn: 'হোটেল', descriptionBn: 'হোটেল এবং আবাসন', imagePath: 'assets/images/categories/hotels.png', route: '/categories'),
  CategoryItem(nameBn: 'মানি এক্সচেঞ্জ', descriptionBn: 'মানি ট্রান্সফার এবং এক্সচেঞ্জ', imagePath: 'assets/images/categories/money.png', route: '/categories'),
  CategoryItem(nameBn: 'মক্তব সানাদ', descriptionBn: 'মক্তব সার্টিফিকেট সেবা', imagePath: 'assets/images/categories/maktab.png', route: '/categories'),
  CategoryItem(nameBn: 'দর্শনীয় স্থান', descriptionBn: 'ওমানের পর্যটন স্থান', imagePath: 'assets/images/categories/tourist.png', route: '/categories'),
  CategoryItem(nameBn: 'পুলিশ স্টেশন', descriptionBn: 'পুলিশ স্টেশন তথ্য', imagePath: 'assets/images/categories/police.png', route: '/categories'),
  CategoryItem(nameBn: 'জরুরী নম্বর', descriptionBn: 'জরুরী যোগাযোগ নম্বর', imagePath: 'assets/images/categories/emergency.png', route: '/emergency'),
  CategoryItem(nameBn: 'সংবাদ', descriptionBn: 'সর্বশেষ সংবাদ', imagePath: 'assets/images/categories/news.png', route: '/news'),
  CategoryItem(nameBn: 'হ্যালো ওমান', descriptionBn: 'আমাদের Facebook পেজ', imagePath: 'assets/images/categories/hellowoman.png', url: 'https://www.facebook.com/helloomanbangla/'),
  CategoryItem(nameBn: 'সালতানাত ওমান', descriptionBn: 'ওমান সালতানাত সম্পর্কে জানুন', imagePath: 'assets/images/categories/sultanate-oman.png', route: '/about-oman'),
];

class CategoryGridWidget extends StatelessWidget {
  const CategoryGridWidget({super.key});

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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16.0),
          child: Text(
            'আমাদের সেবাসমূহ',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: categoriesList.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 0.85,
              crossAxisSpacing: 8,
              mainAxisSpacing: 12,
            ),
            itemBuilder: (context, index) {
              final category = categoriesList[index];
              return InkWell(
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
                        flex: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.asset(
                            category.imagePath,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.error_outline),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2.0),
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
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
