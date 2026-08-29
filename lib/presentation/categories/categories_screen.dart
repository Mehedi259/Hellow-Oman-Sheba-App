import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../home/widgets/category_grid.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  // Color mapping for category icons
  static const List<List<Color>> _cardGradients = [
    [Color(0xFF3B82F6), Color(0xFF1D4ED8)],   // চাকরি - Blue
    [Color(0xFF10B981), Color(0xFF059669)],     // বাসা ভাড়া - Emerald
    [Color(0xFF8B5CF6), Color(0xFF6D28D9)],     // গাড়ি - Violet
    [Color(0xFFF59E0B), Color(0xFFD97706)],     // মার্কেট - Amber
    [Color(0xFFEC4899), Color(0xFFDB2777)],     // প্রশ্ন ও উত্তর - Pink
    [Color(0xFF14B8A6), Color(0xFF0D9488)],     // দূতাবাস - Teal
    [Color(0xFFEF4444), Color(0xFFDC2626)],     // ডাক্তার - Red
    [Color(0xFF6366F1), Color(0xFF4F46E5)],     // হাসপাতাল - Indigo
    [Color(0xFFF43F5E), Color(0xFFE11D48)],     // অ্যাম্বুলেন্স - Rose
    [Color(0xFF0EA5E9), Color(0xFF0284C7)],     // আইনজীবী - Sky
    [Color(0xFF22C55E), Color(0xFF16A34A)],     // ট্রাভেল - Green
    [Color(0xFFA855F7), Color(0xFF9333EA)],     // হোটেল - Purple
    [Color(0xFFEAB308), Color(0xFFCA8A04)],     // মানি এক্সচেঞ্জ - Yellow
    [Color(0xFF06B6D4), Color(0xFF0891B2)],     // মক্তব - Cyan
    [Color(0xFF84CC16), Color(0xFF65A30D)],     // দর্শনীয় - Lime
    [Color(0xFF64748B), Color(0xFF475569)],     // পুলিশ - Slate
    [Color(0xFFD946EF), Color(0xFFC026D3)],     // জরুরী - Fuchsia
    [Color(0xFF2563EB), Color(0xFF1E40AF)],     // সংবাদ - Blue-Dark
    [Color(0xFF3B82F6), Color(0xFF2563EB)],     // হ্যালো ওমান - FB Blue
    [Color(0xFFF97316), Color(0xFFEA580C)],     // সালতানাত - Orange
  ];

  static const List<IconData> _categoryIcons = [
    Icons.work_rounded,              // চাকরি
    Icons.apartment_rounded,          // বাসা ভাড়া
    Icons.directions_car_rounded,     // গাড়ি
    Icons.storefront_rounded,         // মার্কেট
    Icons.forum_rounded,              // প্রশ্ন ও উত্তর
    Icons.account_balance_rounded,    // দূতাবাস
    Icons.medical_services_rounded,   // ডাক্তার
    Icons.local_hospital_rounded,     // হাসপাতাল
    Icons.emergency_rounded,          // অ্যাম্বুলেন্স
    Icons.gavel_rounded,              // আইনজীবী
    Icons.flight_rounded,             // ট্রাভেল
    Icons.hotel_rounded,              // হোটেল
    Icons.currency_exchange_rounded,  // মানি এক্সচেঞ্জ
    Icons.menu_book_rounded,          // মক্তব
    Icons.landscape_rounded,          // দর্শনীয়
    Icons.local_police_rounded,       // পুলিশ
    Icons.phone_in_talk_rounded,      // জরুরী
    Icons.newspaper_rounded,          // সংবাদ
    Icons.facebook_rounded,           // হ্যালো ওমান
    Icons.mosque_rounded,             // সালতানাত
  ];

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
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // --- Premium Header ---
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFF7C3AED),
            automaticallyImplyLeading: false,
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
                    Positioned(top: -30, right: -30, child: Container(width: 120, height: 120, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.06)))),
                    Positioned(bottom: 10, left: -20, child: Container(width: 80, height: 80, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.04)))),
                    Positioned(top: 50, right: 70, child: Container(width: 35, height: 35, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.05)))),
                    // Content
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                              decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.dashboard_rounded, size: 14, color: Colors.white),
                                  SizedBox(width: 6),
                                  Text('ক্যাটাগরি', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text('সকল সেবাসমূহ', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.5)),
                            const SizedBox(height: 6),
                            Text('ওমানে বসবাসের জন্য প্রয়োজনীয় সকল সেবা এক জায়গায়', style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.75))),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // --- Search Pill ---
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
                ),
                child: Row(
                  children: [
                    Icon(Icons.search_rounded, color: Colors.grey.shade400, size: 22),
                    const SizedBox(width: 10),
                    Text('সেবা খুঁজুন...', style: TextStyle(color: Colors.grey.shade400, fontSize: 15, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ),
          ),

          // --- Category Grid ---
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.45,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final category = categoriesList[index];
                  final gradientColors = index < _cardGradients.length
                      ? _cardGradients[index]
                      : [const Color(0xFF64748B), const Color(0xFF475569)];
                  final iconData = index < _categoryIcons.length
                      ? _categoryIcons[index]
                      : Icons.category_rounded;

                  return _buildCategoryCard(context, category, gradientColors, iconData);
                },
                childCount: categoriesList.length,
              ),
            ),
          ),

          // --- Bottom CTA ---
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 24, 16, 0),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [const Color(0xFF7C3AED).withOpacity(0.06), const Color(0xFFDB2777).withOpacity(0.04)]),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF7C3AED).withOpacity(0.1)),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: const Color(0xFF7C3AED).withOpacity(0.1), shape: BoxShape.circle),
                    child: const Icon(Icons.help_outline_rounded, size: 30, color: Color(0xFF7C3AED)),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'আপনার প্রয়োজনীয় সেবা খুঁজে\nপাচ্ছেন না?',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1E293B), height: 1.4),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text('কমিউনিটিতে প্রশ্ন করুন অথবা আমাদের সাথে যোগাযোগ করুন', style: TextStyle(fontSize: 13, color: Colors.grey.shade500), textAlign: TextAlign.center),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [Color(0xFF7C3AED), Color(0xFF6D28D9)]),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [BoxShadow(color: const Color(0xFF7C3AED).withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => context.push('/community'),
                              borderRadius: BorderRadius.circular(14),
                              child: const Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.forum_rounded, size: 18, color: Colors.white),
                                    SizedBox(width: 8),
                                    Text('কমিউনিটি', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFF7C3AED).withOpacity(0.3)),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => context.push('/about'),
                              borderRadius: BorderRadius.circular(14),
                              child: const Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.chat_rounded, size: 18, color: Color(0xFF7C3AED)),
                                    SizedBox(width: 8),
                                    Text('যোগাযোগ', style: TextStyle(color: Color(0xFF7C3AED), fontWeight: FontWeight.w700, fontSize: 14)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, CategoryItem category, List<Color> gradientColors, IconData iconData) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _handleTap(context, category),
        borderRadius: BorderRadius.circular(18),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 4)),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Original Image Icon without background
                SizedBox(
                  width: 50,
                  height: 50,
                  child: Image.asset(
                    category.imagePath,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) =>
                        Icon(iconData, color: gradientColors[0], size: 24),
                  ),
                ),
                const SizedBox(width: 14),
                // Text content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        category.nameBn,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        category.descriptionBn,
                        style: TextStyle(fontSize: 10, color: Colors.grey.shade500, fontWeight: FontWeight.w500, height: 1.3),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
