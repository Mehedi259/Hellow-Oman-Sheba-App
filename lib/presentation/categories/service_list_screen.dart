import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/models/classifieds_models.dart';
import '../classifieds/classifieds_provider.dart';
import '../classifieds/widgets/favorite_button.dart';
import '../chat/widgets/chat_initiator_button.dart';

const Map<String, Map<String, dynamic>> serviceCategoriesData = {
  'ambulance': {'nameBn': 'অ্যাম্বুলেন্স', 'icon': '🚑', 'description': 'জরুরী অ্যাম্বুলেন্স সেবা এবং মেডিকেল ট্রান্সপোর্ট।', 'backendName': 'Ambulance', 'color': 0xFFDC2626},
  'doctors': {'nameBn': 'বিশেষজ্ঞ ডাক্তার', 'icon': '👨‍⚕️', 'description': 'বিশেষজ্ঞ চিকিৎসক, পরামর্শ এবং চেকআপ সেবা।', 'backendName': 'Specialist Doctor', 'color': 0xFF0891B2},
  'hospitals': {'nameBn': 'হাসপাতাল', 'icon': '🏥', 'description': 'হাসপাতাল, ক্লিনিক এবং মেডিকেল সেন্টার।', 'backendName': 'Hospital', 'color': 0xFF059669},
  'maktab': {'nameBn': 'মক্তব সানাদ', 'icon': '📜', 'description': 'মক্তব সার্টিফিকেট, শিক্ষা সনদ এবং সংশ্লিষ্ট সেবা।', 'backendName': 'Maktab Sanad', 'color': 0xFF7C3AED},
  'travel-agency': {'nameBn': 'ট্রাভেল এজেন্সি', 'icon': '✈️', 'description': 'ফ্লাইট বুকিং, হোটেল রিজার্ভেশন এবং ট্যুর প্যাকেজ।', 'backendName': 'Travel Agency', 'color': 0xFF2563EB},
  'tourist-places': {'nameBn': 'দর্শনীয় স্থান', 'icon': '🗿', 'description': 'ওমানের দর্শনীয় স্থান, ঐতিহাসিক স্থান এবং পর্যটন।', 'backendName': 'Tourist Place', 'color': 0xFFD97706},
  'lawyers': {'nameBn': 'আইনজীবী', 'icon': '⚖️', 'description': 'আইনজীবী, আইনগত পরামর্শ এবং লেবার কোর্ট সেবা।', 'backendName': 'Lawyer', 'color': 0xFF6D28D9},
  'hotels': {'nameBn': 'হোটেল', 'icon': '🏨', 'description': 'হোটেল, রেস্ট হাউস এবং আবাসন সেবা।', 'backendName': 'Hotel', 'color': 0xFF0F766E},
  'money-exchange': {'nameBn': 'মানি এক্সচেঞ্জ', 'icon': '💱', 'description': 'মানি এক্সচেঞ্জ, রেমিট্যান্স এবং ব্যাংকিং সেবা।', 'backendName': 'Money Exchange', 'color': 0xFF065F46},
  'police': {'nameBn': 'পুলিশ স্টেশন', 'icon': '👮', 'description': 'পুলিশ স্টেশন, জরুরী সেবা এবং আইন শৃঙ্খলা।', 'backendName': 'Police Station', 'color': 0xFF1E40AF},
};

String _imgUrl(String url) {
  if (url.isEmpty) return '';
  if (url.startsWith('http')) return url;
  return 'http://188.245.212.240$url';
}

// ─────────────────────────────────────────────
// LIST SCREEN
// ─────────────────────────────────────────────
class ServiceListScreen extends ConsumerWidget {
  final String slug;
  const ServiceListScreen({super.key, required this.slug});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryData = serviceCategoriesData[slug];
    if (categoryData == null) {
      return Scaffold(appBar: AppBar(title: const Text('Not Found')), body: const Center(child: Text('Category not found')));
    }

    final catColor = Color(categoryData['color'] as int);
    final backendName = categoryData['backendName'] as String;
    final state = ref.watch(servicesByCategoryProvider(backendName));

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: CustomScrollView(
        slivers: [
          // ─── SliverAppBar ───
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: catColor,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => context.pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [catColor, Color.lerp(catColor, Colors.black, 0.3)!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 56, height: 56,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Center(child: Text(categoryData['icon'] as String, style: const TextStyle(fontSize: 28))),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(categoryData['nameBn'] as String,
                                      style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
                                  const SizedBox(height: 4),
                                  Text(categoryData['description'] as String,
                                      style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
                                      maxLines: 2),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ─── Body ───
          SliverToBoxAdapter(
            child: state.when(
              loading: () => _buildShimmer(),
              error: (err, _) => Padding(
                padding: const EdgeInsets.all(32),
                child: Center(child: Text('সমস্যা হয়েছে: $err')),
              ),
              data: (items) {
                if (items.isEmpty) {
                  return SizedBox(
                    height: 300,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inbox_rounded, size: 64, color: catColor.withOpacity(0.3)),
                          const SizedBox(height: 16),
                          const Text('এই বিভাগে এখনো কোনো সেবা যোগ করা হয়নি।',
                              style: TextStyle(color: Color(0xFF6B7280), fontSize: 15), textAlign: TextAlign.center),
                        ],
                      ),
                    ),
                  );
                }
                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${items.length}টি সেবা প্রদানকারী',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF374151))),
                      const SizedBox(height: 12),
                      ...items.map((item) => _ServiceCard(item: item, catColor: catColor, slug: slug)),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE5E7EB),
      highlightColor: const Color(0xFFF9FAFB),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: List.generate(3, (_) => Container(
            height: 220, margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
          )),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SERVICE CARD (list)
// ─────────────────────────────────────────────
class _ServiceCard extends StatelessWidget {
  final Service item;
  final Color catColor;
  final String slug;

  const _ServiceCard({required this.item, required this.catColor, required this.slug});

  @override
  Widget build(BuildContext context) {
    final imgUrl = _imgUrl(item.primaryImage);

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ServiceDetailScreen(service: item, catColor: catColor, slug: slug))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 16, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Image ───
            if (imgUrl.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Stack(
                  children: [
                    Image.network(imgUrl, height: 180, width: double.infinity, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _noImage(catColor)),
                    if (item.verified)
                      Positioned(top: 10, right: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: const Color(0xFF059669), borderRadius: BorderRadius.circular(20)),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.verified_rounded, color: Colors.white, size: 12),
                              SizedBox(width: 4),
                              Text('যাচাইকৃত', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              )
            else
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: _noImage(catColor),
              ),

            // ─── Content ───
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF111827))),
                  const SizedBox(height: 4),
                  if (item.description.isNotEmpty)
                    Text(item.description, maxLines: 2, overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280), height: 1.4)),
                  const SizedBox(height: 10),

                  // Location + Rating + Phone
                  if (item.location.isNotEmpty)
                    Row(children: [
                      Icon(Icons.location_on_outlined, size: 14, color: catColor),
                      const SizedBox(width: 4),
                      Expanded(child: Text(item.location, style: TextStyle(fontSize: 12, color: catColor), maxLines: 1, overflow: TextOverflow.ellipsis)),
                    ]),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Spacer(),
                      if (item.contactPhone.isNotEmpty)
                        Row(children: [
                          Icon(Icons.phone_outlined, size: 13, color: catColor),
                          const SizedBox(width: 4),
                          Text(item.contactPhone, style: TextStyle(fontSize: 12, color: catColor, fontWeight: FontWeight.w600)),
                        ]),
                    ],
                  ),

                  // Service type tag
                  if (item.serviceType.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      children: item.serviceType.split('،').map((tag) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: catColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: catColor.withOpacity(0.3)),
                        ),
                        child: Text(tag.trim(), style: TextStyle(fontSize: 10, color: catColor, fontWeight: FontWeight.w600)),
                      )).toList(),
                    ),
                  ],

                  const SizedBox(height: 12),
                  const Divider(height: 1),

                  // ─── Action buttons ───
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ServiceDetailScreen(service: item, catColor: catColor, slug: slug))),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: catColor.withOpacity(0.5)),
                              foregroundColor: catColor,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                            child: const Text('বিস্তারিত', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          ),
                        ),

                        const SizedBox(width: 8),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade200),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: FavoriteButton(contentType: 'service', contentId: item.id),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _noImage(Color catColor) {
    return Container(
      height: 160, width: double.infinity,
      color: catColor.withOpacity(0.08),
      child: Center(child: Icon(Icons.business_rounded, size: 48, color: catColor.withOpacity(0.3))),
    );
  }
}

// ─────────────────────────────────────────────
// DETAIL SCREEN
// ─────────────────────────────────────────────
class ServiceDetailScreen extends StatefulWidget {
  final Service service;
  final Color catColor;
  final String slug;

  const ServiceDetailScreen({
    super.key,
    required this.service,
    this.catColor = const Color(0xFF2563EB),
    this.slug = '',
  });

  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  int _imgIndex = 0;

  @override
  Widget build(BuildContext context) {
    final s = widget.service;
    final catColor = widget.catColor;
    final images = s.images.map(_imgUrl).where((u) => u.isNotEmpty).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: CustomScrollView(
        slivers: [
          // ─── Hero image / AppBar ───
          SliverAppBar(
            expandedHeight: images.isNotEmpty ? 280 : 160,
            pinned: true,
            backgroundColor: catColor,
            foregroundColor: Colors.white,
            actions: [FavoriteButton(contentType: 'service', contentId: s.id)],
            flexibleSpace: FlexibleSpaceBar(
              background: images.isNotEmpty
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(images[_imgIndex], fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(color: catColor)),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter, end: Alignment.bottomCenter,
                              colors: [Colors.transparent, catColor.withOpacity(0.7)],
                            ),
                          ),
                        ),
                        // Multi-image dots
                        if (images.length > 1)
                          Positioned(
                            bottom: 12, left: 0, right: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: images.asMap().entries.map((e) => GestureDetector(
                                onTap: () => setState(() => _imgIndex = e.key),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: _imgIndex == e.key ? 20 : 6, height: 6,
                                  margin: const EdgeInsets.symmetric(horizontal: 3),
                                  decoration: BoxDecoration(
                                    color: _imgIndex == e.key ? Colors.white : Colors.white54,
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                              )).toList(),
                            ),
                          ),
                      ],
                    )
                  : Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [catColor, Color.lerp(catColor, Colors.black, 0.3)!],
                          begin: Alignment.topLeft, end: Alignment.bottomRight,
                        ),
                      ),
                      child: SafeArea(
                        child: Center(
                          child: Text(
                            serviceCategoriesData[widget.slug]?['icon'] as String? ?? '🏢',
                            style: const TextStyle(fontSize: 60),
                          ),
                        ),
                      ),
                    ),
            ),
          ),

          // ─── Content ───
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ─── Header card ───
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(s.title,
                                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                                const SizedBox(height: 4),
                                Text(s.category,
                                    style: TextStyle(fontSize: 13, color: catColor, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                          if (s.verified)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(color: const Color(0xFF059669).withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                                Icon(Icons.verified_rounded, color: Color(0xFF059669), size: 14),
                                SizedBox(width: 4),
                                Text('যাচাইকৃত', style: TextStyle(color: Color(0xFF059669), fontSize: 11, fontWeight: FontWeight.w700)),
                              ]),
                            ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      // Stats row
                      Row(
                        children: [
                          _StatChip(icon: Icons.remove_red_eye_outlined, label: '${s.views} বার দেখা হয়েছে', color: const Color(0xFF4B5563)),
                        ],
                      ),
                      if (s.location.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Row(children: [
                          Icon(Icons.location_on_outlined, size: 16, color: catColor),
                          const SizedBox(width: 6),
                          Expanded(child: Text(s.location, style: TextStyle(fontSize: 13, color: catColor))),
                        ]),
                      ],
                    ],
                  ),
                ),

                // ─── Description ───
                if (s.description.isNotEmpty)
                  _SectionCard(
                    title: 'সেবার বিবরণ',
                    child: Text(s.description,
                        style: const TextStyle(fontSize: 14, color: Color(0xFF374151), height: 1.7)),
                  ),

                // ─── Services offered ───
                if (s.serviceType.isNotEmpty)
                  _SectionCard(
                    title: 'প্রদত্ত সেবাসমূহ',
                    child: Wrap(
                      spacing: 8, runSpacing: 8,
                      children: s.serviceType.split('،').map((tag) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: catColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: catColor.withOpacity(0.3)),
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(Icons.check_circle_outline, size: 13, color: catColor),
                          const SizedBox(width: 5),
                          Flexible(child: Text(tag.trim(), style: TextStyle(fontSize: 12, color: catColor, fontWeight: FontWeight.w600))),
                        ]),
                      )).toList(),
                    ),
                  ),

                // ─── Contact ───
                _SectionCard(
                  title: 'যোগাযোগ করুন',
                  child: Column(
                    children: [
                      if (s.contactPhone.isNotEmpty)
                        _ContactRow(
                          icon: Icons.phone_rounded,
                          label: s.contactPhone,
                          color: catColor,
                          onTap: () async {
                            final url = Uri.parse('tel:${s.contactPhone}');
                            if (await canLaunchUrl(url)) await launchUrl(url);
                          },
                        ),
                      const SizedBox(height: 12),
                      Row(children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              final phone = s.contactPhone.isNotEmpty ? s.contactPhone : s.contactInfo;
                              final url = Uri.parse('tel:$phone');
                              if (await canLaunchUrl(url)) await launchUrl(url);
                            },
                            icon: const Icon(Icons.phone_rounded, size: 18),
                            label: const Text('কল করুন'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: catColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                      ]),
                    ],
                  ),
                ),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Helper widgets ───
class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF111827))),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _StatChip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 16, color: color),
      const SizedBox(width: 6),
      Text(label, style: TextStyle(fontSize: 13, color: color, fontWeight: FontWeight.w500)),
    ]);
  }
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ContactRow({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 12),
          Text(label, style: TextStyle(fontSize: 15, color: color, fontWeight: FontWeight.w600)),
          const Spacer(),
          Icon(Icons.chevron_right_rounded, size: 18, color: color),
        ]),
      ),
    );
  }
}
